package main

import (
	"database/sql"
	"log"
	"os"

	_ "github.com/lib/pq"
)

func main( ) {

	uri := os.Getenv("POSTGRES_CLUSTER_URL")
	if uri == "" {
		log.Fatal("env POSTGRES_CLUSTER_URL not found")
	}
	db, err := sql.Open("postgres", uri)
	if err != nil {
		log.Fatalf("Error connecting to the database: %v", err)
	}

	if err= db.Ping( ); err != nil {
		log.Fatalf("Error pinging the database: %v", err)
	}
	log.Println("Successfully connected to the database !")

}