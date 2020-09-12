# extract information from the jmdict xml file and save as json

fs = require "fs"
parse_xml = require("xml2js").parseString
wanakana = require "wanakana"

array_contains_any = (a, b) ->
  b.some (b) -> a.includes(b)

find_reading = (r_ele, frequency_tags) ->
  if frequency_tags.length
    a = r_ele.find (a) ->
      a.RE_PRI and array_contains_any(a.RE_PRI, frequency_tags)
    a and a.REB[0]
  else r_ele[0].REB[0]

update_json = (config) ->
  # convert misc tags to the format used in jmdict
  exclusions = config.misc_tag_exclusions.map (a) -> "&#{a};"
  # parse xml to an object
  xml = fs.readFileSync config.jmdict_path
  parse_xml xml, {strict: false}, (error, jmdict) ->
    if error
      console.log error
      return
    result = {}
    # remove unneeded information
    jmdict.JMDICT.ENTRY.forEach (entry) ->
      # ignore words without kanji
      # take the first writing and select a common reading
      if entry.K_ELE
        word = entry.K_ELE[0].KEB[0]
      else
        return if config.only_words_with_kanji
        word = entry.R_ELE[0].REB[0]
      return if result[word]
      reading = find_reading entry.R_ELE, config.frequency_tags
      return unless reading
      reading = wanakana.toRomaji reading
      # select meanings
      translations = []
      entry.SENSE.forEach (a) ->
        return unless translations.length < config.translations_limit
        unless a.MISC and a.MISC.some (a) -> exclusions.includes(a)
          b = a.GLOSS.filter (a) -> "string" == typeof(a)
          translations.push b.join(", ") if b.length
      return if 0 == translations.length
      result[word] = [reading, translations]
    fs.writeFileSync config.output_path, JSON.stringify result

module.exports =
  update_json: update_json
