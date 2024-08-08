a fast dictionary, lists related to kanji and scripts to compile the lists.

# nihongo dictionary
* kanji stroke order, meaning and common readings lookup
* top 30000 words fuzzy search that searches for similar pronunciation and sorts results by frequency
* single-file browser page. the file can be downloaded and viewed in a browser but is also hosted [here](http://sph.mn/other/japanese/nihongo-dictionary.html)
* data/nihongo-dictionary.html

# csv lists
under [data](data):
* components-ck.csv: [components, kanji] alternative to radkfile
* components-kc.csv: [kanji, components] alternative to kradfile
* jouyou-kanji.csv: [kanji, meaning, readings] the 2136 jouyou kanji as of 2020 sorted by stroke count with single word meaning and common readings
  * some meanings use relatively uncommon english words, for example: acquiesce, adroit, ardent, beckon, confer, consign, consort, consummate, portent. in a few cases the words are ambiguous. for example "vice" isnt meant in the sense of "shortcoming" but in the sense of "deputy"
  * order by stroke count roughly corresponds to complexity, components come first
  * the jouyou kanji in general exclude some commonly seen kanji, for example: 嬉萌伊綺嘘菅貰縺繋呟也
* jouyou-kanji-learning.csv: [[kanji, meaning, readings], [word, reading, meanings]] kanji information and example words with translations. sorted by number of common readings and readings alphabetically. kanji with few common readings come first
* jouyou-kanji-only-words.csv: [word, readings, meanings] frequently used example words for the jouyou kanji
* jouyou-kanji-with-words.csv: [kanji, meaning, readings, words] like jouyou-kanji.csv but with an additional column for newline separated example words
* jouyou-stroke-count.csv: [kanji, stroke-count]
* jouyou-two-shared-components.csv: [component, kanji ...] list of kanji that share at least two components
* jouyou-with-shared-readings.csv: [kanji, readings, multiple-kanji-per-reading]
* kanji-radicals.csv: [stroke-count, radical, meaning, variants, note, is_new]
* multiple-kanji-to-reading.csv: [multiple-kanji, reading]
* ideophones.csv: [romaji, meanings] onomatopoeia, sound symbolisms
* jouyou-kanji-learning-oneline.csv: [kanji, meaning, readings, example-words] like jouyou-kanji-learning.csv but words in one separate column
* chinese-japanese-overlap.csv: sino-japanese cognates, words with the same characters in both languages

some lists can be customized, see exe/update-kanji-words

# anki deck
* data/ja-kanji-learning.apkg: [kanji, [readings, meaning, example words]] and reverse cards

# data sources
* [list of jouyou kanji](https://en.wikipedia.org/wiki/List_of_j%C5%8Dy%C5%8D_kanji) on wikipedia
* word frequency: [gimenes, m., & new, b. (2015) wordlex](http://www.lexique.org/?page_id=250)
* word translations: [jmdict](http://www.edrdg.org/jmdict/j_jmdict.html) (cc-by-sa-3.0)
* stroke order graphics: [kanjisvg](https://github.com/KanjiVG/kanjivg/releases) (cc-by-sa-3.0)
* kanji to component mapping: [kanji bakuhatsu](https://github.com/ScottOglesby/kanji-bakuhatsu) (gpl3)
* component names: [kanji alive](https://github.com/kanjialive/kanji-data-media) language data (cc-by-4.0)
* [list of kanji radicals by stroke count](https://en.wikipedia.org/wiki/List_of_kanji_radicals_by_stroke_count)
* unicode kanji to radical mapping from [ocornut](https://gist.github.com/ocornut/18844be7446b63d936e4fab8fb5e6e01)

data is included. all other data of this project, including the source code, is cc-by-sa-4.0.

# technical
* the generator scripts uses node.js and its package manager npm. code is written in [coffeescript](http://coffeescript.org), which is javascript just with reduced syntax
* how to recreate the csv files
  * initialise the development environment once with "npm install" to install dependencies, which creates a node_modules directory in the current directory
  * see files under exe/, they are shell scripts and can be executed with ./exe/filename and contain configuration options
  * for other tools see "coffee js/filename"
* how to recreate nihongo-dictionary
  * requires the kanji directory from [kanjivg](https://github.com/KanjiVG/kanjivg) to have been downloaded and saved under data/kanjivg
  * create data files with "./exe/update-dictionary-data"
  * execute "./exe/update-dictionary"
  * the result file is build from html/dictionary-template.html
* good to know regarding unicode: multiple kanji components/radicals and kanji that look exactly the same exist at separate codepoints. see [wikipedia: kangxi radical unicode](https://en.wikipedia.org/wiki/Kangxi_radical#Unicode)
