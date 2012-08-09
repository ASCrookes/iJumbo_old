<?php

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



// given a url for a nutritions page it should return an 
// associative array of the details
function getFoodFacts($url) {
	$facts = array();
	$html = file_get_contents($url);
	
	// If the page has not nutrion facts return an empty array and do not add it.
	$pattern = '/Nutritional Information is not available for this recipe/';
	if(preg_match($pattern, $html)) {
	    return $facts;
	}
	$pattern = '/"labelrecipe">(.*)<\//';
	preg_match($pattern, $html, $matches);
	$facts['FoodName'] = $matches[1];
		
	$pattern = '/<font size="5".*">(.*)<\/font/';
	preg_match_all($pattern, $html, $matches);
	$details = $matches[1];
	$facts['serving_size'] = $details[0];
	
	preg_match('/\d+/', $details[1], $matches);
	$facts['calories'] = $matches[0];
	
	preg_match('/\d+/', $details[2], $matches);
	$facts['fat_calories'] = $matches[0];	
	
	$keyConversion = array("Total Fat"     => 'total_fat',
						   "Tot. Carb."    => 'total_carbs',
						   "Sat. Fat"      => 'saturated_fat',
						   "Dietary Fiber" => 'fiber',
						   "Trans Fat"     => 'trans_fat',
						   "Sugars"        => 'sugars',
						   "Sugars---g"    => 'sugars',
						   "Cholesterol"   => 'cholesterol',
						   "Protein"       => 'protein',
						   "Sodium"        => 'sodium');
	
	
	$pattern = '/<font.*?size="4".*?>(.*?)<\/font>/';
	preg_match_all($pattern, $html, $nutritionTags);
	
	$clean = '/\&nbsp;|<\/?b>/';
	
	for($i = 0; $i < count($nutritionTags[1]); $i++) {
		$nutritionTags[1][$i] = preg_replace($clean, '', $nutritionTags[1][$i]);
	}
	$nutritionTags = $nutritionTags[1];
	
	$letter = '/^[a-zA-Z]/';
	$fullDetails = array();
	$details = array();

	for($i = 0; $i < count($nutritionTags); $i++) {
		$info = $nutritionTags[$i];
		if(preg_match($letter, $info) && $i != 0) {
			$fullDetails[] = $details;
			$details = array();
		}
		$details[] = $info;
	}
	$fullDetails[] = $details;
	
	// Commented out stops it from getting percents for each field shown in ios UI
	foreach($fullDetails as $details) {
		$key = $keyConversion[$details[0]];
		
		$amount = $details[1] == '---g' ? 'N/A' : $details[1];
		//$percent = count($details) < 4 ? 'N/A' : $details[2];
		//$facts[$key] = array(0 => $amount, 1 => $percent);
		$facts[$key] = $amount;
	}
	
	// Comments stop it from getting general percents
	//$pattern = '/([\.\d]+%)<\//';
	//preg_match_all($pattern, $html, $percents);
	$pattern = '/"labelingredientsvalue">(.*)<\/span>/';
	preg_match($pattern, $html, $ingredients);
	$pattern = '/"labelallergensvalue">(.*)<\/span>/';
	preg_match($pattern, $html, $allergens);
	
	//$facts['percents']    = $percents[1];
	$facts['ingredients'] = $ingredients[1];
	$facts['allergens'] = !$allergens[1] ? 'None' : $allergens[1];
		
	return $facts;
}


// Argument: meal url to get the food from
function getMeal($mealURL) {

	$meals = array( 'Breakfast' => array('MealName' => 'Breakfast', 'sections' => array()), 
					'Lunch' => array('MealName' => 'Lunch', 'sections' => array()), 
					'Dinner' => array('MealName' => 'Dinner', 'sections' => array()));

	if($mealURL == '') {
		return $meals;
	}

	$html = file_get_contents($mealURL);

	$baseURL = 'http://menus.tufts.edu/foodpro/';

	$pattern = '/<a href="(longmenu\S+)".*<img\s?src/';

	preg_match_all($pattern, $html, $matches);

	$urlPostfixes = $matches[1];

	// Making all meals empty so if not on the page there is empty data for it
	$allMeals = array();

	foreach($urlPostfixes as $urlEnd) {
		$url = $baseURL . $urlEnd;
		$html = file_get_contents($url);
		$pattern = '/>--(.*?)--<.*?longmenucolmenucat/s';
		preg_match_all($pattern, $html, $sections);
		$meal = array();
		$pattern = '/mealName=(.*)$/';
		preg_match($pattern, $url, $name);
		$meal['MealName'] = $name[1];
		$sectionList = array();
		for($i = 0; $i < count($sections[0]); $i++) {
			$section = array();
			$section['SectionName'] = trim($sections[1][$i]);
			$sectionHTML = $sections[0][$i];
		
			$pattern = "/<div\s?class='longmenucoldispname'>.+<a\s?href='(\S+)'/";
			preg_match_all($pattern, $sectionHTML, $matches);
			$foodList = array();
			if($section['SectionName'] != 'FRUIT & YOGURT') {
				foreach($matches[1] as $foodURL) {
					$foodDetailsURL = 'http://menus.tufts.edu/foodpro/' . $foodURL;
					$foodFacts = getFoodFacts($foodDetailsURL);
					if(count($foodFacts) > 0) {
					    $foodList[] = $foodFacts;
				        }
				}
				$section['foods'] = $foodList;
				$sectionList[] = $section;
			}
		
		}
		$meal['sections'] = $sectionList;
		$meals[$meal['MealName']] = $meal;	
	}
	return $meals;
}


// loops through the dining hall urls and creates the final file
function main() {
	$diningURLS = array('Carmichael' => 'http://menus.tufts.edu/foodpro/shortmenu.asp?sName=Tufts+Dining&locationNum=09&locationName=Carmichael+Dining+Center&naFlag=1',
				    	'Dewick'     => 'http://menus.tufts.edu/foodpro/shortmenu.asp?sName=Tufts+Dining&locationNum=14&locationName=Hodgdon+Good-+To-+Go+Take-+Out&naFlag=1',
				    	'Hodgdon'    => 'http://menus.tufts.edu/foodpro/shortmenu.asp?sName=Tufts+Dining&locationNum=14&locationName=Hodgdon+Good-+To-+Go+Take-+Out&naFlag=1');
	$finalMealDict = array();
	foreach($diningURLS as $hall => $hallURL) {
		$finalMealDict[$hall] = getMeal($hallURL);
	}

	$mealJSON = json_encode($finalMealDict);
	file_put_contents('../files/meals.json', $mealJSON);
}


main();


?>