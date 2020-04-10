# loading and displaying data for each kanji and its contained components.
# uses the component data from kanji bakuhatsu https://github.com/ScottOglesby/kanji-bakuhatsu.

fs = require "fs"
array_delete_duplicates = (a) -> a.filter (b, i) -> i is a.indexOf b

parse_composition_map = (path) ->
  data = fs.readFileSync(path, "utf-8").split("\n")
  result = {}
  data.forEach (a) ->
    a = a.replace(/#.*/, "").split(":")
    return false if a.length < 2
    parts = a[1].trim()
    parts = if parts.length then parts.split(" ") else []
    result[a[0]] = parts
  result

find_parts = (composition, parts) ->
  return [] unless parts and parts.length
  parts.map (a) ->
    result = [a]
    subparts = composition[a]
    if subparts
      result.concat(subparts).concat(find_parts(composition, subparts))
    else result

invert_flat = (flat) ->
  parts = new Set
  flat.forEach (a) ->
    a[1].forEach (a) -> parts.add a
  result = []
  parts.forEach (a) ->
    kanji = flat.filter (b) -> b[1].includes a
    kanji = kanji.map (b) -> b[0]
    result.push [a, kanji]
  result

get_tree = (data) ->
  data.jouyou.map (kanji) ->
    parts = data.composition[kanji]
    return [kanji, []] unless parts
    parts = find_parts(data.composition, parts)
    [kanji, parts]

get_flat = (data) ->
  tree = get_tree data
  tree.map (a) ->
    parts = a[1]
    parts = parts.flat(100)
    parts = array_delete_duplicates parts
    [a[0], parts]

get_flat_csv = (data) ->
  flat = get_flat data
  result = flat.map (a) ->
    parts = a[1]
    return unless parts.length
    a[0] + "," + parts.join("")
  result.join("\n")

get_data = (config) ->
  jouyou: fs.readFileSync(config.kanji_path, "utf-8").split("\n")
  composition: parse_composition_map(config.composition_path)

get_flat_inverted = (data) -> invert_flat get_flat data

update_csv = (config) ->
  csv = get_flat_csv get_data config
  fs.writeFileSync config.output_path, csv

module.exports =
  get_data: get_data
  get_flat: get_flat
  get_flat_inverted: get_flat_inverted
  get_tree: get_tree
  invert_flat: invert_flat
  update_csv: update_csv
