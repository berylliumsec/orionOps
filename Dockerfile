FROM kalilinux/kali-bleeding-edge:amd64
ENV DEBIAN_FRONTEND noninteractive
ENV PATH=$PATH:/APP:/usr/local/go/bin:"$HOME"
# hadolint ignore=DL3008,DL3009

RUN apt update -y && apt upgrade -y && apt-get autoremove -y && apt-get clean -y && apt-get -y install --no-install-recommends \
    kali-linux-headless \
    open-iscsi \
    jq \
    zaproxy \
    libpath-tiny-perl \
    make \
    ssh-audit 

RUN pip3 install mitm6 boto3 
WORKDIR tools
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
RUN go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest && export PATH=$PATH:/usr/local/go/bin
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install
RUN export AWS_ACCESS_KEY_ID=my-20-digit-id && \
export AWS_SECRET_ACCESS_KEY=my-40-digit-secret-key && \
export AWS_DEFAULT_REGION=us-east-1
WORKDIR /
RUN mkdir APP RESULTS
WORKDIR /APP
RUN cd /usr/share/nmap/scripts/ && \
    git clone https://github.com/vulnersCom/nmap-vulners.git && \
    wget https://raw.githubusercontent.com/daviddias/node-dirbuster/master/lists/directory-list-2.3-medium.txt
RUN sed -i 's/127.0.0.1 9050/127.0.0.1 1080/g' /etc/proxychains4.conf
RUN git clone https://github.com/CiscoCXSecurity/rdp-sec-check.git
RUN yes | perl -MCPAN -e 'install Encoding::BER'
RUN git clone https://github.com/robertdavidgraham/masscan && cd masscan && make &&  make install
RUN export /go/bin && nuclei
COPY entrypoint.sh ./
COPY /scripts/ /scripts
RUN chmod +x /scripts/bash/*
ENTRYPOINT [ "bash", "entrypoint.sh" ]
