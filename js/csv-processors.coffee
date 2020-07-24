# this file contains various standalone functions for csv files.
# the functions read from standard input and write to standard output.

fs = require "fs"
csv_parse = require "csv-parse"
csv_stringify = require "csv-stringify"
nodeStream = require "stream"
wanakana = require "wanakana"
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))

helper =
  streamToString: (a, c) ->
    nodeStream.finished a, {error: false}, (error) ->
      # will be called when error or end events will not be send.
      # error should have already been logged.
      error && c error
    result = ""
    a.setEncoding("utf8")
    a.on "data", (chunk) -> result += chunk
    a.on "error", c
    a.on "end", () -> c null, result
  process_csv: (f) ->
    helper.streamToString process.stdin, (error, input) ->
      if error then console.log error
      else
        csv_parse input, (error, data) ->
          if error then console.log error
          else
            csv_stringify data.map(f).filter((a) -> a), (error, result) ->
              if error then console.log error
              else console.log result


csv_kana_to_romaji = (column_index) ->
  # translate all kana words at column_index to romaji.
  helper.process_csv (a) ->
    if wanakana.isKana a[column_index]
      a[column_index] = wanakana.toRomaji a[column_index]
    a

csv_delete_kana_rows = (column_index) ->
  # delete all rows where column_index is kana only.
  helper.process_csv (a) ->
    a unless wanakana.isKana a[column_index]

csv_filter_by_list = (list_path, column_index) ->
  # only keep rows whose content at column_index is contained in a list read from list_path.
  # for example to filter a csv with kanji and meanings to contain only the kanji from a list.
  list = fs.readFileSync list_path, "utf8"
  helper.process_csv (a) ->
    a if list.includes a[column_index]

add_translations = (column_index) ->
  config =
    dictionary_path: "data/jmdict-translations.json"
    output_path: "download/jouyou-by-stroke-count.csv"
  dictionary = object_from_json_file config.dictionary_path
  helper.process_csv (a) ->
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


#csv_filter_by_list "newline_list.txt", 1
#csv_delete_kana_rows 3
#csv_kana_to_romaji 1
add_translations 0
