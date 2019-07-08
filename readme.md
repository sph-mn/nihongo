a csv file and anki deck to study basic information about kanji in [topokanji](https://github.com/scriptin/topokanji) order.
for each entry a single word for the meaning and most frequent example words with kana and meaning are included.

download/kanji.csv contains the data for flashcards and download/topokanji.apkg is the anki deck. [ankiweb page](https://ankiweb.net/shared/info/211883411)

# features
* the most common kanji and components sorted by topokanji. "Kanji list covers about 95-99% of kanji found in various Japanese texts. Generally, the goal is provide something similar to Jōyō kanji, but based on actual data."
* kanji and component kana translation and single keyword meaning in english
* top n example words that use a kanji selected by twitter and blog usage frequency
* sensitive words and kana-only words are excluded
* files are in utf-8

# data sources and thanks to
* kanji order: [topokanji](https://github.com/scriptin/topokanji) (cc-by-4.0 and other licenses)
* kanji meanings: [list of joyo kanji](https://en.wikipedia.org/wiki/List_of_j%C5%8Dy%C5%8D_kanji)
* supplementary kanji meanings: [kanjidic2](http://www.edrdg.org/wiki/index.php/KANJIDIC_Project) (cc-by-sa-3.0)
* word translations: [jmdict](http://www.edrdg.org/jmdict/j_jmdict.html) (cc-by-sa-3.0) via a regenerated [jmdict-simplified](https://github.com/scriptin/jmdict-simplified) (cc-by-sa-4.0)
* word frequency: [gimenes, m., & new, b. (2015) wordlex](http://www.lexique.org/?page_id=250)
* component names: [kanji alive](https://github.com/kanjialive/kanji-data-media) language data (cc-by-4.0)
* unicode kanji to radical mapping from [ocornut](https://gist.github.com/ocornut/18844be7446b63d936e4fab8fb5e6e01)

all data sources are included and all other data of this project is cc-by-sa-4.0.

# motivation
to learn fast to recognise the kanji, i thought it would be best to have just the kanji symbol (to learn appearance and to recognise it), core meanings, only the most frequent readings (to give a pronounciation and guess pronounciation in unknown words) and a list of the most common words using it (to better understand the meaning and confirm the readings). readings are currently not included in this list because it may suffice to get the readings from words. standard readings are often not applicable to common words. the kanji should also be well-sorted: "remembering the kanji" sorts the kanji by visual or component similarities and such regularity can help a lot with learning.

# technical
* how to recreate the csv file
  * execute `php php/display-kanji-csv.php`
  * this processes the source files and writes the csv to standard output. php was chosen because it includes all dependencies
  * see the top of the php file for configuration options
* how to recreate the translations file and filter translations
  * `php php/extract-jmdict-translations.php` creates the file data/jmdict-translations.json from jmdict-eng-*.json. this is a stripped down version of jmdict that contains only word and translations and is used for word lookup
  * configuration options are at the top of the php file. for example the jmdict "misc" tags used to exclude words are listed there (info about jmdict field values [here](http://www.edrdg.org/jmdictdb/cgi-bin/edhelp.py?svc=jmdict&sid=))
* how to recreate the supplementary kanjidic translations file
  * `php php/extract-kanjidic2-translations.php > data/kanjidic2-translations.json`. ther resulting file has the same format as jmdict-translations.json
* how to import a csv file into anki
  * ensure a card type with four fields exists then go to file -> import
* a note about unicode: kanji components and kanji that look exactly the same exist at multiple separate codepoints. see [wikipedia: kangxi radical unicode](https://en.wikipedia.org/wiki/Kangxi_radical#Unicode)
