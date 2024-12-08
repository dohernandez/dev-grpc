// Package dev_grpc contains reusable development grpc helpers.
package dev_grpc

// These imports' workaround `go mod vendor` prune.
//
// See https://github.com/golang/go/issues/26366.
import (
	_ "github.com/bufbuild/protovalidate-go"
	_ "github.com/dohernandez/dev-grpc/makefiles"
	_ "github.com/dohernandez/dev-grpc/scripts"
)
