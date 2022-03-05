GO ?= go

PWD ?= $(shell pwd)

DEVGRPCGO_PATH ?= $(PWD)/vendor/github.com/dohernandez/dev-grpc
DEVGRPC_SCRIPTS ?= $(DEVGRPCGO_PATH)/scripts

## Check/install protoc tool
protoc-cli:
	@bash $(DEVGRPC_SCRIPTS)/protoc-gen-cli.sh

.PHONY: protoc-cli
