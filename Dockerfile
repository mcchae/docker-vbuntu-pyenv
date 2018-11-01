FROM mcchae/vbuntu-ide
MAINTAINER MoonChang Chae mcchae@gmail.com
LABEL Description="ubuntu desktop env with pyenv (over xfce with xrdp)"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y \
        libbz2-dev zlib1g-dev libncurses5-dev openssl libssl-dev \
        libreadline-dev libsqlite3-dev \
    && apt-get clean \
    && apt-get autoclean

################################################################################
# pyenv install
################################################################################
# next pyenv need bash
RUN mkdir -p /usr/local/toor \
    && mv /bin/sh /bin/sh.org && ln -s /bin/bash /bin/sh
USER root
ENV HOME=/usr/local/toor \
    SHELL=/bin/bash
WORKDIR /root
#ENV PYTHON_VERSION=${PYTHON_VERSION:-3.5.3}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.6.6}
ENV PYENV_ROOT=${HOME}/.pyenv
ENV PATH=${PYENV_ROOT}/bin:${PATH}
RUN  curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer -o ${HOME}/pyenv-installer.sh \
    && touch ${HOME}/.bashrc \
    && /bin/bash -x ${HOME}/pyenv-installer.sh \
    && rm -f ${HOME}/pyenv-installer.sh \
    # Create a file of the pyenv init commands
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /tmp/pyenvinit \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /tmp/pyenvinit \
    && echo 'eval "$(pyenv init -)"' >> /tmp/pyenvinit \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> /tmp/pyenvinit \
    && source /tmp/pyenvinit \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pip install --upgrade pip \
    && pyenv rehash
#    && if [ ! -d ${HOME}/.autoenv ];then git clone git://github.com/kennethreitz/autoenv.git ${HOME}/.autoenv; fi
# autoenv는 docker-xfce에 /usr/local/toor/.autoenv 에 넣어둠

################################################################################
# main
################################################################################
USER root
ADD chroot/usr /usr

WORKDIR /
ENV HOME=/root \
    SHELL=/bin/bash
ENTRYPOINT ["bash", "/startup.sh"]
