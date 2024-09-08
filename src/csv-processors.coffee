# this file contains various standalone functions for csv files.
# the functions read from standard input and write to standard output.

fs = require "fs"
csv_parse = require("csv-parse/lib/sync")
csv_stringify = require("csv-stringify/lib/sync")
nodeStream = require "stream"
wanakana = require "wanakana"
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))
csv_delimiter = " "

read_csv = (a) -> csv_parse a, {delimiter: csv_delimiter, relax_column_count: true}
write_csv = (a) -> csv_stringify a, {delimiter: csv_delimiter}
process_csv_stdin = (f) ->
  console.log write_csv f read_csv fs.readFileSync(process.stdin.fd, "utf-8")
process_csv_lines_stdin = (f) ->
  process_csv_stdin (a) -> a.map(f).filter((a) -> a)

csv_kana_to_romaji = (column_index) ->
  # translate all kana words at column_index to romaji.
  process_csv_lines_stdin (a) ->
    if wanakana.isKana a[column_index]
      a[column_index] = wanakana.toRomaji a[column_index]
    a

csv_delete_kana_rows = (column_index) ->
  # delete all rows where column_index is kana only.
  process_csv_lines_stdin (a) ->
    a unless wanakana.isKana a[column_index]

csv_filter_by_list = (list_path, column_index) ->
  # only keep rows whose content at column_index is contained in a list read from list_path.
  # for example to filter a csv with kanji and meanings to contain only the kanji from a list.
  list = fs.readFileSync list_path, "utf8"
  process_csv_lines_stdin (a) ->
    a if list.includes a[column_index]

add_translations = (column_index) ->
  config =
    dictionary_path: "data/jmdict-translations.json"
    output_path: "download/jouyou-by-stroke-count.csv"
  dictionary = object_from_json_file config.dictionary_path
  process_csv_lines_stdin (a) ->
    b = a[column_index]
    c = dictionary[a]
    unless b
      c = dictionary[wanakana.toKatakana(b)]
    else
      c = dictionary[wanakana.toHiragana(b)]
    if c
      b = wanakana.toRomaji(b)
      c = c[1].join("; ")
      [b, c]
    else
      b = wanakana.toRomaji(b)
      [b]

sort_by_katakana = (column_index) ->
  # display first rows with katakana-only at column_index,
  # then rows without katakana.
  process_csv_stdin (data) ->
    data.sort (a, b) ->
      an = wanakana.isKatakana a[column_index]
      bn = wanakana.isKatakana b[column_index]
      bn - an

csv_replace_non_ascii = (column_index) ->
  # replace o and u with a line over it with ou uu
  csv_delimiter = ","
  process_csv_lines_stdin (a) ->
    a[2] = a[2].replace("ō", "ou").replace("ū", "uu")
    a

csv_add_slash_count = (column_index) ->
  csv_delimiter = " "
  process_csv_lines_stdin (a) ->
    count = a[column_index].split("/").length
    [count].concat a

csv_converge_readings = (column_index) ->
  csv_delimiter = " "
  process_csv_lines_stdin (a) ->
    readings = a[column_index].split("/")
    readings = readings.map (a) -> a.split("-")[0].replace("'", "")
    readings = readings.filter (a, i, self) -> self.indexOf(a) == i
    a[column_index] = readings.join "/"
    a

#csv_filter_by_list "newline_list.txt", 1
#csv_delete_kana_rows 3
#csv_kana_to_romaji 1
#add_translations 0
#sort_by_katakana 1
#csv_replace_non_ascii 2
csv_add_slash_count 1
#csv_converge_readings 1
