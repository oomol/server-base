FROM --platform=$BUILDPLATFORM ubuntu:22.04
ENV HOME="/root"

RUN apt-get update
RUN apt-get install -y libsecret-1-dev libzmq3-dev libzmq5 jq curl libbz2-dev libssl-dev libreadline-dev libncurses5 libncurses5-dev libncursesw5
RUN apt-get install -y gcc g++ make git zsh

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash
RUN apt-get install -y nodejs

ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN apt-get install -y liblzma-dev libsqlite3-dev
RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | sh
RUN mkdir -p $HOME/.pyenv/cache
RUN v=3.9.16; curl -L https://npmmirror.com/mirrors/python/$v/Python-$v.tar.xz -o $HOME/.pyenv/cache/Python-$v.tar.xz; pyenv install $v; pyenv global $v

CMD ["/bin/sh"]

