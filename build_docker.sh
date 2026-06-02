#!/bin/bash
set -e

get_platform() {
    case "${1:-$(uname -m)}" in
        "x86_64" | "amd64")  echo "linux/amd64" ;;
        "aarch64" | "arm64") echo "linux/arm64" ;;
        *) echo "!! 不支持的架构: $1" >&2 && exit 1 ;;
    esac
}

TARGET_PLATFORM=$(get_platform "$1")
BUILDER_PLATFORM=$(get_platform "$(uname -m)")
ARCH_TAG=${TARGET_PLATFORM#linux/}

echo ":: 本机架构: $BUILDER_PLATFORM"
echo ":: 目标架构: $TARGET_PLATFORM"

if [ "$TARGET_PLATFORM" = "$BUILDER_PLATFORM" ]; then
    echo " -> 原生构建"
    echo " -> Build"
    docker buildx build --platform "$TARGET_PLATFORM" -t "telebox:latest" --load .
else
    echo " -> 交叉构建"
    export DOCKER_BUILDKIT=1
    if ! find "/proc/sys/fs/binfmt_misc" -name "qemu-*" | grep -q qemu; then
        echo " -> binfmt install"
        docker run --privileged --rm tonistiigi/binfmt --install all
    fi
    echo " -> Build"
    docker buildx build --platform "$TARGET_PLATFORM" -t "telebox:$ARCH_TAG" --load .
fi
