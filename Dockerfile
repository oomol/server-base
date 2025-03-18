FROM ubuntu:24.04

ENV HOME="/root"
ENV LANG="C.UTF-8"

# install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git zsh curl wget sudo ca-certificates build-essential locales-all tar xz-utils uuid-runtime libtalloc-dev unzip openssh-client && \
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
ENV NODE_VERSION="v22.14.0"

RUN curl -fsSL https://raw.githubusercontent.com/Schniz/fnm/refs/tags/v1.37.2/.ci/install.sh | bash
ENV FNM_PATH="$HOME/.local/share/fnm"
ENV PATH="${FNM_PATH}/node-versions/$NODE_VERSION/installation/bin:${PATH}"

RUN source $HOME/.zshrc && \
    fnm install ${NODE_VERSION} && \
    fnm use ${NODE_VERSION} && \
    fnm alias default ${NODE_VERSION}

RUN npm install -g pnpm
ENV PNPM_HOME="${HOME}/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN pnpm config set store-dir ${PNPM_HOME}/store && \
    pnpm setup zsh

# setup uv and python
ENV PYTHON_VERSION="3.10.12"
ENV PATH="${HOME}/.local/uv_bin/:${PATH}"

# We need to make python effective globally, but uv currently does not have a command to directly obtain the full path of the current python, so it can be done by manual concatenation.
# Also, there is no elegant way to get the current architecture, so we can only solve it by adding all the paths for x64 and arm64 to PATH.
ENV PATH="${HOME}/.local/share/uv/python/cpython-${PYTHON_VERSION}-linux-x86_64-gnu/bin:${HOME}/.local/share/uv/python/cpython-${PYTHON_VERSION}-linux-aarch64-gnu/bin:${PATH}"

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=${HOME}/.local/uv_bin bash && \
    uv python install ${PYTHON_VERSION} && \
    rm "$(python3 -c "import site, sysconfig; print(sysconfig.get_path('stdlib'));")/EXTERNALLY-MANAGED"


# WSL2 GPU Driver libraries load path
RUN mkdir -p "/etc/ld.so.conf.d" && \
    echo "/usr/lib/wsl/lib" > /etc/ld.so.conf.d/ld.wsl.conf && \
    echo 'ldconfig # /etc/ld.so.cache' >> $HOME/.zshrc
ENV PATH="/usr/lib/wsl/lib/:${PATH}"

# save PATH
# without \$PATH the $PATH will be lost sometime or not be inherited after exec
RUN echo "export PATH=${PATH}:\$PATH" >> $HOME/.zshrc && \
    echo "DISABLE_AUTO_UPDATE=true" >> $HOME/.zshrc

# set font
COPY ./fonts/* /usr/share/fonts/SourceHanSans/

# set matplotlibrc
RUN mkdir -p ${HOME}/.config/matplotlib/
COPY ./matplotlib/* ${HOME}/.config/matplotlib/

# set default timezone
RUN echo "Etc/UTC" > /etc/timezone

CMD ["zsh"]
