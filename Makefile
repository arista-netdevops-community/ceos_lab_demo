up:
	@echo "======================"
	@echo "create docker networks"
	@echo "======================"
	
	docker network create OOB 
	docker network create net1
	docker network create net2
	docker network create net3

	@echo "============================="
	@echo "create ceos docker containers"
	@echo "============================="

	docker create --name=ceos1 --privileged -v $(PWD)/startup-config/ebgp/ceos1:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6031:6030 -p 2001:22/tcp -i -t ceosimage:4.23.3M /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker
	docker create --name=ceos2 --privileged -v $(PWD)/startup-config/ebgp/ceos2:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6032:6030 -p 2002:22/tcp -i -t ceosimage:4.23.3M /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker
	docker create --name=ceos3 --privileged -v $(PWD)/startup-config/ebgp/ceos3:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6033:6030 -p 2003:22/tcp -i -t ceosimage:4.23.3M /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker

	@echo "================================================="
	@echo "connect ceos docker containers to docker networks"
	@echo "================================================="

	docker network connect OOB ceos1
	docker network connect net1 ceos1
	docker network connect net3 ceos1
	
	docker network connect OOB ceos2
	docker network connect net1 ceos2
	docker network connect net2 ceos2
	
	docker network connect OOB ceos3
	docker network connect net2 ceos3
	docker network connect net3 ceos3

	@echo "============================="
	@echo "start ceos docker containers"
	@echo "============================="

	docker start ceos1 ceos2 ceos3 
	
	@echo "===================================="
	@echo "wait for ceos containers to be ready"
	@echo "===================================="
	
	sleep 120s
	
down: 
	@echo "========================================================================"
	@echo "stop docker containers, remove docker containers, remove docker networks"
	@echo "========================================================================"
	
	docker stop ceos1 ceos2 ceos3

	docker rm ceos1 ceos2 ceos3

	docker network rm OOB net1 net2 net3

stop: 
	@echo "======================"
	@echo "stop docker containers"
	@echo "======================"
	
	docker stop ceos1 ceos2 ceos3

start: 
	@echo "============================"
	@echo "start ceos docker containers"
	@echo "============================"
	
	docker start ceos1 ceos2 ceos3

	@echo "===================================="
	@echo "wait for ceos containers to be ready"
	@echo "===================================="
	
	sleep 120s
	
restart: stop start

ceos1-cli:
	@echo "=========================================="
	@echo "start a cli session in the ceos1 container"
	@echo "=========================================="
	
	docker exec -i -t ceos1 Cli

ceos2-cli:
	@echo "=========================================="
	@echo "start a cli session in the ceos2 container"
	@echo "=========================================="
	
	docker exec -i -t ceos2 Cli

ceos3-cli:
	@echo "=========================================="
	@echo "start a cli session in the ceos3 container"
	@echo "=========================================="
	
	docker exec -i -t ceos3 Cli
