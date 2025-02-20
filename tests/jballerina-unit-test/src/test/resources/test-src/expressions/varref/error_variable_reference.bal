// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

type StringRestRec record {|
    string...;
|};

type SMS error <string, record {| string...; |}>;
type SMA error <string, record {| string|boolean...; |}>;
type CMS error <string, record {| string...; |}>;
type CMA error <string, record {| anydata...; |}>;

const ERROR1 = "Some Error One";
const ERROR2 = "Some Error Two";

function testBasicErrorVariableWithMapDetails() returns [string, string, string, string, map<string>, string?,
                                                            string?, string?, map<any>, any, any, any] {
    SMS err1 = error("Error One", message = "Msg One", detail = "Detail Msg");
    SMA err2 = error("Error Two", message = "Msg Two", fatal = true );

    string reason11;
    map<string> detail11;
    string reason12;
    string? message12;
    string? detail12;
    string? extra12;

    error (reason11, ... detail11) = err1;
    error (reason12, message = message12, detail = detail12, extra = extra12) = err1;

    string reason21;
    map<any> detail21;
    string reason22;
    any message22;
    any detail22;
    any extra22;

    error (reason21, ... detail21) = err2;
    error (reason22, message = message22, detail = detail22, extra = extra22) = err2;

    return [reason11, reason12, reason21, reason22, detail11, message12, detail12, extra12, detail21, message22,
    detail22, extra22];
}

function testBasicErrorVariableWithConstAndMap() returns [string, string, string, string, map<string>, string?, string?,
                                                             string?, map<any>, any, any, any] {
    CMS err3 = error(ERROR1, message = "Msg Three", detail = "Detail Msg");
    CMA err4 = error(ERROR2, message = "Msg Four", fatal = true);

    string reason31;
    map<string> detail31;
    string reason32;
    string? message32;
    string? detail32;
    string? extra32;

    error (reason31, ... detail31) = err3;
    error (reason32, message = message32, detail = detail32, extra = extra32) = err3;

    string reason41;
    map<any> detail41;
    string reason42;
    any message42;
    any detail42;
    any extra42;

    error (reason41, ... detail41) = err4;
    error (reason42, message = message42, detail = detail42, extra = extra42) = err4;

    return [reason31, reason32, reason41, reason42, detail31, message32, detail32, extra32, detail41, message42,
    detail42, extra42];
}

type Foo record {
    string message;
    boolean fatal;
};

type FooError error <string, Foo>;

function testBasicErrorVariableWithRecordDetails() returns [string, string, string, boolean, map<anydata|error>] {
    FooError err1 = error("Error One", message = "Something Wrong", fatal = true);
    FooError err2 = error("Error One", message = "Something Wrong", fatal = true);

    string res1;
    map<anydata|error> mapRec;
    string res2;
    string message;
    boolean fatal;

    error (res1, ... mapRec) = err1;
    error (res2, message = message, fatal = fatal) = err2;

    return [res1, res2, message, fatal, mapRec];
}

function testErrorInTuple() returns [int, string, string, anydata|error, boolean] {
    Foo f = { message: "fooMsg", fatal: true };
    [int, string, error, [error, Foo]] t1 = [12, "Bal", error("Err", message = "Something Wrong"),
                                                            [error("Err2", message = "Something Wrong2"), f]];

    int intVar;
    string stringVar;
    error errorVar;
    error errorVar2;
    Foo fooVar;

    [intVar, stringVar, errorVar, [errorVar2, fooVar]] = t1;

    return [intVar, stringVar, errorVar.reason(), errorVar2.detail()["message"], fooVar.fatal];
}

function testErrorInTupleWithDestructure() returns [int, string, string, map<anydata|error>, boolean] {
    [int, string, [error, boolean]] t1 = [12, "Bal", [error("Err2", message = "Something Wrong2"), true]];

    int intVar;
    string stringVar;
    string reasonVar;
    map<anydata|error> detailVar;
    boolean booleanVar;

    [intVar, stringVar, [error(reasonVar, ...detailVar), booleanVar]] = t1;

    return [intVar, stringVar, reasonVar, detailVar, booleanVar];
}

function testErrorInTupleWithDestructure2() returns [int, string, string, anydata|error, boolean] {
    [int, string, [error, boolean]] t1 = [12, "Bal", [error("Err2", message = "Something Wrong2"), true]];

    int intVar;
    string stringVar;
    string reasonVar;
    anydata|error message;
    boolean booleanVar;

    [intVar, stringVar, [error(reasonVar, message = message), booleanVar]] = t1;

    return [intVar, stringVar, reasonVar, message, booleanVar];
}

type Bar record {
    int x;
    error e;
};

function testErrorInRecordWithDestructure() returns [int, string, anydata|error] {
    Bar b = { x: 1000, e: error("Err3", message = "Something Wrong3") };

    int x;
    string reason;
    map<anydata|error> detail;
    { x, e: error (reason, ... detail) } = b;

    return [x, reason, detail["message"]];
}

function testErrorInRecordWithDestructure2() returns [int, string, anydata|error, anydata|error] {
    Bar b = { x: 1000, e: error("Err3", message = "Something Wrong3") };

    int x;
    string reason;
    anydata|error message;
    anydata|error extra;

    { x, e: error (reason, message = message, extra = extra) } = b;

    return [x, reason, message, extra];
}

function testErrorWithRestParam() returns map<string> {
    error<string, record {| string...; |}> errWithMap = error("Error", message = "Fatal", fatal = "true");

    string reason;
    string? message;
    map<string> detailMap;
    error(reason, message = message, ...detailMap) = errWithMap;
    detailMap["extra"] = "extra";

    return detailMap;
}

function testErrorWithUnderscore() returns [string, map<string>] {
    error<string, record {| string...; |}> errWithMap = error("Error", message = "Fatal", fatal = "true");

    string reason;
    map<string> detail;

    error(reason, ... _) = errWithMap;
    error(_, ... detail) = errWithMap;

    return [reason, detail];
}
