SHELL=/bin/bash
build=$(CURDIR)/build

build: clean
	@echo 'TODO replicate fs structure in build dir'
	@echo 'TODO skip anything marked as draft'
	@echo 'TODO insert last modified date into front matter'

clean:
	@if [ -d $(build) ]; then rm -r $(build); fi

push:
	@echo 'TODO publish to ipfs'
	@echo 'TODO pin CID on remote'
	@echo 'TODO sign CID and publish CID/sig somewhere'

run:
	@podman run -d --rm --name content -v $(CURDIR):/mnt/ docker.io/library/rakudo-star raku -e 'sleep 86400'

exec: clean
	@podman exec -ti -w /mnt content raku main.raku --src=src --dst=build
