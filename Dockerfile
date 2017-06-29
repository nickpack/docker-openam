FROM tomcat:8-jre8

MAINTAINER Fábio Matos <fabiomatos@gmail.com>

ARG OPENAM_VERSION=13.0.0
ARG OPENAM_KEYSTORE_PASSWORD=changeit

ENV CATALINA_OPTS="-Xmx2048m -server"

RUN wget https://github.com/OpenRock/OpenAM/releases/download/${OPENAM_VERSION}/OpenAM-${OPENAM_VERSION}.zip && \
    unzip -d unpacked *.zip && \
    mv unpacked/openam/OpenAM*.war $CATALINA_HOME/webapps/openam.war && \
    rm -rf *.zip unpacked

RUN openssl req -new -newkey rsa:2048 -nodes -out /opt/server.csr -keyout /opt/server.key -subj "/C=DE/ST=Berlin/L=Berlin/O=Zalando SE/OU=Technology/CN=openam.dev" \
    && openssl x509 -req -days 365 -in /opt/server.csr -signkey /opt/server.key -out /opt/server.crt \
    && openssl pkcs12 -export -in /opt/server.crt -inkey /opt/server.key -out /opt/server.p12 -name tomcat -password pass:${OPENAM_KEYSTORE_PASSWORD} \
    && keytool -importkeystore -deststorepass ${OPENAM_KEYSTORE_PASSWORD} -destkeypass ${OPENAM_KEYSTORE_PASSWORD} -destkeystore /opt/server.keystore -srckeystore /opt/server.p12 -srcstoretype PKCS12 -srcstorepass ${OPENAM_KEYSTORE_PASSWORD} -alias tomcat

COPY server.xml ${CATALINA_HOME}/conf/

RUN sed -i "s/KEYSTORE_PASSWORD_PLACEHOLDER/${OPENAM_KEYSTORE_PASSWORD}/g" ${CATALINA_HOME}/conf/server.xml
