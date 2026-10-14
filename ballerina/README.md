
## Overview

The `openai.finetunes` module is a direct, fully-typed REST connector for OpenAI's [Fine-tuning](https://platform.openai.com/docs/api-reference/fine-tuning) and Files APIs. Use it as a standalone client to upload training files and to create, monitor, and manage fine-tuning jobs that customize OpenAI models, independent of the `ballerina/ai` agent framework.

### Key Features
- Create and manage fine-tuning jobs for custom model training
- Support for fine-tuning advanced models like GPT-4o-mini and GPT-3.5 Turbo
- Efficient handling of training files and model checkpoints
- Programmatic access to fine-tuned model statuses and metadata
- Secure communication with API key-based authentication

## Setup guide

To use the OpenAI Connector, you must have access to the OpenAI API through a [OpenAI Platform account](https://platform.openai.com) and a project under it. If you do not have a OpenAI Platform account, you can sign up for one [here](https://platform.openai.com/signup).

#### Create a OpenAI API Key

1. Open the [OpenAI Platform Dashboard](https://platform.openai.com).

2. Navigate to Dashboard -> API keys
<img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-openai.finetunes/main/docs/setup/resources/navigate-api-key-dashboard.png alt="OpenAI Platform" style="width: 70%;">

3. Click on the "Create new secret key" button
<img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-openai.finetunes/main/docs/setup/resources/api-key-dashboard.png alt="OpenAI Platform" style="width: 70%;">

4. Fill the details and click on Create secret key
<img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-openai.finetunes/main/docs/setup/resources/create-new-secret-key.png alt="OpenAI Platform" style="width: 70%;">

5. Store the API key securely to use in your application 
<img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-openai.finetunes/main/docs/setup/resources/saved-key.png alt="OpenAI Platform" style="width: 70%;">

## Quickstart

To use the `OpenAI Finetunes` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `openai.finetunes` module.

```ballerina
import ballerinax/openai.finetunes;
import ballerina/io;
```

### Step 2: Instantiate a new connector

Create a `finetunes:ConnectionConfig` with the obtained API Key and initialize the connector.

```ballerina
configurable string token = ?;

final finetunes:Client openAIFinetunes = check new({
    auth: {
        token
    }
});
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

**Note**:  First, create a sample.jsonl file in the same directory. This file should contain the training data formatted according to the guidelines provided [here](https://platform.openai.com/docs/api-reference/files/create).

#### Fine tuning the gpt-3.5-turbo model

```ballerina
public function main() returns error? {

    finetunes:CreateFileRequest req = {
        file: {fileContent: check io:fileReadBytes("sample.jsonl"), fileName: "sample.jsonl"},
        purpose: "fine-tune"
    };

    finetunes:OpenAIFile fileRes = check openAIFinetunes->/files.post(req);

    string fileId = fileRes.id;

    finetunes:CreateFineTuningJobRequest fineTuneRequest = {
        model: "gpt-3.5-turbo",
        training_file: fileId
    };

    finetunes:FineTuningJob fineTuneResponse = 
        check openAIFinetunes->/fine_tuning/jobs.post(fineTuneRequest);
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `OpenAI Finetunes` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-openai.finetunes/tree/main/examples), covering the following use cases:

1. [Sarcastic bot](https://github.com/ballerina-platform/module-ballerinax-openai.finetunes/tree/main/examples/sarcastic-bot) - Fine-tune the GPT-3.5-turbo model to generate sarcastic responses 

2. [Sports headline analyzer](https://github.com/ballerina-platform/module-ballerinax-openai.finetunes/tree/main/examples/sports-headline-analyzer) - Fine-tune the GPT-4o-mini model to extract structured information (player, team, sport, and gender) from sports headlines.
