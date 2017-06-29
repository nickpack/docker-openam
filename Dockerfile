FROM tomcat:8-jre8

MAINTAINER Nick Pack <nick@nickpack.com>

ARG OPENAM_VERSION=13.0.0
ARG OPENAM_KEYSTORE_PASSWORD=changeit
ARG OPENAM_DOWNLOAD_URL=https://github.com/OpenRock/OpenAM/releases/download/${OPENAM_VERSION}/OpenAM-${OPENAM_VERSION}.zip

ENV CATALINA_OPTS="-Xmx2048m -server"

RUN wget ${OPENAM_DOWNLOAD_URL} && \
    unzip -d unpacked *.zip && \
    mv unpacked/openam/OpenAM*.war $CATALINA_HOME/webapps/openam.war && \
    rm -rf *.zip unpacked

RUN openssl req -new -newkey rsa:2048 -nodes -out /opt/server.csr -keyout /opt/server.key -subj "/C=GB/ST=Essex/L=Southend/O=Nick Pack/OU=Technology/CN=openam.test.com" \
    && openssl x509 -req -days 365 -in /opt/server.csr -signkey /opt/server.key -out /opt/server.crt \
    && openssl pkcs12 -export -in /opt/server.crt -inkey /opt/server.key -out /opt/server.p12 -name tomcat -password pass:${OPENAM_KEYSTORE_PASSWORD} \
    && keytool -importkeystore -deststorepass ${OPENAM_KEYSTORE_PASSWORD} -destkeypass ${OPENAM_KEYSTORE_PASSWORD} -destkeystore /opt/server.keystore -srckeystore /opt/server.p12 -srcstoretype PKCS12 -srcstorepass ${OPENAM_KEYSTORE_PASSWORD} -alias tomcat

COPY server.xml ${CATALINA_HOME}/conf/

RUN sed -i "s/KEYSTORE_PASSWORD_PLACEHOLDER/${OPENAM_KEYSTORE_PASSWORD}/g" ${CATALINA_HOME}/conf/server.xml

EXPOSE 8443
