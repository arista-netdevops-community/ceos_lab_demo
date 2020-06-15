Download a cEOS image (cEOS-lab-4.23.3M.tar.xz) from www.arista.com  

Create a docker image: 
```
docker import cEOS-lab-4.23.3M.tar.xz ceosimage:4.23.3M
```
```
docker images | grep ceosimage
ceosimage                       4.23.3M             6cb51b23a934        2 days ago          1.74GB
```
Create the lab (3 ceos-lab containers connected in a triangle topology configured with EBGP): 
```
make up  
======================
create docker networks
======================
docker network create OOB 
50de568c16f3166fa5f51d8ad0074c68b7c02b453dc6bb9d70f1f58ae907a2cf
docker network create net1
619169b307bc03126e16e0717ab4f10c41a45597afec6ceb3e4f4a3c43967447
docker network create net2
dc0106d09f96fe8161db5d16d65c34d43542abdcbb01da471c666deb21bc585c
docker network create net3
389c581712e5d2123b01824193b8e748b7cc4591683839ccc1c93ce3bf6780be
=============================
create ceos docker containers
=============================
docker create --name=ceos1 --privileged -v /Users/ksator/Documents/arista/docker/demo2/startup-config/ebgp/ceos1:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6031:6030 -p 2001:22/tcp -i -t ceosimage:4.23.3M /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker
6d2ae1bf66ed045bcc064e6b1f2b8f7743db0861b866657ec8ead4e439785229
docker create --name=ceos2 --privileged -v /Users/ksator/Documents/arista/docker/demo2/startup-config/ebgp/ceos2:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6032:6030 -p 2002:22/tcp -i -t ceosimage:4.23.3M /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker
65b52733be0e2f0fe89f2c41a202ef191ffe7b7d46a5a0d80c2d3c1a4c986b61
docker create --name=ceos3 --privileged -v /Users/ksator/Documents/arista/docker/demo2/startup-config/ebgp/ceos3:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6033:6030 -p 2003:22/tcp -i -t ceosimage:4.23.3M /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker
2b516ac3c065f245bed0275daedeca6db2deacd15af5081b0d9db37ffda1b349
=================================================
connect ceos docker containers to docker networks
=================================================
docker network connect OOB ceos1
docker network connect net1 ceos1
docker network connect net3 ceos1
docker network connect OOB ceos2
docker network connect net1 ceos2
docker network connect net2 ceos2
docker network connect OOB ceos3
docker network connect net2 ceos3
docker network connect net3 ceos3
=============================
start ceos docker containers
=============================
docker start ceos1 ceos2 ceos3 
ceos1
ceos2
ceos3
====================================
wait for ceos containers to be ready
====================================
sleep 120s
```
Verify:  
```
docker ps                     
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                          NAMES
2b516ac3c065        ceosimage:4.23.3M   "/sbin/init systemd.…"   2 minutes ago       Up 2 minutes        0.0.0.0:2003->22/tcp, 0.0.0.0:6033->6030/tcp   ceos3
65b52733be0e        ceosimage:4.23.3M   "/sbin/init systemd.…"   2 minutes ago       Up 2 minutes        0.0.0.0:2002->22/tcp, 0.0.0.0:6032->6030/tcp   ceos2
6d2ae1bf66ed        ceosimage:4.23.3M   "/sbin/init systemd.…"   2 minutes ago       Up 2 minutes        0.0.0.0:2001->22/tcp, 0.0.0.0:6031->6030/tcp   ceos1
```
```
make ceos1-cli 
==========================================
start a cli session in the ceos1 container
==========================================
docker exec -i -t ceos1 Cli
ceos1>en
ceos1#show ip bgp summary 
BGP summary information for VRF default
Router identifier 1.1.1.1, local AS number 65001
Neighbor Status Codes: m - Under maintenance
  Neighbor         V  AS           MsgRcvd   MsgSent  InQ OutQ  Up/Down State   PfxRcd PfxAcc
  10.0.0.1         4  65002              7         7    0    0 00:01:54 Estab   4      4
  10.0.0.4         4  65003              9         9    0    0 00:01:54 Estab   4      4
ceos1#exit
```
Destroy the lab: 
```
make down
========================================================================
stop docker containers, remove docker containers, remove docker networks
========================================================================
docker stop ceos1 ceos2 ceos3
ceos1
ceos2
ceos3
docker rm ceos1 ceos2 ceos3
ceos1
ceos2
ceos3
docker network rm OOB net1 net2 net3
OOB
net1
net2
net3
```
