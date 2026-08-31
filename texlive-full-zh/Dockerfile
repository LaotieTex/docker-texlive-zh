FROM texlive/texlive:latest

RUN sed -i 's/deb.debian.org/mirrors.163.com/g' /etc/apt/sources.list.d/debian.sources

# ---- 图表支持：PlantUML ----
# plantuml 宏包只是包装器，需配合外部 plantuml.jar（由 apt 的 plantuml 包提供，并自动拉取 Java）
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     fonts-arphic-bkai00mp \
     fonts-arphic-bsmi00lp \
     fonts-arphic-gbsn00lp \
     fonts-arphic-gkai00mp \
     fonts-arphic-ukai \
     fonts-arphic-uming \
     fonts-noto-cjk-extra \
     plantuml \
     graphviz \
  && rm -rf /var/lib/apt/lists/*

ENV PLANTUML_JAR=/usr/share/plantuml/plantuml.jar

RUN tlmgr option repository https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet \
  && tlmgr update --self \
  && tlmgr install plantuml

# ENV LANG=zh_CN.UTF-8 \
#     LC_ALL=zh_CN.UTF-8
