﻿<?php include("password_protect.php"); ?>
<!DOCTYPE html>
<html>
<head>
	<title>Cardinal Quest Alpha 0.2</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	
	<script src="js/swfobject.js" type="text/javascript"></script>
	<script type="text/javascript">
		var flashvars = {
		};
		var params = {
			menu: "false",
			scale: "noScale",
			allowFullscreen: "true",
			allowScriptAccess: "always",
			bgcolor: "#FFFFFF"
		};
		var attributes = {
			id:"cq-0.2"
		};
		swfobject.embedSWF("cq-index.swf", "altContent", 640, 480, "10", "expressInstall.swf", flashvars, params, attributes);
	</script>
	<script type="text/javascript">

	  var _gaq = _gaq || [];
	  _gaq.push(['_setAccount', 'UA-3582984-6']);
	  _gaq.push(['_trackPageview']);

	  (function() {
		var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	  })();

	</script>
	<link href='http://fonts.googleapis.com/css?family=Geo' rel='stylesheet' type='text/css'>
	<style type="text/css">
		body { 
			min-width: 640px;
			background-color:#202020;
			font-family: 'Geo', Helvetica, sans-serif;
			color:#dddddd;
		}
		#wrapper {
			width: 640px;
			margin-left: auto;
			margin-right: auto;
		}
		h1 {
			text-align:center;
			font-family: 'Geo', Helvetica, sans-serif;
		}
		#subtitle {

		}
	</style>
</head>
<body>
	<div id="wrapper">
		<h1>Cardinal Quest 0.2</h1>
		<div id="altContent">
			<p>Flash player not found!</p>
			<p><a href="http://www.adobe.com/go/getflashplayer"><img 
				src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" 
				alt="Get Adobe Flash player" /></a></p>
		</div>
		<div id="subtitle">
			By <a href="http://www.tametick.com">Ido Yehieli</a> and <a href="http://www.servd.com">Corey Martin</a>.<br>
			Graphics by Jagosh Kalezich.
		</div> 
	</div>
</body>
</html>