import ballerinax/java.jms;
import ballerina/io;

// Creates a queue sender. This example makes use of the ActiveMQ Artemis
// broker for demonstration while it can be tried with other brokers that
// support JMS.
jms:QueueSender queueSender = new({
        initialContextFactory: 
        "org.apache.activemq.artemis.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616",
        acknowledgementMode: "AUTO_ACKNOWLEDGE"
    }, "MyQueue");

public function main() {
    // Create a text message.
    var msg = new jms:Message(queueSender.session, jms:TEXT_MESSAGE);
    if (msg is jms:Message) {
        var err = msg.setPayload("Hello from Ballerina");
        if (err is error) {
            io:println("Unable to set payload" , err.reason());
        }
        // Send the Ballerina message to the JMS provider.
        var returnVal = queueSender->send(msg);
        if (returnVal is error) {
            io:println("Error occurred while sending message",
                returnVal.reason());
        }
    } else {
        io:println("Error occurred while creating message",
            msg.reason());
    }
}
