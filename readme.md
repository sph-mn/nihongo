a csv file and anki deck to study basic information about kanji in [topokanji](https://github.com/scriptin/topokanji) order.
the kanji and components are sorted by component dependency and a list of the most frequent words that include a kanji is given.

downloads/kanji.csv contains the data for flashcards and downloads/topokanji.apkg is the anki deck

# features
* the most common kanji and components sorted by topokanji. "Kanji list covers about 95-99% of kanji found in various Japanese texts. Generally, the goal is provide something similar to Jōyō kanji, but based on actual data."
* kanji and component kana translation and meaning in english
* top n example words that use a kanji sorted by frequency in the 2015 japanese wikipedia, with kana translation
* sensitive words and kana only words are excluded
* files are in utf-8

# data sources and thanks to
* kanji order: [topokanji](https://github.com/scriptin/topokanji) (cc-by-4.0 and other licenses)
* translations: [jmdict](http://www.edrdg.org/jmdict/j_jmdict.html) (cc-by-sa-3.0) via [jmdict-simplified](https://github.com/scriptin/jmdict-simplified) (cc-by-sa-4.0)
* word frequency: [wiktionary japanese wikipedia 2015](https://en.wiktionary.org/wiki/Wiktionary:Frequency_lists/Japanese2015_10000) (cc-by-sa-3.0)
* component names: [kanji alive](https://github.com/kanjialive/kanji-data-media) language data (cc-by-4.0)
* unicode kanji to radical mapping from [ocornut](https://gist.github.com/ocornut/18844be7446b63d936e4fab8fb5e6e01)

some data sources are included and all other data of this project is cc-by-sa-4.0.

# motivation
to learn kanji fast, i thought it would be best to have just the kanji symbol (to learn appearance and to recognise it), core meanings, only the most frequent readings (to give a pronounciation and guess pronounciation in unknown words) and a list of the most common words that contain the kanji (to better understand the meaning and confirm the readings). readings are currently not included in this list because it may suffice to get the readings from words.
the kanji should also be well-sorted: "remembering the kanji" sorts the kanji by visual or component similarities and such regularity can help a lot with learning.

# technical
* how to recreate the csv file
  * ensure that all data sources exist
  * execute `php php/display-kanji-csv.php`
  * this processes the source files and writes the csv to standard output. php was chosen because it includes all dependencies
  * see the top of the php file for configuration options
* how to recreate and filter the translations
  * `php extract-jmdict-translations.php` creates the file data/jmdict-translations.json from jmdict-eng-*.json. this is a stripped down version of jmdict that contains only word and translations and is used for word lookup
  * configuration options are at the top of the php file. for example the jmdict "misc" tags used to exclude words are listed there (info about jmdict field values [here](http://www.edrdg.org/jmdictdb/cgi-bin/edhelp.py?svc=jmdict&sid=))
* how to import a csv file into anki
  * ensure a card type with four fields exists then go to file -> import
* a note about unicode: kanji components and kanji that look exactly the same exist at multiple separate codepoints. see [kangxi radical: unicode](https://en.wikipedia.org/wiki/Kangxi_radical#Unicode)

the following three data files are not included because they are quite big even compressed:
~~~
data/
  jmdict-eng-3.0.1.json
  jmdict-only-translations.json
  wikipedia-20150422-lemmas.tsv
~~~
they can be retrieved from the sites linked above.
