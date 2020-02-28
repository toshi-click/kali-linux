FROM kalilinux/kali-rolling

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
    zlib1g-dev
    
RUN gem install wpscan
