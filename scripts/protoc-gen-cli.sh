#!/usr/bin/env bash

[ -z "$GO" ] && GO=go

# Override in Makefile to control proto version.
[ -z "$PROTOBUF_VERSION" ] && PROTOBUF_VERSION="28.3"
[ -z "$PROTOC_GEN_GO_VERSION" ] && PROTOC_GEN_GO_VERSION="v1.35.2"
[ -z "$PROTOC_GEN_GO_GRPC_VERSION" ] && PROTOC_GEN_GO_GRPC_VERSION="1.5.1"
[ -z "$PROTOC_GEN_GRPC_GATEWAY_VERSION" ] && PROTOC_GEN_GRPC_GATEWAY_VERSION="v2.24.0"
[ -z "$PROTOC_GEN_VALIDATE_VERSION" ] && PROTOC_GEN_VALIDATE_VERSION="v1.1.0"

# detecting GOPATH and removing trailing "/" if any
GOPATH="$(go env GOPATH)"
GOPATH=${GOPATH%/}

# Clearing GOFLAGS temporarily to avoid cannot query module due to -mod=vendor issues.
GOFLAGS_SET=${GOFLAGS}
export GOFLAGS=""

# adding GOBIN to PATH
[[ ":$PATH:" != *"$GOPATH/bin"* ]] && PATH=$PATH:"$GOPATH"/bin

# checking if protoc-gen-go is available
install_protoc () {
  case "$2" in
      Darwin*)
        {
          PLATFORM="osx"
          HARDWARE=$(uname -m)

          if [ "$HARDWARE" == "arm64" ]; then \
            HARDWARE="aarch_64"
          fi
        };;
      Linux*)
        {
          PLATFORM=$(echo "$2" | tr '[:upper:]' '[:lower:]')
          HARDWARE=$(uname -m)

          if [ "$HARDWARE" == "aarch64" ]; then \
            HARDWARE="aarch_64"
          fi
        };;
  esac

  FILENAME=protoc-"$PROTOBUF_VERSION"-"$PLATFORM"-"$HARDWARE".zip

  mkdir -p /tmp/protoc-"$1"

  curl -o /tmp/"$FILENAME" -sL https://github.com/protocolbuffers/protobuf/releases/download/v"$1"/"$FILENAME" \
        && unzip -o /tmp/"$FILENAME" -d /tmp/protoc-"$1"

  if [ -d /usr/local/protobuf/"$1" ]
  then
	  echo ">> removing existing directory"
	  sudo rm -r /usr/local/protobuf/"$1"
  fi

  sudo mkdir -p /usr/local/protobuf/"$1" \
      && sudo mv /tmp/protoc-"$1"/* /usr/local/protobuf/"$1"/ \
      && sudo ln -s /usr/local/protobuf/"$1"/bin/protoc /usr/local/bin/protoc
}

osType="$(uname -s)"

case "${osType}" in
    Darwin*)
      {
        # checking if protobuf is installed
        if brew ls --versions protobuf > /dev/null; then
          echo ">> uninstall protobuf via brew manually, run the command... "; \
          echo ">> brew uninstall protobuf "; \
          exit 1
        fi
      };;
    Linux*)
      {
        # checking if protobuf is installed
        if dpkg -l | grep protobuf-compiler > /dev/null; then
          echo ">> uninstall protobuf-compiler via apt-get manually, run the command... "; \
          echo ">> apt-get remove -y protobuf-compiler "; \
          exit 1
        fi

        # checking if unzip is installed
        if ! dpkg -l | grep unzip > /dev/null; then
          echo ">> installing zip via apt-get... "; \
          echo ">> apt-get update && apt-get install -y zip "; \
          exit 1
        fi
      };;
    *)
      {
        echo "Unsupported OS, exiting"
        exit 1
      } ;;
esac

# checking if protoc is available and it is the version specify
if ! command -v protoc > /dev/null; then \
    echo ">> Installing protoc v$PROTOBUF_VERSION..."; \
    install_protoc "$PROTOBUF_VERSION" "$osType"
else
  VERSION_INSTALLED="$(protoc --version | cut -d' ' -f2)"
  if [ "${VERSION_INSTALLED}" != "${PROTOBUF_VERSION}" ]; then \
    echo ">> Updating protoc form v"${VERSION_INSTALLED}" to v$PROTOBUF_VERSION..."; \
    install_protoc "$PROTOBUF_VERSION" "$osType"
  fi
fi

# checking if protoc-gen-go is available
if ! command -v protoc-gen-go > /dev/null; then \
    echo ">> Installing protoc-gen-go $PROTOC_GEN_GO_VERSION... "; \
    $GO install google.golang.org/protobuf/cmd/protoc-gen-go@"$PROTOC_GEN_GO_VERSION";
else
  VERSION_INSTALLED="$(protoc-gen-go --version | cut -d' ' -f2)"
  if [ "${VERSION_INSTALLED}" != "${PROTOC_GEN_GO_VERSION}" ]; then \
    echo ">> Updating protoc-gen-go form "${VERSION_INSTALLED}" to $PROTOC_GEN_GO_VERSION..."; \
    $GO install google.golang.org/protobuf/cmd/protoc-gen-go@"$PROTOC_GEN_GO_VERSION";
  fi
fi

# checking if protoc-gen-go-grpc is available
if ! command -v protoc-gen-go-grpc > /dev/null ; then \
    echo ">> Installing protoc-gen-go-grpc v${PROTOC_GEN_GO_GRPC_VERSION}... "; \
    $GO install google.golang.org/grpc/cmd/protoc-gen-go-grpc@"v$PROTOC_GEN_GO_GRPC_VERSION";
else
  VERSION_INSTALLED="$(protoc-gen-go-grpc --version | cut -d' ' -f2)"
  if [ "${VERSION_INSTALLED}" != "${PROTOC_GEN_GO_GRPC_VERSION}" ]; then \
    echo ">> Updating protoc-gen-go-grpc form v"${VERSION_INSTALLED}" to v$PROTOC_GEN_GO_GRPC_VERSION..."; \
    $GO install google.golang.org/grpc/cmd/protoc-gen-go-grpc@"v$PROTOC_GEN_GO_GRPC_VERSION";
  fi
fi

if ! command -v protoc-gen-grpc-gateway > /dev/null; then \
    echo ">> Installing protoc-gen-grpc-gateway $PROTOC_GEN_GRPC_GATEWAY_VERSION... "; \
    $GO install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@"$PROTOC_GEN_GRPC_GATEWAY_VERSION";
else
  VERSION_INSTALLED="$(protoc-gen-grpc-gateway --version | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+')"
  if [ "${VERSION_INSTALLED}" != "${PROTOC_GEN_GRPC_GATEWAY_VERSION}" ]; then \
    echo ">> Updating protoc-gen-grpc-gateway form "${VERSION_INSTALLED}" to $PROTOC_GEN_GRPC_GATEWAY_VERSION..."; \
    $GO install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@"$PROTOC_GEN_GRPC_GATEWAY_VERSION";
  fi
fi

# checking if protoc-gen-openapiv2 is available
if ! command -v protoc-gen-openapiv2 > /dev/null ; then \
    echo ">> installing protoc-gen-openapiv2... "; \
    $GO install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2;
fi

# Restoring GOFLAGS
export GOFLAGS=${GOFLAGS_SET}
