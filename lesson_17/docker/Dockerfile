FROM alpine:3.15.4

RUN apk add --no-cache nginx && mkdir -p /run/nginx

EXPOSE 8080

COPY custom.conf /etc/nginx/http.d/

COPY . /opt/

CMD [ "nginx", "-g", "daemon off;"]
