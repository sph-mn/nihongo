# this file contains functions that download data from wikipedia or other sources and display csv.
# the functions are called at the bottom when not preceded by #

scraper = require "table-scraper"
wiki = require("wikijs").default
csv_stringify = require "csv-stringify/lib/sync"
_ = require "underscore"

helper =
  get_wiki_tables: (pageName) ->
    wiki().page(pageName).then((page) -> page.tables())

kanji_by_concept = () ->
  wiki().page("List_of_kanji_by_concept").then(page -> page.content()).then (data) ->
    data.forEach (a) ->
      if a.content
        console.log a.content.split "; "

kanji_radicals = () ->
  # display csv with data corresponding to the following header
  header = ["stroke_count", "radical", "meaning", "variants", "note", "is_new"]
  url = "https://en.wikipedia.org/wiki/List_of_kanji_radicals_by_stroke_count"
  scraper.get(url).then (data) ->
    radicals = data[0].map (a) ->
      meaning = a["Meaning and reading"]
      radical = a["Radical (variants)"]
      stroke_count = parseInt a["Stroke count"], 10
      main = radical.match(/[^(]+/)[0]
      alt = radical.match(/\(.+?\)/)
      if alt
        alt = alt[0].trim()
        alt = alt.substring 1, alt.length - 1
        alt = alt.split ","
      else alt = []
      meaning = meaning.match(/[^,(;]+/)[0].trim()
      [stroke_count, main, meaning, alt.join("/"), "", 0]
    new_radicals = data[1].map (a) ->
      [ parseInt(a["Stroke count"], 10)
        a["New radical"]
        ""
        a["Kanji note"]
        1]
    result = radicals.concat new_radicals
    result = result.sort (a, b) -> a[0] - b[0]
    result.unshift header
    console.log csv_stringify result

jouyou_info = (c) ->
  # display csv with data corresponding to the following header.
  # there are html entities and other html in wikidata, not fully usable as is,
  # for example 児.
  header = ["stroke_count", "kanji", "meaning", "readings"]
  get_readings = (a) ->
    a  = a.split("<br>")[1]
    a = a.split(",").map (a) -> a.trim()
    a.filter (a) -> !a.startsWith("(")
  get = (c) -> helper.get_wiki_tables("List_of_jōyō_kanji").then c
  get (data) ->
    data = data[0].map (a) ->
      readings = get_readings a.readings
      [parseInt(a.strokes, 10), a.new[0], a.englishMeaning, readings.join("/")]
    data = data.sort (a, b) ->
      diff = a[0] - b[0]
      if diff then diff
      else a[0] < b[0]
    c {header, data}

jouyou_info_csv = () ->
  jouyou_info (a) ->
    a.data.unshift a.header
    console.log csv_stringify a.data

kanji_radicals_csv = () ->
  kanji_radicals (a) ->
    a.data.unshift a.header
    console.log csv_stringify a.data

jouyou_info_reading_to_kanji = (data) ->
  index = data.data.map (a) ->
    a[3].split("/").map (b) -> [b, a[1]]
  index = [].concat.apply [], index
  index = _.groupBy index, (a) -> a[0]
  index = _.mapObject index, (value, key) -> value.map (a) -> a[1]
  index

jouyou_info_multiple_kanji_to_reading = (data) ->
  reading_to_kanji = jouyou_info_reading_to_kanji data
  result = _.map reading_to_kanji, (value, key) -> [value.join(""), key]
  result.sort (a, b) -> b[0].length - a[0].length

multiple_kanji_to_reading_csv = () ->
  header = ["kanji", "reading"]
  jouyou_info (data) ->
    result = jouyou_info_multiple_kanji_to_reading data
    result.unshift header
    console.log csv_stringify result

#multiple_kanji_to_reading_csv()
#kanji_radicals_csv()
jouyou_info_csv()
