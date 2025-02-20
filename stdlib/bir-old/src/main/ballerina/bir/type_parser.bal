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

import ballerina/io;

public type ByteArrayReader record {
    byte[] buf = [];
    int pos = 0;
};

public type TypeParser object {
    public int TYPE_TAG_INT = 1;
    public int TYPE_TAG_BYTE = TYPE_TAG_INT + 1;
    public int TYPE_TAG_FLOAT = TYPE_TAG_BYTE + 1;
    public int TYPE_TAG_DECIMAL = TYPE_TAG_FLOAT + 1;
    public int TYPE_TAG_STRING = TYPE_TAG_DECIMAL + 1;
    public int TYPE_TAG_BOOLEAN = TYPE_TAG_STRING + 1;
    // All the above types are values type
    public int TYPE_TAG_JSON = TYPE_TAG_BOOLEAN + 1;
    public int TYPE_TAG_XML = TYPE_TAG_JSON + 1;
    public int TYPE_TAG_TABLE = TYPE_TAG_XML + 1;
    public int TYPE_TAG_NIL = TYPE_TAG_TABLE + 1;
    public int TYPE_TAG_ANYDATA = TYPE_TAG_NIL + 1;
    public int TYPE_TAG_RECORD = TYPE_TAG_ANYDATA + 1;
    public int TYPE_TAG_TYPEDESC = TYPE_TAG_RECORD + 1;
    public int TYPE_TAG_STREAM = TYPE_TAG_TYPEDESC + 1;
    public int TYPE_TAG_MAP = TYPE_TAG_STREAM + 1;
    public int TYPE_TAG_INVOKABLE = TYPE_TAG_MAP + 1;
    // All the above types are branded types
    public int TYPE_TAG_ANY = TYPE_TAG_INVOKABLE + 1;
    public int TYPE_TAG_ENDPOINT = TYPE_TAG_ANY + 1;
    public int TYPE_TAG_ARRAY = TYPE_TAG_ENDPOINT + 1;
    public int TYPE_TAG_UNION = TYPE_TAG_ARRAY + 1;
    public int TYPE_TAG_PACKAGE = TYPE_TAG_UNION + 1;
    public int TYPE_TAG_NONE = TYPE_TAG_PACKAGE + 1;
    public int TYPE_TAG_VOID = TYPE_TAG_NONE + 1;
    public int TYPE_TAG_XMLNS = TYPE_TAG_VOID + 1;
    public int TYPE_TAG_ANNOTATION = TYPE_TAG_XMLNS + 1;
    public int TYPE_TAG_SEMANTIC_ERROR = TYPE_TAG_ANNOTATION + 1;
    public int TYPE_TAG_ERROR = TYPE_TAG_SEMANTIC_ERROR + 1;
    public int TYPE_TAG_ITERATOR = TYPE_TAG_ERROR + 1;
    public int TYPE_TAG_TUPLE = TYPE_TAG_ITERATOR + 1;
    public int TYPE_TAG_FUTURE = TYPE_TAG_TUPLE + 1;
    public int TYPE_TAG_INTERMEDIATE_COLLECTION = TYPE_TAG_FUTURE + 1;
    public int TYPE_TAG_FINITE = TYPE_TAG_INTERMEDIATE_COLLECTION + 1;
    public int TYPE_TAG_OBJECT = TYPE_TAG_FINITE + 1;
    public int TYPE_TAG_BYTE_ARRAY = TYPE_TAG_OBJECT + 1;
    public int TYPE_TAG_FUNCTION_POINTER = TYPE_TAG_BYTE_ARRAY + 1;
    public int TYPE_TAG_HANDLE = TYPE_TAG_FUNCTION_POINTER + 1;

    public int TYPE_TAG_SELF = 50;

    ConstPool cp = {};
    ByteArrayReader reader;
    int cpI;
    byte[]?[] unparsedTypes;
    
    public function __init(ConstPool cp, byte[]?[] unparsedTypes, int cpI) {
        var unparsedBytes = unparsedTypes[cpI];
        if (unparsedBytes is byte[]){
            self.reader = {buf: unparsedBytes};
        } else {
            error err = error(cpI + " is not a shape CP.");
            panic err;
        }

        self.cp = cp;
        self.cpI = cpI;
        self.unparsedTypes = unparsedTypes;
    }

    public function parseTypeCpRef() returns BType{
        int cpI = self.readInt32();
        TypeParser p = new (self.cp, self.unparsedTypes, cpI);
        var x = p.parseTypeAndAddToCp();
        return x;
    }

    function parseTypeAndAddToCp() returns BType {
        if (self.cpI < self.cp.types.length()){
            var parsedType = self.cp.types[self.cpI];
            if (parsedType is BType) {
                return parsedType;
            }
        }
        BType newlyParsed = self.parseType();
        self.cp.types[self.cpI] = newlyParsed;
        return newlyParsed;
    }

    function parseType() returns BType {
        var typeTag = self.readInt8();
        // Ignoring name and flags
        _ = self.readInt32();
        _ = self.readInt32();
        if (typeTag == self.TYPE_TAG_ANY){
            return TYPE_ANY;
        } else if (typeTag == self.TYPE_TAG_ANYDATA ){
            return TYPE_ANYDATA;
        } else if (typeTag == self.TYPE_TAG_NONE ){
            return TYPE_NONE;
        } else if (typeTag == self.TYPE_TAG_NIL ){
            return TYPE_NIL;
        } else if (typeTag == self.TYPE_TAG_INT){
            return TYPE_INT;
        } else if (typeTag == self.TYPE_TAG_BYTE){
            return TYPE_BYTE;
        } else if (typeTag == self.TYPE_TAG_DECIMAL){
            return TYPE_DECIMAL;
        } else if (typeTag == self.TYPE_TAG_FLOAT){
            return TYPE_FLOAT;
        } else if (typeTag == self.TYPE_TAG_STRING){
            return TYPE_STRING;
        } else if (typeTag == self.TYPE_TAG_BOOLEAN){
            return TYPE_BOOLEAN;
        } else if (typeTag == self.TYPE_TAG_TYPEDESC) {
            return self.parseTypedescType();
        } else if (typeTag == self.TYPE_TAG_UNION){
            return self.parseUnionType();
        } else if (typeTag == self.TYPE_TAG_TUPLE){
            return self.parseTupleType();
        } else if (typeTag == self.TYPE_TAG_ARRAY){
            return self.parseArrayType();
        } else if (typeTag == self.TYPE_TAG_MAP){
            return self.parseMapType();
        } else if (typeTag == self.TYPE_TAG_TABLE){
            return self.parseTableType();
        } else if (typeTag == self.TYPE_TAG_STREAM){
            return self.parseStreamType();
        } else if (typeTag == self.TYPE_TAG_INVOKABLE){
            return self.parseInvokableType();
        } else if (typeTag == self.TYPE_TAG_RECORD){
            return self.parseRecordType();
        } else if (typeTag == self.TYPE_TAG_OBJECT){
            return self.parseObjectType();
        } else if (typeTag == self.TYPE_TAG_ERROR){
            return self.parseErrorType();
        } else if (typeTag == self.TYPE_TAG_FUTURE){
            return self.parseFutureType();
        } else if (typeTag == self.TYPE_TAG_JSON){
            return TYPE_JSON;
        } else if (typeTag == self.TYPE_TAG_XML){
            return TYPE_XML;
        } else if(typeTag == self.TYPE_TAG_FINITE) {
            return self.parseFiniteType();
        } else if (typeTag == self.TYPE_TAG_HANDLE){
            return <BTypeHandle> {};
        }

        error err = error("Unknown type tag :" + typeTag);
        panic err;
    }

    function parseTypedescType() returns BTypeDesc {
        BTypeDesc obj = { typeConstraint: TYPE_NIL }; // Dummy constraint until actual constraint is read
        obj.typeConstraint = self.parseTypeCpRef();
        return obj;
    }

    function parseArrayType() returns BArrayType {
        BArrayType obj = { state:self.parseArrayState(), size:self.readInt32(), eType:TYPE_NIL }; // Dummy eType until actual eType is read
        obj.eType = self.parseTypeCpRef();
        return obj;
    }

    function parseMapType() returns BMapType {
        BMapType obj = { constraint:TYPE_NIL }; // Dummy constraint until actual constraint is read
        obj.constraint = self.parseTypeCpRef();
        return obj;
    }

    function parseTableType() returns BTableType {
        BTableType obj = { tConstraint:TYPE_NIL }; // Dummy constraint until actual constraint is read
        obj.tConstraint = self.parseTypeCpRef();
        return obj;
    }

    function parseStreamType() returns BStreamType {
        BStreamType obj = { sConstraint:TYPE_NIL }; // Dummy constraint until actual constraint is read
        obj.sConstraint = self.parseTypeCpRef();
        return obj;
    }

    function parseFutureType() returns BFutureType {
        BFutureType obj = { returnType:TYPE_NIL }; // Dummy constraint until actual constraint is read
        obj.returnType = self.parseTypeCpRef();
        return obj;
    }

    function parseUnionType() returns BUnionType {
        BUnionType obj = { members:[] }; 
        obj.members = self.parseTypes();
        return obj;
    }

    function parseTupleType() returns BTupleType {
        BTupleType obj = { tupleTypes:[] }; 
        obj.tupleTypes = self.parseTypes();
        return obj;
    }

    function parseInvokableType() returns BInvokableType {
        BInvokableType obj = { paramTypes:[], retType: TYPE_NIL };
        obj.paramTypes = self.parseTypes();
        obj.retType = self.parseTypeCpRef();
        return obj;
    }

    function parseRecordType() returns BRecordType {
        BRecordType obj = { moduleId:self.cp.packages[self.readInt32()], name:{value:self.readStringCpRef()},
                                sealed:self.readBoolean(),
                    restFieldType: TYPE_NIL, fields: [],
                    initFunction: {funcType: {}, flags: PRIVATE } };
        self.cp.types[self.cpI] = obj;
        obj.restFieldType = self.parseTypeCpRef();
        obj.fields = self.parseRecordFields();
        boolean isInitFuncAvailable = self.readInt8() == 1;
        if (isInitFuncAvailable) {
            obj.initFunction = self.parseRecordInitFunction();
        }
        return obj;
    }

    function parseRecordFields() returns BRecordField?[] {
        int size = self.readInt32();
        int c = 0;
        BRecordField?[] fields = [];
        while c < size {
            fields[c] = self.parseRecordField();
            c = c + 1;
        }
        return fields;
    }

    function parseRecordInitFunction() returns BAttachedFunction {
        var funcName = self.readStringCpRef();
        int flags = self.readInt32();

        var funcType = self.parseTypeCpRef();
        if (funcType is BInvokableType) {
            return {name:{value:funcName},flags:flags,funcType: funcType};
        } else {
            error err = error("expected invokable type but found " + io:sprintf("%s", funcType));
            panic err;
        }
    }

    function parseRecordField() returns BRecordField {
        string nameVal = self.readStringCpRef();
        int flags = self.readInt32();
        self.skipMarkDownDocAttachementForFields();
        BType typeVal = self.parseTypeCpRef();
        return {name:{value:nameVal}, flags:flags, typeValue:typeVal};
    }

    function parseObjectType() returns BType {
        // Below is a temp fix, need to fix this properly by using type tag
        boolean isService = self.readInt8() == 1;
        int pkgCpIndex = self.readInt32();
        ModuleID moduleId = self.cp.packages[pkgCpIndex];
        string objName = self.readStringCpRef();
        boolean isAbstract = self.readBoolean();
        _ = self.readBoolean(); //Read and ignore client or not
        BObjectType obj = { moduleId: moduleId, 
            name: { value: objName },
            isAbstract: isAbstract,
            fields: [],
            attachedFunctions: [],
            constructor: () };
        self.cp.types[self.cpI] = obj;
        obj.fields = self.parseObjectFields();

        boolean constructorPresent = self.readBoolean();
        if (constructorPresent) {
            obj.constructor = self.readAttachFunction();
        }
        obj.attachedFunctions = self.parseObjectAttachedFunctions();
        if (isService) {
            BServiceType bServiceType = {oType: obj};
            return bServiceType;
        }

        return obj;
    }

    function parseObjectAttachedFunctions() returns BAttachedFunction?[] {
        int size = self.readInt32();
        int c = 0;
        BAttachedFunction?[] attachedFunctions = [];
        while c < size {
            attachedFunctions[c] = self.readAttachFunction();
            c = c + 1;
        }

        return attachedFunctions;
    }

    function readAttachFunction() returns BAttachedFunction {
        var funcName = self.readStringCpRef();
        int flags = self.readInt32();

        var funcType = self.parseTypeCpRef();
        if (funcType is BInvokableType) {
            return {name:{value:funcName},flags:flags,funcType: funcType};
        } else {
            error err = error("expected invokable type but found " + io:sprintf("%s", funcType));
            panic err;
        }
    }

    function parseObjectFields() returns BObjectField?[] {
        int size = self.readInt32();
        int c = 0;
        BObjectField?[] fields = [];
        while c < size {
            fields[c] = self.parseObjectField();
            c = c + 1;
        }
        return fields;
    }

    function parseObjectField() returns BObjectField {
        string nameVal = self.readStringCpRef();
        int flags = self.readInt32();
        self.skipMarkDownDocAttachementForFields();
        BType typeValue = self.parseTypeCpRef();
        return {name:{value:nameVal}, flags:flags, typeValue:typeValue};
    }

    function parseErrorType() returns BErrorType {
        BErrorType err = {moduleId:self.cp.packages[self.readInt32()], name:{value:self.readStringCpRef()},
                             reasonType:TYPE_NIL, detailType:TYPE_NIL};
        self.cp.types[self.cpI] = err;
        err.reasonType = self.parseTypeCpRef();
        err.detailType = self.parseTypeCpRef();
        return err;
    }

    function parseTypes() returns BType?[] {
        int count = self.readInt32();
        int i = 0;

        BType?[] types = [];
        while (i < count) {
            types[types.length()] = self.parseTypeCpRef();
            i = i + 1;
        }
        return types;
    }

    function parseArrayState() returns ArrayState {
        int b = self.readInt8();
        if (b == 1) {
            return "CLOSED_SEALED";
        } else if (b == 2) {
            return "OPEN_SEALED";
        } else if (b == 3) {
            return "UNSEALED";
        }
        error err = error("unknown array state tag " + b);
        panic err;
    }

    function parseFiniteType() returns BFiniteType {
        BFiniteType finiteType = {name: { value: self.readStringCpRef()},
                                    flags:self.readInt32(), values:[]};
        int size = self.readInt32();
        int c = 0;
        while c < size {
            BType valueType = self.parseTypeCpRef();
            finiteType.values[c] = (self.getValue(valueType), valueType);
            c = c + 1;
        }
        return finiteType;
    }

    private function getValue(BType valueType) returns (int | string | boolean | float | byte| () | Decimal) {
        if (valueType is BTypeInt) {
            return self.readIntCpRef();
        } else if (valueType is BTypeByte) {
            return self.readByteCpRef();
        } else if (valueType is BTypeString) {
            return self.readStringCpRef();
        } else if (valueType is BTypeDecimal) {
            return {value: self.readStringCpRef()};
        } else if (valueType is BTypeBoolean) {
            return self.readInt8() == 1;
        } else if (valueType is BTypeFloat) {
            return self.readFloatCpRef();
        } else if (valueType is BTypeNil) {
            return ();
        }
    }

    // TODO: remove duplicate function with the same name
    private function readStringCpRef() returns string {
        var stringCpIndex = self.readInt32();
        return self.cp.strings[stringCpIndex];
    }

    // TODO: remove duplicate function with the same name
    private function readIntCpRef() returns int {
        var intCpIndex = self.readInt32();
        return self.cp.ints[intCpIndex];
    }

    // TODO: remove duplicate function with the same name
    private function readFloatCpRef() returns float {
        var floatCpIndex = self.readInt32();
        return self.cp.floats[floatCpIndex];
    }

    public function readByteCpRef() returns byte {
        var byteCpIndex = self.readInt32();
        return self.cp.bytes[byteCpIndex];
    }

    private function readBoolean() returns boolean {
        int pos = self.reader.pos;
        var byteVal = self.reader.buf[pos];
        self.reader.pos = pos + 1;
        return byteVal == 1;
    }

    function skipMarkDownDocAttachementForFields() {
        int docLength = self.readInt32();
        self.reader.pos = self.reader.pos + docLength;
    }

    private function readInt8() returns int {
        int pos = self.reader.pos;
        var byteVal = self.reader.buf[pos];
        self.reader.pos = pos + 1;
        return <int>byteVal;
    }

    private function readInt32() returns int {
        int pos = self.reader.pos;
        int ff = 255;
        int octave1 = 8;
        int octave2 = 16;
        int octave3 = 24;
        var b = self.reader.buf;
        int b0 = int.convert(b[pos + 0]);
        int b1 = int.convert(b[pos + 1]);
        int b2 = int.convert(b[pos + 2]);
        int b3 = int.convert(b[pos + 3]);
        self.reader.pos = pos + 4;
        return b0 <<octave3|(b1 & ff) <<octave2|(b2 & ff) <<octave1|(b3 & ff);
    }
};
