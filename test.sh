#!/bin/bash

source docker-vars.sh

# Run the docker instance, change [CFGDIR] to where you have configs outside of docker

docker run -it -p 3000:3000 -v [CFGDIR]:/home/node/nodecg/cfg:ro $NAME /bin/bash

