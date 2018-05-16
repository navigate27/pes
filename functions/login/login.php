<?php

include '../../db/config.php';

if(isset($_POST['login'])){
	$username = $_POST['username'];
	$password = $_POST['password'];
	$remember = "";
	$loginData = $db->loginUser($username, $password);
	if($loginData){
		session_start();
		$_SESSION['login_data'] = $loginData;
		if($loginData['type'] == 1){
		header("location: ../../product-import.php");
		}else if($loginData['type'] == 2){
			header("location: ../../manpower.php");
		}else if($loginData['type'] == 3){
			header("location: ../../summary.php");
		}else if($loginData['type'] == 4){
			header("location: ../../summary.php");
		}else if($loginData['type'] == 5){
			header("location: ../../manpower.php");
		}
	}else{
		header("location: ../../login.php?alert=1");
	}

}