#!/usr/bin/env bash
set -e

while getopts "u:" arg; do
  case ${arg} in
    u)
      GITHUB_USER=${OPTARG}
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;;
  esac
done

curl -O https://raw.githubusercontent.com/assemator/tools/master/centos7_wireguard.sh
chmod +x centos7_wireguard.sh
./centos7_wireguard.sh
