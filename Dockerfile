FROM kalilinux/kali-rolling:amd64
ENV DEBIAN_FRONTEND noninteractive

# hadolint ignore=DL3008,DL3009

RUN apt update -y && apt upgrade -y && apt-get autoremove -y && apt-get clean -y && apt-get -y install --no-install-recommends \
    kali-tools-top10 \
    zaproxy \ 
    sqlite3 \
    openvas \
    gnupg2 \
    pass \
    ufw \ 
    python3-pip \
    openssh-client \
    jq \
    docker.io \
    expect-dev \
    dirbuster \
    python-tk 

RUN pip3 install \
    pipenv \
    xmltodict \
    PyJSONViewer  


WORKDIR /
RUN mkdir APP RESULTS
WORKDIR /APP
COPY entrypoint.sh nmap_vuln_scan zap_vuln_scan parse_nmap.py parse_zap.py config.py ./
RUN chmod +x nmap_vuln_scan entrypoint.sh zap_vuln_scan 
RUN echo "export PATH=$PATH:/APP" >> /root/.bashrc
RUN cd /usr/share/nmap/scripts/ && \
    git clone https://github.com/vulnersCom/nmap-vulners.git && \
    wget https://raw.githubusercontent.com/daviddias/node-dirbuster/master/lists/directory-list-2.3-medium.txt
ENTRYPOINT [ "bash", "entrypoint.sh" ]