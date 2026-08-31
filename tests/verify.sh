#!/bin/sh
# 在镜像内部执行，验证 texlive-zh 的构建结果。
# 由 run.sh 挂载调用：sh /workdir/verify.sh
# 重点：PlantUML 在 jar 缺失或引擎不匹配时不会报错中止，只会输出占位框，
#       因此这里除了"编译成功"，还额外检查降级提示与真实产物。

PASS=0
FAIL=0

ok()  { printf '  [PASS] %s\n' "$1"; PASS=$((PASS + 1)); }
bad() { printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL + 1)); }

has_cmd() {
  if command -v "$1" >/dev/null 2>&1; then ok "命令存在: $1"; else bad "命令缺失: $1"; fi
}
has_pkg() {
  if kpsewhich "$1" >/dev/null 2>&1; then ok "宏包存在: $1"; else bad "宏包缺失: $1"; fi
}

echo "===== texlive-zh 构建结果验证 ====="
echo

echo "--- 1. 外部引擎 ---"
has_cmd java
has_cmd plantuml
has_cmd dot
has_cmd node
has_cmd npm
has_cmd mmdc
has_cmd chromium
# 中文相关：基础镜像是日文 TeX Live，xelatex 需由 tlmgr 补装
has_cmd xelatex
has_cmd lualatex

echo
echo "--- 2. 环境变量 ---"
if [ -n "${PLANTUML_JAR:-}" ]; then ok "PLANTUML_JAR=$PLANTUML_JAR"; else bad "PLANTUML_JAR 未设置"; fi
if [ -f "${PLANTUML_JAR:-}" ]; then ok "plantuml.jar 文件存在"; else bad "plantuml.jar 不存在: ${PLANTUML_JAR:-<unset>}"; fi
if [ -n "${PUPPETEER_EXECUTABLE_PATH:-}" ]; then ok "PUPPETEER_EXECUTABLE_PATH=$PUPPETEER_EXECUTABLE_PATH"; else bad "PUPPETEER_EXECUTABLE_PATH 未设置"; fi
if [ -n "${PUPPETEER_CONFIG_FILE:-}" ]; then ok "PUPPETEER_CONFIG_FILE=$PUPPETEER_CONFIG_FILE"; else bad "PUPPETEER_CONFIG_FILE 未设置"; fi

echo
echo "--- 3. 宏包 ---"
has_pkg plantuml.sty
has_pkg mermaid.sty
has_pkg ltmermaid.sty
# 镜像原有宏包（回归检查）
has_pkg pstricks.sty
has_pkg calligra.sty
# 中文宏包（基础镜像不自带，需 tlmgr 补装）
has_pkg ctexart.cls
has_pkg ctex.sty
if kpsewhich gbt7714-2005-numeric.bst >/dev/null 2>&1 \
   || kpsewhich gbt7714-2015-numeric.bst >/dev/null 2>&1 \
   || kpsewhich gbt7714-numerical.bst >/dev/null 2>&1; then
  ok "宏包存在: gbt7714 (bst)"
else
  bad "宏包缺失: gbt7714 (bst)"
fi

echo
echo "--- 4. 引擎直测（绕开 LaTeX，隔离定位问题） ---"
tmp="$(mktemp -d)"
printf '@startuml\nAlice -> Bob: test\n@enduml\n' > "$tmp/t.puml"
if plantuml -tpdf -o "$tmp" "$tmp/t.puml" >/dev/null 2>&1 && ls "$tmp"/t.pdf >/dev/null 2>&1; then
  ok "plantuml CLI 直接渲染成功"
else
  bad "plantuml CLI 直接渲染失败"
fi

# 用 svg 输出直测（mermaid-cli 最稳的输出格式），验证 chromium + mmdc 链路本身可用；
# PDF 路径由下方 LaTeX 层的 test-mermaid.tex 覆盖。
printf 'flowchart LR\n A-->B\n' > "$tmp/t.mmd"
if mmdc -i "$tmp/t.mmd" -o "$tmp/m.svg" >/dev/null 2>&1 && [ -s "$tmp/m.svg" ]; then
  ok "mmdc (Mermaid CLI) 直接渲染成功"
else
  bad "mmdc (Mermaid CLI) 直接渲染失败"
fi
rm -rf "$tmp"

echo
echo "--- 5. 编译与出图 ---"

# 5.1 中文（xelatex，无需 shell-escape）
if xelatex -interaction=nonstopmode -halt-on-error test-cjk.tex >/dev/null 2>&1; then
  ok "编译成功: test-cjk.tex (xelatex)"
else
  bad "编译失败: test-cjk.tex (xelatex)"
fi
if [ -s test-cjk.pdf ]; then ok "产出 PDF: test-cjk.pdf"; else bad "缺少 PDF: test-cjk.pdf"; fi

# 5.2 PlantUML（lualatex + shell-escape；该宏包不支持 xelatex）
if lualatex -shell-escape -interaction=nonstopmode -halt-on-error test-plantuml.tex >/dev/null 2>&1; then
  ok "编译成功: test-plantuml.tex (lualatex -shell-escape)"
else
  bad "编译失败: test-plantuml.tex (lualatex -shell-escape)"
fi
if [ -s test-plantuml.pdf ]; then ok "产出 PDF: test-plantuml.pdf"; else bad "缺少 PDF: test-plantuml.pdf"; fi
if grep -q "only works with lualatex" test-plantuml.log 2>/dev/null; then
  bad "PlantUML 未渲染（日志出现引擎不支持的降级提示）"
else
  ok "PlantUML 已渲染（无引擎降级提示）"
fi
if grep -q "PLANTUML_JAR not set" test-plantuml.log 2>/dev/null; then
  bad "PlantUML 未渲染（日志提示 PLANTUML_JAR 未设置）"
else
  ok "PlantUML jar 路径有效（无 PLANTUML_JAR 报错）"
fi

# 5.3 Mermaid（xelatex + shell-escape）
if xelatex -shell-escape -interaction=nonstopmode -halt-on-error test-mermaid.tex >/dev/null 2>&1; then
  ok "编译成功: test-mermaid.tex (xelatex -shell-escape)"
else
  bad "编译失败: test-mermaid.tex (xelatex -shell-escape)"
fi
if [ -s test-mermaid.pdf ]; then ok "产出 PDF: test-mermaid.pdf"; else bad "缺少 PDF: test-mermaid.pdf"; fi
if ls mermaid/*.pdf >/dev/null 2>&1; then
  ok "Mermaid 图表已生成: $(ls mermaid/*.pdf | head -1)"
else
  bad "Mermaid 未生成图表 (mermaid/*.pdf 不存在)"
fi

echo
echo "===== 汇总 ====="
echo "PASS: $PASS   FAIL: $FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
