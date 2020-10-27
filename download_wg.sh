#!/usr/bin/env bash
set -e

curl -O https://raw.githubusercontent.com/assemator/tools/master/centos7_wireguard.sh
chmod +x centos7_wireguard.sh
./centos7_wireguard.sh
