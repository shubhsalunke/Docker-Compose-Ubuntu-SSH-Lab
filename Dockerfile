FROM ubuntu:22.04

RUN apt update && apt install -y openssh-server sudo nano curl iputils-ping net-tools openssh-client \
    && mkdir -p /var/run/sshd

ARG USERNAME

RUN useradd -m -s /bin/bash $USERNAME \
    && usermod -aG sudo $USERNAME \
    && passwd -d $USERNAME

RUN mkdir -p /home/$USERNAME/.ssh

COPY keys/YOUR_KEY.pub /home/$USERNAME/.ssh/authorized_keys

RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh \
    && chmod 700 /home/$USERNAME/.ssh \
    && chmod 600 /home/$USERNAME/.ssh/authorized_keys

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
