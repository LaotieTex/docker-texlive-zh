FROM texlive/texlive:latest

RUN sed -i 's/deb.debian.org/mirrors.163.com/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update \
  && apt-get install -y \
  fonts-arphic-bkai00mp \
  fonts-arphic-bsmi00lp \
  fonts-arphic-gbsn00lp \
  fonts-arphic-gkai00mp \
  fonts-arphic-ukai \
  fonts-arphic-uming \
  fonts-noto-cjk-extra

# ENV LANG=zh_CN.UTF-8 \
#     LC_ALL=zh_CN.UTF-8
