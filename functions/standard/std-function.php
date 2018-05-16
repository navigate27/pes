<?php
	include '../auth.php';

	include '../../db/config.php';
	if(isset($_POST['add'])){

	  $req = array(
	    "role_id" => $_POST['role_id'],
	    "std_id" => $_POST['std_id'],
	    "hour_id" => $_POST['hour_id'],
	    "day" => $_POST['day'],
	    "action" => $_POST['action'],
	    "shift" => strtolower($_POST['shift'])
	  );

	  $add = $db->addStdRolesSchedID($req);
	  header("location: ../../standard2.php?id=".$_POST['std_id']);
	}
	
	if(isset($_POST['editDays'])){
	  $std_id = $_POST['ad_stdid'];
	  $days = $_POST['ad_days'];

	  $res = $db->editStdDay($std_id,$days);
	  header("location: ../../standard2.php?id=".$_POST['ad_stdid']);
	}

	if(isset($_POST['addRoles'])){
	  if($_POST['ar_stdid']!=""){
	    $std_id = $_POST['ar_stdid'];
	    $role_id = $_POST['ar_role_id'];

	    $req = array(
	      "std_id" => $std_id,
	      "role_id" => $role_id
	    );

	    $res = $db->addStdRoles($req);
	    header("location: ../../standard2.php?id=".$_POST['ar_stdid']);
	  }
	}

	if(isset($_POST['removeRoles'])){

	  $std_id = $_POST['rr_std_id'];
	  $role_id = $_POST['rr_role_id'];

	  $req = array(
	    "std_id" => $std_id,
	    "role_id" => $role_id
	  );

	  $res = $db->deleteStdRolesID($req);
	  header("location: ../../standard2.php?id=".$_POST['rr_std_id']);
	}
?>