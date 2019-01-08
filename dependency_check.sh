#!/usr/bin/env bash

if [ -z $(which retire) ]; then
  echo "retire not found. try npm install -g retire"
  exit 1
fi
if [ -z $(which parallel) ]; then
  echo "parallel not found. try 'apt install -y parallel'"
  exit 1
fi
if [ -z $(which waybackurls) ]; then
  echo "waybackurls not found. try 'go get github.com/tomnomnom/waybackurls'"
  exit 1
fi
echo ok
if [ -z $(which searchsploit) ]; then
  echo "optional: searchsploit not found"
fi
exit 0
