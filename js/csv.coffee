fs = require "fs"
csv_parse = require "csv-parse/lib/sync"
csv_stringify = require "csv-stringify"
wanakana = require "wanakana"
array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))
csv_delimiter = " "
read_csv_file = (path) -> csv_parse fs.readFileSync(path, "utf-8"), {delimiter: csv_delimiter}

example_words_to_string = (a, separator) ->
  a = a.map (a) ->
    meaning = a[2].join "; "
    "#{a[0]} (#{a[1]}): #{meaning}"
  a.join(separator)

get_example_words_f = (config) ->
  # f :: kanji -> [[kanji, readings, meanings], ...]
  dictionary = object_from_json_file config.dictionary_path
  words = array_from_newline_file config.word_frequency_path
  if config.word_frequency_limit
    words = words.slice 0, Math.min(words.length, config.word_frequency_limit)
  (kanji) ->
    # try to find limit number of words with kana and translations.
    result = []
    for a in words
      continue unless a.includes kanji
      entry = dictionary[a]
      continue unless entry and entry[1].length
      result.push [a].concat entry
      break if config.example_word_limit <= result.length
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
  csv_out = csv_stringify({delimiter: csv_delimiter})
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
  csv_out = csv_stringify({delimiter: csv_delimiter})
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

remove_duplicate_readings = (a) ->
  a = a.split("/")
  a = a.map (a) -> a.split("-")[0].replace("'", "")
  a = a.filter (a, i, self) -> self.indexOf(a) == i
  a.join "/"

update_jouyou_learning = (config) ->
  # create csv of the format [kanji, meaning, readings, word, ...].
  # sorted by number-of-readings and readings alphabetically.
  # tries to exclude words already included in previous lines and single-kanji words.
  kanji_data = read_csv_file config.kanji_path
  get_example_words = get_example_words_f config
  csv_out = csv_stringify({delimiter: csv_delimiter})
  csv_out.pipe fs.createWriteStream config.output_path
  words = {}
  csv_data = []
  for a in kanji_data
    kanji = a[0]
    meaning = a[1]
    readings = remove_duplicate_readings a[2]
    examples = get_example_words kanji
    examples = examples.map (a) -> a[0]
    # avoid previous words and single kanji words
    if examples.length
      difference = examples.filter((x) -> x.length > 1 && !words[x])
      if (0 is difference.length) then examples = [examples[0]]
      else examples = difference
      if examples.length > config.example_word_limit_final
        examples = examples.slice(0, config.example_word_limit_final)
    else examples = [kanji]
    examples_string = examples.join(config.example_word_separator)
    csv_data.push [kanji, meaning, readings, examples_string]
  csv_data = csv_data.sort (a, b) ->
    diff = a[2].split("/").length - b[2].split("/").length
    if 0 is diff then a[2].localeCompare(b[2])
    else diff
  for a in csv_data
    csv_out.write a
  csv_out.end()

module.exports = {
  update_jouyou_learning
  update_jouyou_with_words
  update_jouyou_only_words
}
