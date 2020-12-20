#!/bin/bash

exist_pem=$(find /root/ -name bundle*.pem)

if [ "${exist_pem}" == '/root/bundle1.pem' ]; then
    echo "current bundle ${exist_pem} and will change to bundle2"
    bundle='bundle2.pem'
    certbot='certbot2'
    delcertbot='certbot1'
else
    bundle='bundle1.pem'
    certbot='certbot1'
    delcertbot='certbot2'
fi

sudo certbot certonly --manual -d example.com --force-renewal

cat /etc/letsencrypt/live/story-toy.de/fullchain.pem /etc/letsencrypt/live/story-toy.de/privkey.pem > "/root/${bundle}"

curl -X PUT --data-binary @/root/$bundle --unix-socket  \
       /run/control.unit.sock  \
       "http://localhost/certificates/${certbot}"

curl -X PUT --data-binary "\"${certbot}\"" --unix-socket        /run/control.unit.sock        'http://localhost/config/listeners/127.0.0.1:8090/tls/certificate'

curl -X PUT --data-binary "\"${certbot}\"" --unix-socket        /run/control.unit.sock        'http://localhost/config/listeners/127.0.0.1:8091/tls/certificate'

curl -X DELETE --unix-socket /run/control.unit.sock  \
      "http://localhost/certificates/${delcertbot}"

rm "${exist_pem}"
