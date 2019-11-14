csv_parse = require "csv-parse"
csv_stringify = require "csv-stringify"
nodeStream = require "stream"
fs = require "fs"
wanakana = require "wanakana"

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

# the following functions read from standard input and write to standard output.

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

#csv_filter_by_list "newline_list.txt", 1
#csv_delete_kana_rows 3
csv_kana_to_romaji 1
