#!/bin/bash

# the directory containing the script file
dir="$(cd "$(dirname "$0")"; pwd)"
cd "$dir"


log()   { echo -e "\e[30;47m ${1^^} \e[0m ${@:2}"; }        # $1 uppercase background white
info()  { echo -e "\e[48;5;28m ${1^^} \e[0m ${@:2}"; }      # $1 uppercase background green
warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background orange
error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background red


# log $1 in underline then $@ then a newline
under() {
    local arg=$1
    shift
    echo -e "\033[0;4m${arg}\033[0m ${@}"
    echo
}

usage() {
    under usage 'call the Makefile directly: make dev
      or invoke this file directly: ./make.sh dev'
}

# run redis alpine docker image
redis() {
  docker run \
    --rm \
    --name redis \
    --publish 6379:6379 \
    redis:alpine
}

# run local website using npm - dev mode (livereload + nodemon)
npm() {
  cd vote
  # https://unix.stackexchange.com/a/454554
  command npm install
  npx livereload . --wait 200 --extraExts 'njk' & \
    NODE_ENV=development \
    WEBSITE_PORT=3000 \
    REDIS_HOST=127.0.0.1 \
    npx nodemon --ext js,json,njk index.js
}

# run the project using docker-compose (same as redis + npm)
compose-dev() {
  export COMPOSE_PROJECT_NAME=k8s_init_container
  docker-compose \
      --file docker-compose.dev.yml \
      up \
      --remove-orphans \
      --force-recreate \
      --build \
      --no-deps 
}

# build the site docker image
docker-build() {
  cd vote
  docker image build \
    --file Dockerfile.dev \
    --tag site \
    .
}


# if `$1` is a function, execute it. Otherwise, print usage
# compgen -A 'function' list all declared functions
# https://stackoverflow.com/a/2627461
FUNC=$(compgen -A 'function' | grep $1)
[[ -n $FUNC ]] && { info execute $1; eval $1; } || usage;
exit 0