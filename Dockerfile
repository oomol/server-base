FROM python:3.12.1-slim

ENV HOME="/home/ovm"

# 替换清华源
# RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free" > /etc/apt/sources.list \
#   && echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free" >> etc/apt/sources.list \
#   && echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list \
#   && echo "deb https://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y git zsh curl sudo

RUN adduser --disabled-password  --shell /usr/bin/zsh --gecos '' ovm
RUN adduser ovm sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s lts

RUN apt-get clean

CMD ["/bin/zsh"]
