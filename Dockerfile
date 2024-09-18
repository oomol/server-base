FROM ubuntu:jammy

ENV HOME="/root"
ENV LANG="C.UTF-8"

# install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git zsh curl wget sudo ca-certificates && \
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
ENV SHELL="/bin/zsh"
SHELL [ "/bin/zsh", "-c" ]


# setup nvm / node / npm / pnpm
ENV NVM_DIR="${HOME}/.nvm"
RUN mkdir -p ${NVM_DIR}
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
ENV NODE_VERSION="20.15.1"
RUN source ${NVM_DIR}/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION} && \
    rm -rf ${NVM_DIR}/.* ${NVM_DIR}/*.md ${NVM_DIR}/test ${NVM_DIR}/versions/node/v${NODE_VERSION}/*.md
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

RUN npm install -g pnpm
ENV PNPM_HOME="${HOME}/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN pnpm config set store-dir ${PNPM_HOME}/store && \
    pnpm setup zsh

# setup uv and python
ENV PYTHON_VERSION="3.12.1"
ENV PATH="${HOME}/.local/uv_bin/bin/:${PATH}"
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=${HOME}/.local/uv_bin bash && \
    uv python install ${PYTHON_VERSION} 
# ENV is a static command and cannot obtain the architecture information of the local machine.
ENV PATH="${HOME}/.local/share/uv/python/cpython-${PYTHON_VERSION}-linux-x86_64-gnu/bin:${HOME}/.local/share/uv/python/cpython-${PYTHON_VERSION}-linux-aarch64-gnu/bin:${PATH}"

# WSL2 GPU Driver libraries load path
RUN mkdir -p "/etc/ld.so.conf.d" && \
    echo "/usr/lib/wsl/lib" > /etc/ld.so.conf.d/ld.wsl.conf && \
    echo 'ldconfig # /etc/ld.so.cache' >> $HOME/.zshrc
ENV PATH="/usr/lib/wsl/lib/:${PATH}"

# save PATH
# without \$PATH the $PATH will be lost sometime or not be inherited after exec
RUN echo "export PATH=${PATH}:\$PATH" >> $HOME/.zshrc

# set font
COPY ./fonts/* /usr/share/fonts/SourceHanSans/

# set matplotlibrc
RUN mkdir -p ${HOME}/.config/matplotlib/
COPY ./matplotlib/* ${HOME}/.config/matplotlib/

CMD ["zsh"]
