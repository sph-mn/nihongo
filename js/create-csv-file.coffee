fs = require "fs"
csv = require("csv-stringify")()

config =
  kanji_path: "data/all.txt"
  output_path: "download/topokanji-deck.csv"
  #kanji_path: "data/jouyou-by-stroke-count.txt"
  #output_path: "download/jouyou-by-stroke-count.csv"
  additions_path: "data/manual-additions"
  dictionary_path: "data/jmdict-translations.json"
  add_example_words: false
  example_limit: 5
  example_meanings_limit: 1
  example_separator: "\n"
  kanji_radical_path: "data/kanji-to-radical.csv"
  limit: 3000
  meanings_path: "data/joyo-meanings.csv"
  radicals_path: "data/japanese-radicals-513ba7a.csv"
  words_path: "data/wordlex-2011.txt"

array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))

get_meanings = (path, additions_path) ->
  result = {}
  # additions that are not not found otherwise
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

examples_to_string = (a, separator, meanings_limit) ->
  a = a.map (word) ->
    # get the first word of each sense
    meaning = word[2].map (a) -> a[0]
    if meanings_limit < meaning.length then meaning = meaning.slice(0, meanings_limit)
    meaning = meaning.join "; "
    "#{word[0]} (#{word[1]}): #{meaning}"
  a.join(separator)

words = array_from_newline_file(config.words_path).slice(0, 100100)
kanjis = array_from_newline_file config.kanji_path
meanings = get_meanings config.meanings_path, config.additions_path
dictionary = object_from_json_file config.dictionary_path
kanji_radical = get_kanji_radical(config.kanji_radical_path)
radicals = array_from_newline_file(config.radicals_path).map((a) -> a.split(";"))
components = get_components radicals, kanji_radical

# anki doesnt skip csv headers so none is included for now
csv.pipe fs.createWriteStream config.output_path
if config.add_example_words
  for kanji in kanjis
    examples = get_example_words kanji, config.example_limit, words, dictionary
    examples_string = examples_to_string examples, config.example_separator, config.example_meanings_limit
    info = get_kanji_info kanji, config, meanings, dictionary
    csv.write [kanji, info, examples_string]
else
  for kanji in kanjis
    info = get_kanji_info kanji, config, meanings, dictionary
    csv.write [kanji, info]
csv.end()
