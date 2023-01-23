package main

import (
	"log"

	"github.com/streadway/amqp"
	"google.golang.org/protobuf/proto"

	protoGenerated "receiver/proto/generated"
)

var (
	MessageQueueName *string
	RabbitMQChannel *amqp.Channel
)

func main( ) {

	//* connecting to rabbitMQ
	rabbitMQConnection, error := amqp.Dial("amqp://user:password@10.43.79.24:5672/")
	if error != nil {
		log.Fatal(error.Error( )) }

	defer rabbitMQConnection.Close( )

	//* creating a rabbitMQ channel
	RabbitMQChannel, error= rabbitMQConnection.Channel( )
	if error != nil {
		log.Fatal(error.Error( )) }

	defer RabbitMQChannel.Close( )

	//* consuming messages from the queue `Main`
	newTestMessages, error := RabbitMQChannel.Consume(
		"Main", "", true, false, false, false, nil)
	if error != nil {
		log.Fatal(error.Error( )) }

	for testMessage := range newTestMessages {
		var unmarshalledMessage protoGenerated.TestMessage

		error := proto.Unmarshal(testMessage.Body, &unmarshalledMessage)
		if error != nil {
			log.Println("error unmarshalling message from rabbitMQ - ", error.Error( )) }

		log.Println("received new message from rabbitMQ queue `Main` - ", unmarshalledMessage.Message)
	}
}