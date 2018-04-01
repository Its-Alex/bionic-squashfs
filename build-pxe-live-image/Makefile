.PHONY: build
build:
	vagrant up builder
	vagrant ssh builder -c "cd /vagrant/ && sudo ./docker_to_pxe/docker_to_pxe.py --build --generate docker-build/Dockerfile"
	rm docker-build/tmp -rf
	vagrant halt builder

.PHONY: clean
clean:
	vagrant destroy -f | true
	rm -rf release .vagrant
