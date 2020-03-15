# extract relevant information from the jmdict file and output json

parse_xml = require("xml2js").parseString
fs = require "fs"

config =
  jmdict_path: "data/extras/JMdict_e"
  output_path: "data/extras/jmdict-translations.json"
  misc_tag_exclusions: [
    # uk: usually written using kana alone
    # x: rude or x-rated terms
    "abbr"
    "arch"
    "derog"
    "obs"
    "obsc"
    "organization"
    "person"
    "sens"
    #"uk"
    "vulg"
    "work"
    "x"
  ]
  frequency: [
    "news1",
    "ichi1",
    "spec1"
  ]

# convert misc tags to format as used in jmdict
exclusions = config.misc_tag_exclusions.map (a) -> "&#{a};"
# parse xml to an object
xml = fs.readFileSync config.jmdict_path

array_contains_any = (a, b) ->
  b.some (b) -> a.includes(b)

find_reading = (re_ele) ->
  if config.frequency.length
    a = re_ele.find (a) ->
      a.RE_PRI and array_contains_any(a.RE_PRI, config.frequency)
    a and a.REB[0]
  else entry.R_ELE[0].REB[0]

parse_xml xml, {strict: false}, (error, jmdict) ->
  if error
    console.log error
    return
  # remove unneeded information
  result = {}
  jmdict.JMDICT.ENTRY.forEach (entry) ->
    # ignore words not written with kanji
    return false unless entry.K_ELE
    # take only the first writing and reading
    word = entry.K_ELE[0].KEB[0]
    reading = find_reading entry.R_ELE
    return if not reading
    return if result[word]
    # filter translations
    translations = entry.SENSE.map (sense) ->
      exclude = sense.MISC and sense.MISC.some (a) -> exclusions.includes(a)
      sense.GLOSS unless exclude
    translations = translations.filter (a) -> a
    return false unless translations.length
    result[word] = [reading, translations]
  fs.writeFileSync config.output_path, JSON.stringify result
