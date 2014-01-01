<!DOCTYPE html>
<html>
<head lang="en">
	<meta charset="UTF-8">
	<title>CptServer</title>
</head>
<body>
	
<h1>CptServer</h1>
<p>
	The installation was successful!
</p>
<h3>Useful Links</h3>
<ul>
	<li><a href="phpinfo.php">PHP Info</a> - View information about the software on this server.</li>
	<li><a href="phpmyadmin">phpMyAdmin</a> - Create and manage databases.</li>
</ul>

<h3>Your Websites</h3>
<ul>
	<?php
		$vsites = file_get_contents('vhosts.txt');
		$vsites = explode(",{", $vsites);
		for($i = 0; $i < count($vsites); $i++){
			$vsites[$i] = explode(",", $vsites[$i]);
			foreach ($vsites[$i] as $key => &$value) {
				$value = ltrim($value, '{, ,"');
				$value = str_replace('"=>"', '=>', $value);
				$value = rtrim($value, '}, ,"');
				list($key2, $value2) = explode("=>", $value);
				if($key2 == 'ServerAlias'){
					$value2 = explode(' ', $value2);
				}
				$newsitearr[$i][$key2] = $value2;
			}
			echo "<li><a href='http://".$newsitearr[$i]['ServerName']."'>".$newsitearr[$i]['ServerName']."</a></li>";
			echo "<ul>";
			foreach ($newsitearr[$i]['ServerAlias'] as $kv => $vv) {
				echo "<li><a href='http://".$newsitearr[$i]['ServerAlias'][$kv]."'>".$newsitearr[$i]['ServerAlias'][$kv]."</a></li>";
			}
			echo "</ul>";
		}
	?>
</ul>
<em>After adding vhosts to config.yaml and your computer's hosts file, don't forget to run the command "vagrant up"</em>

</body>
</html>