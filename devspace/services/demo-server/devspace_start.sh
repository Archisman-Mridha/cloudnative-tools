#!/bin/bash
set +e  #* Continue on errors

echo "📦 entering dev container"

go run main.go

#* open shell
bash --norc
