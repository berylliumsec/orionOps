# Dockerfile for berylliumsec
FROM kalilinux/kali-bleeding-edge:amd64

LABEL maintainer="BerylliumSec Team <david@berylliumsec.com>"
LABEL version="1.0"
LABEL description="Customized Kali Linux image by BerylliumSec"

ENV DEBIAN_FRONTEND noninteractive
ENV PATH=$PATH:/APP:/usr/local/go/bin:"$HOME":/root/go/bin/

# hadolint ignore=DL3008,DL3009
RUN apt update -y && apt upgrade -y && apt-get autoremove -y && apt-get clean -y && apt-get -y install --no-install-recommends \
    kali-linux-headless \
    open-iscsi \
    jq \
    zaproxy \
    libpath-tiny-perl \
    make \
    ssh-audit \
    pciutils


RUN pip3 install mitm6 boto3 

WORKDIR /tools

# Install Go and Nuclei
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
RUN go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install
ENV AWS_ACCESS_KEY_ID=my-20-digit-id
ENV AWS_SECRET_ACCESS_KEY=my-40-digit-secret-key
ENV AWS_DEFAULT_REGION=us-east-1

WORKDIR /APP

# Install Nmap scripts and other tools
RUN cd /usr/share/nmap/scripts/ && \
    git clone https://github.com/vulnersCom/nmap-vulners.git && \
    wget https://raw.githubusercontent.com/daviddias/node-dirbuster/master/lists/directory-list-2.3-medium.txt

RUN sed -i 's/127.0.0.1 9050/127.0.0.1 1080/g' /etc/proxychains4.conf

RUN git clone https://github.com/CiscoCXSecurity/rdp-sec-check.git

RUN apt-get install -y libcrypt-ssleay-perl liblwp-protocol-https-perl # Install required dependencies
RUN cpan -T -i Encoding::BER # Install Perl module

# Install Masscan
RUN git clone https://github.com/robertdavidgraham/masscan && cd masscan && make &&  make install
RUN nuclei -update-templates
# Copy entrypoint script and scripts
COPY entrypoint.sh /entrypoint.sh
COPY scripts/ /scripts/
RUN chmod +x /scripts/bash/* && chmod +x /entrypoint.sh
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--", "bash", "/entrypoint.sh"]
