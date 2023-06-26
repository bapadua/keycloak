FROM quay.io/keycloak/keycloak:latest as builder
#version 1.0
# Enable health and metrics support
ENV KC_HEALTH_ENABLED=false
ENV KC_METRICS_ENABLED=false

# Configure a database vendor
ENV KC_DB=${{ secrets.KEYCLOAK_DB }}

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running db instance
ENV KC_DB=${{ secrets.KEYCLOAK_DB }}
ENV KC_DB_URL=${{ secrets.KEYCLOAK_DB_URL }}
ENV KC_DB_USERNAME=${{ secrets.KEYCLOAK_DB_USERNAME }}
ENV KC_DB_PASSWORD=${{ secrets.KEYCLOAK_DB_PASSWORD }}
ENV KC_HOSTNAME=${{ secrets.KEYCLOAK_HOSTNAME }}
ENV KEYCLOAK_ADMIN=${{ secrets.KEYCLOAK_ADMIN }}
ENV KEYCLOAK_ADMIN_PASSWORD=${{ secrets.KEYCLOAK_ADMIN_PASSWORD }}

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]