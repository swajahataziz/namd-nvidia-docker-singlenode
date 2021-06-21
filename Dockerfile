FROM nvcr.io/hpc/namd:2.13-singlenode

ENV USER root

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y iproute2 cmake openssh-server openssh-client python python-pip build-essential gfortran wget curl
RUN pip install supervisor awscli

RUN mkdir -p /var/run/sshd
ENV DEBIAN_FRONTEND noninteractive

ENV NOTVISIBLE "in users profile"

RUN mkdir /usr/tmp/

ADD apoa1 apoa1
RUN chmod 755 apoa1/apoa1.namd

ENV INPUT "apoa1/apoa1.namd"

#####################################################
## SSH SETUP

RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "export VISIBLE=now" >> /etc/profile

RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV SSHDIR /root/.ssh
RUN mkdir -p ${SSHDIR}
RUN touch ${SSHDIR}/sshd_config
RUN ssh-keygen -t rsa -f ${SSHDIR}/ssh_host_rsa_key -N ''
RUN cp ${SSHDIR}/ssh_host_rsa_key.pub ${SSHDIR}/authorized_keys
RUN cp ${SSHDIR}/ssh_host_rsa_key ${SSHDIR}/id_rsa
RUN echo " IdentityFile ${SSHDIR}/id_rsa" >> /etc/ssh/ssh_config
RUN echo "Host *" >> /etc/ssh/ssh_config && echo " StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN chmod -R 600 ${SSHDIR}/* && \
chown -R ${USER}:${USER} ${SSHDIR}/
# check if ssh agent is running or not, if not, run
RUN eval `ssh-agent -s` && ssh-add ${SSHDIR}/id_rsa

##################################################
## S3 OPTIMIZATION

RUN aws configure set default.s3.max_concurrent_requests 30
RUN aws configure set default.s3.max_queue_size 10000
RUN aws configure set default.s3.multipart_threshold 64MB
RUN aws configure set default.s3.multipart_chunksize 16MB
RUN aws configure set default.s3.max_bandwidth 4096MB/s
RUN aws configure set default.s3.addressing_style path

##################################################


EXPOSE 2022
ADD batch-runtime-scripts/entry-point.sh batch-runtime-scripts/entry-point.sh
RUN chmod 755 batch-runtime-scripts/entry-point.sh

CMD /batch-runtime-scripts/entry-point.sh
