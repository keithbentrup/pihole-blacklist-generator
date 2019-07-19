#!/usr/bin/env bash

# stop on errors
set -e

# debug
# set -x

# grab the text-only version of the big blocklist collection
curl -sSL 'https://v.firebog.net/hosts/lists.php?type=all' | \
  # curl those urls and normalize the list to just domain names \
  xargs -n 1 curl -sSL | \
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
    s/\s*$/\n/' | \
  # write a pre-filtered list for comparison and debugging
  tee pre-filtered-blocklist.txt | \
  # only keep remaining entries that match valid domain entries (need to find more on valid blocklist format) \
  # start w/ alphanumeric or dot, have 1 or more valid chars, end with "." followed by at least 2 alphanumeric chars \
  perl -ne '/^[[:alnum:]\.][[:alnum:]\-\_\.]+\.[[:alnum:]\-]{2,}$/ and print' | \
  # sort and remove duplicates \
  sort -u | \
  tee blocklist.txt | \
  wc -l
    
echo "entries added to blocklist.txt"    
