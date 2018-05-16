<?php
session_start();
if(!$_SESSION['login_data']||!$_SESSION){
	header("location: ".$db->base_url."/functions/login/logout.php");
}