# Current directory name
OS_NAME = $(notdir $(shell pwd))

OUTPUT_DIR = ./output

.PHONY: build
build:
	mkdir -p $(OUTPUT_DIR)
	vagrant up
	vagrant ssh -c "sudo /home/vagrant/scripts/build-liveos.sh"

.PHONY: clean
clean:
	vagrant destroy -f | true
	rm -rf $(OUTPUT_DIR) ubuntu-xenial-*.log

.PHONY: rebuild
rebuild: clean build
