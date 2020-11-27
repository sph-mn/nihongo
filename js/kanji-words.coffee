# code to generate csv with kanji, meaning, readings and example words with readings and meanings.
# any field can be excluded from the result. see default_config.

fs = require "fs"
csv_parse = require "csv-parse/lib/sync"
csv_stringify = require "csv-stringify"
wanakana = require "wanakana"
array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))
read_csv_file = (path, delimiter) -> csv_parse fs.readFileSync(path, "utf-8"), {delimiter: delimiter}
object_merge = require "deepmerge"

array_take = (a, n) ->
  return a unless 0 < n
  a.slice 0, Math.min(a.length, n)

array_limit = (a, n) ->
  if 0 is n then []
  else if n < a.length then a.slice(0, n)
  else a

default_config =
  csv_delimiter: " "
  dictionary_path: "data/jmdict-translations-examples.json"
  output_path: "download/jouyou-kanji-learning.csv"
  sort_by_readings: true
  kanji:
    include: true
    include_kanji: true
    include_meaning: true
    include_readings: true
    path: "download/jouyou-kanji.csv"
    reading_separator: "/"
  words:
    as_column: true
    include: true
    include_word: true
    include_readings: true
    include_meanings: true
    path: "data/wordlex-2011.txt"
    limit: 3
    meanings_limit: 3
    readings_limit: 2
    separator: "\n"
    data_separator: " - "
    meaning_separator: "; "
    reading_separator: "/"

remove_duplicate_readings = (a) ->
  # "kyuu/oyo-bu/oyo-bi/oyo-bosu" -> "kyuu/oyo"
  parse_readings_no_duplicates(a).join "/"

parse_readings_no_duplicates = (a) ->
  a = a.split("/")
  a = a.map (a) -> a.split("-")[0].replace("'", "")
  a.filter (a, i, self) -> self.indexOf(a) == i

get_example_words = (kanji, dictionary, words, config) ->
  result = []
  return result if 0 == config.words.limit
  meanings_limit = config.words.meanings_limit
  readings_limit = config.words.readings_limit
  for a in words
    continue unless a.length > 1
    continue unless a.includes kanji
    entry = dictionary[a]
    continue unless entry
    # currently only one reading in input data
    readings = array_limit([entry[0]], readings_limit)
    meanings = array_limit(entry[1], meanings_limit)
    result.push [a, readings, meanings]
    break if config.words.limit <= result.length
  result

get_kanji_words = (config) ->
  # -> [[kanji, meaning, [reading, ...], [[word, reading, [meaning, ...]], ...]]]
  kanji_data = read_csv_file config.kanji.path, " "
  dictionary = object_from_json_file config.dictionary_path
  words = array_from_newline_file config.words.path
  result = []
  kanji_data.map (a) ->
    kanji = a[0]
    meaning = a[1]
    readings = parse_readings_no_duplicates a[2]
    examples = get_example_words kanji, dictionary, words, config
    [kanji, meaning, readings, examples]

join_words = (words, config) ->
  # convert the nested word/readings/meanings array into one string
  words = words.map (a) ->
    b = []
    if config.words.include_word
      b.push a[0]
    if config.words.include_readings
      b.push a[1].join(config.words.reading_separator)
    if config.words.include_meanings
      meanings = a[2].join(config.words.meaning_separator)
      b.push meanings
    if config.words.as_column then b.join(config.words.data_separator)
    else b
  if config.words.as_column then words.join(config.words.separator)
  else words

get_kanji_words_csv_data = (config) ->
  # get kanji_words data with nested arrays joined for csv columns
  result = []
  data = get_kanji_words config
  if config.sort_by_readings
    data = data.sort (a, b) ->
      diff = a[2].length - b[2].length
      if 0 is diff then a[2].join("/").localeCompare(b[2].join("/"))
      else diff
  for a in data
    if config.kanji.include
      row = []
      if config.kanji.include_kanji
        row.push a[0]
      if config.kanji.include_meaning
        row.push a[1]
      if config.kanji.include_readings
        row.push a[2].join(config.kanji.reading_separator)
      if config.words.include && config.words.as_column
        row.push join_words(a[3], config)
      result.push row
    if config.words.include && !config.words.as_column
      result = result.concat join_words(a[3], config)
  result

update_kanji_words_csv = (config) ->
  # create a csv file
  config = object_merge.all [{}, default_config, config]
  data = get_kanji_words_csv_data config
  csv_out = csv_stringify({delimiter: config.csv_delimiter})
  csv_out.pipe fs.createWriteStream config.output_path
  for a in data
    csv_out.write a
  csv_out.end()

module.exports = {
  update_kanji_words_csv
  get_kanji_words
  get_kanji_words_csv_data
}
