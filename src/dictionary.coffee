abc_regexp = /[a-z]/
dom = {}; (dom[a.id] = a for a in document.querySelectorAll("[id]"))
word_data = __word_data__

debounce = (func, wait, immediate = false) ->
  timeout = null
  ->
    context = this
    args = arguments
    later = ->
      timeout = null
      func.apply(context, args) unless immediate
    call_now = immediate and not timeout
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
    func.apply(context, args) if call_now

class character_search_class
  character_data: __character_data__
  reset: ->
    dom.character_input.value = ""
    dom.character_results.innerHTML = ""
  svg_text_positions: (svg_paths) ->
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
      placed_positions.push [x, y, index + 1]
    placed_positions
  make_svg: (svg_paths) ->
    html = "<svg viewbox=\"0 0 100 100\">"
    html += "<path d=\"#{a}\"/>" for a in svg_paths
    for [x, y, i] in @svg_text_positions svg_paths
      html += "<text x=\"#{x}\" y=\"#{y}\">#{i}</text>"
    html + "</svg>"
  make_result_html: (char, meaning, latin, svg_paths) ->
    html = ""
    if svg_paths
      svg = @make_svg svg_paths
      html += "<div>"
      html += "#{svg}<div class=\"m\"><div class=\"text_char\">#{char}</div><div class=\"latin\">#{latin}</div></div>"
      html += "</div>"
    else
      html += "<div class=\"nosvg\">"
      html += "<div class=\"text_char\">#{char}</div>"
      html += "<div class=\"m\"><div class=\"latin\">#{latin}</div></div>"
      html += "</div>"
    html
  match_values: (values, meaning, latin) -> values.some (a) -> a.test(meaning) || a.test(latin)
  filter: =>
    dom.character_results.innerHTML = ""
    values = dom.character_input.value.split(",").map (a) -> a.trim()
    values = for a in values
      continue unless 0 < a.length
      if 4 > a.length then a = "\\b#{a}\\b"
      else if 5 > a.length then a = "\\b#{a}"
      new RegExp a
    return unless values.length
    html = ""
    for [char, meaning, latin, svg_paths] in @character_data
      if dom.character_input.value.includes(char) or @match_values(values, meaning, latin)
        html += @make_result_html char, meaning, latin, svg_paths
    dom.character_results.innerHTML = html || "no character results"
  constructor: (app) ->
    dom.character_input.addEventListener "keyup", debounce(@filter, 300)
    dom.character_input.addEventListener "change", @filter
    dom.character_reset.addEventListener "click", @reset
    dom.character_results.addEventListener "click", (event) =>
      # make a word search when clicking on character
      target = event.target
      if "character_show_remaining" == target.id
        @matches_limit = 1024
        @filter()
        return
      if target.classList.contains("text_char") && !target.parentNode.classList.contains("nosvg")
        char = target.innerHTML
        return if dom.word_input.value.includes char
        dom.word_input.value = char
        app.word_search.filter()

class word_search_class
  result_limit: 150
  reset: ->
    dom.word_input.value = ""
    dom.word_results.innerHTML = ""
  make_search_regexp: (word) ->
    return RegExp(word.replace("\"", "")) if "\"" == word[0]
    replacements = [
      [/sh|tch|ch|j/g, "#0"], [/tts|ts|ss|s|z/g, "#1"], [/ou/g, "#2"], [/ae|ai/g, "#6"], [/ei|e/g, "#3"],
      [/iy|y/g, "#5"], [/ii|i/g, "(ii|i)"], [/uu|u/g, "(uu|u)"], [/o/g, "(ou|o)"],
      [/tt|t|d/g, "(tt|t|d)"], [/kk|k|g/g, "(kk|k|g)"], [/pp|p|b/g, "(pp|p|b)"], [/nn|n/g, "(nn|n)"],
      [/#0/g, "(sh|tch|ch|j)"], [/#1/g, "(tts|ts|ss|s|z)"], [/#2/g, "(ou|o)"], [/#3/g, "(ei|e)"],
      [/#5/g, "(iy|y)"], [/#6/g, "(ae|ai)"]
    ]
    replacements.forEach (a) -> word = word.replace(a[0], a[1])
    new RegExp word
  make_result_html: (a) ->
    b = "<span>" + a[0] + "</span> " + a[1] + " "
    if a[2].some (a) -> a.includes " "
      b + "\"" + a[2].join(" / ") + "\"<br/>"
    else b + a[2].join("/") + "<br/>"
  filter: =>
    dom.word_results.innerHTML = ""
    value = dom.word_input.value.trim()
    return if 0 == value.length
    matches_count = 0
    html = ""
    if abc_regexp.test value
      extended = dom.search_extended.checked
      translation_regexp = new RegExp("\\b" + value)
      regexp = @make_search_regexp value
      length_limit_subtraction = if extended then 1 else 2
      length_limit = value.length + Math.max(0, value.length - length_limit_subtraction) ** 2
      match = (a) ->
        return true if length_limit >= a[1].length and regexp.test(a[1].replace(/"/g, ""))
        return true if extended and value.length > 2 and a[2].some (a) -> translation_regexp.test a
        false
      for a in word_data
        break unless matches_count < @result_limit
        if match a
          html += @make_result_html a
          matches_count += 1
    else
      regexp = new RegExp value
      for a in word_data
        break unless matches_count < @result_limit
        if regexp.test a[0]
          html += @make_result_html a
          matches_count += 1
    dom.word_results.innerHTML = html || "no word results"
  constructor: (app) ->
    dom.word_input.addEventListener "keyup", debounce(@filter, 150)
    dom.word_input.addEventListener "change", @filter
    dom.word_reset.addEventListener "click", @reset
    dom.search_extended.addEventListener "change", @filter

class app_class
  constructor: ->
    dom.toggle_search_type.checked = false
    dom.about_link.addEventListener "click", -> dom.about.classList.toggle "hidden"
    dom.about_link_close.addEventListener "click", -> dom.about.classList.toggle "hidden"
    dom.toggle_search_type.addEventListener "change", (event) -> dom.filter.classList.toggle "search_character_active"
    @url_params = new URLSearchParams window.location.search
    @character_search = new character_search_class @
    @word_search = new word_search_class @

new app_class()
