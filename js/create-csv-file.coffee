fs = require "fs"
csv = require("csv-stringify")()

config =
  additions_path: "data/manual-additions"
  dictionary_path: "data/jmdict-translations.json"
  example_limit: 5
  example_translation_limit: 2
  example_translation_word_limit: 1
  kanji_path: "data/aozora-694107d.txt"
  kanji_radical_path: "data/kanji-to-radical.csv"
  limit: 3000
  meanings_path: "data/joyo-meanings.csv"
  output_path: "download/topokanji-deck.csv"
  radicals_path: "data/japanese-radicals-513ba7a.csv"
  word_separator: "\n"
  words_path: "data/wordlex-2011.txt"

array_from_newline_file = (path) -> fs.readFileSync(path).toString().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))

get_meanings = (path, additions_path) ->
  result = {}
  # additions not found otherwise
  a = array_from_newline_file config.meanings_path
  a.forEach (a) ->
    a = a.split ","
    result[a[0]] = a[1]
  additions = array_from_newline_file additions_path
  additions.forEach (a) ->
    a = a.split ","
    result[a[0]] = a[1]
  result

get_example_words = (kanji, limit, words, dictionary) ->
  # try to find $count number of words with kana and translations.
  result = []
  return result unless limit
  for a in words
    continue unless a.includes kanji
    entry = dictionary[a]
    continue unless entry
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
    value = [meaning.split(",")[0], reading]
    result[char] = value
    if kanji_radical[char]
      result[kanji_radical[char]] = value
  result

words = array_from_newline_file(config.words_path).slice(0, 100100)
kanjis = array_from_newline_file config.kanji_path
meanings = get_meanings config.meanings_path, config.additions_path
dictionary = object_from_json_file config.dictionary_path
kanji_radical = get_kanji_radical(config.kanji_radical_path)
radicals = array_from_newline_file(config.radicals_path).map((a) -> a.split(";"))
components = get_components radicals, kanji_radical

get_kanji_info = (kanji, config, meanings, dictionary) ->
  a = meanings[kanji]
  return a if a
  a = components[kanji]
  return a[0] if a
  console.log "no meaning found for #{kanji}"

# anki doesnt skip the csv header so it isnt included for now
csv.pipe fs.createWriteStream config.output_path
for kanji in kanjis
  examples = get_example_words kanji, 2, words, dictionary
  info = get_kanji_info kanji, config, meanings, dictionary
  csv.write [kanji, info]
csv.end()
