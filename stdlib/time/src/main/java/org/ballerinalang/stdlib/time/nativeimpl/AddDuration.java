/*
*   Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
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
*/
package org.ballerinalang.stdlib.time.nativeimpl;

import org.ballerinalang.bre.Context;
import org.ballerinalang.jvm.scheduling.Strand;
import org.ballerinalang.jvm.values.MapValue;
import org.ballerinalang.natives.annotations.BallerinaFunction;

/**
 * Add given durations to the time.
 *
 * @since 0.89
 */
@BallerinaFunction(
        orgName = "ballerina", packageName = "time",
        functionName = "addDuration"
)
public class AddDuration extends AbstractTimeFunction {

    @Override
    public void execute(Context context) {
    }

    public static MapValue<?, ?> addDuration(Strand strand, MapValue<String, Object> timeRecord, long years,
                                             long months, long dates, long hours, long minutes, long seconds,
                                             long milliSeconds) {
        return addDuration(timeRecord, years, months, dates, hours, minutes, seconds, milliSeconds);
    }
}
