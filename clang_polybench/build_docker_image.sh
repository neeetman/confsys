#!/bin/bash
set -e

PROXY=""
BUILDSCRIPT_ARGS=""

function show_usage() {
  cat << EOF
Usage: build_docker_image.sh [options]

Available options:
  General:
    -h|--help			show this help message
    -p|--proxy <ip:port>	set http/https proxy=ip:port
  Git-specific:
    -b|--branch <id> 	    	set llvm version
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    -p|--proxy)
      shift
      PROXY="$1"
      shift
      ;;
    -b|--branch)
      shift
      LLVM_BRANCH="$1"
      shift
      ;;
    *)
      echo "Unknown atgument $1"
      exit 1
      ;;
  esac
done

if [ "$LLVM_BRANCH" != "" ]; then
  BUILDSCRIPT_ARGS="$BUILDSCRIPT_ARGS -b $LLVM_BRANCH"
fi

if [ "$PROXY" != "" ]; then
  BUILDSCRIPT_ARGS="$BUILDSCRIPT_ARGS -p $PROXY"
fi

BUILD_DIR=$(mktemp -d)
trap "rm -rf $BUILD_DIR" EXIT
echo "Using a temporary directory for the build: $BUILD_DIR"

cp Dockerfile "$BUILD_DIR/"
cp -r scripts "$BUILD_DIR/"

echo "Building clang-ubuntu:latest"

docker build -t clang-polybench:latest \
  --build-arg "buildscript_args=$BUILDSCRIPT_ARGS" \
  -f "$BUILD_DIR/Dockerfile" \
  "$BUILD_DIR"

echo "Done"
