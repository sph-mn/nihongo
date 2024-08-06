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

pinyin_to_alphanumeric_ascii = (a) ->
  pinyin_map =
    "ā": "a", "á": "a", "ǎ": "a", "à": "a",
    "ē": "e", "é": "e", "ě": "e", "è": "e",
    "ī": "i", "í": "i", "ǐ": "i", "ì": "i",
    "ō": "o", "ó": "o", "ǒ": "o", "ò": "o",
    "ū": "u", "ú": "u", "ǔ": "u", "ù": "u",
    "ǖ": "u", "ǘ": "u", "ǚ": "u", "ǜ": "u",
    "ü": "u", "1": "", "2": "", "3": "", "4": "", "5": "",
  a.split("").map((a) -> if a of pinyin_map then pinyin_map[a] else a).join("")

sorensen_dice = (a, b) ->
  a = new Set a
  b = new Set b
  intersection = new Set([...a].filter (c) -> b.has c)
  (2 * intersection.size) / (a.size + b.size)

delete_duplicates = (a) -> [...new Set(a)]

sort_ja_overlap_by_similarity = () ->
  a = read_csv_file "data/chinese-japanese-overlap.csv"
  c = for b in a
    cn = pinyin_to_alphanumeric_ascii b[1]
    ja = delete_duplicates b[3].split "/"
    ja = ja.map((a) -> [a, sorensen_dice(cn, a)]).sort((a, b) -> b[1] - a[1])
    b[3] = ja.map((a) -> a[0]).join "/"
    [ja[0][1]].concat b
  c = c.sort((a, b) -> (a[1].length - b[1].length) || (b[0] - a[0]))
  a = (b.slice(1) for b in c)
  write_csv_file "data/chinese-japanese-overlap-sorted.csv", a

run = () ->
  #ja_overlap()
  sort_ja_overlap_by_similarity()

module.exports = {
  run
}
