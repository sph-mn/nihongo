<?php

$config = [
  "kanji_path" => "data/aozora-694107d.txt",
  "kanji_to_radical_path" => "data/kanji-to-radical.csv",
  "jmdict_path" => "data/jmdict-translations.json",
  "kanjidic_path" => "data/kanjidic2-translations.json",
  "word_frequency_path" => "data/wikipedia-20150422-lemmas.tsv",
  "components_path" => "data/japanese-radicals-513ba7a.csv",
  "example_limit" => 15,
  "example_translation_limit" => 3,
  "example_translation_word_limit" => 3,
  "limit" => 3000,
  "word_separator" => "\n"
];

function string_contains($a, $b) {
  return false !== mb_strpos($a, $b);
}

function get_word_frequencies($path) {
  $lines = file($path, FILE_IGNORE_NEW_LINES);
  $result = [];
  foreach ($lines as $a) {
    $a = explode("\t", $a)[2];
    if(1 == mb_strlen($a)) continue;
    $result[] = $a;
  }
  return $result;
}

function get_radical_to_kanji($path) {
  # radicals and same looking kanji characters have separate unicode codepoints.
  # this returns a lookup table.
  $rows = array_map("str_getcsv", file($path));
  $result = [];
  foreach($rows as $a) {
    $key = mb_chr(hexdec($a[0]));
    $value = mb_chr(hexdec($a[1]));
    $result[$value] = $key;
  }
  return $result;
}

function get_components($path, $kanji_to_radical_path) {
  # -> [character => [string:description, string:kana-name], ...]
  $result = [];
  $lines = file($path, FILE_IGNORE_NEW_LINES);
  $radical_to_kanji = get_radical_to_kanji($kanji_to_radical_path);
  foreach ($lines as $a) {
    $a = array_filter(array_filter(str_getcsv($a, ";")), "trim");
    $entry = [$a[3]];
    if(isset($a[4])) $entry[] = $a[4];
    $key = $a[1];
    $result[$key] = $entry;
    # also include kanji version of radical characters (separate, identically looking characters in unicode)
    if(isset($radical_to_kanji[$key])) $result[$radical_to_kanji[$key]] = $entry;
  }
  # add additional characters that apparently dont have a radical codepoint
  # and arent included as such in the components file.
  $result["亻"] = ["man, human. variant of 人", "ひと"];
  $result["扌"] = ["hand. variant of 手", "て"];
  $result["耂"] = ["old", "ろう"];
  $result["刂"] = ["sword. variant of 刀", "かたな"];
  $result["灬"] = ["fire. variant of 火", "ひ"];
  $result["阝"] = ["town. variant of 邑", "むら"];
  $result["礻"] = ["altar, display. variant of 示", "しめす"];
  $result["忄"] = ["heart. variant of 心", "りっしんべん"];
  $result["氵"] = ["water. variant of 水", "みず"];
  $result["衤"] = ["clothes. variant of 衣", "ころも"];
  $result["⼌"] = ["to enclose", "けいがまえ"];
  $result["冂"] = ["to enclose", "けいがまえ"];
  $result["⼳"] = ["short thread", "いとがしら"];
  $result["攵"] = ["strike", "のぶん"];
  $result["幺"] = ["short thread", "いとがしら"];
  $result["辶"] = ["walk. variant of ⻌", "チャク"];
  $result["罒"] = ["net", "あみがしら"];
  $result["飠"] = ["eat, food", "しょくへん"];
  $result["尢"] = ["lame leg", "だいのまげあし"];
  $result["彑"] = ["pig head. variant of 彐", "けいがしら"];
  $result["旡"] = ["crooked heaven", ""];
  return $result;
}

function get_example_words($word_frequencies, $jmdict, $kanji, $count) {
  # try to find $count number of words with kana and translations.
  $result = [];
  if(0 == $count) return $result;
  foreach ($word_frequencies as $a) {
    if(string_contains($a, $kanji)) {
      $entry = isset($jmdict[$a]) ? $jmdict[$a] : false;
      if($entry) $result[$a] = $entry;
      if($count == count($result)) break;
    }
  }
  return $result;
}

function join_translations($a, $limit, $word_limit) {
  # take only the first n translations/meanings
  $c = [];
  $meanings = array_slice($a, 0,
    min($word_limit, count($a)),
    true);
  foreach($meanings as $b) {
    $c[] = join(", ", $b);
  }
  $c = array_slice($c, 0, min($limit, count($c)), true);
  return join("; ", $c);
}

function get_example_words_string($words, $config) {
  if(!$words) return null;
  $translation_limit = $config["example_translation_limit"];
  $translation_word_limit = $config["example_translation_word_limit"];
  $separator = $config["word_separator"];
  $result = [];
  foreach($words as $word => $details) {
    $translations = join_translations($details[1], $translation_limit, $translation_word_limit);
    $kana = $details[0];
    $kana = $kana ? (" (" . $kana[0] . ")") : "";
    $result[] = $word . "$kana: $translations";
  }
  return join($separator, $result);
}

function get_kanji_info($jmdict, $components, $kanjidic, $kanji, $config) {
  # get details for a single kanji or component
  $translation = null;
  $kana = null;
  $word = null;
  if(isset($components[$kanji])) {
    $info = $components[$kanji];
    $translation = "kanji component: " . $info[0];
    if(isset($info[1])) $kana = $info[1];
  }
  else {
    $entry = false;
    if (isset($kanjidic[$kanji])) {
      $entry = $kanjidic[$kanji];
    }
    else if (isset($jmdict[$kanji])){
      $entry = $jmdict[$kanji];
    }
    if($entry) {
      $translation_limit = $config["example_translation_limit"];
      $translation_word_limit = $config["example_translation_word_limit"];
      $translation = join_translations($entry[1], $translation_limit, $translation_word_limit);
      if($entry[0]) $kana = $entry[0][0];
    }
  }
  return [$translation, $kana];
}

function main($c) {
  $components = get_components($c["components_path"], $c["kanji_to_radical_path"]);
  $kanji_list = file($c["kanji_path"], FILE_IGNORE_NEW_LINES);
  $jmdict = json_decode(file_get_contents($c["jmdict_path"]), true);
  $kanjidic = json_decode(file_get_contents($c["kanjidic_path"]), true);
  $word_frequencies = get_word_frequencies($c["word_frequency_path"]);
  $limit = $c["limit"];
  $out = fopen("php://output", "w");
  # anki doesnt skip the csv header so it isnt included for now
  #fputcsv($out, ["kanji", "kana", "meaning", "example words"]);
  foreach($kanji_list as $index => $kanji) {
    if($limit <= $index) break;
    $example_words = get_example_words($word_frequencies, $jmdict, $kanji, $c["example_limit"]);
    $example_words_string = get_example_words_string($example_words, $c);
    $kanji_info = get_kanji_info($jmdict, $components, $kanjidic, $kanji, $c);
    fputcsv($out, [$kanji, $kanji_info[0], $kanji_info[1], $example_words_string]);
  }
}

main($config);
