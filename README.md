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

## License / 许可证

MIT (c) 3846masa

---

Forked from [paperist/texlive-ja] \(under the MIT License\).

[paperist/texlive-ja]: https://github.com/Paperist/texlive-ja