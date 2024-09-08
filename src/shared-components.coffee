fs = require "fs"
components = require "./kanji-to-components"

array_complement = (a, b) -> a.filter((aa) -> b.includes(aa))
array_delete_duplicates = (a) -> a.filter (b, i) -> i is a.indexOf b

complement_product = (flat) ->
  # [[key, values] ...] -> [[key1 + key2, shared_values] ...]
  # ignored are:
  # * entries without at least 2 shared values
  # * equal key1 and key2
  # * key2 + key1 combinations
  # * keys that are included in any of the compared values
  result = []
  used = new Set
  flat.forEach (a) ->
    flat.forEach (b) ->
      return if a[0] is b[0]
      return if used.has b[0] + a[0]
      used.add a[0] + b[0]
      return if a[1].includes(b[0]) or b[1].includes(a[0])
      parts = array_complement a[1], b[1]
      parts = array_delete_duplicates parts
      if 2 <= parts.length
        result.push [a[0], b[0], parts]
  result

get_shared = (data) ->
  flat = components.get_flat_inverted data
  flat = flat.filter (a) -> a[1].length
  complement_product flat

update_csv = (config) ->
  data = components.get_data config
  shared = get_shared data
  csv = shared.map (a) ->
    a[0] + a[1] + "," + a[2].join("")
  csv = csv.join "\n"
  fs.writeFileSync config.output_path, csv

module.exports =
  complement_product: complement_product
  update_csv: update_csv
