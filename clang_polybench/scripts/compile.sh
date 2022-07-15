#!/usr/bin/env bash
set -e 

# POLYBENCH_DIR=""
BENCHMARK=""
STANDARD_PASSES=""
POLLY_PASSES=""
USE_PAPI=0

function show_usage() {
  cat << EOF
Usage: compile.sh [options]

Availbale options:
    -h|--help      Show this help message
    -b <benchmark> Select target benchmark to compile
    -sp <passes>   Run standard passes in the <passes>, a comma separated string
    -pp <passes>   Run polly passes in the <passes>, a comma separated string
    --papi         Enable PAPI

Required options: -b
All options after '--' are passed to clang(polybench).
EOF
}


while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    -b)
      shift
      BENCHMARK="$1"
      shift
      ;;
    -sp)
      shift
      STANDARD_PASSES="$1"
      shift
      ;;
    -pp)
      shift
      POLLY_PASSES="$1"
      shift
      ;;
    --papi)
      USE_PAPI=1
      shift
      ;;
    *)
      echo "Unknow argument $1"
      exit 1
      ;;
  esac
done

if [ "$POLYBENCH_DIR" == "" ]; then
  echo "Required argument missing: -i"
  exit 1
fi

if [ "$BENCHMARK" == "" ]; then
  echo "Required argument missing: -b"
  exit 1
fi     

BENCHMARK_DIR=$(find $POLYBENCH_DIR -name $BENCHMARK)
if [ "$BENCHMARK_DIR" == "" ]; then
  echo "No benchmark named '$BENCHMARK' were found"
  exit 1
fi

UTILS_DIR="$POLYBENCH_DIR/utilities"

COMPILE_DIR=$(mktemp -d)
trap "rm -rf $COMPILE_DIR" exit
# echo "Using a tempory directory for compile: $COMPILE_DIR"

pushd $COMPILE_DIR > /dev/null

if [ $USE_PAPI == 1 ]; then
  clang $UTILS_DIR/polybench.c $BENCHMARK_DIR/${BENCHMARK}.c \
    -c -emit-llvm -O0 -Xclang -disable-O0-optnone \
    -I/${PAPI_DIR}/include -I${UTILS_DIR} -DPOLYBENCH_PAPI
else
  clang $UTILS_DIR/polybench.c $BENCHMARK_DIR/${BENCHMARK}.c \
    -c -emit-llvm -O0 -Xclang -disable-O0-optnone \
    -I${UTILS_DIR} -DPOLYBENCH_TIME
fi

llvm-link polybench.bc ${BENCHMARK}.bc -o ${BENCHMARK}_linked.bc && \
opt ${BENCHMARK}_linked.bc -o ${BENCHMARK}_optted.ll -passes="${STANDARD_PASSES}" -S

if [ "$POLLY_PASSES" != "" ]; then
  opt ${BENCHMARK}_optted.ll -o ${BENCHMARK}_before_polly.ll -polly-canonicalize -S && \
  opt ${BENCHMARK}_before_polly.ll -o ${BENCHMARK}_optted.ll -passes="${POLLY_PASSES}" -S
fi

llc ${BENCHMARK}_optted.ll -o ${BENCHMARK}.s -relocation-model=pic && \
gcc ${BENCHMARK}.s -lpapi -L/${PAPI_DIR}/lib -o ${BENCHMARK}.exe && \
./${BENCHMARK}.exe
  
popd > /dev/null