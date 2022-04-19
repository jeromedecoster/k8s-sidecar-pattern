.SILENT:

help:
	{ grep --extended-regexp '^[a-zA-Z_-]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) || true; } \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-15s\033[0m%s\n", $$1, $$2 }'

redis: # run redis alpine docker image
	./make.sh redis

npm: # run local website using npm - dev mode (livereload + nodemon)
	./make.sh npm

compose-dev: # run the project using docker-compose (same as redis + npm)
	./make.sh compose-dev

docker-build: # build the site docker image
	./make.sh docker-build
