FROM kalilinux/kali-bleeding-edge:amd64
ENV DEBIAN_FRONTEND noninteractive

# hadolint ignore=DL3008,DL3009

RUN apt update -y && apt upgrade -y && apt-get autoremove -y && apt-get clean -y && apt-get -y install --no-install-recommends \
    kali-linux-headless \
    open-iscsi

RUN pip3 install mitm6
WORKDIR /
RUN mkdir APP RESULTS
WORKDIR /APP
COPY entrypoint.sh ./
COPY /scripts/ /scripts
RUN chmod +x entrypoint.sh && echo "export PATH=$PATH:/APP" >> /root/.bashrc
RUN chmod +x /scripts/bash/*
RUN cd /usr/share/nmap/scripts/ && \
    git clone https://github.com/vulnersCom/nmap-vulners.git && \
    wget https://raw.githubusercontent.com/daviddias/node-dirbuster/master/lists/directory-list-2.3-medium.txt
ENTRYPOINT [ "bash", "entrypoint.sh" ]
