FROM phusion/baseimage:focal-1.0.0alpha1-amd64

RUN add-apt-repository --yes ppa:deadsnakes/ppa

RUN apt-get -y update && apt-get -y install tzdata sudo lxc python python-apt wget chromium-browser openjdk-8-jdk openjdk-11-jdk maven
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# locale UTF-8 fr
RUN apt-get -y install language-pack-fr && /usr/sbin/update-locale
RUN echo 'fr_FR.UTF-8 UTF-8' > /etc/locale.gen && /usr/sbin/locale-gen

# timezone Europe/Paris
RUN echo "tzdata tzdata/Areas select Europe" > /tmp/tzdata.txt && echo "tzdata tzdata/Zones/Europe select Paris" >> /tmp/tzdata.txt && debconf-set-selections /tmp/tzdata.txt && rm /etc/timezone && rm /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

ARG user_uid=1000
ARG user_gid=1000

# with your user / group id
RUN export uid=$user_uid gid=$user_gid internal_user=dev && \
    mkdir -p /home/${internal_user} && \
    echo "${internal_user}:x:${uid}:${gid}:${internal_user},,,:/home/${internal_user}:/bin/bash" >> /etc/passwd && \
    echo "${internal_user}:*:18750:0:99999:7:::" >> /etc/shadow && \
    echo "${internal_user}:x:${uid}:" >> /etc/group && \
    echo "${internal_user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${internal_user} && \
    chmod 0440 /etc/sudoers.d/${internal_user} && \
    chown ${uid}:${gid} -R /home/${internal_user}

# postgresql 10 client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list

# dev utils
RUN apt-get -y update && \
    apt-get -y install git zsh net-tools man-db tree curl wget tcpdump traceroute ngrep sysstat htop bash-completion gitk vim libxml2-dev autoconf libxslt1-dev gnuplot ghostscript imagemagick \
    tmux xclip ccze xvfb inotify-tools source-highlight strace graphviz libffi-dev libfreetype6-dev libpng-dev pkg-config libjpeg-dev python-dev python3-dev \
    firefox chromium-browser iputils-ping maven libcairo2-dev python3-pip libssl1.1 libssl-dev libjpeg8-dev zlib1g-dev gnupg2 nsis cpio tesseract-ocr icnsutils python3.7 virtualenv pinentry-gtk2 \
    postgresql-client-10 libpq-dev redis-tools jq libgif-dev libxcomposite1 libxcursor1 libxi6 libxtst6 libnss3 libcups2 libxss1 libxrandr2 libasound2 libatk1.0-0 libatk-bridge2.0-0 \
    libgtk-3-0 git-extras software-properties-common nano autojump pass poppler-utils libpoppler-cpp-dev libpoppler-dev qpdf cmake unzip

# xar for mac packages
# for xar see https://github.com/mackyle/xar/issues/18 patch for libSSL
RUN wget https://github.com/downloads/mackyle/xar/xar-1.6.1.tar.gz && tar -zxf xar-1.6.1.tar.gz && cd xar-1.6.1 && sed -i 's/OpenSSL_add_all_ciphers/OPENSSL_init_crypto/' configure.ac && ./autogen.sh && make && make install
RUN wget https://github.com/hogliux/bomutils/archive/0.2.tar.gz  && tar -zxf 0.2.tar.gz && cd bomutils-0.2 && make && make install

RUN python3 -m pip install --upgrade pip && \
    pip3 install ansible==2.10.3 && \
    pip3 install molecule==2.22 && \
    pip3 install pipenv && \
    pip3 install boto3 awscli && \
    pip3 install cerberus


# Install terraform
RUN wget https://releases.hashicorp.com/terraform/0.13.0/terraform_0.13.0_linux_amd64.zip -O /tmp/terraform.zip && \
    unzip /tmp/terraform.zip && \
    mv terraform /usr/local/bin && \
    chmod 755 /usr/local/bin/terraform && \
    rm -f /tmp/terraform.zip

# Install helm and helmfile
RUN wget https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz -O /tmp/helm.tar.gz && \
    tar -xzvf /tmp/helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin && \
    mv linux-amd64/tiller /usr/local/bin && \
    rm -rf /tmp/helm.tar.gz linux-amd64 && \
    helm init --stable-repo-url=https://charts.helm.sh/stable --client-only && \
    wget https://github.com/roboll/helmfile/releases/download/v0.130.0/helmfile_linux_amd64 -O /tmp/helmfile && \
    mv /tmp/helmfile /usr/local/bin && \
    chmod 755 /usr/local/bin/helmfile && \
    helm plugin install https://github.com/aslafy-z/helm-git --version 0.8.0 && \
    helm plugin install https://github.com/databus23/helm-diff && \
    helm plugin install https://github.com/zendesk/helm-secrets

# ADD user to docker group
RUN groupadd docker -g 999 && gpasswd -a dev docker

# n : node version manager
RUN mkdir -p /opt/n && curl -L https://git.io/n-install | PREFIX=/opt/n N_PREFIX=/opt/n bash -s -- -y && /opt/n/bin/n 14.15.5 && npm install -g yarn majestic

# install ruby RVM
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
RUN curl -sSL https://get.rvm.io | bash -s stable && chown -R dev:dev /usr/local/rvm

# install ruby 2.4.6 and tmuxinator
SHELL ["/bin/bash", "-l", "-c"]
RUN . /etc/profile.d/rvm.sh && rvm install 2.4.6 && rvm use --default 2.4.6 && gem install tmuxinator -v 1.1.5

ENV HOME="/home/dev" LANGUAGE="en" LANG="fr_FR.UTF-8"
ADD ./hello.sh /opt/hello.sh
