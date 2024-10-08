#!/bin/sh

PREVDIR=`pwd`
cd ${APP_HOME}/src
echo "Building Subversion stack inside `pwd`..."

alternatives --set python /usr/bin/python2
python -m pip install --user scons
export PATH="/root/.local/bin:${PATH}"

# libserf
if [ -d "serf" ]; then
    echo "Using local py3c..."
else
    echo "Fetching serf..."
    wget https://archive.apache.org/dist/serf/serf-1.3.10.tar.bz2 -O- | tar xfj -
    mv serf-1.3.10 serf
fi
(cd serf; PYTHON=python2 scons && scons install)
alternatives --set python /usr/bin/python3

# mod_python
if [ -d "mod_python" ]; then
    echo "Using local mod_python..."
else
    echo "Fetching mod_python..."
    wget https://fossies.org/linux/www/apache_httpd_modules/mod_python-3.5.0.tgz -O- | tar xfz -
    mv mod_python-3.5.0 mod_python
fi
(cd mod_python; ./configure && make && make install)

# py3c
if [ -d "py3c" ]; then
    echo "Using local py3c..."
else
    echo "Fetching py3c..."
    wget https://github.com/encukou/py3c/archive/v1.4.tar.gz -O- | tar xfz -
    mv py3c-1.4 py3c
fi
(cd py3c; cp -R include/* /usr/local/include)

# sqlite
if [ -d "sqlite" ]; then
    echo "Using local sqlite..."
else
    echo "Fetching sqlite..."
    wget https://www.sqlite.org/2024/sqlite-autoconf-3460100.tar.gz -O- | tar xfz -
    mv sqlite-autoconf-3460100 sqlite
fi
(cd sqlite; ./configure && make && make install)

# subversion (with python bindings)
if [ -d "subversion" ]; then
    echo "Using local subversion..."
else
    echo "Fetching subversion..."
    wget https://archive.apache.org/dist/subversion/subversion-1.14.3.tar.bz2 -O- | tar xfj -
    mv subversion-1.14.3 subversion
fi
(cd subversion; \
 PYTHON=python3 ./configure --with-py3c=internal --with-lz4=internal --with-utf8proc=internal --with-apxs=/usr/bin/apxs \
     && make install install-swig-py \
     && echo "/usr/local/lib/svn-python" > /usr/lib/python3.6/site-packages/svn.pth \
     && make install-mods-shared && mv /usr/local/libexec/* /usr/lib64/httpd/modules)

cd ${PREVDIR}
