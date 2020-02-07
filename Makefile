
IMAGE_NAME:=dotfilestest

docker-build:
	docker build --rm --no-cache -t $(IMAGE_NAME):1.0 .

docker-run:
	docker run -it --rm $(IMAGE_NAME):1.0 bash 

docker-all: docker-build docker-run
