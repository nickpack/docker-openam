
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

https://openam.test.com:8443/openam/saml2/jsp/spSSOInit.jsp?metaAlias=/sp&idpEntityID=https://WIN-5MT4QSQBG6K.test.local/adfs/services/trust&NameIDFormat=urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified

https://WIN-5MT4QSQBG6K.test.local/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=https://openam.test.com:8443/openam

c:[Type == "sAmAcctName"]
 => issue(Type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier",
Issuer = c.Issuer, OriginalIssuer = c.OriginalIssuer, Value = c.Value, ValueType = c.ValueType,
Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/format"] = "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified", Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/namequalifier"] = "https://WIN-5MT4QSQBG6K.test.local/adfs/services/trust", Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/spnamequalifier"] = "https://openam.test.com:8443/openam");

keytool -list -keystore /etc/ssl/certs/java/cacerts

ssoadm export-svc-cfg -u amadmin -f password -o ~/backup-`date -u +%F-%m-%S`.xml
