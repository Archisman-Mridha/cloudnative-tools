package utils

import (
	"flag"
	"log"
	"net"
	"os"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var GRPCServerPort= flag.String("port", "localhost:4000", "Port where gRPC server will listen")

func CreateGRPCServer(setupGrpcServer func(*grpc.Server)) *grpc.Server {

	//* creating a tcp listener which will listen at port 4000
	portListener, error := net.Listen("tcp", *GRPCServerPort)

	if error != nil {
		log.Println(error.Error( ))

		os.Exit(1)
	}

	//* creating the grpc server

	gRPCServer := grpc.NewServer( )
	reflection.Register(gRPCServer)

	setupGrpcServer(gRPCServer)

	//* starting the grpc server

	log.Println("🚀 starting gRPC server")

	gRPCServer.Serve(portListener)

	return gRPCServer
}