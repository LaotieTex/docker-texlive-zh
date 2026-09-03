FROM paperist/texlive-ja:latest

# 使用国内 apt 镜像加速（海外/CI 构建保持注释此行，用官方源）
# 本机实测速度：deb.debian.org 75KB/s < 163 744KB/s < aliyun 3.1MB/s < 清华 13.5MB/s < 中科大 17MB/s
# RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources || true

# 单次 apt-get update + install：中文字体 / PlantUML(Java+graphviz) / Mermaid(Node+无头 Chromium)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     libfontconfig \
     ca-certificates \
     wget \
     fonts-arphic-bkai00mp \
     fonts-arphic-bsmi00lp \
     fonts-arphic-gbsn00lp \
     fonts-arphic-gkai00mp \
     fonts-arphic-ukai \
     fonts-arphic-uming \
     fonts-noto-cjk-extra \
     plantuml \
     graphviz \
     nodejs \
     npm \
     chromium \
     libgbm1 \
     libnss3 \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# PlantUML 宏包只是包装器，需配合外部 plantuml.jar（上面 apt 的 plantuml 包已提供，并自动拉取 Java）
ENV PLANTUML_JAR=/usr/share/plantuml/plantuml.jar

# Mermaid CLI（mmdc）；puppeteer 复用上面的系统 chromium，跳过自带下载
RUN printf '{\n  "args": ["--no-sandbox", "--disable-setuid-sandbox"]\n}\n' \
      > /usr/local/etc/puppeteer.config.json \
  && npm config set registry https://registry.npmmirror.com \
  && PUPPETEER_SKIP_DOWNLOAD=true npm install -g @mermaid-js/mermaid-cli@10.9.1 \
  && npm cache clean --force

# 容器内以 root 运行，chromium 必须 --no-sandbox。
# Debian 的 /usr/bin/chromium 是 shell 包装脚本，会 source /etc/chromium.d/*，
# 在这里加标志最可靠（puppeteer 配置文件不一定被 mermaid-cli 读取）。
RUN printf 'export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --no-sandbox --disable-setuid-sandbox"\n' \
      > /etc/chromium.d/no-sandbox

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    PUPPETEER_CONFIG_FILE=/usr/local/etc/puppeteer.config.json

# 基础镜像是日文 TeX Live：只有 luatexja/ptex，没有 ctex 宏包也没有 xetex 引擎。
# 中文文档（ctexart / xelatex）必须补装这两项。
# 国内构建可把上面的 CTAN 源换成中科大镜像以提速（海外/CI 保持官方源）：
#   https://mirrors.ustc.edu.cn/CTAN/systems/texlive/tlnet
RUN tlmgr option repository https://mirror.ctan.org/systems/texlive/tlnet \
  && (tlmgr update --self || true) \
  # luacode 是 plantuml 宏包的运行时依赖，但 CTAN 未声明，tlmgr 不会自动装，必须显式补上
  && tlmgr install gbt7714 pstricks fundus-calligra ctex xetex plantuml ltmermaid luacode
