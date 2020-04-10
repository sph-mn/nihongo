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

display_flat_csv = (data) ->
  flat = get_flat data
  flat.forEach (a) ->
    parts = a[1]
    return unless parts.length
    console.log a[0] + "," + parts.join("")

data =
  jouyou: fs.readFileSync("data/jouyou-by-stroke-count.txt", "utf-8").split("\n")
  composition: parse_composition_map "data/extras/kanji-composition-map.txt"

display_flat_csv data
