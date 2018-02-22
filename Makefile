cluster:
	# chmod u+x create_cluster.sh  
	./create_cluster.sh 2

destroy:
	docker-machine ls --filter name=node-.* --filter driver=digitalocean --format "{{.Name}}" | xargs docker-machine rm -y
