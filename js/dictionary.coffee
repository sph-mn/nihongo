# this code compiles the html file for the single-file dictionary page built from
# html/dictionary-template.html and kanjivg stroke images.
# https://github.com/KanjiVG/kanjivg/releases

fs = require "fs"
wanakana = require "wanakana"
xml2js = require "xml2js"
csv_parse = require "csv-parse/sync"
array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))
read_csv_file = (path, delimiter) -> csv_parse.parse fs.readFileSync(path, "utf-8"), {delimiter: delimiter || " ", relax_column_count: true}
object_array_add = (object, key, value) -> if object[key] then object[key].push value else object[key] = [value]

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

clean_svg = (xml, c) ->
  # the kanjisvg xml has many attributes and styles that are irrelevant
  # and would bloat the result file size
  xml = xml.replace(/\n|\t|\r/g, "").replace(/>\\s+</, "")
  xml2js.parseString xml, {trim: true}, (error, data) ->
    if error
      console.error error.toString()
      c false
      return
    object_tree_foreach data, (key, value, object) ->
      if "$" is key
        delete value.id
        delete value["kvg:type"]
        delete value["kvg:variant"]
        delete value["kvg:position"]
        delete value["kvg:phon"]
        delete value["kvg:element"]
        delete value["kvg:radical"]
        delete value["kvg:part"]
        delete value["kvg:original"]
        delete value["xmlns"]
        excludedStyles = ["stroke-width", "stroke", "font-size"]
        if value.style
          style = value.style.split ";"
          style = style.filter (a) ->
            property = a.split ":"
            not excludedStyles.includes property[0]
          value.style = style.join ";"
    builder = new xml2js.Builder({renderOpts: {pretty: false}, headless: true})
    c builder.buildObject data

update_kanji_data = (config) ->
  stroke_order_svg = (id) ->
    filename = "0" + id.charCodeAt(0).toString(16) + ".svg"
    path = config.kanjivg_path + "/" + filename
    new Promise (resolve, reject) ->
      fs.readFile path, "utf8", (error, xml) ->
        if error
          console.error error.toString(), "for character #{id}"
          resolve false
        else clean_svg xml, resolve
  kanji = read_csv_file config.kanji_path
  # load all svg files asynchronously
  result_promises = kanji.map (a) ->
    [id, meaning, readings] = a
    readings = deduplicate_readings readings
    new Promise (resolve, reject) ->
      resolver = (svg) -> resolve [id, meaning, readings, svg]
      stroke_order_svg(a[0]).then resolver
  Promise.all(result_promises).then (result) ->
    fs.writeFileSync config.output_path, JSON.stringify(result)

update_dictionary = (config) ->
  kanji = fs.readFileSync config.kanji_data_path, "utf8"
  words = fs.readFileSync config.word_data_path, "utf8"
  html = fs.readFileSync config.html_path, "utf8"
  html = html.replace("{kanji-data}", kanji).replace("{word-data}", words)
  on_error = (a) -> if a then console.error a
  fs.writeFile config.output_path, html, on_error

for_each_word_data = (config, f) ->
  dictionary = object_from_json_file config.dictionary_path
  by_reading = {}
  for word in Object.keys dictionary
    for b in dictionary[word]
      object_array_add by_reading, b[0], word
  words = array_from_newline_file config.word_frequency_path
  words = words.filter (a) -> (a.length > 1 || !wanakana.isHiragana(a)) && !wanakana.isKatakana(a)
  if config.word_frequency_limit
    words = words.slice 0, Math.min(words.length, config.word_frequency_limit)
  for word in words
    entries = dictionary[word] || by_reading[word]
    continue unless entries
    for entry in entries
      meanings = entry[1]
      romaji = wanakana.toRomaji entry[0]
      f [word, romaji, meanings]

update_word_data = (config) ->
  result = []
  for_each_word_data config, (a) -> result.push a
  fs.writeFileSync config.output_path, JSON.stringify result

module.exports =
  update_word_data: update_word_data
  update_kanji_data: update_kanji_data
  update_dictionary: update_dictionary
