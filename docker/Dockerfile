FROM python:3

RUN apt-get update -y && \
    apt-get upgrade -y && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install libgmp-dev libmpfr-dev libmpc-dev -y && \
    pip install numpy opencv-python scikit-image && \
    apt-get install tzdata -y && \
    echo "America/Sao_Paulo" > /etc/timezone && \
    apt-get install cron -y

RUN mkdir /root/.ssh/
COPY id_rsa /root/.ssh/
COPY id_rsa.pub /root/.ssh/
COPY known_hosts /root/.ssh/

RUN eval $(ssh-agent -s) && \
    ssh-add && \
    git clone git@gitlab.com:felipetcazetta/gladiator.git

WORKDIR gladiator/

RUN crontab crontab/crontabfile
