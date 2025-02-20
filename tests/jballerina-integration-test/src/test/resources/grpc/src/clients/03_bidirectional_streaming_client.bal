// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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
// This is client implementation for bidirectional streaming scenario

import ballerina/grpc;
import ballerina/io;
import ballerina/runtime;

int total = 0;
string responseMsg = "";
const string ERROR_MSG_FORMAT = "Error from Connector: %s - %s";
const string RESP_MSG_FORMAT = "Failed: Invalid Response, expected %s, but received %s";

// Enable when you need to test locally.
//public function main() {
//    string resp = testBidiStreaming();
//    io:println(resp);
//}

public function testBidiStreaming() returns string {
    grpc:StreamingClient ep = new;
    ChatClient chatEp = new ("http://localhost:9093");
    string response = "";
    // Executing unary non-blocking call registering server message listener.
    var res = chatEp->chat(ChatMessageListener);
    if (res is error) {
        string msg = io:sprintf(ERROR_MSG_FORMAT, res.reason(), <string> res.detail()["message"]);
        io:println(msg);
    } else {
        ep = res;
    }
    runtime:sleep(1000);
    ChatMessage mes1 = {name:"Sam", message:"Hi"};
    error? connErr = ep->send(mes1);
    if (connErr is error) {
        return io:sprintf(ERROR_MSG_FORMAT, connErr.reason(), <string> connErr.detail()["message"]);
    }
    if (!isValidResponse("Sam: Hi")) {
        return io:sprintf(RESP_MSG_FORMAT, "Sam: Hi", responseMsg);
    } else {
        responseMsg = "";
    }

    ChatMessage mes2 = {name:"Sam", message:"GM"};
    connErr = ep->send(mes2);
    if (connErr is error) {
        return io:sprintf(ERROR_MSG_FORMAT, connErr.reason(), <string> connErr.detail()["message"]);
    }
    if (!isValidResponse("Sam: GM")) {
        return io:sprintf(RESP_MSG_FORMAT, "Sam: GM", responseMsg);
    }

    checkpanic ep->complete();
    return "Success: received valid responses from server";
}

function isValidResponse(string expectedMsg) returns boolean {
    int waitCount = 0;
    while(responseMsg == "") {
        runtime:sleep(1000);
        io:println("response message: ", responseMsg);
        if (waitCount > 10) {
            break;
        }
        waitCount += 1;
    }
    return responseMsg == expectedMsg;
}

service ChatMessageListener = service {

    function onMessage(string message) {
        responseMsg = <@untainted> message;
        io:println("Response received from server: " + responseMsg);
    }

    function onError(error err) {
        responseMsg = io:sprintf(ERROR_MSG_FORMAT, err.reason(), <string> err.detail()["message"]);
        io:println(responseMsg);
    }

    resource function onComplete() {
        io:println("Server Complete Sending Responses.");
    }
};


// Non-blocking client endpoint
public type ChatClient client object {

    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config);
        error? result = c.initStub("non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }

    remote function chat(service msgListener, grpc:Headers? headers = ()) returns (grpc:StreamingClient|error) {
        return self.grpcClient->streamingExecute("Chat/chat", msgListener, headers);
    }
};

type ChatMessage record {
    string name = "";
    string message = "";
};

const string ROOT_DESCRIPTOR = "0A0A436861742E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F22280A0B436861744D657373616765120A0A046E616D6518012809120D0A076D65737361676518022809323C0A044368617412340A0463686174120B436861744D6573736167651A1B676F6F676C652E70726F746F6275662E537472696E6756616C756528013001620670726F746F33";
function getDescriptorMap() returns map<string> {
    return {
        "Chat.proto":
        "0A0A436861742E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F22280A0B436861744D657373616765120A0A046E616D6518012809120D0A076D65737361676518022809323C0A044368617412340A0463686174120B436861744D6573736167651A1B676F6F676C652E70726F746F6275662E537472696E6756616C756528013001620670726F746F33"
        ,
        "google/protobuf/wrappers.proto":
        "0A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F120F676F6F676C652E70726F746F627566221C0A0B446F75626C6556616C7565120D0A0576616C7565180120012801221B0A0A466C6F617456616C7565120D0A0576616C7565180120012802221B0A0A496E74363456616C7565120D0A0576616C7565180120012803221C0A0B55496E74363456616C7565120D0A0576616C7565180120012804221B0A0A496E74333256616C7565120D0A0576616C7565180120012805221C0A0B55496E74333256616C7565120D0A0576616C756518012001280D221A0A09426F6F6C56616C7565120D0A0576616C7565180120012808221C0A0B537472696E6756616C7565120D0A0576616C7565180120012809221B0A0A427974657356616C7565120D0A0576616C756518012001280C427C0A13636F6D2E676F6F676C652E70726F746F627566420D577261707065727350726F746F50015A2A6769746875622E636F6D2F676F6C616E672F70726F746F6275662F7074797065732F7772617070657273F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"
    };
}

