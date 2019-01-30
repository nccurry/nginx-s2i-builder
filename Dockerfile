FROM alpine:latest

MAINTAINER Nick Curry <code@nickcurry.io>

EXPOSE 8080
EXPOSE 8443

ENV SUMMARY="" \
    DESCRIPTION=""

LABEL io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Nginx s2i builder" \
      io.openshift.tags="s2i,builder,nginx,alpine" \
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.openshift.expose-services="8080:http" \
      io.openshift.expose-services="8443:https" \
      io.s2i.scripts-url=image:///usr/libexec/s2i \
      com.redhat.deployments-dir="/opt/app-root/src" \
      com.redhat.dev-mode="DEV_MODE:false" \
      com.redhat.dev-mode.port="DEBUG_PORT:5858" \
      maintainer="Nick Curry <code@nickcurry.io>" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      version="0.1.0" \
      name="nccurry/nginx-s2i-builder" \
      help="For more information visit https://github.com/nccurry/nginx-s2i-builder" \
      usage="s2i build --copy . nccurry/nginx-s2i-builder:latest sample-app"

ENV STI_SCRIPTS_PATH=/usr/libexec/s2i \
    APP_ROOT=/opt/app-root \
    HOME=/opt/app-root/src \
    NGINX_CONFIGURATION_PATH=/etc/conf.d \
    NGINX_CONF_PATH=/etc/nginx/nginx.conf

ENV PATH=$HOME/bin:$APP_ROOT/bin:$PATH

COPY ./s2i/ $STI_SCRIPTS_PATH

RUN apk add nginx bash && \
    mkdir -p ${HOME} && \
    adduser -S -u 1001 -G root -h ${HOME} -s /sbin/nologin -g "Default Application User" default && \
    chown -R 1001:0 ${APP_ROOT} && \
    chown -R 1001:0 /etc/nginx && \
    chown -R 10010:0 /var/tmp/nginx && \
    chown -R 10010:0 /var/lib/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

USER 1001

WORKDIR ${HOME}

CMD ${STI_SCRIPTS_PATH}/usage
