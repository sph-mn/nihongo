csv_parse = require "csv-parse/sync"
csv_stringify = require "csv-stringify/sync"
fs = require "fs"
hanzi_tools = require "hanzi-tools"
wanakana = require "wanakana"
xml2js = require "xml2js"
coffee = require "coffeescript"
array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_array_add = (object, key, value) -> if object[key] then object[key].push value else object[key] = [value]
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))
on_error = (a) -> if a then console.error a
read_csv_file = (path, delimiter) -> csv_parse.parse fs.readFileSync(path, "utf-8"), {delimiter: delimiter || " ", relax_column_count: true}
read_text_file = (a) -> fs.readFileSync a, "utf8"
write_text_file = (path, a) -> fs.writeFileSync path, a
delete_duplicates = (a) -> [...new Set(a)]
replace_placeholders = (text, mapping) -> text.replace /__(.*?)__/g, (_, k) -> mapping[k] or ""

write_csv_file = (path, data) ->
  csv = csv_stringify.stringify(data, {delimiter: " "}, on_error).trim()
  fs.writeFile path, csv, on_error

is_object = (a) ->
  type = typeof a
  type == "function" || type == "object" && !!a

object_tree_foreach = (a, f) ->
  Object.keys(a).forEach (key) ->
    value = a[key]
    if is_object value
      object_tree_foreach value, f
      f key, value
    else f key, value, a

deduplicate_readings = (a) ->
  # yoku/a-biru/a-biseru -> yoku/a
  a = a.split("/")
  a = a.map (a) -> a.split("-")[0].replace("'", "")
  a = a.filter (a, i, self) -> self.indexOf(a) == i
  a.join("/")

update_dictionary_character_data = () ->
  xml_parser = new xml2js.Parser()
  find_paths = (node) ->
    d_values = []
    if node?.path
      for path in node.path
        d_values.push path['$'].d
    for key, value of node
      if typeof value is 'object'
        d_values = d_values.concat find_paths value
    d_values
  get_svg = (char) ->
    filename = "0" + char.charCodeAt(0).toString(16) + ".svg"
    path = "data/kanjivg/#{filename}"
    new Promise (resolve, reject) ->
      fs.readFile path, "utf8", (error, xml) ->
        if error
          console.error error.toString(), "for character #{char}"
          resolve false
        else
          xml_parser.parseString xml, (error, result) ->
            if error then resolve false
            else resolve find_paths result.svg
  kanji = read_csv_file "data/jouyou-kanji.csv"
  # load all svg files asynchronously
  result_promises = kanji.map (a) ->
    [char, meaning, readings] = a
    readings = deduplicate_readings readings
    new Promise (resolve, reject) ->
      get_svg(a[0]).then (svg) -> resolve [char, meaning, readings, svg]
  Promise.all(result_promises).then (result) ->
    write_text_file "data/dictionary-character-data.json", JSON.stringify(result)

update_dictionary_word_data = () ->
  result = []
  dictionary = object_from_json_file "data/jmdict-translations-dictionary.json"
  by_reading = {}
  for word in Object.keys dictionary
    for b in dictionary[word]
      object_array_add by_reading, b[0], word
  words = array_from_newline_file "data/wordlex-2011.txt"
  words = words.filter (a) -> (a.length > 1 || !wanakana.isHiragana(a)) && !wanakana.isKatakana(a)
  for word in words
    entries = dictionary[word] || by_reading[word]
    continue unless entries
    for entry in entries
      romaji = wanakana.toRomaji entry[0]
      meanings = entry[1]
      if Array.isArray meanings
        result.push [word, romaji, meanings]
  write_text_file "data/dictionary-word-data.json", JSON.stringify(result)

update_dictionary_data = () ->
  update_dictionary_character_data()
  update_dictionary_word_data()

update_dictionary = () ->
  character_data = read_text_file "data/dictionary-character-data.json"
  word_data = read_text_file "data/dictionary-word-data.json"
  font = read_text_file "src/NotoSansJP-Light.ttf.base64"
  script = read_text_file "src/dictionary.coffee"
  script = replace_placeholders script, {character_data, word_data}
  script = coffee.compile(script, bare: true).trim()
  html = read_text_file "src/nihongo-dictionary-template.html"
  html = replace_placeholders html, {script, font}
  write_text_file "compiled/nihongo-dictionary.html", html

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
  write_csv_file "data/chinese-japanese-overlap.csv", a

update_ja_overlap = () ->
  ja_overlap()
  sort_ja_overlap_by_similarity()

run = () ->

module.exports = {
  update_dictionary_data,
  update_dictionary,
  update_ja_overlap,
  run
}
