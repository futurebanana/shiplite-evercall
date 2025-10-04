FROM traefik:v3.4.4

ARG version=none
ENV VERSION=$version

EXPOSE 80 443

ADD config/traefik.yml /etc/traefik/traefik.yml

ADD config/conf.d /etc/traefik/conf.d
