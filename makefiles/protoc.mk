GO ?= go

PWD ?= $(shell pwd)

DEVGRPCGO_PATH ?= $(PWD)/vendor/github.com/dohernandez/dev-grpc
DEVGRPC_SCRIPTS ?= $(DEVGRPCGO_PATH)/scripts

ifeq ($(strip $(SRC_PROTO_PATH)),)
	$(error SRC_PROTO_PATH is not set)
endif

ifeq ($(strip $(GO_PROTO_PATH)),)
	$(error GO_PROTO_PATH is not set)
endif

# Override in app Makefile to control build target, example SWAGGER_PATH=./resources/swagger
SWAGGER_PATH ?= .

## Check/install protoc tool
protoc-cli:
	@bash $(DEVGRPC_SCRIPTS)/protoc-gen-cli.sh

## Generate code from proto file(s)
proto-gen-code: protoc-cli
	protoc --proto_path=$(SRC_PROTO_PATH) $(SRC_PROTO_PATH)/*.proto  --go_opt=paths=source_relative --go_out=:$(GO_PROTO_PATH)

## Generate code from proto file(s) and swagger doc
proto-gen-code-swagger: protoc-cli
	protoc --proto_path=$(SRC_PROTO_PATH) $(SRC_PROTO_PATH)/*.proto  --go_opt=paths=source_relative --go_out=:$(GO_PROTO_PATH) --go-grpc_opt=paths=source_relative --go-grpc_out=:$(GO_PROTO_PATH) --grpc-gateway_opt=paths=source_relative --grpc-gateway_out=:$(GO_PROTO_PATH) --openapiv2_out=:$(SWAGGER_PATH)


.PHONY: protoc-cli proto-gen-code proto-gen-code-swagger
