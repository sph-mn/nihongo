a csv file and anki deck to learn the shape and only one useful meaning of the 2136 jouyou kanji.
because it contains less information than many other decks, you will be familiar with the whole set in a shorter period of time and then have an easy time learning anything else related to kanji.
the characters are sorted by stroke count, which is a natural order that roughly corresponds to complexity, where parts come before compounds and the learning progress is always apparent.

`download/jouyou by stroke count.apkg` is the anki deck and `download/jouyou-by-stroke-count.csv` is the csv file.

# data source
* kanji order and meanings: [list of joyo kanji](https://en.wikipedia.org/wiki/List_of_j%C5%8Dy%C5%8D_kanji)

all data sources are included and all other data of this project is cc-by-sa-4.0.

# extra features
originally this project had a different focus and because of this, more features are available and still maintained.

* a configurable number of example words per character sorted by frequency of usage in media
  * example words with kana reading can be included by setting add_example_words at the top of js/create-csv-file.coffee to true and recreating the csv file
  * the example words were selected based on twitter and blog usage frequencies and sensitive words are excluded
* topokanji order

the extra features use data from these additional sources:
* [topokanji](https://github.com/scriptin/topokanji)
* word translations: [jmdict](http://www.edrdg.org/jmdict/j_jmdict.html) (cc-by-sa-3.0)
* word frequency: [gimenes, m., & new, b. (2015) wordlex](http://www.lexique.org/?page_id=250)
* component names: [kanji alive](https://github.com/kanjialive/kanji-data-media) language data (cc-by-4.0)
* unicode kanji to radical mapping from [ocornut](https://gist.github.com/ocornut/18844be7446b63d936e4fab8fb5e6e01)

# technical
* uses javascript, nodejs and its package manager npm. the code is actually written in [coffeescript](http://coffeescript.org), but note that this is just javascript written with less code
* how to recreate the csv file
  * initialise the development environment once with "npm install" to install dependencies
  * execute `npm run compile`. if the coffee command is not found, then `./node_modules/coffee-script/bin/coffee js/create-csv-file.coffee` might work instead
  * see the top of the code file for configuration options
* to create a csv file with extra features see js/create-csv-file-with-extras.coffee for configuration and execute like for the standard csv file
* a note about unicode: kanji components and kanji that look exactly the same exist at multiple separate codepoints. see [wikipedia: kangxi radical unicode](https://en.wikipedia.org/wiki/Kangxi_radical#Unicode)
