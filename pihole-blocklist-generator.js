#!/usr/bin/env node

const fetch = require('node-fetch')

;(async () => {
  const response = await fetch('https://v.firebog.net/hosts/lists.php?type=nocross')
  const body = await response.text()
  const urls = body.trim().split('\n')

  // console.log(urls)

  const texts = await Promise.all(urls.map(async url => {
    const resp = await fetch(url)
    const txt = await resp.text()
    // use this to inspect badly formatted lines in the output
    // put a unique string from the offending matched line in the regex
    // if (/PUTUNIQUESTRINGHERE/.test(txt)) {
    //   console.log(txt.substring(0,500))
    // }
    return txt
  }));

  let combined = {}
  texts.forEach(txt => {
    txt = txt.replace(/\s*(\n|$)/g, '$1') // remove trailing whitespace
    txt = txt.replace(/\s*[#;].*(\n|$)/g, '$1') // remove trailing comments
    txt = txt.replace(/(^|\n)\s*/g, '$1') // remove leading whitespace
    txt = txt.replace(/(^|\n)#.*/g, '$1') // lines beginning with #
    txt = txt.replace(/(^|\n)\d+\.\d+\.\d+\.\d+\s+(.*)/g, '$1$2') // drop any preceding IPv4 address
    txt = txt.replace(/^(^|\n)[0-9A-Fa-f:]+\s+(.*)/g, '$1$2') // drop any preceding IPv6 address
    // fix at least one badly formatted list from firebog where there's no space between an IP and hostname
    txt = txt.replace(/(^|\n)0\.0\.0\.0(.*)/g, '$1$2')
    let lines = txt.split('\n')
    lines.forEach(line => {
      if (/\.[a-z][a-z0-9]{1,}$/.test(line)) { // line must end in valid TLD (ref https://stackoverflow.com/questions/9071279/number-in-the-top-level-domain)
        combined[line] = null
      } else {
        // console.log(line) // inspect what's being skipped
      }
    })
  })
  console.log(Object.keys(combined).sort().join('\n'))

})()
