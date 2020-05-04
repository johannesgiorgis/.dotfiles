
IMAGE_NAME:=dotfilestest

docker-build-no-cache:
	docker build --rm --no-cache -t $(IMAGE_NAME):1.0 .

docker-build:
	docker build --rm -t $(IMAGE_NAME):1.0 .

docker-run:
	docker run -it --rm $(IMAGE_NAME):1.0 zsh

docker-all: docker-build docker-run

docker-all-dev: docker-build-no-cache docker-run
