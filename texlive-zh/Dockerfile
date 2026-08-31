FROM paperist/texlive-ja:latest

# 使用国内 apt 镜像加速（海外构建可注释此行）
# RUN sed -i 's/deb.debian.org/mirrors.163.com/g' /etc/apt/sources.list.d/debian.sources || true

RUN apt-get update \
  && apt-get install -y \
    libfontconfig \
    fonts-arphic-bkai00mp \
    fonts-arphic-bsmi00lp \
    fonts-arphic-gbsn00lp \
    fonts-arphic-gkai00mp \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-noto-cjk-extra \
    wget \
    ca-certificates \
  && apt autoremove -y \
  && apt clean -y \
  && rm -rf /var/lib/apt/lists/*

# ---- 图表支持：PlantUML ----
# plantuml 宏包只是包装器，需配合外部 plantuml.jar（由 apt 的 plantuml 包提供，并自动拉取 Java）
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     plantuml \
     graphviz \
  && rm -rf /var/lib/apt/lists/*

ENV PLANTUML_JAR=/usr/share/plantuml/plantuml.jar

# ---- 图表支持：Mermaid ----
# mermaid 宏包（tlmgr: ltmermaid，提供 mermaid.sty）仅作包装，需 Mermaid CLI(mmdc) + 无头 Chromium
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     nodejs \
     npm \
     chromium \
     libgbm1 \
     libnss3 \
  && rm -rf /var/lib/apt/lists/*

RUN printf '{\n  "args": ["--no-sandbox", "--disable-setuid-sandbox"]\n}\n' \
      > /usr/local/etc/puppeteer.config.json \
  && npm config set registry https://registry.npmmirror.com \
  && PUPPETEER_SKIP_DOWNLOAD=true npm install -g @mermaid-js/mermaid-cli@10.9.1 \
  && npm cache clean --force

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    PUPPETEER_CONFIG_FILE=/usr/local/etc/puppeteer.config.json

RUN wget http://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet/update-tlmgr-latest.sh \
  && sh update-tlmgr-latest.sh -- --upgrade \
  && tlmgr option repository http://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet \
  && tlmgr update --self --all \
  && tlmgr install gbt7714 pstricks fundus-calligra plantuml ltmermaid
