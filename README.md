# An automatic Docker Swarm example with a dynamic webservice

This setup is based on the following tutorial:
https://www.digitalocean.com/community/tutorials/how-to-create-a-cluster-of-docker-containers-with-docker-swarm-and-digitalocean-on-ubuntu-16-04




## The webservice





```bash
$ docker-machine ssh node-0 "docker service ps webserver"
ID                  NAME                IMAGE                         NODE                DESIRED STATE       CURRENT STATE             ERROR                       PORTS
t3hydzqddr8p        webserver.1         helgecph/swarmserver:latest   node-0              Ready               Ready 4 seconds ago
z6vvs27oq79v         \_ webserver.1     helgecph/swarmserver:latest   node-0              Shutdown            Complete 2 minutes ago
z2g9veekah5o         \_ webserver.1     helgecph/swarmserver:latest   node-0              Shutdown            Failed 7 minutes ago      "task: non-zero exit (2)"
zedvzfy9s1eh         \_ webserver.1     helgecph/swarmserver:latest   node-1              Shutdown            Complete 8 minutes ago
z4bq3yqmovdm         \_ webserver.1     helgecph/swarmserver:latest   node-2              Shutdown            Complete 10 minutes ago
s9vs2r1fsusk        webserver.2         helgecph/swarmserver:latest   node-2              Running             Running 6 seconds ago
y9sc28i5q0e3         \_ webserver.2     helgecph/swarmserver:latest   node-0              Shutdown            Failed 29 seconds ago     "task: non-zero exit (2)"
z138m5fnvijw         \_ webserver.2     helgecph/swarmserver:latest   node-2              Shutdown            Complete 35 seconds ago
ywklc1gw7fw4         \_ webserver.2     helgecph/swarmserver:latest   node-0              Shutdown            Complete 3 minutes ago
ylq1hsjb6eg9         \_ webserver.2     helgecph/swarmserver:latest   node-2              Shutdown            Complete 18 minutes ago
r2fse86dkwsg        webserver.3         helgecph/swarmserver:latest   node-1              Running             Running 10 seconds ago
z4xyqtuerjd1         \_ webserver.3     helgecph/swarmserver:latest   node-1              Shutdown            Failed 2 minutes ago      "task: non-zero exit (2)"
z9bt248zz8sb         \_ webserver.3     helgecph/swarmserver:latest   node-0              Shutdown            Complete 11 minutes ago
z52et7t9ago4         \_ webserver.3     helgecph/swarmserver:latest   node-1              Shutdown            Complete 15 minutes ago
z7wnppulqooq         \_ webserver.3     helgecph/swarmserver:latest   node-2              Shutdown            Complete 17 minutes ago
2we0e2r82lih        webserver.4         helgecph/swarmserver:latest   node-1              Running             Running 1 second ago
xg1qmk677mrm         \_ webserver.4     helgecph/swarmserver:latest   node-1              Shutdown            Complete 2 minutes ago
zjhrsm398hbw         \_ webserver.4     helgecph/swarmserver:latest   node-0              Shutdown            Complete 10 minutes ago
yd1e5tolos22         \_ webserver.4     helgecph/swarmserver:latest   node-2              Shutdown            Complete 18 minutes ago
z3okaczr8znw         \_ webserver.4     helgecph/swarmserver:latest   node-0              Shutdown            Complete 18 minutes ago
sdk1ictcovvl        webserver.5         helgecph/swarmserver:latest   node-0              Running             Running 15 seconds ago
zfjdx2qd0bi9         \_ webserver.5     helgecph/swarmserver:latest   node-0              Shutdown            Failed 21 seconds ago     "task: non-zero exit (2)"
zq1ojiweikoz         \_ webserver.5     helgecph/swarmserver:latest   node-2              Shutdown            Complete 7 minutes ago
z5qhabgm7mcd         \_ webserver.5     helgecph/swarmserver:latest   node-0              Shutdown            Complete 8 minutes ago
zhts8iziut5j         \_ webserver.5     helgecph/swarmserver:latest   node-1              Shutdown            Complete 12 minutes ago
```