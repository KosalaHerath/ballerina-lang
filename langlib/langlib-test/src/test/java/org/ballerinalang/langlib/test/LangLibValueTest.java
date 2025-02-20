/*
 *  Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */
package org.ballerinalang.langlib.test;

import org.ballerinalang.model.types.TypeTags;
import org.ballerinalang.model.values.BBoolean;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BString;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.model.values.BValueArray;
import org.ballerinalang.test.util.BCompileUtil;
import org.ballerinalang.test.util.BRunUtil;
import org.ballerinalang.test.util.CompileResult;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import java.util.Arrays;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNull;

/**
 * Test cases for value lib functions.
 *
 * @since 1.0
 */
public class LangLibValueTest {

    private CompileResult compileResult;

    @BeforeClass
    public void setup() {

        compileResult = BCompileUtil.compile("test-src/valuelib_test.bal");
        if (compileResult.getErrorCount() != 0) {
            Arrays.stream(compileResult.getDiagnostics()).forEach(System.out::println);
            Assert.fail("Compilation contains error");
        }
    }

    @Test
    public void testToJsonString() {

        BValue[] returns = BRunUtil.invokeFunction(compileResult, "testToJsonString");
        assertEquals(returns[0].getType().getTag(), TypeTags.MAP_TAG);

        BMap<String, BString> arr = (BMap<String, BString>) returns[0];
        assertEquals(arr.get("aNil").stringValue(), "null");
        assertEquals(arr.get("aString").stringValue(), "aString");
        assertEquals(arr.get("aNumber").stringValue(), "10");
        assertEquals(arr.get("aFloatNumber").stringValue(), "10.5");
        assertEquals(arr.get("anArray").stringValue(), "[\"hello\", \"world\"]");
        assertEquals(arr.get("anObject").stringValue(),
                "{\"name\":\"anObject\", \"value\":10, \"sub\":{\"subName\":\"subObject\", \"subValue\":10}}");
        assertEquals(arr.size(), 6);
    }

    @Test
    public void testFromJsonString() {

        BValue[] returns = BRunUtil.invokeFunction(compileResult, "testFromJsonString");
        assertEquals(returns[0].getType().getTag(), TypeTags.MAP_TAG);

        BMap<String, BValue> arr = (BMap<String, BValue>) returns[0];
        assertEquals(arr.get("aNil").getType().getTag(), TypeTags.ERROR_TAG);
        assertNull(arr.get("aNull"));
        assertEquals(arr.get("aString").stringValue(), "aString");
        assertEquals(arr.get("aNumber").stringValue(), "10");
//        assertEquals(arr.get("aFloatNumber").stringValue(), "10.5"); // TODO : Enable this. Bug in JVM Type checker.
        assertEquals(arr.get("anArray").stringValue(), "[\"hello\", \"world\"]");
        assertEquals(arr.get("anObject").stringValue(),
                "{\"name\":\"anObject\", \"value\":10, \"sub\":{\"subName\":\"subObject\", \"subValue\":10}}");
        assertEquals(arr.get("anInvalid").getType().getTag(), TypeTags.ERROR_TAG);
        assertEquals(arr.size(), 7);
    }

    @Test
    public void testToString() {
        BValue[] returns = BRunUtil.invokeFunction(compileResult, "testToStringMethod");
        BValueArray array = (BValueArray) returns[0];
        assertEquals(array.getRefValue(0).stringValue(), "4");
        assertEquals(array.getRefValue(1).stringValue(), "4");
        assertEquals(array.getRefValue(2).stringValue(), "4");
        assertEquals(array.getRefValue(3).stringValue(), "4");
    }

    @Test(dataProvider = "mergeJsonFunctions")
    public void testMergeJson(String function) {
        BValue[] returns = BRunUtil.invoke(compileResult, function);
        Assert.assertTrue(((BBoolean) returns[0]).booleanValue());
    }

    @DataProvider(name = "mergeJsonFunctions")
    public Object[][] mergeJsonFunctions() {
        return new Object[][] {
            { "testNilAndNonNilJsonMerge" },
            { "testNonNilNonMappingJsonMerge" },
            { "testMappingJsonAndNonMappingJsonMerge1" },
            { "testMappingJsonAndNonMappingJsonMerge2" },
            { "testMappingJsonNoIntersectionMergeSuccess" },
            { "testMappingJsonWithIntersectionMergeFailure1" },
            { "testMappingJsonWithIntersectionMergeFailure2" },
            { "testMappingJsonWithIntersectionMergeSuccess" }
        };
    }
}
