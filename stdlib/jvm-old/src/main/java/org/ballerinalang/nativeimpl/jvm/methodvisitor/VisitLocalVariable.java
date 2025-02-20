/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.ballerinalang.nativeimpl.jvm.methodvisitor;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.nativeimpl.jvm.ASMUtil;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.objectweb.asm.Label;
import org.objectweb.asm.MethodVisitor;

import static org.ballerinalang.model.types.TypeKind.INT;
import static org.ballerinalang.model.types.TypeKind.OBJECT;
import static org.ballerinalang.model.types.TypeKind.STRING;
import static org.ballerinalang.nativeimpl.jvm.ASMUtil.JVM_PKG_PATH;
import static org.ballerinalang.nativeimpl.jvm.ASMUtil.LABEL;
import static org.ballerinalang.nativeimpl.jvm.ASMUtil.METHOD_VISITOR;

/**
 * Native class for jvm method byte code creation.
 */
@BallerinaFunction(
        orgName = "ballerina", packageName = "jvm",
        functionName = "visitLocalVariable",
        receiver = @Receiver(type = TypeKind.OBJECT, structType = METHOD_VISITOR, structPackage = JVM_PKG_PATH),
        args = {
                @Argument(name = "varName", type = STRING),
                @Argument(name = "descriptor", type = STRING),
                @Argument(name = "startLabel", type = OBJECT, structType = LABEL),
                @Argument(name = "endLabel", type = OBJECT, structType = LABEL),
                @Argument(name = "index", type = INT)
        }
)
public class VisitLocalVariable extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {
        MethodVisitor mv = ASMUtil.getRefArgumentNativeData(context, 0);
        String varName = context.getStringArgument(0);
        String descriptor = context.getStringArgument(1);
        Label startLabel = ASMUtil.getRefArgumentNativeData(context, 1);
        Label endLabel = ASMUtil.getRefArgumentNativeData(context, 2);
        int index = (int) context.getIntArgument(0);
        mv.visitLocalVariable(varName, descriptor, null, startLabel , endLabel, index);
    }
}
