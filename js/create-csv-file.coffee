# when executed, this code creates a csv file at config.output_path.
# note: anki import doesnt skip csv headers so none is written for now.

config =
  kanji_order_path: "data/jouyou-by-stroke-count.txt"
  output_path: "download/jouyou-by-stroke-count.csv"
  meanings_path: "data/joyo-meanings.csv"

fs = require "fs"
csv = require("csv-stringify")()
array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")

get_all_meanings = (path) ->
  # -> {kanji: meaning}
  reduce_f = (result, a) ->
    a = a.split ","
    result[a[0]] = a[1]
    result
  meanings = array_from_newline_file config.meanings_path
  meanings.reduce reduce_f, {}

get_kanji_meaning = (kanji, meanings) ->
  # -> string
  a = meanings[kanji]
  return a if a
  console.log "no meaning found for #{kanji}"

kanji_order = array_from_newline_file config.kanji_order_path
meanings = get_all_meanings config.meanings_path
csv.pipe fs.createWriteStream config.output_path
for kanji, i in kanji_order
  meaning = get_kanji_meaning kanji, meanings
  csv.write [kanji, meaning, i]
csv.end()
