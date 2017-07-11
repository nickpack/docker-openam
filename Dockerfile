FROM tomcat:8-jre8

MAINTAINER Nick Pack <nick@nickpack.com>

ARG AM_VERSION=5.1.0
ARG AM_KEYSTORE_PASSWORD=changeit

WORKDIR /tmp

COPY AM-eval-${AM_VERSION}.zip /tmp

ENV CATALINA_OPTS="-Xmx2048m -server"

RUN unzip -d unpacked AM-eval-${AM_VERSION}.zip && \
    mv unpacked/openam/AM-eval*.war $CATALINA_HOME/webapps/openam.war && \
    unzip unpacked/openam/SSOAdminTools-${AM_VERSION}.zip -d /root/ssoadmintools && \
    rm -rf *.zip unpacked

RUN openssl req -new -newkey rsa:2048 -nodes -out /opt/server.csr -keyout /opt/server.key -subj "/C=GB/ST=Essex/L=Southend/O=Nick Pack/OU=Technology/CN=openam.test.com" \
    && openssl x509 -req -days 365 -in /opt/server.csr -signkey /opt/server.key -out /opt/server.crt \
    && openssl pkcs12 -export -in /opt/server.crt -inkey /opt/server.key -out /opt/server.p12 -name tomcat -password pass:${AM_KEYSTORE_PASSWORD} \
    && keytool -importkeystore -deststorepass ${AM_KEYSTORE_PASSWORD} -destkeypass ${AM_KEYSTORE_PASSWORD} -destkeystore /opt/server.keystore -srckeystore /opt/server.p12 -srcstoretype PKCS12 -srcstorepass ${AM_KEYSTORE_PASSWORD} -alias tomcat

COPY server.xml ${CATALINA_HOME}/conf/

RUN sed -i "s/KEYSTORE_PASSWORD_PLACEHOLDER/${AM_KEYSTORE_PASSWORD}/g" ${CATALINA_HOME}/conf/server.xml

EXPOSE 8443
