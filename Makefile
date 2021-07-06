SHELL=/bin/bash
build=$(CURDIR)/build
ctr=content
run_cmd=podman run -d --rm --name content -v $(CURDIR):/mnt/ docker.io/library/rakudo-star raku -e 'sleep 86400'
install_cmd=podman exec -ti $(ctr) zef install FileSystem::Helpers

build: clean start-ctr
	@podman exec -ti -w /mnt $(ctr) raku main.raku --src=src --dst=build

start-ctr:
	@if [ -z "`podman ps | grep $(ctr)`" ]; then $(run_cmd); $(install_cmd); fi

stop-ctr:
	@if [ ! -z "`podman ps | grep $(ctr)`" ]; then podman stop $(ctr); fi

clean:
	@if [ -d $(build) ]; then rm -r $(build); fi

push:
	@echo 'TODO publish to ipfs'
	@echo 'TODO pin CID on remote'
	@echo 'TODO sign CID and publish CID/sig somewhere'
