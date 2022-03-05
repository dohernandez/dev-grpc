# Go development grpc helpers

This library provides scripts to automate common routines with modular `Makefile` for grpc.

## Installation

### Manual

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

# Add your custom targets here.

```