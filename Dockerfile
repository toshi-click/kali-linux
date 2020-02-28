FROM kalilinux/kali-rolling

# Debian set Locale
# tzdataのapt-get時にtimezoneの選択で止まってしまう対策でDEBIAN_FRONTENDを定義する
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
  apt -y install task-japanese locales-all locales && \
  locale-gen ja_JP.UTF-8 && \
  rm -rf /var/lib/apt/lists/*
ENV LC_ALL=ja_JP.UTF-8 \
  LC_CTYPE=ja_JP.UTF-8 \
  LANGUAGE=ja_JP:jp
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8

# Debian set TimeZone
ENV TZ=Asia/Tokyo
RUN echo "${TZ}" > /etc/timezone && \
  rm /etc/localtime && \
  ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata

# コンテナのデバッグ等で便利なソフト導入しておく
RUN apt update && \
  apt -y install \
  vim \
  git \
  curl \
  wget \
  zip \
  unzip \
  net-tools \
  iproute2 \
  iputils-ping && \
  apt -y clean && \
  rm -rf /var/lib/apt/lists/*

# コンテナ内からメール
ENV SMTP_SERVER in-the-container.test
ENV FROM_ADDRESS root@in-the-container.test
RUN apt update && apt -y install msmtp msmtp-mta && apt -y clean && rm -rf /var/lib/apt/lists/*
RUN { \
    echo '#!/bin/bash -eu'; \
    echo '{'; \
    echo 'echo "defaults"'; \
    echo 'echo "account default"'; \
    echo 'echo "host ${SMTP_SERVER}"'; \
    echo 'echo "from ${FROM_ADDRESS}"'; \
    echo 'echo "port 25"'; \
    echo 'echo "logfile /var/log/msmtp.log"'; \
    echo '} >> /etc/msmtprc'; \
    echo 'chmod 0644 /etc/msmtprc'; \
    } > /usr/local/bin/run.sh; \
    chmod +x /usr/local/bin/run.sh;

RUN touch /var/log/msmtp.log \
    && touch /root/.msmtprc \
    && chmod 0777 /var/log/msmtp.log

# WPScan
RUN apt update \
    && apt upgrade -y \
    && apt install -y \
    vim \
    nmap \
    ruby \
    build-essential \
    libcurl4-openssl-dev \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    ruby-dev \
    libgmp-dev \
    zlib1g-dev \
    && apt -y clean \
    && rm -rf /var/lib/apt/lists/*
RUN gem install wpscan

# golismero
RUN apt update \
    && apt upgrade -y \
    && apt install -y \
    python2.7 \
    python2.7-dev \
    python-pip \
    python-docutils \
    git \
    perl \
    nmap \
    sslscan \
    && apt -y clean \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /opt
RUN git clone https://github.com/golismero/golismero.git
WORKDIR /opt/golismero
RUN pip install -r requirements.txt \
  && pip install -r requirements_unix.txt \
  && ln -s /opt/golismero/golismero.py /usr/bin/golismero

CMD ["/usr/local/bin/run.sh"]
