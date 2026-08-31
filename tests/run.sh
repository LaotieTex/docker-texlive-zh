#!/usr/bin/env bash
# 宿主机入口：把测试文件挂进镜像，在容器内执行 verify.sh。
#
# 用法:
#   ./tests/run.sh                                   # 默认验证 laotie255/texlive-zh:latest
#   IMAGE=laotie255/texlive-zh:full-latest ./tests/run.sh
#
# 说明：测试在临时目录中进行，不会污染仓库（产物用完即删）。
set -uo pipefail

IMAGE="${IMAGE:-laotie255/texlive-zh:latest}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WORK="$(mktemp -d)"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

cp "$HERE"/*.tex "$HERE"/verify.sh "$WORK"/

echo "镜像: $IMAGE"
echo

docker run --rm -v "$WORK":/workdir -w /workdir "$IMAGE" sh verify.sh
rc=$?

echo
if [ "$rc" -eq 0 ]; then
  echo "结果: 全部通过"
else
  echo "结果: 存在失败项（详见上方 [FAIL] 行）"
fi
exit "$rc"
