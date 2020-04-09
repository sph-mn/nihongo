# features
* anki deck for kanji and one-word meaning. the characters are sorted by stroke count, which is a natural order that roughly corresponds to complexity, where parts come before compounds and learning progress is apparent
* csv file with kanji meaning
* one file stroke-order lookup application at `download/kanji-viewer.html`. this html file can be downloaded and viewed in a browser but is also hosted [here](http://sph.mn/other/kanji-viewer.html)
* csv file with kanji and example words. words in the top 10000, sensitive words excluded
* csv file with only example words for the jouyou kanji. currently up to 5 words per kanji, freely adjustable
* all csv files have a sort index field at the end that can be used as a sort field in anki
* some additional files for kanji components and other things under download/extras and data/extras, including a list of kanji that share at least two radicals
* uses the 2136 jouyou kanji as of 2020

# about the anki deck
* contains less information than many other decks, which means familiarity with the whole set is reached in a shorter period of time
* uses a font that looks hand-drawn and makes individual strokes more apparent. this can also help with differentiating components. note: it is not clear if the font needs to be included with the anki deck, currently it is not included
* some meanings use relatively uncommon english words. examples: acquiesce, adroit, ardent, beckon, confer, consign, consort, consummate, portent
* the jouyou kanji in general exclude some commonly seen kanji. examples: 嬉萌伊綺嘘菅貰縺繋呟也
* the deck is not on ankiweb because ankiweb deletes decks that dont get popular enough in a period of a few weeks. there are apparently not enough people interested in such a deck for it to not get deleted

# data sources
* [list of joyo kanji](https://en.wikipedia.org/wiki/List_of_j%C5%8Dy%C5%8D_kanji) on wikipedia
* word frequency: [gimenes, m., & new, b. (2015) wordlex](http://www.lexique.org/?page_id=250)
* word translations: [jmdict](http://www.edrdg.org/jmdict/j_jmdict.html) (cc-by-sa-3.0)
* stroke order graphics: [kanjisvg](https://github.com/KanjiVG/kanjivg/releases)
* extras
  * component names: [kanji alive](https://github.com/kanjialive/kanji-data-media) language data (cc-by-4.0)
  * [jlpt n5 words and meanings](http://www.passjapanesetest.com/jlpt-n5-vocabulary-list/)
  * [list of kanji radicals by stroke count](https://en.wikipedia.org/wiki/List_of_kanji_radicals_by_stroke_count)
  * unicode kanji to radical mapping from [ocornut](https://gist.github.com/ocornut/18844be7446b63d936e4fab8fb5e6e01)

data is included, except for kanjisvg and the jlpt n5 wordlist. all other data of this project is cc-by-sa-4.0.

# technical
* code uses node.js and its package manager npm. code is written in [coffeescript](http://coffeescript.org), which is really just javascript reduced
* how to recreate the csv files
  * initialise the development environment once with "npm install" to install dependencies, which creates a node_modules directory in the current directory
  * see files under exe/, they can be executed with ./exe/filename and contain configuration options
  * for other tools "coffee js/filename"
* how to recreate kanji-viewer
  * built from html/template.html and js/viewer-html.coffee
  * requires the kanji directory from [kanjivg](https://github.com/KanjiVG/kanjivg) to have been downloaded and saved under data/kanjivg
  * execute "coffee js/viewer-html.coffee"
* good to know regarding unicode: kanji components/radicals and kanji that look exactly the same exist at separate codepoints. see [wikipedia: kangxi radical unicode](https://en.wikipedia.org/wiki/Kangxi_radical#Unicode)
