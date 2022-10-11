FROM kalilinux/kali-rolling:amd64
ENV DEBIAN_FRONTEND noninteractive

# hadolint ignore=DL3008,DL3009

RUN apt update -y && apt upgrade -y && apt-get autoremove -y && apt-get clean -y && apt-get -y install --no-install-recommends \
    nmap \
    zaproxy \ 
    gnupg2 \
    pass \
    python3-pip \
    openssh-client \
    jq \
    python-tk \
    git \
    wget

RUN pip3 install --no-cache-dir \
    pipenv \
    xmltodict \
    PyJSONViewer \
    requests \
    pandas \
    python-logging-loki


WORKDIR /
RUN mkdir APP RESULTS
WORKDIR /APP
COPY entrypoint.sh parse_zap.py config.py ./
RUN chmod +x entrypoint.sh && echo "export PATH=$PATH:/APP" >> /root/.bashrc
ENTRYPOINT [ "bash", "entrypoint.sh" ]