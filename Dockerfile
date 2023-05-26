FROM jboss/Vault:latest

ENV Vault_User=admin
ENV Vault_Password=admin

COPY realm-export.json /tmp/realm-export.json

CMD ["-b", "0.0.0.0", "-Dvault.import=/tmp/realm-export.json"]