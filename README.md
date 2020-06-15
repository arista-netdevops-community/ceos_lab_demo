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
```
