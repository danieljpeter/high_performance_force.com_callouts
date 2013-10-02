<?php
$refreshTime = 1000; //ms


if (isset($_POST['isSubmitted'])) {
	if (trim($_POST['isSubmitted']."") == "true") {
		file_put_contents("./log.txt", "");
	}
}

?>


<html>

	<head>

	<style type="text/css">
		
		span#data {			
			width: 600px:			
		}
		
	</style>
	
	
	
		<script src="http://code.jquery.com/jquery-latest.js"></script>	


		<script>
		
			setInterval(function(){
			 $("#data").load("viewer_data.php");
			}, <?=$refreshTime?>);
			
			$(document).ready(function() {
				$("#data").load("viewer_data.php");
			});	
		</script>	
		
	</head>

	<body>

	<form action="viewer.php" method="post">
		<input type="hidden" name="isSubmitted" value="true">
		<input type="submit" value="Clear"/>		
	</form>

		<span id="data">
		</span> 	
	</body>

</html>




