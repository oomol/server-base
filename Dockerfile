FROM python:3.12.1-slim

ENV HOME="/root"

# install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git zsh curl sudo && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# set ssh
RUN mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh
COPY ./ssh_config ${HOME}/.ssh/config

# set app directory
RUN sudo mkdir /app
WORKDIR /app

# setup zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    sudo chsh -s $(which zsh) && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="essembeh"/g' $HOME/.zshrc
ENV SHELL /bin/zsh
SHELL [ "/bin/zsh", "-c" ]

# setup nvm / node / npm / pnpm
ENV NVM_DIR ${HOME}/.nvm
RUN mkdir -p ${NVM_DIR}
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
ENV NODE_VERSION 20.15.1
RUN source ${NVM_DIR}/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION} && \
    rm -rf ${NVM_DIR}/.* ${NVM_DIR}/*.md ${NVM_DIR}/test ${NVM_DIR}/versions/node/v${NODE_VERSION}/*.md
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g pnpm
ENV PNPM_HOME=${HOME}/.local/share/pnpm
ENV PATH="$PNPM_HOME:$PATH"
RUN pnpm config set store-dir ${PNPM_HOME}/store && \
    pnpm setup zsh

# setup python
ENV PYENV_ROOT="${HOME}/.pyenv" PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip install wheel

# save PATH
RUN echo "export PATH=${PATH}" >> $HOME/.zshrc

# set font
COPY ./fonts/* /usr/share/fonts/SourceHanSans/

# set matplotlibrc
RUN mkdir -p ${HOME}/.config/matplotlib/
COPY ./matplotlib/* ${HOME}/.config/matplotlib/

CMD ["/bin/zsh"]
