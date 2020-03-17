fs = require "fs"
csv = require("csv-stringify")()
wanakana = require "wanakana"

config =
  kanji_path: "data/jouyou-by-stroke-count.txt"
  output_path: "download/extras/jouyou-by-stroke-count-extras.csv"
  output_path_words_only: "download/extras/jouyou-example-words.csv"
  additions_path: "data/extras/manual-additions"
  dictionary_path: "data/extras/jmdict-translations.json"
  add_example_words: true
  example_limit: 5
  example_meanings_limit: 1
  example_separator: "\n"
  kanji_radical_path: "data/extras/kanji-to-radical.csv"
  limit: 3000
  words_limit: 10000
  meanings_path: "data/joyo-meanings.csv"
  radicals_path: "data/extras/japanese-radicals-513ba7a.csv"
  words_path: "data/extras/wordlex-2011.txt"

array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))

get_meanings = (path, additions_path) ->
  result = {}
  a = array_from_newline_file config.meanings_path
  a.forEach (a) ->
    a = a.split ","
    result[a[0]] = a[1]
  # additions that are not found otherwise
  additions = array_from_newline_file additions_path
  additions.forEach (a) ->
    a = a.split ","
    result[a[0]] = a[1]
  result

get_example_words = (kanji, limit, words, dictionary) ->
  # try to find limit number of words with kana and translations.
  result = []
  return result unless limit
  for a in words
    continue unless a.includes kanji
    entry = dictionary[a]
    continue unless entry and entry[1].length
    result.push [a].concat entry
    break if limit is result.length
  result

get_kanji_radical = (path) ->
  # radicals and same looking kanji characters have separate unicode codepoints.
  # this returns a lookup table.
  result = {}
  a = array_from_newline_file(config.kanji_radical_path)
  a.forEach (a) ->
    a = a.split(",")
    return unless 2 is a.length
    key = String.fromCharCode parseInt a[0], 16
    value = String.fromCharCode parseInt a[1], 16
    result[value] = key
  result

get_components = (radicals, kanji_radical) ->
  # return a lookup table from component kanji to details.
  # -> {character: [string:description, string:kana-name], ...}
  result = {}
  for a in radicals
    continue if 2 > a.length
    char = a[1]
    meaning = a[3]
    reading = a[4]
    value = [meaning.split(",")[0]]
    result[char] = value
    if kanji_radical[char]
      result[kanji_radical[char]] = value
  result

get_kanji_info = (kanji, config, meanings, dictionary) ->
  a = meanings[kanji]
  return a if a
  a = components[kanji]
  return a[0] if a
  console.log "no meaning found for #{kanji}"

examples_filter = (a, meanings_limit) ->
  a.map (word) ->
    # get the first word of each sense
    meaning = word[2].map (a) -> a[0]
    if meanings_limit < meaning.length then meaning = meaning.slice(0, meanings_limit)
    [word[0], word[1], meaning]

examples_to_string = (a, separator, meanings_limit) ->
  examples = examples_filter(a, meanings_limit).map (a) ->
    meaning = a[2].join "; "
    "#{a[0]} (#{a[1]}): #{meaning}"
  examples.join(separator)

words = array_from_newline_file(config.words_path)
words = words.slice(0, Math.min(words.length, config.words_limit))
kanjis = array_from_newline_file config.kanji_path
meanings = get_meanings config.meanings_path, config.additions_path
dictionary = object_from_json_file config.dictionary_path
kanji_radical = get_kanji_radical(config.kanji_radical_path)
radicals = array_from_newline_file(config.radicals_path).map((a) -> a.split(";"))
components = get_components radicals, kanji_radical

csv_with_extras = () ->
  # anki doesnt skip csv headers so none is included for now
  csv.pipe fs.createWriteStream config.output_path
  if config.add_example_words
    for kanji, i in kanjis
      examples = get_example_words kanji, config.example_limit, words, dictionary
      examples_string = examples_to_string examples, config.example_separator, config.example_meanings_limit
      info = get_kanji_info kanji, config, meanings, dictionary
      csv.write [kanji, info, examples_string, i]
  else
    for kanji, i in kanjis
      info = get_kanji_info kanji, config, meanings, dictionary
      csv.write [kanji, info, i]
  csv.end()

only_example_words = () ->
  csv.pipe fs.createWriteStream config.output_path_words_only
  config.add_example_words = true
  index = 0
  for kanji in kanjis
    examples = get_example_words kanji, config.example_limit, words, dictionary
    examples = examples_filter examples, config.example_meanings_limit
    for a, i2 in examples
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

only_example_words()
#csv_with_extras()
