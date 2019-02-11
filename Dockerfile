FROM ubuntu

ADD install.sh /install.sh
RUN /install.sh
