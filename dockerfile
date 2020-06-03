FROM ubuntu:latest AS ubuntu

RUN apt-get update && apt-get upgrade -y    
RUN apt -y install apt-utils
RUN apt-get install python3 -y
RUN apt-get install git -y
RUN apt-get install python3-pip -y
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10
RUN pip3 install mysql-connector-python
RUN pip3 install --upgrade oauth2client
RUN pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
ENV userDB=$userDB
ENV passDB='Qazxsw21!!'
RUN cd /opt; \
    git clone https://github.com/ismaeldarosa19/challenge.git 
WORKDIR /opt/challenge
ADD token.json /opt/challenge
ADD credentials.json /opt/challenge
