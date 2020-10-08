#!/bin/bash
set -eu
set -o pipefail

BAZEL="${BAZEL:-bazelisk}"
if ! command -v "$BAZEL" >/dev/null 2>&1; then
  BAZEL=bazel
fi

XPU="${XPU:-gpu}"
DEF=''
case "$XPU" in
  cpu)   DEF='--define MEDIAPIPE_DISABLE_GPU=1' ;;
  gpu)   DEF='--copt -DMESA_EGL_NO_X11_HEADERS --copt -DEGL_NO_X11' ;;
  *)   echo "XPU = gpu | cpu, not: $XPU" && exit 2 ;;
esac

DEMO="${DEMO:-boxes}"
case "$DEMO" in
  boxes) ;;
  *)   echo "DEMO = boxes, not: $DEMO" && exit 2 ;;
esac

echo Creating CPU pipes from GPU version...
pwd="$(dirname "$0")"
for gpu in "$pwd"/nvr/graphs/*_gpu.pbtxt; do
  # Turns IMAGE_GPU:... into IMAGE:...
  # as well as use_gpu: true into use_gpu: false
  cat   "$gpu" |
    sed   's%_GPU%%g;s%use_gpu: true%use_gpu: false%g' \
      >"${gpu%%_gpu.pbtxt}"_cpu.pbtxt
done

set -x
# GLOG_v=2 \
GLOG_logtostderr=1 \
  "$BAZEL" run \
  --run_under="cd $PWD && " \
  --platform_suffix="-$XPU" \
  -c     opt $DEF \
  nvr:"${DEMO}_$XPU"     -- "$@"
