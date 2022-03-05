# Go development grpc helpers

This library provides scripts to automate common routines with modular `Makefile` for grpc.

## Installation

### Manual

#### As standalone

Add a test file (e.g. `dev_test.go`) to your module with unused import.

```go
package mymodule_test

import _ "github.com/dohernandez/dev-grpc" // Include development grpc helpers to project. 
```

Add `Makefile` to your module with includes standard targets.

```Makefile
#GOLANGCI_LINT_VERSION := "v1.44.2" # Optional configuration to pinpoint golangci-lint version.

# The head of Makefile determines location of dev-go to include standard targets.
GO ?= go
export GO111MODULE = on

ifneq "$(GOFLAGS)" ""
  $(info GOFLAGS: ${GOFLAGS})
endif

ifneq "$(wildcard ./vendor )" ""
  $(info Using vendor)
  modVendor =  -mod=vendor
  ifeq (,$(findstring -mod,$(GOFLAGS)))
      export GOFLAGS := ${GOFLAGS} ${modVendor}
  endif
  ifneq "$(wildcard ./vendor/github.com/dohernandez/dev-grpc)" ""
  	DEVGRPCGO_PATH := ./vendor/github.com/dohernandez/dev-grpc
  endif
endif

ifeq ($(DEVGRPCGO_PATH),)
	DEVGRPCGO_PATH := $(shell GO111MODULE=on $(GO) list ${modVendor} -f '{{.Dir}}' -m github.com/bool64/dev)
	ifeq ($(DEVGRPCGO_PATH),)
    	$(info Module github.com/dohernandez/dev-grpc not found, downloading.)
    	DEVGRPCGO_PATH := $(shell export GO111MODULE=on && $(GO) get github.com/dohernandez/dev-grpc && $(GO) list -f '{{.Dir}}' -m github.com/dohernandez/dev-grpc)
	endif
endif

-include $(DEVGRPCGO_PATH)/makefiles/protoc.mk

SRC_PROTO_PATH = ./path/to/proto/files
GO_PROTO_PATH = ./path/to/proto/gen/code

# Add your custom targets here.

## Generate code from proto file(s)
proto-gen: proto-gen-code
```

In case you want to generate the swagger doc too, use the option `proto-gen-code-swagger` instead of `proto-gen-code`. The variable `SWAGGER_PATH` should be overwritten with the path where to save the `swagger.json`

```Makefile
...

## Generate code from proto file(s)
proto-gen: proto-gen-code-swagger
```

#### In combination with github.com/bool64/dev

When is already in use  [github.com/bool64/dev](github.com/bool64/dev) for GitHub CI and Makefile features.

Add in the existing test file (e.g. `dev_test.go`) to your module with unused import. There is no need to define another file.

```go
package mymodule_test

import (
	_ "github.com/bool64/dev" // Include development helpers to project.
    _ "github.com/dohernandez/dev-grpc" // Include development grpc helpers to project. 
)
```

Add `Makefile` to your module with includes standard targets.

```Makefile
...

ifneq "$(wildcard ./vendor )" ""
  ...
  ifneq "$(wildcard ./vendor/github.com/bool64/dev)" ""
  	DEVGO_PATH := ./vendor/github.com/bool64/dev
  endif
  # adding github.com/dohernandez/dev-grpc
  ifneq "$(wildcard ./vendor/github.com/dohernandez/dev-grpc)" ""
  	DEVGRPCGO_PATH := ./vendor/github.com/dohernandez/dev-grpc
  endif
endif

...

# defining DEVGRPCGO_PATH
ifeq ($(DEVGRPCGO_PATH),)
	DEVGRPCGO_PATH := $(shell GO111MODULE=on $(GO) list ${modVendor} -f '{{.Dir}}' -m github.com/bool64/dev)
	ifeq ($(DEVGRPCGO_PATH),)
    	$(info Module github.com/dohernandez/dev-grpc not found, downloading.)
    	DEVGRPCGO_PATH := $(shell export GO111MODULE=on && $(GO) get github.com/dohernandez/dev-grpc && $(GO) list -f '{{.Dir}}' -m github.com/dohernandez/dev-grpc)
	endif
endif

...
-include $(DEVGO_PATH)/makefiles/reset-ci.mk

-include $(DEVGRPCGO_PATH)/makefiles/protoc.mk

# Add your custom targets here.

## Run tests
test: test-unit

## Generate code from proto file(s)
proto-gen: proto-gen-code
```