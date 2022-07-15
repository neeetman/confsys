#!/usr/bin/env bash
set -e 

# POLYBENCH_DIR=""
BENCHMARK=""
PASSES=""
USE_PAPI=0

function show_usage() {
  cat << EOF
Usage: compile.sh [options]

Availbale options:
    -h|--help      Show this help message
    -b <benchmark> Select target benchmark to compile
    -p <passes>    Run passes in the <passes>, a comma separated string
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
    -p)
      shift
      PASSES="$1"
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

FORMAT_PASSES=""
if [ "$PASSES" != "" ]; then
  FORMAT_PASSES=" -"${PASSES//,/ -}
fi

UTILS_DIR="$POLYBENCH_DIR/utilities"

COMPILE_DIR=$(mktemp -d)
trap "rm -rf $COMPILE_DIR" exit
# echo "Using a tempory directory for compile: $COMPILE_DIR"

pushd $COMPILE_DIR > /dev/null

if [ $USE_PAPI == 1 ]; then
  gcc $UTILS_DIR/polybench.c $BENCHMARK_DIR/${BENCHMARK}.c  -o ${BENCHMARK}.exe \
    -O1 $FORMAT_PASSES \
    -I${PAPI_DIR}/include -I${UTILS_DIR} -L${PAPI_DIR}/lib -lpapi -DPOLYBENCH_PAPI
else
  gcc $UTILS_DIR/polybench.c $BENCHMARK_DIR/${BENCHMARK}.c -o ${BENCHMARK}.exe \
    -O1 $FORMAT_PASSES \
    -I${UTILS_DIR} -DPOLYBENCH_TIME
fi

./${BENCHMARK}.exe
  
popd > /dev/null