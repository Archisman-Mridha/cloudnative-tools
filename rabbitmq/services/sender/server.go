package main

import (
	"context"
	"log"
	"os"
	"shared/utils"

	"github.com/streadway/amqp"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/proto"

	protoGenerated "sender/proto/generated"
)

type SenderServer struct {
	protoGenerated.UnimplementedSenderServer
}

func(SenderServer) SendMessage(
	ctx context.Context, request *protoGenerated.SendMessageRequest) (*protoGenerated.SendMessageResponse, error) {

	message, error := proto.Marshal(
		&protoGenerated.TestMessage{
			Message: "hi",
		},
	)

	if error != nil {
		log.Println("error marshalling message - ", error.Error( ))

		responseError := "error sending message to rabbitMQ"
		return &protoGenerated.SendMessageResponse{ Error: &responseError }, nil
	}

	RabbitMQChannel.Publish("",
		*MessageQueueName,
		false, false,
		amqp.Publishing{

			Body: message,
		},
	)

	return &protoGenerated.SendMessageResponse{ }, nil
}

var (
	MessageQueueName *string
	RabbitMQChannel *amqp.Channel
)

func main( ) {

	//! connecting to rabbitMQ

	rabbitMQClusterAddress, isEnvFound := os.LookupEnv("RABBITMQ_CLUSTER_ADDRESS")
	if !isEnvFound {
		log.Fatal("env RABBITMQ_CLUSTER_ADDRESS not found") }

	rabbitMQConnection, error := amqp.Dial(rabbitMQClusterAddress)
	if error != nil {
		log.Fatal("error connecting to rabbitMQ \n", error.Error( )) }

	defer rabbitMQConnection.Close( )

	//! creating a rabbitMQ channel
	RabbitMQChannel, error= rabbitMQConnection.Channel( )
	if error != nil {
		log.Fatal("error creating a rabbitMQ channel \n", error.Error( )) }

	defer RabbitMQChannel.Close( )

	//! creating a queue
	messageQueue, error := RabbitMQChannel.QueueDeclare(
		"Main", false, false, false, false, nil)

	if error != nil {
		log.Fatal("error creating a new rabbitMQ queue \n", error.Error( )) }

	MessageQueueName= &messageQueue.Name

	log.Println("connected to RabbitMQ and created the new queue `Main` 💫")

	//! creating the gRPC server
	gRPCServer := utils.CreateGRPCServer(
		func(gRPCServer *grpc.Server) {
			protoGenerated.RegisterSenderServer(gRPCServer, &SenderServer{ })
		},
	)

	defer gRPCServer.Stop( )
}