FROM phusion/baseimage

RUN add-apt-repository --yes ppa:webupd8team/java
# name: oracle license selected
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
# name: oracle license seen
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections 

RUN apt-get -y update && apt-get -y install tzdata sudo lxc python python-apt oracle-java8-installer
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

# dev utils
RUN apt-get -y update && apt-get -y install git net-tools man-db tree curl wget tcpdump traceroute ngrep sysstat htop bash-completion gitk vim libxml2-dev libxslt1-dev gnuplot ghostscript imagemagick tmux xclip ccze xvfb inotify-tools source-highlight strace graphviz libffi-dev libfreetype6-dev libpng12-dev pkg-config libcurl4-openssl-dev libjpeg-dev python-dev python3-dev firefox iputils-ping maven libcairo2-dev python-pip python3-pip libssl-dev libjpeg8-dev zlib1g-dev

RUN pip install ansible==2.6.3

# ADD user to docker group
RUN groupadd docker -g 999 && gpasswd -a dev docker

USER dev

# install nodejs in dev HOME
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash && bash -c 'source $HOME/.nvm/nvm.sh && nvm install 8.9.4 && nvm use 8.9.4 && npm install -g yarn'

USER root

ENV HOME="/home/dev" LANGUAGE="en" LANG="fr_FR.UTF-8"
