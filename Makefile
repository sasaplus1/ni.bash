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
	if type certutil >/dev/null 2>&1; \
	then \
	  certutil -hashfile shunit2.tar.gz SHA256 | awk 'NR==1 {sub(/:$$/, "", $$4); filename=$$4} NR==2 {hash=$$1} END {print hash "  " filename}' > shunit2-sha256sum.txt; \
	  diff shunit2-sha256sum.txt sha256sum.txt; \
	else \
	  shasum -ca 256 sha256sum.txt; \
	fi
	tar fxvz shunit2.tar.gz
	mv 'shunit2-$(commit)' shunit2

.PHONY: test
test: ## run tests
	bash ni_test.bash
