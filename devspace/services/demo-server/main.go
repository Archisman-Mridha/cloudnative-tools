package main

import (
	"fmt"
	"log"
	"net/http"
)

const PORT int16= 4000

func main( ) {
	log.Println(fmt.Sprintf("server starting at http://localhost:%d", PORT))

	http.HandleFunc("/",
		func(responseWriter http.ResponseWriter, request *http.Request) {
			responseWriter.Write([ ]byte("server is running"))
		},
	)

	serverStartingError := http.ListenAndServe(fmt.Sprintf(":%d", PORT), nil)

	if serverStartingError != nil {
		log.Fatal(serverStartingError) }
}