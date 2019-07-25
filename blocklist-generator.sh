#!/usr/bin/env bash

# stop on errors
# set -e

# debug
# set -x

blocklist_path_prefix=/tmp/.tmp-blocklist
# remove old tmp blocklists if they exist
rm $blocklist_path_prefix-http* || :

# find the right list of blocklists for you from firebog
# prune that list (here)
# then whitelist the few remaining necessary domains (in pihole) 

# grab your preferred text-only version of the big blocklist collection
curl -sSL 'https://v.firebog.net/hosts/lists.php?type=nocross' | \
  # remove over aggressive lists with too many valid whitelist domains
  grep -v hostsfile.org | \
  # how do you find over aggressive lists?
  # save tmp blocklists to grep later for repeated false positives during a trial phase
  xargs -n 1 -I % bash -c 'curl -sSL "%" -o '$blocklist_path_prefix'-$(echo % | tr '/' '_' | tr -cd '[:alnum:]\_\.\-\n')'

# normalize the blocklists to just lists of domain names
perl -pe '
  # remove leading ip addresses
  s/^(\d+\.){3}\d+\s*//;
  # remove trailing comments
  s/\s*#.*//;
  # remove some html 
  s/<.*//;
  # remove everything after ";"
  s/;.*//;
  # remove some IPv6 prefixes
  s/:.*\s+//;
  # some lines from some lists start with "0 " 
  s/^0\s+//;
  # remove trailing whitespace including "\r" endings
  s/\s*$/\n/' \
  $blocklist_path_prefix-* | \
  # only keep remaining entries that match valid domain entries (need to find more on valid blocklist format)
  # start w/ alphanumeric or dot, have 1 or more valid chars, end with "." followed by at least 2 alphanumeric chars
  perl -ne '/^[[:alnum:]\.][[:alnum:]\-\_\.]+\.[[:alnum:]\-]{2,}$/ and print' | \
  # sort and remove duplicates
  sort -u | \
  tee blocklist.txt | \
  wc -l
    
echo "entries added to blocklist.txt"

