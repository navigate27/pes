<?php
	include '../../db/config.php';

	if(isset($_POST['delete-dt'])){
		$dt_id = $_POST['dt_id'];

		if($db->deleteDowntimeID($dt_id)){
			header("location: ../../manpower.php");
		}else{
			header("location: ../../error.php");
		}
	}else if(isset($_POST['delete-pn'])){
		$product_id = $_POST['product_id'];

		if($db->deleteProductID($product_id)){
			header("location: ../../manpower.php");
		}else{
			header("location: ../../error.php");
		}
	}else if(isset($_POST['delete-account'])){
		$account_id = $_POST['account_id'];

		if($db->deleteAccountID($account_id)){
			header("location: ../../account-list.php");
		}else{
			header("location: ../../error.php");
		}
	}else if(isset($_POST['delete-st'])){

		if($db->deleteAllSt()){
			echo true;
		}else{
			echo false;
		}
	}else if(isset($_POST['del-st'])){
		$id = $_POST['del_st_id'];

		if($db->deleteSTID($id)){
			header("location: ../../product-import.php");
		}else{
			header("location: ../../error.php");
		}
	}else if(isset($_POST['delete-pic'])){
		$id = $_POST['delete-pic'];
		if($db->deletePICID($id)){
			echo true;
		}else{
			echo false;
		}
	}else if(isset($_POST['delete-rsn'])){
		$id = $_POST['delete-rsn'];
		if($db->deleteReasonID($id)){
			echo true;
		}else{
			echo false;
		}
	}