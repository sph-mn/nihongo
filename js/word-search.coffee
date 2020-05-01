fs = require "fs"
wanakana = require "wanakana"
array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))

for_each_frequent_word_translations = (config, f) ->
  dictionary = object_from_json_file config.dictionary_path
  words = array_from_newline_file config.word_frequency_path
  words = words.slice 0, Math.min(words.length, config.word_frequency_limit)
  words = words.filter (a) -> a.length > 1
  return unless config.word_frequency_limit
  for word in words
    entry = dictionary[word]
    continue unless entry
    meanings = entry[1].map (a) -> a[0]
    if config.meanings_limit < meanings.length
      meanings = meanings.slice(0, config.meanings_limit)
    romaji = wanakana.toRomaji entry[0]
    f [word, romaji, meanings]

update_frequent_word_translations = (config) ->
  result = []
  for_each_frequent_word_translations config, (a) -> result.push a
  fs.writeFileSync config.output_path, JSON.stringify result

update_word_search = (config) ->
  html = fs.readFileSync config.html_path, "utf8"
  translations = JSON.parse fs.readFileSync(config.translations_path, "utf8")
  translations = translations.sort (a, b) ->
    if a[1].length == b[1].length then 0
    else if a[1].length < b[1].length then -1
    else 1
  html = html.replace "{content}", JSON.stringify(translations)
  fs.writeFile config.output_path, html, (error) ->
    if error then console.error error

module.exports =
  update_frequent_word_translations: update_frequent_word_translations
  update_word_search: update_word_search
