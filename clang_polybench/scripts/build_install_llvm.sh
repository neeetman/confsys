#!/usr/bin/env bash

CLANG_BUILD_DIR=/tmp/clang-build
CHECKOUT_DIR="$CLANG_BUILD_DIR/src"

LLVM_BRANCH=""
PROXY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--banch)
      shift
      LLVM_BRANCH="$1"
      shift
      ;;
    -p|--proxy)
      shift
      PROXY="$1"
      shift
      ;;
  esac
done

echo "Checking out sources from git"
mkdir -p "$CHECKOUT_DIR"

if [ "$PROXY" != "" ]; then
  git config --global http.proxy http://$PROXY
  git config --global https.proxy http://$PROXY
fi

echo "Checking out https://github.com/llvm/llvm-project.git to $CHECKOUT_DIR"
if [ "$LLVM_BRANCH" != "" ]; then
  git clone -b "$LLVM_BRANCH" "https://github.com/llvm/llvm-project.git" "$CHECKOUT_DIR" 
else
  git clone "https://github.com/llvm/llvm-project.git" "$CHECKOUT_DIR" 
fi	

echo "Done"


mkdir -p "$CLANG_BUILD_DIR/build"
pushd "$CLANG_BUILD_DIR/build"

CLANG_INSTALL_DIR=/usr/local
mkdir -p "CLANG_INSTALL_DIR"

echo "Runing build"
cmake -GNinja \
  -DCMAKE_INSTALL_PREFIX="$CLANG_INSTALL_DIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_PROJECTS="clang;polly" \
  "$CLANG_BUILD_DIR/src/llvm"
ninja && ninja install

popd

rm -rf "$CLANG_BUILD_DIR"

echo "Done"