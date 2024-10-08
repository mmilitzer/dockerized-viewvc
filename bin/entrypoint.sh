#!/bin/sh

prepare_httpd() {
    mkdir -p /etc/httpd/viewvc-conf.d/
    cp -R ${APP_HOME}/bin/etc/httpd/conf/* /etc/httpd/conf/
    cp -R ${APP_HOME}/bin/etc/httpd/conf.d/${1}/* /etc/httpd/viewvc-conf.d/
    rm -rf /run/httpd/* /tmp/httpd*
}

/opt/viewvc/bin/db/make-database --hostname db --port 3306 --username root --password admin --dbname ViewVC
cat <<EOF | mysql --protocol=TCP --host=db --port=3306 --user=root --password=admin
CREATE USER 'viewvc' IDENTIFIED BY 'viewvc';
GRANT ALL ON ViewVC.* TO 'viewvc';
EOF
case ${VIEWVC_MODE} in
    standalone)
        export PYTHONPATH=/opt/viewvc/lib
        # Add -u here to run in Unicode mode.
        exec python3 /opt/viewvc/bin/standalone.py --host 0.0.0.0 --port 80 --config-file /opt/viewvc/viewvc.conf 2>&1
        ;;
    wsgi)
        prepare_httpd wsgi
        exec /usr/sbin/httpd -DFOREGROUND
        ;;
    cgi)
        prepare_httpd cgi
        exec /usr/sbin/httpd -DFOREGROUND
        ;;
    modpython)
        # mod_wsgi and mod_python can't coexist.
        rm /etc/httpd/conf.modules.d/*wsgi*
        prepare_httpd modpython
        exec /usr/sbin/httpd -DFOREGROUND
        ;;
    *)
        echo "ERROR: Unsupported value for VIEWVC_MODE environment variable." 2>&1
        ;;
esac
