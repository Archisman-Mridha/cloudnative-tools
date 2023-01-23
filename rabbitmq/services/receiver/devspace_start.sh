#!/bin/bash
set +e  # Continue on errors

#* creating go.work file

if [ ! -f go.work ]; then
    go work init
fi

#* registering modules in the go.work file
go work use ./services/receiver
go work use ./shared

echo 🧊 you are now in the dev container.

# navigating to the receiver microservice directory
cd ./services/receiver

# Open shell
bash --norc
