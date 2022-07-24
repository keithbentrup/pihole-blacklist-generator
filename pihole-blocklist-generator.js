const fetch = require('node-fetch')
const cheerio = require('cheerio')

;async () => {
  const response = await fetch('https://firebog.net/')
  const body = await response.text()
  const $ = cheerio.load(body)
  const titleList = []
  $('li.bdTick').each((i, title) => {
    const titleNode = $(title)
    const titleText = titleNode.text()
    titleList.push(titleText)
  })

  console.log(titleList)
}
