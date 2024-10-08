FROM almalinux:8

# Grab packages needed for development.
RUN yum -y groupinstall "Development Tools"
RUN yum -y install apr-devel \
                   apr-util-devel \
                   epel-release \
                   httpd \
                   httpd-devel \
                   mariadb \
                   mariadb-devel \
                   openssl-devel \
                   python2 \
                   python2-pip \
                   python3-chardet \
                   python3-devel \
                   python3-mod_wsgi \
                   python3-pygments \
                   swig \
                   systemd \
                   wget \
                   which \
                   zlib-devel
RUN python3 -m pip install mysqlclient

# Install CVS requirements.
RUN yum -y install https://vault.centos.org/7.9.2009/os/x86_64/Packages/rcs-5.9.0-7.el7.x86_64.rpm 

# Setup the application home directory.
ENV APP_HOME="/app"
RUN mkdir $APP_HOME
COPY ./src $APP_HOME/src
COPY ./bin $APP_HOME/bin

# Create volume mount points.
RUN mkdir -p /opt/viewvc
RUN mkdir -p /opt/svn
RUN mkdir -p /opt/cvs

# Build Subversion and friends.
RUN /app/bin/build-subversion-stack.sh

STOPSIGNAL SIGTERM
EXPOSE 80
CMD ["/app/bin/entrypoint.sh"]
