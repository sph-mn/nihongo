fs = require "fs"
csv_parse = require "csv-parse/lib/sync"
csv_stringify = require "csv-stringify"
wanakana = require "wanakana"
array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))
read_csv_file = (path) -> csv_parse fs.readFileSync(path, "utf-8"), {delimiter: ","}

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
    return result unless config.example_word_limit
    for a in words
      continue unless a.includes kanji
      entry = dictionary[a]
      continue unless entry and entry[1].length
      result.push [a].concat entry
      break if config.example_word_limit is result.length
    result.map (word) ->
      # get the first word of each sense
      meaning = word[2]
      if config.example_meanings_limit < meaning.length
        meaning = meaning.slice(0, config.example_meanings_limit)
      [word[0], word[1], meaning]

update_jouyou_with_words = (config) ->
  # kanji, meaning, readings, words
  kanji_data = read_csv_file config.kanji_path
  get_example_words = get_example_words_f config
  csv_out = csv_stringify()
  csv_out.pipe fs.createWriteStream config.output_path
  for kanji, i in kanji_data
    examples = get_example_words kanji[0]
    examples_string = example_words_to_string examples, config.example_word_separator
    csv_out.write [kanji[0], kanji[1], kanji[2], examples_string]
  csv_out.end()

update_jouyou_only_words = (config) ->
  # word, pronounciation, meanings
  kanji_data = read_csv_file config.kanji_path
  get_example_words = get_example_words_f config
  csv_out = csv_stringify()
  csv_out.pipe fs.createWriteStream config.output_path
  words = {}
  for kanji in kanji_data
    examples = get_example_words kanji[0]
    for a in examples
      # ignore duplicates
      continue if words[a[0]]
      words[a[0]] = true
      a[2] = a[2].join "; "
      a[1] = wanakana.toRomaji(a[1])
      csv_out.write a
  csv_out.end()

module.exports = {
  update_jouyou_with_words
  update_jouyou_only_words
}
