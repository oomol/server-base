FROM python:3.12.1-slim

ENV HOME="/home/ovm"

# install system dependencies
RUN apt-get update
RUN apt-get install -y git zsh curl sudo
RUN apt-get clean

# create ovm user with sudo privileges
RUN adduser --disabled-password  --shell /usr/bin/zsh --gecos '' ovm
RUN adduser ovm sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER ovm

# set ssh
RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh
COPY --chown=ovm ./ssh_config ${HOME}/.ssh/config

# set app directory
RUN sudo mkdir /app
RUN sudo chown ovm /app
WORKDIR /app

# setup zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sudo chsh -s $(which zsh)
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="essembeh"/g' ~/.zshrc

# setup n / node / npm / pnpm
RUN curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | sudo bash -s lts
RUN mkdir ~/.npm-global
RUN npm config set prefix "~/.npm-global"
ENV PATH="$HOME/.npm-global/bin:$PATH"

RUN npm install -g pnpm
# fix https://github.com/pnpm/pnpm/issues/5803
RUN pnpm config set store-dir ${HOME}/.pnpm-store

# setup python
ENV PYENV_ROOT="${HOME}/.pyenv" PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
RUN pip install wheel

CMD ["/bin/zsh"]
