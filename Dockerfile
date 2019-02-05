FROM phusion/baseimage

RUN add-apt-repository --yes ppa:webupd8team/java && add-apt-repository --yes ppa:deadsnakes/ppa
# name: oracle license selected
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
# name: oracle license seen
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

RUN apt-get -y update && apt-get -y install tzdata sudo lxc python python-apt oracle-java8-installer wget chromium-browser
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# locale UTF-8 fr
RUN apt-get -y install language-pack-fr && /usr/sbin/update-locale
RUN echo 'fr_FR.UTF-8 UTF-8' > /etc/locale.gen && /usr/sbin/locale-gen

# timezone Europe/Paris
RUN echo "tzdata tzdata/Areas select Europe" > /tmp/tzdata.txt && echo "tzdata tzdata/Zones/Europe select Paris" >> /tmp/tzdata.txt && debconf-set-selections /tmp/tzdata.txt && rm /etc/timezone && rm /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# with your user / group id
RUN export uid=1000 gid=1000 internal_user=dev && \
    mkdir -p /home/${internal_user} && \
    echo "${internal_user}:x:${uid}:${gid}:${internal_user},,,:/home/${internal_user}:/bin/bash" >> /etc/passwd && \
    echo "${internal_user}:x:${uid}:" >> /etc/group && \
    echo "${internal_user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${internal_user} && \
    chmod 0440 /etc/sudoers.d/${internal_user} && \
    chown ${uid}:${gid} -R /home/${internal_user}

# postgresql 10 client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list

# dev utils
RUN apt-get -y update && apt-get -y install git zsh net-tools man-db tree curl wget tcpdump traceroute ngrep sysstat htop bash-completion gitk vim libxml2-dev libxslt1-dev gnuplot ghostscript imagemagick tmux xclip ccze xvfb inotify-tools source-highlight strace graphviz libffi-dev libfreetype6-dev libpng12-dev pkg-config libcurl4-openssl-dev libjpeg-dev python-dev python3-dev firefox chromium-browser iputils-ping maven libcairo2-dev python-pip python3-pip libssl-dev libjpeg8-dev zlib1g-dev gnupg2 nsis cpio tesseract-ocr icnsutils python3.6 virtualenv postgresql-client-10 redis-tools jq

# xar for mac packages
RUN wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/xar/xar-1.5.2.tar.gz && tar -zxf xar-1.5.2.tar.gz && cd xar-1.5.2 && ./configure && make && make install
RUN wget https://github.com/hogliux/bomutils/archive/0.2.tar.gz  && tar -zxf 0.2.tar.gz && cd bomutils-0.2 && make && make install

RUN pip install ansible==2.6.3

# ADD user to docker group
RUN groupadd docker -g 999 && gpasswd -a dev docker

# n : node version manager
RUN mkdir -p /opt/n && curl -L https://git.io/n-install | PREFIX=/opt/n N_PREFIX=/opt/n bash -s -- -y && /opt/n/bin/n 8.9.4 && npm install -g yarn

ENV HOME="/home/dev" LANGUAGE="en" LANG="fr_FR.UTF-8"
ADD ./hello.sh /opt/hello.sh
