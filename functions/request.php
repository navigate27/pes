<?php
	if(isset($_POST['data'])){
		$arr = array();
		parse_str($_POST['data'], $arr);
		print_r($arr);
	}
?>