.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

root := $(makefile_dir)

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: install
install: commit := 100ffe4dda539ebbe4ae9867132f08eeee8e80cb
install: ## install dependencies
	curl -fsSL -o shunit2.tar.gz 'https://github.com/kward/shunit2/archive/$(commit).tar.gz'
	if type sha256sum >/dev/null 2>&1; \
	then \
	  sha256sum -c sha256sum.txt; \
	elif type shasum >/dev/null 2>&1; \
	then \
	  shasum -ca 256 sha256sum.txt; \
	else \
	  certutil -hashfile shunit2.tar.gz SHA256 | awk 'NR==2 {hash=$$1} END {print hash "  shunit2.tar.gz"}' > shunit2-sha256sum.txt; \
	  diff shunit2-sha256sum.txt sha256sum.txt; \
	fi
	tar fxvz shunit2.tar.gz
	mv 'shunit2-$(commit)' shunit2

.PHONY: test
test: ## run tests
	bash ni_test.bash
