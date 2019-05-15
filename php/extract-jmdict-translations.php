<?php

# extract and filter kanji words and translations from jmdict and write the result to a json file.
# output file format is {word: [[kana, ...], [[translation, ...], ...]]}

$config = [
  "jmdict_path" => "data/jmdict-eng.json",
  "misc_tag_exclusions" => [
    # uk: usually written using kana alone
    # x: rude or x-rated terms
    "abbr",
    "arch",
    "derog",
    "obs",
    "obsc",
    "organization",
    "person",
    "sens",
    "uk",
    "vulg",
    "work",
    "x"]];

function string_contains($a, $b) {
  return false !== mb_strpos($a, $b);
}

function get_text($a) {
  $result = [];
  foreach($a as $b) {
    $result[] = $b["text"];
  }
  return $result;
}

function is_component($gloss) {
  # example strings to match:
  # "kanji "dotted cliff" radical (radical 53)"
  # "kanji "ice" radical"
  # "kanji radical 79 at right"
  # "top component of the kanji \"thread\" radical"
  foreach($gloss as $a) {
    if(preg_match("/kanji \".*\" radical/", $a)
      || preg_match("/kanji \".*radical\"/", $a)
      || preg_match("/kanji radical \d+/", $a)
      || string_contains($a, "grain stalk radical")
      || string_contains($a, "illness radical")
      || string_contains($a, "insect radical")
      || string_contains($a, "radical leaf")
      || string_contains($a, "kanji \"crooked-leg\" dai radical")
      || string_contains($a, "kanji radical \"wa\"")
      || string_contains($a, "\"roof\" kanji radical")
      || string_contains($a, "two-branch tree radical")
      || string_contains($a, "water radical")
      || string_contains($a, "worm radical"))
    {
      return true;
    }
  }
  return false;
}

function main($c) {
  $jmdict = json_decode(file_get_contents($c["jmdict_path"]), true);
  $exclusions = $c["misc_tag_exclusions"];
  $result = [];
  foreach($jmdict["words"] as $a) {
    if($a["kanji"]) {
      $translations = [];
      foreach($a["sense"] as $b) {
        if(array_intersect($b["misc"], $exclusions)) continue;
        $gloss = get_text($b["gloss"]);
        # exclude kanji radicals
        if(is_component($gloss)) continue;
        $translations[] = $gloss;
      }
      if(!$translations) continue;
      $kana = get_text($a["kana"]);
      $kanji = get_text($a["kanji"]);
      foreach($kanji as $b) {
        # there can be multiple entries for the same word. only keep the first entry
        if(isset($result[$b])) continue;
        $result[$b] = [$kana, $translations];
      }
    }
  }
  file_put_contents("data/jmdict-translations.json", json_encode($result));
}

main($config);