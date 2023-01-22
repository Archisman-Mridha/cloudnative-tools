package main

import (
	"log"

	"github.com/streadway/amqp"
)

var (
	MessageQueueName *string
	RabbitMQChannel *amqp.Channel
)

func main( ) {

	//* connecting to rabbitMQ
	rabbitMQConnection, error := amqp.Dial("amqp://user:password@localhost:5672/")
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
		"Main", "", false, false, false, false, nil)
	if error != nil {
		log.Fatal(error.Error( )) }

	for testMessage := range newTestMessages {
		log.Println("received new message from rabbitMQ queue `Main` - ", string(testMessage.Body))
	}
}