import ballerina/io;
import ballerina/lang.runtime;

// import ballerinax/openai.finetunes;

configurable string token = ?;
string serviceUrl = "https://api.openai.com/v1";

string trainingFileName = "training.jsonl";
string validationFileName = "validation.jsonl";
string trainingFilePath = "./data/" + trainingFileName;
string validationFilePath = "./data/" + validationFileName;

final ConnectionConfig config = {auth: {token}};
final Client openAIFinetunes = check new Client(config, serviceUrl);

public function main() returns error? {

    byte[] trainingFileContent = check io:fileReadBytes(trainingFilePath);
    byte[] validationFileContent = check io:fileReadBytes(validationFilePath);

    CreateFileRequest trainingFileRequest = {
        file: {fileContent: trainingFileContent, fileName: trainingFileName},
        purpose: "fine-tune"
    };
    CreateFileRequest validationFileRequest = {
        file: {fileContent: validationFileContent, fileName: validationFileName},
        purpose: "fine-tune"
    };

    OpenAIFile trainingFileResponse =
        check openAIFinetunes->/files.post(trainingFileRequest);
    OpenAIFile validationFileResponse =
        check openAIFinetunes->/files.post(validationFileRequest);

    string trainingFileId = trainingFileResponse.id;
    string validationFileId = validationFileResponse.id;
    io:println("Training file id: " + trainingFileId);
    io:println("Validation file id: " + validationFileId);

    CreateFineTuningJobRequest fineTuneRequest = {
        model: "gpt-3.5-turbo",
        training_file: trainingFileId,
        validation_file: validationFileId,
        hyperparameters: {
            n_epochs: 15,
            batch_size: 3,
            learning_rate_multiplier: 0.3
        }
    };

    FineTuningJob fineTuneResponse =
        check openAIFinetunes->/fine_tuning/jobs.post(fineTuneRequest);
    string fineTuneJobId = fineTuneResponse.id;
    io:println("Fine-tuning job id: " + fineTuneJobId);

    FineTuningJob fineTuneJob =
        check openAIFinetunes->/fine_tuning/jobs/[fineTuneJobId].get();

    io:print("Validating files...");
    while (fineTuneJob.status == "validating_files") {
        io:print(".");
        fineTuneJob = check openAIFinetunes->/fine_tuning/jobs/[fineTuneJobId].get();

        runtime:sleep(1);
    }

    io:print("\nFiles validated successfully.");
    while (fineTuneJob.status == "queued") {
        io:print(".");
        fineTuneJob = check openAIFinetunes->/fine_tuning/jobs/[fineTuneJobId].get();
        runtime:sleep(1);
    }

    io:println("\nTraining...");
    while (fineTuneJob.status == "running") {
        fineTuneJob = check openAIFinetunes->/fine_tuning/jobs/[fineTuneJobId].get();
        ListFineTuningJobEventsResponse eventsResponse =
        check openAIFinetunes->/fine_tuning/jobs/[fineTuneJobId]/events.get();
        io:println(eventsResponse.data[0].message);
        runtime:sleep(1);
    }

    if (fineTuneJob.status != "succeeded") {
        io:println("Fine-tuning job failed.");
        return;
    }

    io:println("\nFine-tuning job details: ");
    io:println("Fine-tuned Model: ", fineTuneJob.fine_tuned_model);
    io:println("Model: ", fineTuneJob.model);
    io:println("Fine-tuning job completed successfully.");
}
