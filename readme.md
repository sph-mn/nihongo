a fast dictionary, lists related to kanji and scripts to compile the lists.

# kanji viewer
* kanji stroke order, meaning and common readings lookup
* top 30000 words fuzzy search that searches for similar pronunciation and sorts results by frequency
* single-file browser page. the file can be downloaded and viewed in a browser but is also hosted [here](http://sph.mn/other/kanji-viewer.html)
* download/kanji-viewer.html

# csv lists
under download/
* components-ck.csv: [components, kanji] alternative to radkfile
* components-kc.csv: [kanji, components] alternative to kradfile
* jouyou-kanji.csv: [kanji, meaning, readings] the 2136 jouyou kanji as of 2020 sorted by stroke count with single word meaning and common readings
  * some meanings use relatively uncommon english words, for example: acquiesce, adroit, ardent, beckon, confer, consign, consort, consummate, portent
  * stroke count roughly corresponds to complexity, components come first
  * the jouyou kanji in general exclude some commonly seen kanji, for example: 嬉萌伊綺嘘菅貰縺繋呟也
* jouyou-kanji-learning.csv: [[kanji, meaning, readings], [word, reading, meanings]] kanji information and up to three example words with translations. sorted by number of common readings and readings alphabetically. kanji with few common readings come first
* jouyou-kanji-only-words.csv: [word, readings, meanings] frequently used example words for the jouyou kanji. currently up to 5 words per kanji
* jouyou-kanji-with-words.csv: [kanji, meaning, readings, words] like jouyou-kanji.csv but with an additional column for newline separated example words
* jouyou-kanji-by-reading.csv: [kanji, readings, word] sorted by number of readings and reading, starting with kanji that have few common readings
* jouyou-stroke-count.csv: [kanji, stroke-count]
* jouyou-two-shared-components.csv: [component, kanji] list of kanji that share at least two components
* jouyou-with-shared-readings.csv [kanji, readings, multiple-kanji-per-reading]
* kanji-radicals.csv [stroke-count, radical, meaning, variants, note, is_new]
* multiple-kanji-to-reading.csv [multiple-kanji, reading]

# data sources
* [list of jouyou kanji](https://en.wikipedia.org/wiki/List_of_j%C5%8Dy%C5%8D_kanji) on wikipedia
* word frequency: [gimenes, m., & new, b. (2015) wordlex](http://www.lexique.org/?page_id=250)
* word translations: [jmdict](http://www.edrdg.org/jmdict/j_jmdict.html) (cc-by-sa-3.0)
* stroke order graphics: [kanjisvg](https://github.com/KanjiVG/kanjivg/releases)
* kanji to component mapping: [kanji bakuhatsu](https://github.com/ScottOglesby/kanji-bakuhatsu) (gpl3)
* component names: [kanji alive](https://github.com/kanjialive/kanji-data-media) language data (cc-by-4.0)
* [list of kanji radicals by stroke count](https://en.wikipedia.org/wiki/List_of_kanji_radicals_by_stroke_count)
* unicode kanji to radical mapping from [ocornut](https://gist.github.com/ocornut/18844be7446b63d936e4fab8fb5e6e01)

data is included, except for kanjisvg. all other data of this project is cc-by-sa-4.0.

# technical
* code uses node.js and its package manager npm. code is written in [coffeescript](http://coffeescript.org), which is javascript just with reduced syntax
* how to recreate the csv files
  * initialise the development environment once with "npm install" to install dependencies, which creates a node_modules directory in the current directory
  * see files under exe/, they are shell scripts and can be executed with ./exe/filename and contain configuration options
  * for other tools "coffee js/filename"
* how to recreate kanji-viewer
  * requires the kanji directory from [kanjivg](https://github.com/KanjiVG/kanjivg) to have been downloaded and saved under data/kanjivg
  * uses data files created by "./exe/update-viewer-data"
  * execute "./exe/update-viewer"
  * the result file is build from html/viewer-template.html
* good to know regarding unicode: multiple kanji components/radicals and kanji that look exactly the same exist at separate codepoints. see [wikipedia: kangxi radical unicode](https://en.wikipedia.org/wiki/Kangxi_radical#Unicode)
