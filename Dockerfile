FROM python:3

RUN ldd /usr/bin/ssh

RUN apt-get update &&\
    apt-get install jq libssl-dev libssl-dev -y

RUN pip install python-dotenv

COPY . /app

RUN mkdir /root/.ssh

RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

RUN ssh-keygen -y -f /root/.ssh/id_rsa > /root/.ssh/id_rsa.pub
# RUN ssh -i /root/.ssh/id_rsa

WORKDIR /app/scripts

RUN pip install -r ./requirements.txt

RUN python ./repos_java.py


RUN chmod +x ./clone_repos.sh

CMD ["./clone_repos.sh"]
