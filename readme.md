a csv file and anki deck to memorise the shape and only one useful meaning of each of the 2136 jouyou kanji.
because it contains less information than many other decks, you will be familiar with the characters in a shorter period of time and then have an easier time learning anything else related to kanji.
the characters are sorted by stroke count, which is a natural order that roughly corresponds to complexity, where parts come before compounds and learning progress is apparent.

`download/jouyou by stroke count.apkg` is the anki deck and `download/jouyou-by-stroke-count.csv` is the source data csv file.

additionally included in this repository are
* a one file stroke-order lookup application at `download/kanji-viewer.html`. this html file can be downloaded and viewed in a browser but is also hosted [here](http://sph.mn/other/kanji-viewer.html).
* under download/extras:
  * multiple-kanji-to-reading.csv: a list of multiple kanji and their shared reading
  * jouyou-with-shared-readings.csv: a list of kanji and for each of its readings the kanji that share the reading
  * writing-n5.csv: a jlpt n5 vocabulary list for practising writing for only words that include kanji with pronounciation in romaji, meaning and the word
  * writing-n5.apkg: an anki deck for the jlpt n5 vocabulary list for writing practice
  * kanji-radicals.csv

notes
* the anki deck uses a special font that looks hand-drawn and makes individual strokes more apparent. this can also help with differentiating components
* this deck uses a small number of relatively uncommon english words. examples: beckon, portent, acquiesce
* the jouyou kanji generally dont include some commonly used kanji. examples: 嬉萌伊綺嘘菅貰縺繋呟也

# adding example words
originally this project had a different focus and because of this, more features are available and still maintained.
to add example words to jouyou-by-stroke-count.csv, set add_example_words at the top of js/create-csv-file-with-extras.coffee to true and generate a csv file (see section "technical" below).
the example words are sorted by twitter and blog usage frequencies and sensitive words will be excluded.

# data sources
* [list of joyo kanji](https://en.wikipedia.org/wiki/List_of_j%C5%8Dy%C5%8D_kanji)
* extras
  * word translations: [jmdict](http://www.edrdg.org/jmdict/j_jmdict.html) (cc-by-sa-3.0)
  * word frequency: [gimenes, m., & new, b. (2015) wordlex](http://www.lexique.org/?page_id=250)
  * component names: [kanji alive](https://github.com/kanjialive/kanji-data-media) language data (cc-by-4.0)
  * unicode kanji to radical mapping from [ocornut](https://gist.github.com/ocornut/18844be7446b63d936e4fab8fb5e6e01)
  * [jlpt n5 words and meanings](http://www.passjapanesetest.com/jlpt-n5-vocabulary-list/)
  * [list of kanji radicals by stroke count](https://en.wikipedia.org/wiki/List_of_kanji_radicals_by_stroke_count)

most data is included, except for the jlpt n5 wordlist, and all other data of this project is cc-by-sa-4.0.

# technical
* the code uses javascript, nodejs and its package manager npm. the code is actually written in [coffeescript](http://coffeescript.org), which is javascript written with less code
* how to recreate the csv file
  * initialise the development environment once with "npm install" to install dependencies
  * execute `npm run compile`. if the coffee command is not found, then `./node_modules/coffee-script/bin/coffee js/create-csv-file.coffee` might work instead
  * see the top of the code file for configuration options
* to create a csv file with extra features, see js/create-csv-file-with-extras.coffee for configuration and execute this file with the coffee command as for the standard csv file
* good to know regarding unicode: kanji components and kanji that look exactly the same exist at multiple separate codepoints. see [wikipedia: kangxi radical unicode](https://en.wikipedia.org/wiki/Kangxi_radical#Unicode)
* kanji-viewer.html is built from html/template.html and js/create-kanji-viewer.coffee, and requires the kanji directory from [kanjivg](https://github.com/KanjiVG/kanjivg) to have been downloaded and its path configured in the coffee file
