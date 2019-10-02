#!/usr/bin/env bash

target_host=$1
severity=$2
workdir=`pwd`
target_dir=${workdir}/target_${target_host}
exploits_dir=${target_dir}/exploits
urls_file=${target_dir}/url_list.txt
retirejs_file=${target_dir}/retirejs.json
searchsploit_file=${target_dir}/searchsploit.json

if [ -z "${severity}" ]; then
  severity=low
fi

embed_newline()
{
   local p="$1"
   shift
   for i in "$@"
   do
      p="$p"$'\n'"$i"    # Append
   done
   echo "$p"             # No need -e
}

if [ -z ${target_host} ]; then
  echo -e "pass in a domain"
  exit 1
fi

mkdir -p ${target_dir}
mkdir -p ${exploits_dir}
rm ${urls_file} 2>/dev/null
rm ${urls_file}.tmp 2>/dev/null
waybackurls ${target_host} | grep -Ei '*.js|*.css|*.txt' | uniq | sort >>${urls_file}.tmp

if [ -z "$(cat ${urls_file}.tmp)" ]; then
  echo "no urls found in waybackmachine for ${target_host}"
  exit 0
fi

# use the output to get only urls with Status:200
cat ${urls_file}.tmp | \
  parallel -j50 -q curl -X HEAD -Lw 'Status:%{http_code}\t Size:%{size_download}\t %{url_effective}\n' -o /dev/null -sk | \
  grep 'Status:200' | \
  egrep -o 'https?://[^ ]+' >>${urls_file}

rm ${urls_file}.tmp

# TODO get list of redirects from tmp_${urls_file} and try https, add to ${urls_file}
# if [ "$rewrite_to_https" = "true" ]; then
#   while read -r line; do
#     url=`echo ${line/http:/https:}`
#     urls="$( embed_newline ${url} ${urls} )"
#   done <<< "${waybackurls}"
# else
#   urls=${waybackurls}
# fi

cd ${target_dir}
echo Downloading website files
cat ${urls_file} | xargs wget --timestamping 2>/dev/null
cd ${workdir}
echo Detecting vulnerabilities
if [ -z "$(which searchsploit)" ]; then
  # if not using searchsploit just display findings and exit
  retire --path ${target_dir} --severity ${severity} --colors
  exit 0
fi

retire --path ${target_dir} --severity ${severity} --outputformat json --outputpath ${retirejs_file}

jq -r '.data[].results[].component' ${retirejs_file} | uniq | paste -sd ' ' \
| xargs searchsploit --json > ${searchsploit_file}
echo "Searched: $(jq -r '.SEARCH' ${searchsploit_file})"
jq -r '.RESULTS_EXPLOIT[].Path' ${searchsploit_file} | xargs cp -t ${exploits_dir} 2>/dev/null

jq -r '.data[].results[].component + " " + .data[].results[].version' ${retirejs_file} | uniq | paste -sd ' ' \
| xargs searchsploit --json > ${searchsploit_file}
echo "Searched: $(jq -r '.SEARCH' ${searchsploit_file})"
jq -r '.RESULTS_EXPLOIT[].Path' ${searchsploit_file} | xargs cp -t ${exploits_dir} 2>/dev/null

jq -r '.data[].results[].vulnerabilities[].identifiers.CVE[]' ${retirejs_file} | uniq | paste -sd ' ' \
| xargs searchsploit --json > ${searchsploit_file}
echo "Searched: $(jq -r '.SEARCH' ${searchsploit_file})"
jq -r '.RESULTS_EXPLOIT[].Path' ${searchsploit_file} | xargs cp -t ${exploits_dir} 2>/dev/null
echo "Check for exploits in: ${exploits_dir}"
exit 0