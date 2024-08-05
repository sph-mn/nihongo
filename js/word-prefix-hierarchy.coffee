fs = require "fs"
_ = require "underscore"
object_merge = require "deepmerge"

default_config =
  dictionary_word_data: "data/dictionary-word-data.json"

object_from_json_file = (path) -> JSON.parse(fs.readFileSync(path))

syllables = [
  "ka", "sa", "ta", "na", "ha", "ma", "ya", "ra", "wa",
  "ki", "shi", "chi", "ni", "hi", "mi", "ri",
  "ku", "su", "tsu", "nu", "fu", "mu", "yu", "ru",
  "ke", "se", "te", "ne", "he", "me", "re",
  "ko", "so", "to", "no", "ho", "mo", "yo", "ro", "wo",
  "ga", "za", "da", "ba",
  "gi", "ji", "dzi", "bi",
  "gu", "zu", "dzu", "bu",
  "ge", "ze", "de", "be",
  "go", "zo", "do", "bo"
  "pa", "pi", "pu", "pe", "po",
  "sha", "shu", "sho", "ja", "ju", "jo", "cho", "cha", "chu", "gya", "kya", "kyu", "gyu",
  "a", "i", "u", "e", "o", "n", "ou", "ei",
  "kk", "pp", "tt", "ss", "jou", "tchu", "nya", "nyo", "myo", "mya", "kyo", "hyo", "hya", "ryo", "rya", "ryu", "byo", "gyo",
  "pyo", "bya"
  ]

group_by_prefix = (data, prefixes) ->
  data = _.groupBy data, (a) ->
    prefix = prefixes.find (b) -> a[1].match(new RegExp("^" + b))
    prefix || "other"

produce_strings = (a, b) ->
  a = if _.isArray a then a else [a]
  b = if _.isArray b then b else [b]
  c = a.map (a) ->
    b.map (b) ->
      a + b
  _.flatten(c)

quote = (a) ->
  a = if _.isArray a then a.join("; ") else a
  "\"" + a.replace(/"/g, "\"") + "\""

translation_string = (indent, a) ->
  indent_string = ""
  while indent
    indent_string += "  "
    indent -= 1
  [indent_string + a[0], a[1], quote(a[2])].join(" ")

word_prefix_hierarchy = (config) ->
  config = object_merge.all [{}, default_config, config]
  word_data = object_from_json_file config.dictionary_word_data
  word_data = group_by_prefix word_data, syllables
  _.forEach word_data, (value, key) ->
    word_data[key] = group_by_prefix value, produce_strings(key, syllables)
  lines = []
  # only a few uninteresting words, like JR and facebook, were left in .other
  if word_data.other then delete word_data.other
  _.forEach word_data, (value, key) ->
    if value.other
      lines.push key + "*"
      _.forEach value.other, (value) ->
        lines.push translation_string 1, value
      delete value.other
    _.forEach value, (value2, key2) ->
      lines.push key2 + "*"
      #console.log value2.length, key2
      _.forEach value2, (value3, key3) ->
        lines.push translation_string 1, value3
  lines

update_word_prefix_hierarchy = (config) ->
  lines = word_prefix_hierarchy config
  fs.writeFileSync config.output_path, lines.join("\n") + "\n"

module.exports = {
  update_word_prefix_hierarchy
}
