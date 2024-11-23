
# The head of Makefile determines location of dev-go to include standard targets.
GO ?= go
export GO111MODULE = on

# Override in Makefile the working directory.
PWD ?= $(shell pwd)

DEVGRPCGO_PATH = .

MAKEFILES_PATH ?= $(PWD)/makefiles

SRC_PROTO_PATH = ./testdata/proto
GO_PROTO_PATH = ./testdata
SWAGGER_PATH = ./testdata

-include $(MAKEFILES_PATH)/help.mk
-include $(MAKEFILES_PATH)/protoc.mk
