<?php

if(isset($_POST['request'])){

	include '../db/config.php';
	include 'auth.php';
		$request = $_POST['request'];
		$result = array();
	
		init($request,$db);
}else{
	echo "Oops! How did you do that?";
}


function init($request,$db){
	switch ($request) {
		case 'sample':
			getSample();
		break;

		//!GENERAL SCHEDULE
		case 'genSchedID':
			$id = $_POST['id'];
			getGenSchedID($db,$id);
		break;
		case 'genSched':
			$car_maker = $_POST['car_maker'];
			getGenSched($db,$car_maker);
		break;
		case 'addSchedID':
			$f = $_POST['form'];
			$hn = $_POST['hn'];
			$dr_cp = $_POST['dr_cp'];
			$car_maker = $_POST['car_maker'];
			addSchedID($db,$f,$hn,$dr_cp,$car_maker);
		break;
		case 'editSchedID':
			$f = $_POST['form'];
			editSchedID($db,$f);
		break;
		case 'deleteSchedID':
			$id = $_POST['id'];
			deleteSchedID($db,$id);
		break;
		//END

		//PROCESS DETAIL
		case 'processDetail':
			$process_id = $_POST['process_id'];
			getAllProcessDetailOnProcessID($db,$process_id);
			break;
		
		default:
			requestInvalid();
		break;
	}

}


function getGenSched($db,$car_maker){
	$result = array();
	$error = true;
	$res = $db->getGenSchedAll($car_maker);
	if($res){
		foreach ($res as $r) {
			$result[] = array(
				'id' => $r['ID'],
			);
		}
		$error = false;
	}

	$result = array(
		"error" => $error,
		"result" => $result
	);
	showResult($result);
}

function deleteRolesSchedID($db,$id){
	$res = $db->deleteRolesSchedID($id);
	showResult($res);
}


function getAllProcessDetailOnProcessID($db,$process_id){
	$result = array();
	$error = true;


	$res = $db->getAllProcessDetailOnProcessID($process_id);
	if($res){
		foreach ($res as $r) {
			$result[] = array(
				'id' => $r['ID'],
				'process_detail_name' => $r['process_detail_name'],
				'process_id' => $r['process_id'],
				'not_count' => $r['not_count'],
				'process_name' => $r['process_name'],
			);
		}
		$error = false;
	}

	$result = array(
		"error" => $error,
		"result" => $result
	);
	showResult($result);
}


function requestInvalid(){
	return "Sorry. The request is invalid";
}

function showResult($result){
	if($result){

		header("content-type: application/json");
		echo json_encode($result);
		// print_r($result);

	}else{
		echo json_encode(
			array(
					'error_msg' => "Fatal: Undefined."
				)
		);
	}
	// print_r($result);
}

