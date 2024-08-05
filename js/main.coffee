fs = require "fs"
hanzi_tools = require "hanzi-tools"
csv_parse = require "csv-parse/sync"
csv_stringify = require "csv-stringify/sync"
object_array_add = (object, key, value) -> if object[key] then object[key].push value else object[key] = [value]
read_csv_file = (path, delimiter) -> csv_parse.parse fs.readFileSync(path, "utf-8"), {delimiter: delimiter || " ", relax_column_count: true}
on_error = (a) -> if a then console.error a
write_csv_file = (path, data) ->
  csv = csv_stringify.stringify(data, {delimiter: " "}, on_error).trim()
  fs.writeFile path, csv, on_error

ja_overlap = () ->
  ja_dict = {}
  ja_words = JSON.parse fs.readFileSync "data/dictionary-word-data.json"
  for a in ja_words
    object_array_add ja_dict, a[0], a
  cn_dict = {}
  # depends on https://github.com/sph-mn/hanyu
  cn_words = read_csv_file "../hanyu/data/cedict.csv"
  for a in cn_words
    object_array_add cn_dict, a[0], a
  shared = []
  for a in Object.keys cn_dict
    ja = ja_dict[hanzi_tools.traditionalize a]
    continue unless ja
    cn = cn_dict[a]
    readings = ja.map((b) -> b[1]).join("/")
    shared.push [a, cn[0][1], ja[0][0], readings]
  write_csv_file "data/chinese-japanese-overlap.csv", shared

run = () ->
  ja_overlap()

module.exports = {
  run
}
