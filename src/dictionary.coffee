kanji_data = __kanji_data__
word_data = __word_data__
abc_regexp = /[a-z]/
dom = {}; (dom[a.id] = a for a in document.querySelectorAll("[id]"))

kanji_search_init = ->
  input = dom.kanji_input
  button = dom.kanji_reset
  results = dom.kanji_results
  make_svg = (svg_paths) ->
    result = '<svg viewbox="0 0 100 100">'
    result += "<path d=\"#{a}\"/>" for a in svg_paths
    # create text elements while ensuring that they do not overlap with each other
    min_distance = 5
    placed_positions = []
    for path, index in svg_paths
      match = /M\s*(-?\d+\.?\d*),\s*(-?\d+\.?\d*)/.exec path
      continue unless match
      x = parseFloat match[1]
      y = parseFloat match[2]
      x += 1
      y -= 1
      is_overlapping = (current_x, current_y) ->
        for pos in placed_positions
          dx = current_x - pos[0]
          dy = current_y - pos[1]
          distance = Math.sqrt dx * dx + dy * dy
          return true if distance < min_distance
        false
      original_y = y
      offset_step = 10  # pixels to move vertically each attempt
      max_attempts = 10
      attempt = 0
      while is_overlapping(x, y) and attempt < max_attempts
        y += offset_step  # move the text down by offset_step pixels
        attempt += 1
      continue if is_overlapping x, y
      result += "<text x=\"#{x}\" y=\"#{y}\">#{index + 1}</text>"
      placed_positions.push([x, y])
    result + "</svg>"
  make_result = (kanji, meaning, readings, svg) ->
    result = document.createElement("div")
    k = document.createElement("div")
    k1 = document.createElement("span")
    k2 = document.createElement("span")
    m = document.createElement("div")
    m_content = document.createElement("div")
    k.className = "k"
    k1.className = "k1"
    k2.className = "k2"
    m.className = "m"
    k1.innerHTML = make_svg svg
    k2.innerHTML = kanji
    m_content.innerHTML = "<div>" + meaning + "</div><div class=\"r\">" + readings + "</div>"
    k.appendChild k1
    k.appendChild k2
    m.appendChild m_content
    result.appendChild k
    result.appendChild m
    result
  match_values = (meaning, readings, values) -> values.some (a) -> a.test(meaning) || a.test(readings)
  on_filter = ->
    results.innerHTML = ""
    temp = input.value.split(",")
    values = []
    i = 0
    while i < temp.length
      value = temp[i].trim()
      if 0 < value.length
        if 4 > value.length
          value = "\\b" + value + "\\b"
        else if 5 > value.length
          value = "\\b" + value
        values.push new RegExp(value)
      i += 1
    return if 0 == values.length
    temp = []
    i = 0
    while i < kanji_data.length
      entry = kanji_data[i]
      if input.value.includes(entry[0]) or match_values(entry[1], entry[2], values)
        result = make_result.apply null, entry
        result.addEventListener "dblclick", ((a) ->
          -> a.classList.toggle "mini"
        )(result)
        temp.push result
      i += 1
    # using the temp array seems to display a bit faster
    i = 0
    while i < temp.length
      results.appendChild temp[i]
      i += 1
    results.innerHTML = "no kanji results" if 0 == temp.length
  on_reset = ->
    input.value = ""
    results.innerHTML = ""
  input.addEventListener "keyup", on_filter
  input.addEventListener "change", on_filter
  button.addEventListener "click", on_reset

word_search_init = ->
  input = dom.word_input
  button = dom.word_reset
  checkbox_extended = dom.word_extended
  results = dom.word_results
  result_limit = 150
  make_search_regexp = (word) ->
    return RegExp(word.replace("\"", "")) if "\"" == word[0]
    replacements = [
      [/sh|tch|ch|j/g, "#0"], [/tts|ts|ss|s|z/g, "#1"], [/ou/g, "#2"], [/ei|e/g, "#3"],
      [/iy|y/g, "#5"], [/ii|i/g, "(ii|i)"], [/uu|u/g, "(uu|u)"], [/o/g, "(ou|o)"],
      [/tt|t|d/g, "(tt|t|d)"], [/kk|k|g/g, "(kk|k|g)"], [/pp|p|b/g, "(pp|p|b)"], [/nn|n/g, "(nn|n)"],
      [/#0/g, "(sh|tch|ch|j)"], [/#1/g, "(tts|ts|ss|s|z)"], [/#2/g, "(ou|o)"], [/#3/g, "(ei|e)"],
      [/#5/g, "(iy|y)"]
    ]
    replacements.forEach (a) -> word = word.replace(a[0], a[1])
    new RegExp word
  make_result_line = (a) ->
    b = "<span>" + a[0] + "</span> " + a[1] + " "
    if a[2].some (a) -> a.includes " "
      b + "\"" + a[2].join(" / ") + "\""
    else b + a[2].join("/")
  on_filter = ->
    results.innerHTML = ""
    value = input.value.trim()
    return if 0 == value.length
    matches = []
    if abc_regexp.test(value)
      extended = checkbox_extended.checked
      translation_regexp = new RegExp("\\b" + value)
      regexp = make_search_regexp value
      length_limit_subtraction = if extended then 1 else 2
      length_limit = value.length + Math.max(0, value.length - length_limit_subtraction) ** 2
      i = 0
      match = (a) ->
        return true if length_limit >= a[1].length and regexp.test(a[1].replace(/"/g, ""))
        return true if extended and value.length > 2 and a[2].some (a) -> translation_regexp.test a
        false
      while i < word_data.length and matches.length < result_limit
        matches.push make_result_line(word_data[i]) if match word_data[i]
        i += 1
    else
      regexp = new RegExp(value)
      i = 0
      while i < word_data.length and matches.length < result_limit
        if regexp.test(word_data[i][0])
          matches.push make_result_line word_data[i]
        i += 1
    results.innerHTML = if matches.length then matches.join("<br/>") else "no word results"
  on_reset = ->
    input.value = ""
    results.innerHTML = ""
  input.addEventListener "keyup", on_filter
  input.addEventListener "change", on_filter
  button.addEventListener "click", on_reset
  checkbox_extended.addEventListener "change", on_filter

about_init = ->
  about_link = dom.about_link
  about = dom.about
  about_link.addEventListener "click", -> about.classList.toggle "hidden"

kanji_search_init()
word_search_init()
about_init()
