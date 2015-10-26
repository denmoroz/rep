FROM ubuntu:14.04
MAINTAINER Andrey Ustyuzhanin <anaderi@yandex-team.ru>
RUN apt-get update && apt-get install -y \
  python2.7 \
  python-pip \
  python-dev \
  libatlas-base-dev \
  gfortran \
  liblapack-dev

RUN apt-get install git dpkg-dev make g++ gcc binutils libx11-dev libxpm-dev libxft-dev libxext-dev libpng3 libjpeg8 gfortran libssl-dev libpcre3-dev libgl1-mesa-dev libglew1.5-dev libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio3-dev graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev libkrb5-dev libgsl0-dev libqt4-dev curl python-pycurl --force-yes -y

RUN apt-get install libcurl4-gnutls-dev libffi-dev wget -y --force-yes

# basic python modules
#
RUN easy_install distribute
# numpy goes first
RUN pip install \
  numpy==1.10.1

ENV TEMP /tmp
RUN curl https://raw.githubusercontent.com/yandex/rep/master/requirements.txt > $TEMP/requirements.txt 
RUN pip install -r $TEMP/requirements.txt

# root.cern.ch
#
RUN sudo apt-get install -y root-system libroot-bindings-python-dev libroot-roofit5.34
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu/root5.34/:$LD_LIBRARY_PATH
ENV PYTHONPATH=/usr/lib/x86_64-linux-gnu/root5.34:$PYTHONPATH
 
#WORKDIR $TEMP
#RUN git clone http://root.cern.ch/git/root.git \
#  && cd root \
#  && git checkout v5-34-21 \
#  && ./configure --prefix=/usr/local --gminimal --enable-asimage --enable-x11 \
#          --enable-python --enable-roofit --enable-xml --enable-minuit2 \
#	  --disable-xrootd --fail-on-missing \
#  && make -j2 \
#  && make install \
#  && cd .. \
#  && rm -rf root
#ENV ROOTSYS /usr/local
#ENV PATH /usr/local/bin:$PATH
#ENV LD_LIBRARY_PATH /usr/local/lib/root:$LD_LIBRARY_PATH
#ENV PYTHONPATH /usr/local/lib/root

RUN easy_install -U pip
RUN pip install \
  rootpy==0.7.1 \
  root_numpy==4.4.0

# XGboost
#

RUN git clone https://github.com/dmlc/xgboost.git $TEMP/xgboost && \
  cd $TEMP/xgboost && \
  ./build.sh && \
  cd python-package && \
  python setup.py install && \
  cd .. && \
  cp tests/python/test_basic.py . && \
  python -c "import test_basic ; test_basic.test_basic()" && \
  cd / && \
  rm -rf $TEMP/xgboost

#RUN git clone https://github.com/tqchen/xgboost.git /xgboost && \
#  cd /xgboost &&\
#  make
#
#ENV PYTHONPATH /usr/local/lib/root:/xgboost/wrapper

# ipykee preparation
#
RUN apt-get install ruby ruby-dev -y --force-yes
RUN gem install nokogiri -v '1.6.3.1' && \
  cd $TEMP && \
  git clone https://github.com/alebedev/git-media.git && cd git-media &&\
  gem install bundler &&\
  bundle install &&\
  gem build git-media.gemspec &&\
  gem install git-media-*.gem &&\
  cd &&\
  rm -rf $TEMP/git-media

RUN cd $TEMP &&\
  git clone https://github.com/tarmstrong/nbdiff.git &&\
  cd nbdiff && pip install . && cd && rm -rf $TEMP/nbdiff

RUN pip install xlrd

# TEST

CMD ["bash"]
