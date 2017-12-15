#FROM debian:stretch
FROM debian:stretch-slim

# https://wiki.debian.org/AutomaticDebugPackages
RUN echo "deb http://debug.mirrors.debian.org/debian-debug/ stretch-debug main" \
	| tee /etc/apt/sources.list.d/debian-debug.list

RUN apt-get update -qyy && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y locales

# Configure locale
RUN sed -i -E "s/^([^#].+)/# \1/" /etc/locale.gen && \
	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=en_US.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
	git curl bash-completion build-essential gdb pkg-config ssh \
	neovim tmate gpg sudo sl cowsay \
	python-numpy net-tools tightvncserver

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
	xfce4-session gnome-icon-theme thunar xfce4-terminal

ADD bin/start.sh /usr/local/bin/
ADD bin/start-tmate.sh /usr/local/bin/
ADD bin/start-vnc.sh /usr/local/bin/

# NoVNC
RUN mkdir -p /opt/novnc \
	&& curl -fsSL https://github.com/novnc/noVNC/archive/v1.0.0-testing.2.tar.gz | tar xzv --strip 1 -C /opt/novnc
RUN mkdir -p /opt/novnc/utils/websockify \
	&& curl -fsSL https://github.com/novnc/websockify/archive/v0.8.0.tar.gz | tar -xzv --strip 1 -C /opt/novnc/utils/websockify

# Firefox
RUN mkdir -p /opt/firefox \
	&& curl -fsSL "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" \
	| tar -xjv --strip 1 -C /opt/firefox

#
# Environment configuration
#

RUN addgroup --gid 1000 pairing
RUN adduser --home /pairing --disabled-password --gecos "" --uid 1000 --ingroup pairing pair
RUN echo "pair ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

USER pair:pairing
ENV USER pair
ENV LANG en_US.UTF-8
WORKDIR /pairing
CMD /bin/bash

#
# After this line are things specific to my project
#


# Latest Go
RUN sudo curl -sSL -o /usr/local/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme \
	&& sudo chmod +x /usr/local/bin/gimme \
	&& sudo /usr/local/bin/gimme "$(/usr/local/bin/gimme -k | head -n 1)"

# GTK+3
RUN DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
	devhelp libgtk-3-dev libgtk-3-0-dbgsym libgtk-3-doc

# Pokemon Say
ENV COWPATH=/usr/local/share/pokemonsay/cows:/usr/local/share/cowsay/cows:/usr/share/cowsay/cows
RUN sudo mkdir -p /usr/local/share/cowsay \
	&& sudo git clone https://github.com/paulkaefer/cowsay-files.git /usr/local/share/cowsay
RUN sudo mkdir -p /usr/local/share/pokemonsay \
	&& sudo git clone https://github.com/possatti/pokemonsay.git /usr/local/share/pokemonsay
