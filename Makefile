.PHONY: build
build: clean
	vagrant up
	vagrant ssh -c "sudo /vagrant/builder-install.sh"

.PHONY: clean
clean:
	vagrant destroy -f | true
	rm -rf release
