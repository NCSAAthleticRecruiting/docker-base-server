FROM sillelien/jessy:master

ENV SSH_USERNAME root
ENV SSH_PASSWORD password

ENV GUI_USERNAME developer
ENV GUI_PASSWORD password
ENV PRIVATE_KEY_CONTENTS none

# install syncthing and openssh
RUN apt-get update && apt-get remove apt-listchanges && apt-get install -y curl
RUN apt-get install -y openssh-server && cd /tmp && \
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    rm -rf /tmp/*

RUN if [ ! -d "/var/run/sshd" ]; then mkdir /var/run/sshd; fi;
RUN chmod 0755 /var/run/sshd
RUN echo "${SSH_USERNAME}:${SSH_PASSWORD}" | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i -e 's/^#*\(PermitEmptyPasswords\) .*/\1 yes/' /etc/ssh/sshd_config
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

RUN if [ "${PRIVATE_KEY_CONTENTS}" != "none" ]; \
    then echo "${PRIVATE_KEY_CONTENTS}" > ~/.ssh/${PRIVATE_KEY_FILE} \
    sed -i 's/\\n/\/g' ~/.ssh/${PRIVATE_KEY_FILE} \
    chmod 600  ~/.ssh/${PRIVATE_KEY_FILE}; \
    fi
  
# public key goes here
RUN if [ ! -d "/root/.ssh" ]; then mkdir /root/.ssh; fi
RUN chmod 0700 /root/.ssh


VOLUME ["/root/Sync","/root/.ssh"]
EXPOSE 8384 22000 22 21025/udp 21026/udp 22026/udp

ENTRYPOINT /usr/sbin/sshd -D && service sshd start
