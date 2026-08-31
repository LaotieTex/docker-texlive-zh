FROM paperist/texlive-ja:latest

# 使用国内 apt 镜像加速（海外构建可注释此行）
# RUN sed -i 's/deb.debian.org/mirrors.163.com/g' /etc/apt/sources.list.d/debian.sources || true

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

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    PUPPETEER_CONFIG_FILE=/usr/local/etc/puppeteer.config.json

RUN tlmgr option repository https://mirror.ctan.org/systems/texlive/tlnet \
  && (tlmgr update --self || true) \
  && tlmgr install gbt7714 pstricks fundus-calligra plantuml ltmermaid
