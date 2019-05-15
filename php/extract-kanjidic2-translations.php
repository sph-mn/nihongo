<?php

# extract english readings from kanjidic2.xml and write json to standard output.
# output format: {kanji: [[kana, ...], [[meaning, ...], ...]]}

$kanjidic2_path = "data/kanjidic2.xml";
$kanjidic = new SimpleXMLElement(file_get_contents($kanjidic2_path));

# file format details: http://www.edrdg.org/kanjidic/kanjidic2_dtdh.html

$result = [];
foreach($kanjidic->character as $a) {
  $key = (string)$a->literal;
  $rmgroup = $a->reading_meaning->rmgroup;
  if(isset($rmgroup->meaning)) {
    $meaning = [];
    foreach($rmgroup->meaning as $b) {
      # english if unset
      if(isset($b["m_lang"])) continue;
      $meaning[] = [(string)$b];
    }
    $result[$key] = [[], $meaning];
  }
}

echo json_encode($result);