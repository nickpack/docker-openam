
#### Requirements
- Docker 1.9+

#### Build and Run
```
docker build -t openam .
docker run --name openam -p 8443:8443 -d openam
```

#### Build Arguments
- OPENAM_VERSION (default: 13.0.0)
- OPENAM_KEYSTORE_PASSWORD (default: changeit)

##### Example:
```
docker build --build-arg OPENAM_VERSION=12.0.0 --build-arg OPENAM_KEYSTORE_PASSWORD=secret -t openam .
docker run --name openam -p 8443:8443 -d openam
```

#### URL
<https://localhost:8443/openam>


#### ADFS experiment guff
If using self-signed SSL, add to ssoadm:

``
-D"opensso.protocol.handler.pkgs=com.sun.identity.protocol" \
-D"com.iplanet.am.jssproxy.trustAllServerCerts=true" \
``

ssoadm create-metadata-templ -u amadmin -f password -m sp.xml -x sp-extend.xml -s /sp -y https://openam.test.com:8443/openam -c saml2

ssoadm create-metadata-templ -u amadmin -f password -m idp.xml -x idp-extend.xml -i /adfs -y https://WIN-5MT4QSQBG6K.test.local/adfs/services/trust -c saml2
