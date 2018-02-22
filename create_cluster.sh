#!/bin/bash

# This script automates what is described in:
# https://www.digitalocean.com/community/tutorials/how-to-create-a-cluster-of-docker-containers-with-docker-swarm-and-digitalocean-on-ubuntu-16-04

# cat <<EOF
# Usage: $0 [options]

# -h | --help          Shows this help message.
# -m | --no_managers   
# -w | --no_workers   this is my second option
# EOF


export DIGITALOCEAN_REGION=fra1
export DIGITALOCEAN_SIZE=512mb
export DIGITALOCEAN_PRIVATE_NETWORKING=true

export NO_WORKERS=$1

for (( i=0; i<=$NO_WORKERS; i++ ))
do
    echo "Creating node $i"
    docker-machine create --driver digitalocean \
                          --digitalocean-image  ubuntu-16-04-x64 \
                          --digitalocean-access-token $DIGITAL_OCEAN_TOKEN \
                          node-$i
done

# https://www.digitalocean.com/community/tutorials/how-to-configure-the-linux-firewall-for-docker-swarm-on-ubuntu-16-04
echo "Setting firewall rules for manager"
docker-machine ssh node-0 "ufw allow 22/tcp;ufw allow 2376/tcp;ufw allow 2377/tcp;ufw allow 7946/tcp;ufw allow 7946/udp;ufw allow 4789/udp;ufw reload;ufw --force enable;systemctl restart docker"

for (( i=1; i<=$NO_WORKERS; i++ ))
do
    echo "Setting firewall rules for client node-$i"
    docker-machine ssh node-$i "ufw allow 22/tcp;ufw allow 2376/tcp;ufw allow 7946/tcp;ufw allow 8080/tcp;ufw allow 7946/udp;ufw allow 4789/udp;ufw reload;ufw --force enable;systemctl restart docker"
done


export SWARM_MANAGER_IP=`docker-machine ip node-0`

echo "Making node-0 the manager"
docker-machine ssh node-0 "docker swarm init --advertise-addr $SWARM_MANAGER_IP" 
# >> /tmp/jointoken.txt
# This is a bit dirty but the following line returns a different token, which 
# does not work
# remote_cmd=`cat /tmp/jointoken.txt | sed "3q;d" | xargs`

# Got that from here: https://stackoverflow.com/a/46841126
# get manager and worker tokens
export MANAGER_TOKEN=`docker-machine ssh node-0 "docker swarm join-token worker -q"`
export REMOTE_CMD="docker swarm join --token $MANAGER_TOKEN $SWARM_MANAGER_IP:2377"

for (( i=1; i<=$NO_WORKERS; i++ ))
do
    echo "Making node-$i join the swarm as worker"
    echo "Trying from node-$i: $REMOTE_CMD"
    docker-machine ssh node-$i "$REMOTE_CMD"
done

# export WORKER_TOKEN=`docker-machine ssh node-1 "docker swarm join-token worker -q"`

echo "Starting a service via manager node-0 on the cluster..."
docker-machine ssh node-0 "docker service create -p 8080:8080 --name webserver helgecph/swarmserver"
echo "Starting the service to five instances..."
docker-machine ssh node-0 "docker service scale webserver=5"

echo "The services are running on the follwing nodes:"
docker-machine ssh node-0 "docker service ps webserver"

echo "Connect to either of the following addresses:"
for (( i=0; i<=$NO_WORKERS; i++ ))
do
    echo "http://`docker-machine ip node-$i`:8080/status"
done
echo "You should see a page served from different nodes."

echo "To remove a node and it's droplet run, e.g., docker-machine rm node-0"

#docker-machine create --driver digitalocean --digitalocean-image  ubuntu-16-04-x64 --digitalocean-access-token $DIGITAL_OCEAN_TOKEN node-0
