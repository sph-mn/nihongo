# this code displays the html for the single file viewer page built from
# html/template.html and kanjisvg stroke images.

config =
  html_path: "html/template.html"
  kanjivg_path: "/home/nonroot/temp/japanese/1/reading-writing/kanjivg/kanji"
  kanji_path: "download/jouyou-by-stroke-count.csv"
  output_path: "download/kanji-viewer.html"

fs = require "fs"
xml2js = require "xml2js"

read_kanji = (path) ->
  fs.readFileSync(path).toString().trim().split("\n").map (a) -> a.split ","

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

result_promises = kanji.map (a) ->
  [id, meaning] = a
  new Promise (resolve, reject) ->
    resolver = (svg) -> resolve [id, meaning, svg]
    stroke_order_svg(a[0]).then resolver

with_results = (results) ->
  html_list = results.map (a) ->
    [id, meaning, svg] = a
    return unless svg
    "<div class=\"i\" id=\"#{id}\">" +
      "<div class=\"k\"><span class=\"k1\">#{svg}</span><span class=\"k2\">#{id}</span></div>" +
      "<div class=\"m\"><div>#{meaning}</div></div>" +
    "</div>"
  html = fs.readFileSync config.html_path, "utf8"
  html = html.replace "{content}", html_list.join ""
  fs.writeFile config.output_path, html, (error) ->
    if error then console.error error

Promise.all(result_promises).then with_results
