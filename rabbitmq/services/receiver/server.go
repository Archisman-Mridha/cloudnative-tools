package main

import (
	"context"
	"shared/utils"

	"google.golang.org/grpc"

	proto "receiver/proto/generated"
)

type ReceiverServer struct {
	proto.UnimplementedReceiverServer
}

func(ReceiverServer) SendMessage(
	ctx context.Context, request *proto.ReceiveMessageRequest) (*proto.ReceiveMessageResponse, error) {

	// TODO: receive test message from the sender

	return &proto.ReceiveMessageResponse{ }, nil
}

func main( ) {

	gRPCServer := utils.CreateGRPCServer(
		func(gRPCServer *grpc.Server) {
			proto.RegisterReceiverServer(gRPCServer, &ReceiverServer{ })
		},
	)

	defer gRPCServer.Stop( )
}