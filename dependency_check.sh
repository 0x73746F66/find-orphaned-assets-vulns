#!/usr/bin/env bash

if [ -z "$(which retire)" ]; then
  echo "retire not found"
  echo "Hint: npm i retire -g"
  exit 1
fi
if [ -z "$(which parallel)" ]; then
  echo "parallel not found"
  echo "Hint: apt install -y parallel"
  exit 1
fi
if [ -z "$(which waybackurls)" ]; then
  echo "waybackurls not found"
  echo "Hint: go get github.com/tomnomnom/waybackurls"
  exit 1
fi
echo ok
if [ -z "$(which searchsploit)" ]; then
  echo "optional: searchsploit not found"
  echo "Hint: https://github.com/offensive-security/exploitdb"
fi
exit 0