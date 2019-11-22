#!/usr/bin/env bash
#
# Create self-signed key & cert

mkdir -p ./ssl
rm -rf ./ssl/*

openssl req \
  -x509 \
  -newkey rsa:4096 \
  -nodes \
  -subj '/C=JP/ST=Osaka/L=example/O=example/CN=openam.example.net' \
  -keyout ./ssl/webserver-key.pem \
  -out ./ssl/webserver-cert.pem \
  -days 36500
