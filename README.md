# texlive-zh

The minimal TeXLive Docker image for Chinese <br/>
面向中文写作者的 TexLive 精简镜像。



## Supported tags / 标签


- [`latest`](./debian/Dockerfile)
  - AMD64, ARM64 supported.
  - 支持 AMD64, ARM64 (M1 mac) 

## Install / 安装

The image can be installed from Docker Hub Registry. <br/>
可以在通过 Docker Hub 拉取镜像

### Docker Hub

```bash
docker pull laotie255/texlive-zh:latest
```


## Usage / 使用方法

### Command line 

```bash
$ docker run --rm -it -v $PWD:/workdir laotie255/texlive-zh:latest \
    sh -c 'xelatex main.tex'
```

### 与 VSCode LaTeX Workshop 插件集成

```json
{
    "latex-workshop.docker.enabled": true,
    "latex-workshop.docker.image.latex": "laotie255/texlive-zh:latest",
    "latex-workshop.latex.tools": [
        {
            "name": "xelatexmk-shell-escape",
            "command": "latexmk",
            "args": [
                "-e",
                "$pdflatex=q/xelatex -shell-escape %O %S/",
                "-e",
                "$xelatex=q/xelatex -shell-escape %O %S/",
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "-pdf",
                "-outdir=%OUTDIR%",
                "%DOC%"
            ]
        }
    ],
    "latex-workshop.latex.recipes": [
        {
            "name": "latexmk (xelatex + shell-escape)",
            "tools": [
                "xelatexmk-shell-escape"
            ]
        }
    ],
    "[latex]": {
        "editor.defaultFormatter": "James-Yu.latex-workshop"
    },
    "latex-workshop.latex.autoClean.run": "onBuilt"
}
```

> 内置的 `xelatexmk` 工具默认**不带** `-shell-escape`，而 PlantUML / Mermaid 宏包必须靠它调用外部引擎，
> 所以这里自定义了 `xelatexmk-shell-escape` 工具。若你的文档不使用图表宏包，用默认 `xelatexmk` 即可。

Document of the [Latex Workshop Extension](https://github.com/James-Yu/LaTeX-Workshop/wiki/Install)<br>
[Latex Workshop Extension](https://github.com/James-Yu/LaTeX-Workshop/wiki/Install)官方文档

### Dev Container

Create a dev container configuration file `.devcontainer.json` in the root of your project. And paste the following configurations.<br>
在你的项目根目录创建开发容器配置文件 `.devcontainer.json`, 并粘贴下面这段配置。

```json
{
    "name": "TeX Live Zh",
    "image": "laotie255/texlive-zh:latest",
    "customizations": {
        "vscode": {
            "extensions": [
                "james-yu.latex-workshop"
            ]
        }
    }
}

```

Document of the [VSCode Dev Container](https://code.visualstudio.com/docs/devcontainers/containers)<br>
[VSCode Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) 官方文档

## Diagrams / 图表支持（PlantUML & Mermaid）

镜像内置 PlantUML 与 Mermaid 支持，可直接在 LaTeX 文档中绘制流程图、时序图、类图、架构图等。

### PlantUML

`plantuml` 宏包只是包装器，镜像已通过 apt 安装 `plantuml`（自带 Java 运行时）与 `graphviz`，
并设置了 `PLANTUML_JAR` 环境变量指向 `plantuml.jar`，同时用 tlmgr 安装了 `plantuml` 宏包。

编译时需要 `-shell-escape`。

> ⚠️ **引擎限制**：`plantuml` 宏包自 0.7.0 起支持 **lualatex 与 pdflatex**，但**不支持 xelatex**
> （0.6.0 更是仅支持 lualatex）。用 xelatex 编译时它**不会报错中止**，而是输出一个占位框，
> 容易造成"编译成功但图没出来"的假象。若你的中文文档习惯用 xelatex，PlantUML 图表请用
> `lualatex -shell-escape` 编译（ctex 在 lualatex 下同样可用）。

```latex
\documentclass{ctexart}
\usepackage{plantuml}
\begin{document}
\begin{plantuml}
@startuml
actor 用户
用户 -> 后端: 发起请求
后端 --> 用户: 返回结果
@enduml
\end{plantuml}
\end{document}
```

```bash
# 必须用 lualatex（或 pdflatex）+ -shell-escape
lualatex -shell-escape main.tex
```

### Mermaid

`mermaid` 宏包（tlmgr 安装 `ltmermaid`，同时提供 `mermaid.sty` 与 `ltmermaid.sty`）直接驱动 Mermaid CLI（`mmdc`）。
底层依赖无头 Chromium（Puppeteer），镜像已安装并配置 `--no-sandbox`，无需额外参数。

```latex
\documentclass{ctexart}
\usepackage{mermaid}
\begin{document}
\begin{mermaid}
flowchart LR
  A[开始] --> B[处理] --> C[结束]
\end{mermaid}
\end{document}
```

```bash
# 命令行编译需加 -shell-escape
xelatex -shell-escape main.tex
```

> 若 `mmdc` 不在 PATH，可在导言区指定 `\usepackage[Renderer={npx -y @mermaid-js/mermaid-cli}]{mermaid}`
> （首次编译会联网下载 mermaid-cli）。

### 排错

**1. 必须开启 `-shell-escape`**：PlantUML 与 Mermaid 宏包都要调用外部程序，缺该参数会直接编译失败。

```bash
# 直接跑 xelatex（最直接，能看到真实报错）
xelatex -shell-escape -interaction=nonstopmode main.tex

# 用 latexmk（latexmk 没有 -shell-escape 选项，需通过 -e 注入）
latexmk -e '$pdflatex=q/xelatex -shell-escape %O %S/' -pdf -interaction=nonstopmode main.tex
```

**2. latexmk 卡在"上一次失败"状态**：出现 `All targets ... are up-to-date` 并提示
`gave an error in previous invocation of latexmk` 时，说明 latexmk 已缓存失败状态并拒绝继续，
**真正的报错并不在这段输出里**。清掉文件数据库后重跑即可看到真实错误：

```bash
rm -f main.fdb_latexmk        # 或 latexmk -C（会连 pdf 一起清掉）
latexmk -e '$pdflatex=q/xelatex -shell-escape %O %S/' -pdf main.tex
```

**3. Mermaid 单独排查**：`mermaid` 宏包会把 CLI 的报错写到 `mermaid/` 目录下的 `.err` 文件，
编译失败时优先查看该目录。也可手动验证渲染链路：

```bash
echo 'flowchart LR A-->B' > /tmp/t.mmd && mmdc -i /tmp/t.mmd -o /tmp/t.pdf && echo OK
```

若 `mmdc` 报 Chromium/sandbox 相关错误，确认 `PUPPETEER_EXECUTABLE_PATH`、`PUPPETEER_CONFIG_FILE`
两个环境变量没被覆盖（镜像已内置配置，无需手动设置）。

## Tests / 验证镜像构建结果

`tests/` 下提供了一组用例，用于验证镜像构建产物是否符合预期。

```bash
# 验证精简镜像（默认 laotie255/texlive-zh:latest）
./tests/run.sh

# 验证 full 镜像
IMAGE=laotie255/texlive-zh:full-latest ./tests/run.sh
```

| 类别 | 检查项 |
|---|---|
| 外部引擎 | `java` / `plantuml` / `dot`(graphviz) / `node` / `npm` / `mmdc` / `chromium` |
| 环境变量 | `PLANTUML_JAR`（含文件存在性）、`PUPPETEER_EXECUTABLE_PATH`、`PUPPETEER_CONFIG_FILE` |
| 宏包 | `plantuml.sty`、`mermaid.sty`、`ltmermaid.sty`；原有 `pstricks.sty` / `calligra.sty` / `gbt7714` 回归 |
| 引擎直测 | 绕开 LaTeX，直接用 `plantuml` CLI 与 `mmdc` 各渲染一张图，便于隔离定位 |
| 出图验证 | 中文 PDF、PlantUML PDF、Mermaid PDF（`mermaid/*.pdf`） |

> **设计要点**：PlantUML 在 jar 缺失或引擎不匹配时会**静默降级为占位框**，
> 所以脚本除了检查"编译成功"，还会检查日志中的降级提示，避免把"没画出图"误判为通过。

测试在临时目录中进行，产物用完即删，不会污染仓库。

## Source Code / 镜像源码

https://github.com/LaotieTex/docker-texlive-zh

## License / 许可证

MIT (c) 3846masa

---

Forked from [paperist/texlive-ja] \(under the MIT License\).

[paperist/texlive-ja]: https://github.com/Paperist/texlive-ja