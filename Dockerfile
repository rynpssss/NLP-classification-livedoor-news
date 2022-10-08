FROM python:3.9.7-slim-buster

SHELL ["/bin/bash", "-c"]

# apt install
RUN apt-get clean \
    && rm -rf /var/lib/apt/list/* \
    && apt-get update --fix-missing \
    && apt-get -y upgrade --fix-missing\
    && apt-get install -y \
       build-essential \
       cmake curl make vim tmux \
       gcc git g++ \
       wget unzip \
       mecab mecab-ipadic-utf8 libmecab-dev swig \
       --fix-missing

# Mecab
WORKDIR /root
RUN git clone https://github.com/taku910/mecab.git \
    && cd mecab/mecab/ \
    && ./configure --enable-utf8-only --with-charset=utf8 \
    && make \
    && make install \
    && cd ../mecab-ipadic \
    && ./configure --with-charset=utf8 \
    && make \
    && make install

# CRF++ (Cabochaで必要)
WORKDIR /root
RUN curl -L -o CRF++-0.58.tar.gz 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ'
RUN tar -zxf CRF++-0.58.tar.gz
WORKDIR CRF++-0.58
RUN ./configure
RUN make
RUN make install

# CaboCha
WORKDIR /root
ENV CPPFLAGS -I/usr/local/include
RUN curl -c cookies.txt 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU'| sed -r 's/"/\n/g'|grep id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU | grep confirm |sed 's/&amp;/\&/g' | xargs -I{} curl -b cabocha-0.69.tar.bz2 -L -o cabocha-0.69.tar.bz2 {}
RUN tar -jxf cabocha-0.69.tar.bz2
WORKDIR cabocha-0.69
RUN ./configure --prefix=/usr/local --with-charset=utf8
RUN make
RUN make install
RUN echo "/usr/local/lib" >> /etc/ld.so.conf.d/lib.conf
RUN ldconfig

# ssh
RUN mkdir -p -m 0600 ~/.ssh

# poetry
WORKDIR /root/workspace
COPY src/ /root/workspace/src/
COPY pyproject.toml /root/workspace/pyproject.toml
RUN rm -rf /root/workspace/.venv
RUN python -m venv /root/workspace/.venv
ENV HOME=/root
ENV POETRY_HOME=$HOME/.poetry
ENV PATH=$POETRY_HOME/bin:$PATH
RUN curl -sSL https://install.python-poetry.org | python3.9 -
# RUN poetry config virtualenvs.create false
RUN poetry self update \
    && poetry config virtualenvs.in-project true \
    && poetry run pip install --upgrade pip \
    && poetry install
RUN echo export PATH="$PATH" >> ~/.bashrc \
    && echo alias python=python3 >> ~/.bashrc \
    && source ~/.bashrc %

RUN apt-get install -y file
# mecab-ipadic-NEologdのインストール
WORKDIR /root
# RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
#    && cd mecab-ipadic-neologd \
#    && bin/install-mecab-ipadic-neologd -n -y
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
  cd mecab-ipadic-neologd && \
  ./bin/install-mecab-ipadic-neologd -n -y && \
  echo dicdir = `mecab-config --dicdir`"/mecab-ipadic-neologd">/etc/mecabrc && \
  cp /etc/mecabrc /usr/local/etc && \
  cd ..
