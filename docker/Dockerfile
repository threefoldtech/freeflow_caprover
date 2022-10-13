FROM ubuntu:18.04
RUN apt-get update && apt-get install apt-transport-https  ca-certificates  curl  gnupg lsb-release -y
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" |  tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install docker-ce docker-ce-cli containerd.io openssh-server ufw -y

COPY ./zinit /sbin/zinit
COPY ./scripts/ /scripts/
COPY ./zinit_services/ /etc/zinit/

RUN chmod +x /sbin/zinit && chmod +x /scripts/*.sh

ENTRYPOINT ["/sbin/zinit", "init"]
