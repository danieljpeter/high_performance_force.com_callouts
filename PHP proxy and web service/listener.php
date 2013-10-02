<?php

$sReq = '';

if (array_key_exists('lead', $_POST)) {
	$sReq = $_POST['lead'];
}

if (array_key_exists('lead', $_GET)) {
	$sReq = $_GET['lead'];
}

if (trim($sReq.'') != '') {
	$sReq .= '<br/>';
	$logFile = "./log.txt";
	$fh = fopen($logFile, 'a') or die("can't open file");
	fwrite($fh, $sReq);
	fclose($fh);
}

?>
