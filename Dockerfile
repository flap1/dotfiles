FROM ubuntu:22.04

ARG USERNAME=flap1

RUN apt-get update \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends \
    sudo git zsh

# adduser ${USERNAME}:${USERNAME} with password '${USERNAME}'
RUN groupadd -g 1000 ${USERNAME} \
   && useradd -g ${USERNAME} -G sudo -m -s /bin/bash ${USERNAME} \
   && echo "${USERNAME}:${USERNAME}" | chpasswd

RUN echo "Defaults visiblepw" >> /etc/sudoers
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN git clone https://gitlab.com/flap1/dotfiles.git /home/${USERNAME} \ 
  && bash /home/${USERNAME}/dotfiles/setup.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}/
