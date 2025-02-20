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
package org.ballerinalang.nativeimpl.jvm.interop;

import org.ballerinalang.jvm.BallerinaValues;
import org.ballerinalang.jvm.types.BTypes;
import org.ballerinalang.jvm.values.ArrayValue;
import org.ballerinalang.jvm.values.ErrorValue;
import org.ballerinalang.jvm.values.MapValue;
import org.ballerinalang.jvm.values.MapValueImpl;

import java.util.ArrayList;
import java.util.List;

import static org.ballerinalang.nativeimpl.jvm.interop.JInteropException.CLASS_NOT_FOUND_REASON;
import static org.ballerinalang.nativeimpl.jvm.interop.JInteropException.UNSUPPORTED_PRIMITIVE_TYPE_READON;
import static org.ballerinalang.util.BLangConstants.ORG_NAME_SEPARATOR;

/**
 * This class contains a set of utility methods and constants used in this implementation.
 *
 * @since 1.0.0
 */
class JInterop {

    static final String ORG_NAME = "ballerina";
    static final String MODULE_NAME = "jvm";
    static final String JAVA_MODULE_NAME = "java";
    static final String JVM_PACKAGE_PATH = ORG_NAME + ORG_NAME_SEPARATOR + MODULE_NAME;
    static final String ERROR_REASON_PREFIX = "{" + ORG_NAME + "/" + JAVA_MODULE_NAME + "}";
    static final String PARAM_TYPE_CONSTRAINTS_FIELD = "paramTypeConstraints";
    static final String CLASS_FIELD = "class";
    static final String NAME_FIELD = "name";
    static final String KIND_FIELD = "kind";
    static final String IS_INTERFACE_FIELD = "isInterface";
    static final String IS_ARRAY_FIELD = "isArray";
    static final String IS_STATIC_FIELD = "isStatic";
    static final String SIG_FIELD = "sig";
    static final String METHOD_TYPE_FIELD = "mType";
    static final String FIELD_TYPE_FIELD = "fType";
    static final String PARAM_TYPES_FIELD = "paramTypes";
    static final String RETURN_TYPE_FIELD = "retType";
    static final String METHOD_FIELD = "method";
    static final String TAG_FIELD = "tag";
    static final String BFUNC_TYPE_FIELD = "bFuncType";
    static final String HANDLE_TYPE_NAME = "handle";
    static final String METHOD_TYPE_NAME = "Method";
    static final String FIELD_TYPE_NAME = "Field";
    static final String METHOD_TYPE_TYPE_NAME = "Method";
    static final String J_REF_TYPE_NAME = "RefType";
    static final String TYPE_NAME_FIELD = "typeName";
    static final String NO_TYPE_NAME = "NoType";

    static MapValue<String, Object> createRecordBValue(String typeName) {
        return BallerinaValues.createRecordValue(JVM_PACKAGE_PATH, typeName);
    }

    static MapValue<String, Object> createJMethodTypeBValue(JMethod jMethod) {
        MapValue<String, Object> jMethodTypeBRecord = createRecordBValue(METHOD_TYPE_TYPE_NAME);

        ArrayValue paramBTypeArray = new ArrayValue(BTypes.typeAnydata);
        Class<?>[] paramClassTypes = jMethod.getParamTypes();
        for (int paramIndex = 0; paramIndex < paramClassTypes.length; paramIndex++) {
            Class<?> paramClassType = paramClassTypes[paramIndex];
            Object jParamType = createJTypeBValue(paramClassType);
            paramBTypeArray.add(paramIndex, jParamType);
        }
        jMethodTypeBRecord.put(PARAM_TYPES_FIELD, paramBTypeArray);

        Class<?> retClassType = jMethod.getReturnType();
        jMethodTypeBRecord.put(RETURN_TYPE_FIELD, createJTypeBValue(retClassType));
        return jMethodTypeBRecord;
    }

    static Object createJTypeBValue(Class<?> jTypeClass) {
        if (jTypeClass.isPrimitive()) {
            return jTypeClass.getName();
        } else if (jTypeClass == Void.class) {
            throw new IllegalArgumentException("The Java Void type is not yet supported.");
        }

        MapValue<String, Object> jRefTypeBRecord = createRecordBValue(J_REF_TYPE_NAME);
        jRefTypeBRecord.put(TAG_FIELD, J_REF_TYPE_NAME);
        jRefTypeBRecord.put(TYPE_NAME_FIELD, jTypeClass.getName().replace('.', '/'));
        jRefTypeBRecord.put(IS_INTERFACE_FIELD, jTypeClass.isInterface());
        jRefTypeBRecord.put(IS_ARRAY_FIELD, jTypeClass.isArray());
        return jRefTypeBRecord;
    }

    static String getMethodSig(Class<?> returnType, Class<?>... parameterTypes) {
        StringBuilder sb = new StringBuilder();
        sb.append('(');
        for (Class<?> type : parameterTypes) {
            sb.append(getSig(type));
        }
        sb.append(')');
        return sb.append(getSig(returnType)).toString();
    }

    static String getSig(Class<?> c) {
        if (c.isPrimitive()) {
            if (int.class == c) {
                return "I";
            } else if (long.class == c) {
                return "J";
            } else if (boolean.class == c) {
                return "Z";
            } else if (byte.class == c) {
                return "B";
            } else if (short.class == c) {
                return "S";
            } else if (char.class == c) {
                return "C";
            } else if (float.class == c) {
                return "F";
            } else if (double.class == c) {
                return "D";
            } else {
                // This is void
                return "V";
            }
        } else if (void.class == c || Void.class == c) {
            return "V";
        } else {
            String className = c.getName().replace('.', '/');
            if (c.isArray()) {
                return className;
            } else {
                return 'L' + className + ';';
            }
        }
    }

    static boolean isHandleType(Object bValue) {
        if (bValue instanceof MapValue) {
            MapValue<String, Object> bTypeValue = (MapValue<String, Object>) bValue;
            String handleTypeName = (String) bTypeValue.get(TYPE_NAME_FIELD);
            return handleTypeName.equals(HANDLE_TYPE_NAME);
        }
        return false;
    }

    static ParamTypeConstraint[] buildParamTypeConstraints(ArrayValue javaTypeConstraints, JMethodKind kind) {
        List<ParamTypeConstraint> constraintList = new ArrayList<>();
        // Here the assumption is that all param types are handle types. This will be improved soon.
        int startParamOffset = (kind == JMethodKind.INSTANCE) ? 1 : 0;
        for (int paramIndex = startParamOffset; paramIndex < javaTypeConstraints.size(); paramIndex++) {
            Object javaTypeConstraint = javaTypeConstraints.get(paramIndex);
            constraintList.add(buildParamTypeConstraint(javaTypeConstraint));
        }
        return constraintList.toArray(new ParamTypeConstraint[0]);
    }

    private static ParamTypeConstraint buildParamTypeConstraint(Object javaTypeConstraint) {
        if (isJavaRefType(javaTypeConstraint)) {
            return buildConstraintFromJavaRefType((MapValue<String, Object>) javaTypeConstraint);
        } else if (isJavaNoType(javaTypeConstraint)) {
            return ParamTypeConstraint.NO_CONSTRAINT;
        } else {
            return buildConstraintFromJavaPrimitiveType((String) javaTypeConstraint);
        }
    }

    private static ParamTypeConstraint buildConstraintFromJavaRefType(MapValue<String, Object> javaRefType) {
        String constraintBValue = (String) javaRefType.get(TYPE_NAME_FIELD);
        return new ParamTypeConstraint(loadClass(constraintBValue));
    }

    private static ParamTypeConstraint buildConstraintFromJavaPrimitiveType(String primitiveTypeName) {
        // Java primitive types: byte, short, char, int, long, float, double, boolean
        Class<?> constraintClass;
        switch (primitiveTypeName) {
            case "byte":
                constraintClass = byte.class;
                break;
            case "short":
                constraintClass = short.class;
                break;
            case "char":
                constraintClass = char.class;
                break;
            case "int":
                constraintClass = int.class;
                break;
            case "long":
                constraintClass = long.class;
                break;
            case "float":
                constraintClass = float.class;
                break;
            case "double":
                constraintClass = double.class;
                break;
            case "boolean":
                constraintClass = boolean.class;
                break;
            default:
                throw new JInteropException(UNSUPPORTED_PRIMITIVE_TYPE_READON,
                        "Unsupported Java primitive type '" + primitiveTypeName + "'");
        }
        return new ParamTypeConstraint(constraintClass);
    }

    private static boolean isJavaRefType(Object javaTypeConstraint) {
        if (javaTypeConstraint instanceof MapValue) {
            MapValue jRefTypeBValue = (MapValue) javaTypeConstraint;
            String tagValue = (String) jRefTypeBValue.get(TAG_FIELD);
            return tagValue != null && tagValue.equals(J_REF_TYPE_NAME);
        } else {
            return false;
        }
    }

    private static boolean isJavaNoType(Object javaTypeConstraint) {
        if (javaTypeConstraint instanceof String) {
            String javaNoTypeBValue = (String) javaTypeConstraint;
            return javaNoTypeBValue.equals(NO_TYPE_NAME);
        } else {
            return false;
        }
    }

    static Class<?> loadClass(String className) {
        try {
            return Class.forName(className.replace("/", "."));
        } catch (ClassNotFoundException e) {
            throw new JInteropException(CLASS_NOT_FOUND_REASON, e.getMessage(), e);
        }
    }

    static ErrorValue createErrorBValue(String reason, String details) {
        MapValue<String, Object> refData = new MapValueImpl<>(BTypes.typeError.detailType);
        if (details != null) {
            refData.put("message", details);
        } else {
            refData.put("message", "");
        }
        return new ErrorValue(BTypes.typeError, ERROR_REASON_PREFIX + reason, refData);
    }
}
