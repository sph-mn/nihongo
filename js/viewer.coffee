# this code writes the html file for the single-file viewer page built from
# html/viewer-template.html and kanjivg stroke images.
# https://github.com/KanjiVG/kanjivg/releases

fs = require "fs"
wanakana = require "wanakana"
xml2js = require "xml2js"
array_from_newline_file = (path) -> fs.readFileSync(path).toString().trim().split("\n")
object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))

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

read_kanji = (path) ->
  fs.readFileSync(path).toString().trim().split("\n").map (a) -> a.split ","

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

update_kanji_info = (config) ->
  stroke_order_svg = (id) ->
    filename = "0" + id.charCodeAt(0).toString(16) + ".svg"
    path = config.kanjivg_path + "/" + filename
    new Promise (resolve, reject) ->
      fs.readFile path, "utf8", (error, xml) ->
        if error
          console.error error.toString(), "for character #{id}"
          resolve false
        else clean_svg xml, resolve
  kanji = read_kanji config.kanji_path
  # load all svg files asynchronously
  result_promises = kanji.map (a) ->
    [id, meaning] = a
    new Promise (resolve, reject) ->
      resolver = (svg) -> resolve [id, meaning, svg]
      stroke_order_svg(a[0]).then resolver
  Promise.all(result_promises).then (result) ->
    fs.writeFileSync config.output_path, JSON.stringify(result)

update_viewer = (config) ->
  kanji = fs.readFileSync(config.kanji_info_path, "utf8")
  words = fs.readFileSync config.word_info_path, "utf8"
  html = fs.readFileSync config.html_path, "utf8"
  html = html.replace("{kanji-data}", kanji).replace("{word-data}", words)
  on_error = (a) -> if a then console.error a
  fs.writeFile config.output_path, html, on_error

for_each_word_info = (config, f) ->
  dictionary = object_from_json_file config.dictionary_path
  by_reading = {}
  for key in Object.keys dictionary
    a = dictionary[key]
    by_reading[a[0]] = key
  duplicates = {}
  words = array_from_newline_file config.word_frequency_path
  words = words.filter (a) ->
    (a.length > 1 || !wanakana.isHiragana(a)) && !wanakana.isKatakana(a)
  if config.word_frequency_limit
    words = words.slice 0, Math.min(words.length, config.word_frequency_limit)
  for word in words
    entry = dictionary[word]
    unless entry
      word = by_reading[word]
      if word && !duplicates[word]
        entry = dictionary[word]
    continue unless entry
    duplicates[word] = true
    meanings = entry[1]
    romaji = wanakana.toRomaji entry[0]
    f [word, romaji, meanings]

update_word_info = (config) ->
  result = []
  for_each_word_info config, (a) -> result.push a
  fs.writeFileSync config.output_path, JSON.stringify result

module.exports =
  update_word_info: update_word_info
  update_kanji_info: update_kanji_info
  update_viewer: update_viewer
