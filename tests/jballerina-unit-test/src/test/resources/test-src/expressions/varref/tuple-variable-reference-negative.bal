// Copyright [c] 2018 WSO2 Inc. [http://www.wso2.org] All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 [the "License"]; you may not use this file except
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

function testBasicNegative0() {
    [string, int, float] [s, i, f] = ["D", 4, 6.7];
    [s, i, f] = ["FFF", 345, 6.77, "EFEFE"];
}

function testBasicNegative1() {
    [string, int, float] [s, i, f] = ["D", 4, 6.7];
    [s, i, f] = ["FFF", 345];
}

function testBasicNegative2() {
    [string, int, float] [s, i, f] = ["D", 4, 6.7];
    [s, i, f] = [22, "WWWW", true];
}

function testBasicNegative3() {
    [string, int, float] [s, i, f] = ["D", 4, 6.7];
    [s, i, f, e] = [22, "Test", true, 4444];
}

function testBasicNegative4() {
    [string, int, float] [s, i, f] = ["D", 4, 6.7];
    [s, i, f] = ["FFF", 345, 6.77];
    [int, string] [s, i] = [4, "SSSS"];
}

function testVarRefNegative1() {
    [string, int, float] [s1, i1, f1] = ["D", 4, 6.7];
    s1 = 45;
    i1 = "DDD";
    f1 = true;
}

function testVarRefNegative2() {
    [string, int, float] [s1, i1, f1] = ["D", 4, 6.7];
    [s1, i1, f1] = fn0();
}

function fn0() returns [float, boolean, int] {
    [float, boolean, int] [s1, i1, f1] = [5.6, true, 444];
    return [s1, i1, f1];
}

function testVarRefNegative3() {
    [string, int, float] [s1, i1, f1] = ["D", 4, 6.7];
    [s1, i1] = [12, "FF"];
    f1 = true;
}

function testVarRefNegative4() {
    Foo foo = {name:"Test", age:23};
    Bar bar = {id:34, flag:true};
    FooObj fooObj = new ("Fooo", 3.7, 23);
    BarObj barObj = new (true, 56);
    [[Foo, [BarObj, FooObj]], Bar] [[f, [bo, fo]], b] = [[foo, [barObj, fooObj]], bar];
    [[f, [bo, fo]], b] = [[bar, [fooObj, barObj]], foo];
}

function testVarRefNegative5() {
    Foo foo = {name:"Test", age:23};
    Bar bar = {id:34, flag:true};
    FooObj fooObj = new ("Fooo", 3.7, 23);
    BarObj barObj = new (true, 56);
    [[Foo, [BarObj, FooObj]], Bar] [[f, [bo, fo]], b] = [[foo, [barObj, fooObj]], bar];
    [f, [bo, fo], b] = [bar, fooObj, foo];
}

function testVarRefNegative6() {
    Foo foo = {name:"Test", age:23};
    Bar bar = {id:34, flag:true};
    FooObj fooObj = new ("Fooo", 3.7, 23);
    BarObj barObj = new (true, 56);
    [int, Foo, [BarObj, string, FooObj], Bar, boolean] [i, fr, [bo, s, fo], br, b] = [12, foo, [barObj, "DDD", fooObj], bar, true];
    [i, fr, [bo, s, fo], br, b] = [bar, 12, [fooObj, "DD", barObj], foo, true];
}

type Foo record {
    string name;
    int age;
};

type Bar record {
    int id;
    boolean flag;
};

type FooObj object {
    public string s;
    public float f;
    public byte b;
    function __init(string s, float f, byte b) {
        self.s = s;
        self.f = f;
        self.b = b;
    }
};

type BarObj object {
    public boolean b;
    public int i;
    function __init(boolean b, int i) {
        self.b = b;
        self.i = i;
    }
};

function testInvalidTupleVarDef1() {
    [[string, [int, [boolean, int]]], [float, int]] [[s, [i1, [b, y]]], [f, i2]] = [["Bal", [3, [true, 34]]], [5.6, 45]];
    [[string, [int, [boolean, int]]], [float, int]] t = [["Bal", [3, [true, 34]]], [5.6, 45]];
    any a = t;
    [[s, [i1, [b, y]]], [f, i2]] = a;
}

function testInvalidTupleVarDef2() returns [string, int, boolean, int, float, int] {
    [[string, [int, [boolean, int]]], [float, int]] [[s, [i1, [b, y]]], [f, i2]] = [["Bal", [3, [true, 34]]], [5.6, 45]];
    [[string, [int, [boolean, int]]], [float, int]] t = [["Bal", [3, [true, 34]]], [5.6, 45]];
    any a = t;
    [[s, [i1, [b, y]]], [f, i2]] = fn1(a);
    return [s, i1, b, y, f, i2];
}

function fn1(any t) returns [string, int, boolean, int, float, int] {
    [[string, [int, [boolean, int]]], [float, int]] [[s, [i1, [b, y]]], [f, i2]] = t;
    return [s, i1, b, y, f, i2];
}

