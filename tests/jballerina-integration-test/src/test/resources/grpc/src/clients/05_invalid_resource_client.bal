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
import ballerina/grpc;
import ballerina/io;

HelloWorldBlockingClient helloWorldBlockingEp = new ("http://localhost:9095");

// Enable when you need to test locally.
//public function main() {
//    string resp1 = testInvalidRemoteMethod("WSO2");
//    io:println(resp1);
//    int resp2 = testInvalidInputParameter(100);
//    io:println(resp2);
//    var resp3 = testInvalidOutputResponse(1.0);
//    io:println(resp3);
//    var resp4 = testNonExistenceRemoteMethod(true);
//    io:println(resp4);
//}

function testInvalidRemoteMethod(string name) returns (string) {
    [string, grpc:Headers]|error unionResp = helloWorldBlockingEp->hello(name);
    if (unionResp is error) {
        return io:sprintf("Error from Connector: %s - %s", unionResp.reason(), <string> unionResp.detail()["message"]);
    } else {
        io:println("Client Got Response : ");
        string result = "";
        [result, _] = unionResp;
        io:println(result);
        return "Client got response: " + result;
    }
}

function testInvalidInputParameter(int age) returns (int) {
    [int, grpc:Headers]|error unionResp = helloWorldBlockingEp->testInt(age);
    if (unionResp is error) {
        string message = io:sprintf("Error from Connector: %s - %s", unionResp.reason(), <string> unionResp.detail()["message"]);
        io:println(message);
        return -1;
    } else {
        io:println("Client got response : ");
        int result = 0;
        [result, _] = unionResp;
        io:println(result);
        return result;
    }
}

function testInvalidOutputResponse(float salary) returns (float|string) {
    [float, grpc:Headers]|error unionResp = helloWorldBlockingEp->testFloat(salary);
    if (unionResp is error) {
        string message = io:sprintf("Error from Connector: %s - %s", unionResp.reason(), <string> unionResp.detail()["message"]);
        io:println(message);
        return message;
    } else {
        io:println("Client got response : ");
        float result = 0.0;
        [result, _] = unionResp;
        io:println(result);
        return result;
    }
}

function testNonExistenceRemoteMethod(boolean isAvailable) returns (boolean|string) {
    [boolean, grpc:Headers]|error unionResp = helloWorldBlockingEp->testBoolean(isAvailable);
    if (unionResp is error) {
        string message = io:sprintf("Error from Connector: %s - %s", unionResp.reason(), <string> unionResp.detail()["message"]);
        io:println(message);
        return message;
    } else {
        io:println("Client got response : ");
        boolean result = false;
        [result, _] = unionResp;
        io:println(result);
        return result;
    }
}

public type HelloWorldBlockingClient client object {
    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config);
        error? result = c.initStub("blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }

    remote function hello(string req, grpc:Headers? headers = ()) returns ([string, grpc:Headers]|error) {
        var unionResp = check self.grpcClient->blockingExecute("grpcservices.HelloWorld98/hello1", req, headers);
        anydata result = ();
        grpc:Headers resHeaders = new;
        [result, resHeaders] = unionResp;
        return [result.toString(), resHeaders];
    }

    remote function testInt(int req, grpc:Headers? headers = ()) returns ([int, grpc:Headers]|error) {
        var unionResp = check self.grpcClient->blockingExecute("grpcservices.HelloWorld98/testInt", req, headers);
        anydata result = ();
        grpc:Headers resHeaders = new;
        [result, resHeaders] = unionResp;
        var value = typedesc<int>.constructFrom(result);
        if (value is int) {
            return [value, resHeaders];
        } else {
            return value;
        }
    }

    remote function testFloat(float req, grpc:Headers? headers = ()) returns ([float, grpc:Headers]|error) {
        var unionResp = check self.grpcClient->blockingExecute("grpcservices.HelloWorld98/testFloat", req, headers);
        anydata result = ();
        grpc:Headers resHeaders = new;
        [result, resHeaders] = unionResp;
        var value = typedesc<float>.constructFrom(result);
        if (value is float) {
            return [value, resHeaders];
        } else {
            error err = error("{ballerina/grpc}INTERNAL", message = value.reason());
            return err;
        }
    }

    remote function testBoolean(boolean req, grpc:Headers? headers = ()) returns ([boolean, grpc:Headers]|error) {
        var unionResp = check self.grpcClient->blockingExecute("grpcservices.HelloWorld98/testBoolean", req, headers);
        anydata result = ();
        grpc:Headers resHeaders = new;
        [result, resHeaders] = unionResp;
        var value = typedesc<boolean>.constructFrom(result);
        if (value is boolean) {
            return [value, resHeaders];
        } else {
            return value;
        }
    }
};

const string ROOT_DESCRIPTOR = "0A1248656C6C6F576F726C6439382E70726F746F120C6772706373657276696365731A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F32E1010A0C48656C6C6F576F726C64393812430A0568656C6C6F121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512440A0774657374496E74121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A1B2E676F6F676C652E70726F746F6275662E496E74363456616C756512460A0974657374466C6F6174121B2E676F6F676C652E70726F746F6275662E466C6F617456616C75651A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C7565620670726F746F33";
function getDescriptorMap() returns map<string> {
    return {
        "HelloWorld98.proto":
        "0A1248656C6C6F576F726C6439382E70726F746F120C6772706373657276696365731A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F32E1010A0C48656C6C6F576F726C64393812430A0568656C6C6F121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512440A0774657374496E74121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A1B2E676F6F676C652E70726F746F6275662E496E74363456616C756512460A0974657374466C6F6174121B2E676F6F676C652E70726F746F6275662E466C6F617456616C75651A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C7565620670726F746F33"
        ,

        "google/protobuf/wrappers.proto":
        "0A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F120F676F6F676C652E70726F746F627566221C0A0B446F75626C6556616C7565120D0A0576616C7565180120012801221B0A0A466C6F617456616C7565120D0A0576616C7565180120012802221B0A0A496E74363456616C7565120D0A0576616C7565180120012803221C0A0B55496E74363456616C7565120D0A0576616C7565180120012804221B0A0A496E74333256616C7565120D0A0576616C7565180120012805221C0A0B55496E74333256616C7565120D0A0576616C756518012001280D221A0A09426F6F6C56616C7565120D0A0576616C7565180120012808221C0A0B537472696E6756616C7565120D0A0576616C7565180120012809221B0A0A427974657356616C7565120D0A0576616C756518012001280C427C0A13636F6D2E676F6F676C652E70726F746F627566420D577261707065727350726F746F50015A2A6769746875622E636F6D2F676F6C616E672F70726F746F6275662F7074797065732F7772617070657273F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"
        ,

        "google/protobuf/empty.proto":
        "0A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F120F676F6F676C652E70726F746F62756622070A05456D70747942760A13636F6D2E676F6F676C652E70726F746F627566420A456D70747950726F746F50015A276769746875622E636F6D2F676F6C616E672F70726F746F6275662F7074797065732F656D707479F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"
    };
}

type Request record {
    string name = "";
    string message = "";
    int age = 0;
};

type Response record {
    string resp = "";
};
