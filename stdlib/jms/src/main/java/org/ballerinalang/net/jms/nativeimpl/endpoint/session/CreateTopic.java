/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package org.ballerinalang.net.jms.nativeimpl.endpoint.session;

import org.ballerinalang.jvm.scheduling.Strand;
import org.ballerinalang.jvm.values.ObjectValue;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.net.jms.JmsConstants;
import org.ballerinalang.net.jms.JmsUtils;
import org.ballerinalang.net.jms.utils.BallerinaAdapter;

import javax.jms.JMSException;
import javax.jms.Session;

/**
 * Create Text JMS Message.
 */
@BallerinaFunction(orgName = JmsConstants.BALLERINAX, packageName = JmsConstants.JAVA_JMS,
                   functionName = "createTopic",
                   receiver = @Receiver(type = TypeKind.OBJECT, structType = JmsConstants.SESSION_OBJ_NAME,
                                        structPackage = JmsConstants.PROTOCOL_PACKAGE_JMS),
                   args = {@Argument(name = "name", type = TypeKind.STRING)})
public class CreateTopic {


    public Object createTopic(Strand strand, ObjectValue sessionObj, String topicName) {

        Session session = (Session) sessionObj.getNativeData(JmsConstants.JMS_SESSION);
        try {
            return JmsUtils.populateAndGetDestinationObj(session.createTopic(topicName));
        } catch (JMSException e) {
            return BallerinaAdapter.getError("Failed to create topic destination.", e);
        }
    }

    private CreateTopic() {
    }
}
