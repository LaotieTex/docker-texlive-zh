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
    "latex-workshop.latex.recipes": [
        {
            "name": "latexmk (xelatex)",
            "tools": [
                "xelatexmk"
            ]
        }
    ],
    "[latex]": {
        "editor.defaultFormatter": "James-Yu.latex-workshop"
    },
    "latex-workshop.latex.autoClean.run": "onBuilt"
}
```

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

## Diagrams / 图表支持（PlantUML）

镜像内置 PlantUML 支持，可直接在 LaTeX 文档中绘制流程图、时序图、类图等。

`plantuml` 宏包只是包装器，镜像已通过 apt 安装 `plantuml`（自带 Java 运行时）与 `graphviz`，
并设置了 `PLANTUML_JAR` 环境变量指向 `plantuml.jar`，同时用 tlmgr 安装了 `plantuml` 宏包。

编译时需要 `-shell-escape`（LaTeX Workshop 默认开启，命令行需手动加）。

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
# 命令行编译需加 -shell-escape
xelatex -shell-escape main.tex
```

> 注：Mermaid 支持未内置。Mermaid 渲染必须依赖无头 Chromium（Puppeteer），会显著增大镜像体积；
> 如需加入，可后续单独扩展（例如安装 `mermaid-cli` + Chromium 并使用 CTAN 的 `mermaid`/`ltmermaid` 宏包）。

## Source Code / 镜像源码

https://github.com/LaotieTex/docker-texlive-zh

## License / 许可证

MIT (c) 3846masa

---

Forked from [paperist/texlive-ja] \(under the MIT License\).

[paperist/texlive-ja]: https://github.com/Paperist/texlive-ja