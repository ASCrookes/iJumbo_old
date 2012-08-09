<?php

#  joeyScraper.php
#  
#
#  Created by Amadou Crookes on 6/18/12.
#  Copyright (c) 2012 Amadou Crookes. All rights reserved.

if (!function_exists('json_decode')) {
    function json_decode($content, $assoc=false) {
        require_once 'JSON.php';
        if ($assoc) {
            $json = new Services_JSON(SERVICES_JSON_LOOSE_TYPE);
        }
        else {
            $json = new Services_JSON;
        }
        return $json->decode($content);
    }
}

if (!function_exists('json_encode')) {
    function json_encode($content) {
        require_once 'JSON.php';
        $json = new Services_JSON;
        return $json->encode($content);
    }
}


$html = file_get_contents('http://m.tufts.edu/transportation/joey/etas/');

$pattern = '/<ol.*<\/ol>/s';
preg_match($pattern, $html, $matches);

#block is the html chunk of text that has the information
$block = $matches[0];

$pattern = '/<li>.*<\/li>/';
preg_match_all($pattern, $block, $matches);

$namePattern = '/<li>(.*)<br/';
$etaPattern = '/"date">(.*)<\/span/';
$joeyInfo = array();

foreach($matches[0] as $line) {
	$details = array();
	preg_match($namePattern, $line, $nameMatch);
	$details['ETA'] = $nameMatch[1];
	preg_match($etaPattern, $line, $etaMatch);
	$details['location'] = $etaMatch[1] == 'ETA not available' ? 'N/A' : $etaMatch[1];
	$joeyInfo[]  = $details;
}

$joeyJSON = json_encode($joeyInfo);
file_put_contents('joey.json', $joeyJSON);


?>