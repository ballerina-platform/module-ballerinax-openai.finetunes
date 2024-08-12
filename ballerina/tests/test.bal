// AUTO-GENERATED FILE. DO NOT MODIFY.
// This file is auto-generated by the Ballerina OpenAPI tool.

// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

// Configurable variables for environment setup.
configurable boolean isLiveServer = ?;
configurable string token = ?;
configurable string serviceUrl = isLiveServer ? "https://api.openai.com/v1" : "http://localhost:9090";
configurable string apiKey = isLiveServer ? token : "";

// Initialize the connection configuration and client.
final ConnectionConfig config = {auth: {token: apiKey}};
final Client openAIFinetunes = check new Client(config, serviceUrl);

// Define sample file content and name.
final string fileName = "sample.jsonl";
const byte[] fileContent = [123,13,10,32,32,32,32,34,112,114,111,109,112,116,34,58,32,34,87,104,97,116,32,105,115,32,116,104,101,32,97,110,115,119,101,114,32,116,111,32,50,43,50,34,44,13,10,32,32,32,32,34,99,111,109,112,108,101,116,105,111,110,34,58,32,34,52,34,13,10,125];

// Record type to hold test data.
public type TestData record {
    string fileId;
    string modelId;
    string jobId;
};

// Initialize test data.
TestData testData = {fileId: "", modelId: "", jobId: ""};

// Function to generate test data.
function dataGen() returns TestData[][] {
    return [[testData]];
}

@test:Config {
    dataProvider:  dataGen,
    groups: ["Models"]
}
isolated function testListModels(TestData testData) returns error? {
    ListModelsResponse modelsResponse = check openaiFinetunes->/models.get();
    testData.modelId = "gpt-3.5-turbo";
    test:assertEquals(modelsResponse.'object, "list", "Object type mismatched");
    test:assertTrue(modelsResponse.hasKey("data"), "Response does not have the key 'data'");
}

@test:Config {
    dataProvider:  dataGen,
    dependsOn: [testListModels],
    groups: ["Models"]
}
isolated function testRetrieveModel(TestData testData) returns error? {
    string modelId = testData.modelId;
    Model modelResponse = check openaiFinetunes->/models/[modelId].get();
    test:assertEquals(modelResponse.id, modelId, "Model id mismatched");
    test:assertTrue(modelResponse.hasKey("object"), "Response does not have the key 'object'");
}

@test:Config {
    dependsOn: [testCreateFineTuningJob, testListModels, testRetrieveModel, testListFineTuningJobCheckpoints, testListFineTuningEvents],
    dataProvider:  dataGen,
    enable: isLiveServer? false : true, // Enable this test only for mock server.
    groups: ["Models"]
}
isolated function testDeleteModel(TestData testData) returns error? {
    string modelIdCreated = testData.modelId;
    DeleteModelResponse modelResponseDelete = check openaiFinetunes->/models/[modelIdCreated].delete();
    test:assertEquals(modelResponseDelete.id, modelIdCreated, "Model id mismatched");
    test:assertTrue(modelResponseDelete.hasKey("object"), "Response does not have the key 'object'");
}

@test:Config {
    groups: ["Files"]
}
isolated function testListFiles() returns error? {
    ListFilesResponse filesResponse = check openaiFinetunes->/files.get();
    test:assertEquals(filesResponse.'object, "list", "Object type mismatched");
    test:assertTrue(filesResponse.hasKey("data"), "Response does not have the key 'data'");
}

@test:Config {
    dependsOn: [testListFiles],
    dataProvider: dataGen,
    groups: ["Files"]
}
isolated function testCreateFile(TestData testData) returns error? {
    CreateFileRequest fileRequest = {
        file: {fileContent, fileName},
        purpose: "fine-tune"
    };

    OpenAIFile fileResponse = check openaiFinetunes->/files.post(fileRequest);
    testData.fileId = fileResponse.id;
    test:assertEquals(fileResponse.purpose, "fine-tune", "Purpose mismatched");
    test:assertTrue(fileResponse.id !is "", "File id is empty");
}

@test:Config {
    dependsOn: [testCreateFile],
    dataProvider:  dataGen,
    groups: ["Files"]
}
isolated function testRetrieveFile(TestData testData) returns error? {
    string fileId = testData.fileId;
    OpenAIFile fileResponse = check openaiFinetunes->/files/[fileId].get();
    test:assertEquals(fileResponse.id, fileId, "File id mismatched");
    test:assertTrue(fileResponse.hasKey("object"), "Response does not have the key 'object'");
}

@test:Config {
    dependsOn: [testCreateFile],
    dataProvider:  dataGen,
    groups: ["Files"]
}
isolated function testDownloadFile(TestData testData) returns error? {
    string fileId = testData.fileId;
    byte[] fileContentDownload = check openaiFinetunes->/files/[fileId]/content.get();
    test:assertFalse(fileContentDownload.length() <= 0, "File content is empty");
}

@test:Config {
    dependsOn: [testCreateFile, testRetrieveFile, testDownloadFile, testCreateFineTuningJob],
    dataProvider:  dataGen,
    groups: ["Files"]
}
isolated function testDeleteFile(TestData testData) returns error? {
    string fileId = testData.fileId;
    DeleteFileResponse fileResponseDelete = check openaiFinetunes->/files/[fileId].delete();
    test:assertEquals(fileResponseDelete.id, fileId, "File id mismatched");
    test:assertTrue(fileResponseDelete.hasKey("object"), "Response does not have the key 'object'");
}

@test:Config {
    groups: ["Fine-tuning"]
}
isolated function testListPaginatedFineTuningJobs() returns error? {
    ListPaginatedFineTuningJobsResponse jobsResponse = check openaiFinetunes->/fine_tuning/jobs.get();
    test:assertEquals(jobsResponse.'object, "list", "Object type mismatched");
    test:assertTrue(jobsResponse.hasKey("data"), "Response does not have the key 'data'");
}

@test:Config {
    dependsOn: [testListModels, testCreateFile],
    dataProvider:  dataGen,
    groups: ["Fine-tuning"]
}
isolated function testCreateFineTuningJob(TestData testData) returns error? {
    string fileId = testData.fileId;
    string modelId = testData.modelId;

    CreateFineTuningJobRequest fineTuneRequest = {
        model: modelId,
        training_file: fileId
    };

    FineTuningJob fineTuneResponse = check openaiFinetunes->/fine_tuning/jobs.post(fineTuneRequest);
    testData.jobId = fineTuneResponse.id;
    test:assertTrue(fineTuneResponse.hasKey("object"), "Response does not have the key 'object'");
    test:assertTrue(fineTuneResponse.hasKey("id"), "Response does not have the key 'id'");
}

@test:Config {
    dependsOn: [testCreateFineTuningJob],
    dataProvider:  dataGen,
    groups: ["Fine-tuning"]
}
isolated function testRetrieveFineTuningJob(TestData testData) returns error? {
    string jobId = testData.jobId;
    FineTuningJob jobResponse = check openaiFinetunes->/fine_tuning/jobs/[jobId].get();
    test:assertEquals(jobResponse.id, jobId, "Job id mismatched");
    test:assertEquals(jobResponse.'object, "fine_tuning.job", "Response does not have the key 'object'");
}

@test:Config {
    dependsOn: [testCreateFineTuningJob],
    dataProvider:  dataGen,
    groups: ["Fine-tuning"]
}
isolated function testListFineTuningEvents(TestData testData) returns error? {
    string fine_tuning_job_id = testData.jobId;
    ListFineTuningJobEventsResponse eventsResponse = check openaiFinetunes->/fine_tuning/jobs/[fine_tuning_job_id]/events.get();
    test:assertEquals(eventsResponse.'object, "list", "Object type mismatched");
    test:assertTrue(eventsResponse.hasKey("data"), "Response does not have the key 'data'");
}

@test:Config {
    dependsOn: [testCreateFineTuningJob],
    dataProvider:  dataGen,
    groups: ["Fine-tuning"]
}
isolated function testListFineTuningJobCheckpoints(TestData testData) returns error? {
    string fine_tuning_job_id = testData.jobId;
    ListFineTuningJobCheckpointsResponse checkpointsResponse = check openaiFinetunes->/fine_tuning/jobs/[fine_tuning_job_id]/checkpoints.get();
    test:assertEquals(checkpointsResponse.'object, "list", "Object type mismatched");
    test:assertTrue(checkpointsResponse.hasKey("data"), "Response does not have the key 'data'");
}

@test:Config {
    dependsOn: [testCreateFineTuningJob],
    dataProvider:  dataGen,
    enable: isLiveServer? false : true, // Enable this test only for mock server.
    groups: ["Fine-tuning"]
}
isolated function testCancelFineTuningJob(TestData testData) returns error? {
    string fine_tuning_job_id = testData.jobId;
    FineTuningJob jobResponse = check openaiFinetunes->/fine_tuning/jobs/[fine_tuning_job_id]/cancel.post();
    test:assertEquals(jobResponse.id, fine_tuning_job_id, "Job id mismatched");
    test:assertTrue(jobResponse.hasKey("object"), "Response does not have the key 'object'");
}
