run:
	docker run -it --rm -v $(pwd)/src:/src -p 8083:8080 -w /src golang:jessie go run server.go

build-image: Dockerfile
	docker build -t helgecph/swarmserver .

run-container:
	docker run --rm --name webserver -p 8083:8080 helgecph/swarmserver

clean:
	docker rmi helgecph/swarmserver

publish-image:
	docker login --username helgecph --password-stdin;docker push helgecph/swarmserver;docker logout