<?php

require_once('settingsInc.php');
require("rolling-curl/RollingCurl.php");

define("USERNAME", 			$USERNAME);
define("PASSWORD", 			$PASSWORD);
define("AUTH_URL", 			$AUTH_URL);
define("API_URL", 			$API_URL);
define("CLIENT_ID", 		$CLIENT_ID);
define("CLIENT_SECRET", 	$CLIENT_SECRET);

if (array_key_exists('leadIds', $_POST)) {
	$sReq = $_POST['leadIds'];
}

$arrLeadIds = array();

if (trim($sReq.'') != '') {
	addToLog($sReq);
	$arrLeadIds = json_decode($sReq, true);
}

function addToLog($sIn) {
	$sIn .= '<br/>';
	$logFile = "./../log.txt";
	$fh = fopen($logFile, 'a') or die("can't open file");
	fwrite($fh, $sIn);
	fclose($fh);
}


if (count($arrLeadIds) > 0) {
	processLeadInBatches($arrLeadIds);	
}


function processLeadInBatches($arrLeadIds) {
	
	$sessionID = getSessionID();	
	
	//get these in batches of 200.  that's the default max salesforce supports
	$arrLeadIdsBatch = array();
	$arrLeadBatch = array();
	foreach($arrLeadIds as $value) {
		array_push($arrLeadIdsBatch, $value);
		if (count($arrLeadIdsBatch) == 200) {			
			$arrLeadBatch = getLeads($sessionID, $arrLeadIdsBatch);
			rollingCurlBatch($arrLeadBatch);
			$arrLeadIdsBatch= array();
		}
	}
	
	//get any leftover batch
	if (count($arrLeadIdsBatch) > 0) {
		$arrLeadBatch = getLeads($sessionID, $arrLeadIdsBatch);
		rollingCurlBatch($arrLeadBatch);
		$arrLeadIdsBatch= array();
	}	
	
}


function getLeads($access_token, $arrLeadIds) {
	
	$csvIds = '';
	foreach($arrLeadIds as $value) {
		$csvIds .= ("'".$value."',");
	}
	$csvIds = rtrim($csvIds, ",");
	
	$query = 'SELECT Id, FirstName, LastName, Company, Description FROM Lead WHERE Id IN('.$csvIds.')';    
	$query = urlencode($query);
    $url = API_URL."query?q=".$query;
	
    $curl = curl_init($url);
    curl_setopt($curl, CURLOPT_HEADER, false);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, array("Authorization: OAuth ".$access_token));

    $json_response = curl_exec($curl);
    curl_close($curl);
	
	//addToLog($json_response);

    $response = json_decode($json_response, true);

	return (array)$response['records'];
}



function rollingCurlBatch($arrLeads) {

	$rc = new RollingCurl("request_callback");
	$rc->window_size = 200;
	
	foreach($arrLeads as $lead) {
		$postString = 'lead='.urlencode( $lead['Id'] . ' *** ' . $lead['FirstName'] . ' *** ' . $lead['LastName'] . ' *** ' . $lead['Company'] . ' *** ' . $lead['Description']);
		//$postString = 'lead='.urlencode( $lead['Id'] . ' *** ' . $lead['FirstName'] . ' *** ' . $lead['LastName'] . ' *** ' . $lead['Company']);
		
		$request = new RollingCurlRequest('http://some.webservice.com/listener.php', 'POST', $postString);
		$rc->add($request);	
	}
	
	$rc->execute();	
}




function getSessionID() {
	
	//set up our data array to auth with
	$data = array(
	   "grant_type"		=> "password",
	   "client_id"		=> CLIENT_ID,
	   "client_secret"	=> CLIENT_SECRET,
	   "username"		=> USERNAME,
	   "password"		=> PASSWORD
	);	
	
	$fields = '';
	foreach($data as $key => $value) { 
		$fields .= $key . '=' . $value . '&'; 
	}
	rtrim($fields, '&');

	$post = curl_init();
	curl_setopt($post, CURLOPT_URL, AUTH_URL.'/token');
	curl_setopt($post, CURLOPT_POST, count($data));
	curl_setopt($post, CURLOPT_POSTFIELDS, $fields);
	curl_setopt($post, CURLOPT_RETURNTRANSFER, 1);
	$result = curl_exec($post);
	curl_close($post);

	$sessionId = '';
	$arrAuth = array();
	try {		
		$arrAuth = json_decode($result, true);
		$sessionId = $arrAuth['access_token'];
	} catch (Exception $e) {
		
	}	
	
	return $sessionId;
}




?>
