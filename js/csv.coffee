fs = require "fs"
csv = require("csv-stringify")()
wanakana = require "wanakana"
fs = require "fs"
csv = require("csv-stringify")()
array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))

get_meanings = (path) ->
  # -> {kanji: meaning}
  result = {}
  a = array_from_newline_file path
  a.forEach (a) ->
    a = a.split ","
    result[a[0]] = a[1]
  result

example_words_to_string = (a, separator) ->
  a = a.map (a) ->
    meaning = a[2].join "; "
    "#{a[0]} (#{a[1]}): #{meaning}"
  a.join(separator)

get_example_words_f = (config) ->
  dictionary = object_from_json_file config.dictionary_path
  words = array_from_newline_file config.word_frequency_path
  words = words.slice 0, Math.min(words.length, config.word_frequency_limit)
  (kanji) ->
    # try to find limit number of words with kana and translations.
    result = []
    return result unless config.example_words_limit
    for a in words
      continue unless a.includes kanji
      entry = dictionary[a]
      continue unless entry and entry[1].length
      result.push [a].concat entry
      break if config.example_words_limit is result.length
    result.map (word) ->
      # get the first word of each sense
      meaning = word[2].map (a) -> a[0]
      if config.example_meanings_limit < meaning.length
        meaning = meaning.slice(0, config.example_meanings_limit)
      [word[0], word[1], meaning]

update_csv_with_words = (config) ->
  kanji_list = array_from_newline_file config.kanji_path
  meanings = get_meanings config.meanings_path
  get_example_words = get_example_words_f config
  csv.pipe fs.createWriteStream config.output_path
  for kanji, i in kanji_list
    examples = get_example_words kanji
    examples_string = example_words_to_string examples, config.example_word_separator
    info = meanings[kanji]
    csv.write [kanji, info, examples_string, i]
  csv.end()

update_jouyou_words = (config) ->
  kanji_list = array_from_newline_file config.kanji_path
  get_example_words = get_example_words_f config
  csv.pipe fs.createWriteStream config.output_path
  words = {}
  index = 0
  for kanji in kanji_list
    examples = get_example_words kanji
    for a in examples
      # ignore duplicates
      continue if words[a[0]]
      words[a[0]] = true
      a[2] = a[2].join "; "
      a[1] = wanakana.toRomaji a[1]
      # partofspeech, sort index
      a.push ""
      a.push index
      csv.write a
      index += 1
  csv.end()

update_csv = (config) ->
  # creates a csv file at config.output_path.
  # anki import doesnt skip csv headers so none is written for now.
  kanji_order = array_from_newline_file config.kanji_order_path
  meanings = get_meanings config.meanings_path
  csv.pipe fs.createWriteStream config.output_path
  for kanji, i in kanji_order
    csv.write [kanji, meanings[kanji], i]
  csv.end()

module.exports = {
  update_csv
  update_csv_with_words
  update_jouyou_words
}
