FROM python:3.9.7-buster
ARG DEBIAN_FRONTEND=noninteractive

# パッケージの追加とタイムゾーンの設定
# 必要に応じてインストールするパッケージを追加してください
RUN apt-get update && apt-get install -y \
    tzdata \
&&  ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

ENV TZ=Asia/Tokyo

# JupyterLab関連のパッケージ（いくつかの拡張機能を含む）
# 必要に応じて、JupyterLabの拡張機能などを追加してください
RUN python3 -m pip install --upgrade pip \
&&  pip install --no-cache-dir \
    black \
    jupyterlab \
    jupyterlab_code_formatter \
    jupyterlab-git \
    lckr-jupyterlab-variableinspector \
    jupyterlab_widgets \
    ipywidgets \
    import-ipynb

# 基本モジュール
RUN pip install --no-cache-dir \
    numpy \
    pandas \
    scikit-learn \
    matplotlib \
    japanize_matplotlib \
    seaborn \
    statsmodels

WORKDIR workspace

# Install MeCab
# RUN apt-get update \
#  && apt-get install -y mecab


# Install mecab-ipadic-NEologd
# RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git /tmp/neologd \
#   && /tmp/neologd/bin/install-mecab-ipadic-neologd -n -a -y \
#   && sed -i -e "s|^dicdir.*$|dicdir = /usr/lib/mecab/dic/mecab-ipadic-neologd|" /etc/mecabrc \
#   && rm -rf /tmp/neologd

# Install neologdn
# RUN pip install neologdn
