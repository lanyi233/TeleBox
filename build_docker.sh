#!/bin/bash
set -e

get_platform() {
    case "${1:-$(uname -m)}" in
        "x86_64" | "amd64")  echo "linux/amd64" ;;
        "aarch64" | "arm64") echo "linux/arm64" ;;
        *) echo "❌ 不支持的架构: $1" && exit 1 ;;
    esac
}

TARGET_PLATFORM=$(get_platform "$1")
BUILDER_PLATFORM=$(get_platform "$(uname -m)")

echo ":: 本机架构: $BUILDER_PLATFORM"
echo ":: 目标架构: $TARGET_PLATFORM"

if [ "$TARGET_PLATFORM" = "$BUILDER_PLATFORM" ]; then
    echo " -> 原生构建"
    docker build --platform "$TARGET_PLATFORM" -t "telebox:latest" .
else
    echo " -> 交叉构建"
    export DOCKER_BUILDKIT=1
    docker buildx build --platform "$TARGET_PLATFORM" -t "telebox:$TARGET_PLATFORM" --load . || {
      echo "!! 缺少虚拟化支持, 运行命令以注册"
      echo "docker run --privileged --rm tonistiigi/binfmt --install all"
      echo "or"
      echo "docker run --rm --privileged multiarch/qemu-user-static --reset -p yes"
      exit 1
    }
fi
