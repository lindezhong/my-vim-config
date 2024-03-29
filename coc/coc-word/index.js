const { sources } = require('coc.nvim')
const path = require('path')
const fs = require('fs')

let words = []
let wordMap = {}

exports.activate = async context => {
  let file = path.resolve(__dirname, 'word.txt')
  fs.readFile(file, 'utf8', (err, content) => {
    if (err) return
    let fileWords = content.split(/\n/)
    words = fileWords.map(word => word.split(" : ")[0])
    fileWords.forEach(word => {
      wordMap[word.split(" : ")[0]] = word
    })
  })

  context.subscriptions.push(sources.createSource({
    name: 'word',
    triggerCharacters: [],
    doComplete: async function (opt) {
      if (!opt.input) return null
      if (!/^[A-Za-z]{1,}$/.test(opt.input)) return null
      let first = opt.input[0]
      let list = words.filter(s => s[0] == first.toLowerCase())
      let code = first.charCodeAt(0)
      let upperCase = code <= 90 && code >= 65
      return {
        items: list.map(str => {
          let word = upperCase ? str[0].toUpperCase() + str.slice(1) : str
          return {
            word: word,
            info: wordMap[str],
            menu: this.menu
          }
        })
      }
    }
  }))
}
