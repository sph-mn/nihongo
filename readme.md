a csv file and anki deck to learn basic information about kanji in [topokanji](https://github.com/scriptin/topokanji) order.
kanji + single word meaning + most frequently used words + kana reading.
download/topokanji-deck.csv contains the data for flashcards and download/topokanji.apkg is the anki deck ([ankiweb page](https://ankiweb.net/shared/info/211883411)).

# features
* the most common kanji and components. "covers about 95-99% of kanji found in various Japanese texts. Generally, the goal is provide something similar to Jōyō kanji, but based on actual data."
* sensitive words and kana-only words are excluded
* files are in utf-8

# data sources and thanks to
* kanji order: [topokanji](https://github.com/scriptin/topokanji) (cc-by-4.0 and other licenses)
* kanji meanings: [list of joyo kanji](https://en.wikipedia.org/wiki/List_of_j%C5%8Dy%C5%8D_kanji)
* word translations: [jmdict](http://www.edrdg.org/jmdict/j_jmdict.html) (cc-by-sa-3.0)
* word frequency: [gimenes, m., & new, b. (2015) wordlex](http://www.lexique.org/?page_id=250)
* component names: [kanji alive](https://github.com/kanjialive/kanji-data-media) language data (cc-by-4.0)
* unicode kanji to radical mapping from [ocornut](https://gist.github.com/ocornut/18844be7446b63d936e4fab8fb5e6e01)

all data sources are included and all other data of this project is cc-by-sa-4.0.

# technical
* how to recreate the csv file
  * execute `coffee js/create-csv-file.coffee`
  * see the top of the code file for configuration options
* how to import a csv file into anki
  * ensure a card type with at least three fields exists then go to file -> import
* a note about unicode: kanji components and kanji that look exactly the same exist at multiple separate codepoints. see [wikipedia: kangxi radical unicode](https://en.wikipedia.org/wiki/Kangxi_radical#Unicode)
