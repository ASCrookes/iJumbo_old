<?php
#!/bin/sh

#  eventScraper.php
#  
#
#  Created by Amadou Crookes on 6/19/12.
#  Copyright (c) 2012 Amadou Crookes. All rights reserved.

$URL_PREFIX = 'https://www.tuftslife.com';

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

// pass in the url with more details from the main page
// also pass in the start and end time cause it is easier to 
// get that information from the previous page 
function getDetailsFromURL($url, $startTime, $endTime) {
	$details = array();
	
	$pattern = '/\&nbsp;/';
	$details['start_time'] = preg_replace($pattern, '', $startTime);
	$details['end_time']   = preg_replace($pattern, '', $endTime);
	
	$html = file_get_contents($url);
	
	$pattern = '/<meta name="description"\s?content="(.*)"\s?\/>/';
	preg_match($pattern, $html, $matches);
	$details['event_info'] = $matches[1];
	
	$pattern = '/<h2>(.+)<\/h2>/';
	preg_match($pattern, $html, $matches);
	$details['name'] = $matches[1];
	
	$pattern = '/<p><strong>Location:<\/strong>\s?(.*)<\/p>/';
	preg_match($pattern, $html, $matches);
	$details['location'] = $matches[1];
	
	$pattern = '/<p><strong>Category:<\/strong>\s?(.*)<\/p>/';
	preg_match($pattern, $html, $matches);
	$details['event_type'] = $matches[1];
	
	return $details;
}

function getEvents($url) {
	
	$html = file_get_contents('https://www.tuftslife.com/calendar');
	//<td><a href="/events/12956">
	$pattern = '/<td><a href="(\/events.*)">/';
	preg_match_all($pattern, $html, $matches);

	$eventUrlPostfix = $matches[1];

	$pattern = '/<td class=".*">(.*)<\/td>/';
	preg_match_all($pattern, $html, $matches);
	// clean for html cases
	$times = $matches[1];


	$events = array();
	$i = 0;
	foreach($eventUrlPostfix as $end) {

		$eventURL = $URL_PREFIX . $end;
		$events[] = getDetailsFromURL($eventURL, $times[$i], $times[$i+1]);
		$i += 2;
	}

	$eventsJSON = json_encode($events);
	file_put_contents('../files/final.json', $eventsJSON);
	
}

function main() {
	date_default_timezone_set('UTC');
	echo date('1');
}


main();






?>