/*
 *  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
package org.ballerinalang.observe.nativeimpl;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.jvm.observability.metrics.Gauge;
import org.ballerinalang.jvm.observability.metrics.Snapshot;
import org.ballerinalang.jvm.scheduling.Strand;
import org.ballerinalang.jvm.values.ArrayValue;
import org.ballerinalang.jvm.values.ObjectValue;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.natives.annotations.ReturnType;

/**
 * This is the getSnapshot extern function implementation of the Gauge object.
 *
 * @since 0.980.0
 */

@BallerinaFunction(
        orgName = "ballerina",
        packageName = "observe",
        functionName = "getSnapshot",
        receiver = @Receiver(type = TypeKind.OBJECT, structType = ObserveNativeImplConstants.GAUGE,
                structPackage = ObserveNativeImplConstants.OBSERVE_PACKAGE_PATH),
        isPublic = true,
        returnType = @ReturnType(type = TypeKind.ARRAY)
)
public class GaugeGetSnapshot extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {
//        BMap bStruct = (BMap) context.getRefArgument(0);
//        Gauge gauge = (Gauge) bStruct.getNativeData(ObserveNativeImplConstants.METRIC_NATIVE_INSTANCE_KEY);
//        Snapshot[] snapshots = gauge.getSnapshots();
//        BValueArray bSnapshots = Utils.createBSnapshots(snapshots, context);
//        context.setReturnValues(bSnapshots);
    }

    public static Object getSnapshot(Strand strand, ObjectValue guageObj) {
        Gauge gauge = (Gauge) guageObj.getNativeData(ObserveNativeImplConstants.METRIC_NATIVE_INSTANCE_KEY);
        Snapshot[] snapshots = gauge.getSnapshots();
        ArrayValue bSnapshots = Utils.createBSnapshots(snapshots, strand);
        return bSnapshots;
    }
}
