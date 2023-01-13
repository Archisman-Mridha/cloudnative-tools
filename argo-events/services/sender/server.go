package main

import (
	"context"
	"shared/utils"

	"google.golang.org/grpc"

	proto "sender/proto/generated"
)

type SenderServer struct {
	proto.UnimplementedSenderServer
}

func(SenderServer) SendMessage(
	ctx context.Context, request *proto.SendMessageRequest) (*proto.SendMessageResponse, error) {

	// TODO: send test message to the receiver

	return &proto.SendMessageResponse{ }, nil
}

func main( ) {

	gRPCServer := utils.CreateGRPCServer(
		func(gRPCServer *grpc.Server) {
			proto.RegisterSenderServer(gRPCServer, &SenderServer{ })
		},
	)

	defer gRPCServer.Stop( )
}