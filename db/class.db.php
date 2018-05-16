<?php

class DB
{


 private $db;
 public $base_url;
 
function __construct($conn)
{
	$this->db = $conn;
	$this->base_url = 'http://'.$_SERVER['HTTP_HOST'];
}

public function getModal($page){

	switch ($page) {
		case 'home':
			include_once $this->base_url.'/src/modals/home/add-sched-modal.php';
			include_once $this->base_url.'/src/modals/home/edit-sched-modal.php';
			include_once $this->base_url.'/src/modals/home/delete-sched-modal.php';
			include_once $this->base_url.'/src/modals/home/choose-harness-modal.php';
		break;
		case 'employee':
			include_once $this->base_url.'/src/modals/employee/add-employee-modal.php';
			include_once $this->base_url.'/src/modals/employee/edit-employee-modal.php';
			include_once $this->base_url.'/src/modals/employee/delete-employee-modal.php';
			include_once $this->base_url.'/src/modals/employee/edit-emp-role-modal.php';
		break;
		case 'group':
			include_once $this->base_url.'/src/modals/group/add-group-modal.php';
			include_once $this->base_url.'/src/modals/group/edit-group-modal.php';
			include_once $this->base_url.'/src/modals/group/delete-group-modal.php';
			break;
		case 'standard':
			include_once $this->base_url.'/src/modals/standard/add-standard-modal.php';
			include_once $this->base_url.'/src/modals/standard/edit-standard-modal.php';
			include_once $this->base_url.'/src/modals/standard/delete-standard-modal.php';
			break;
		case 'profile':
			// include_once $this->base_url.'/src/modals/global/profile-modal.php';
			break;
		default:
			# code...
			break;
	}
}

public function dateParse($date,$format){
	if($date!=''){
		if($date!='0000-00-00 00:00:00'){
			switch ($format) {
				case 'local':
					return date("n\/j\/Y", strtotime($date));
					break;
				case 'ISO_8601':
					return date('c',strtotime($date));
					break;
				case 'common':
					return date('Y-m-d H:i:s',strtotime($date));
					break;
				case 'date':
					return date('Y-m-d',strtotime($date));
					break;
				case 'date2':
					return date('Y\/m\/d',strtotime($date));
					break;
				case 'word':
					return date('F j, Y',strtotime($date));
					break;
				case 'word-trim':
					return date('M j',strtotime($date));
					break;
				case 'time12':
					return date('h:i a',strtotime($date));
					break;
				case 'time24':
					return date('H:i',strtotime($date));
					break;
				default:
					return 'No selected format.';
					break;
			}
		}else{
			return '';
			// return '<i class="text-muted small">N/A</i>';
		}
	}else{
		return '';
	}
}

public function jpConvert($string){
	$string = mb_convert_encoding($string, 'UTF-8', array('EUC-JP', 'SHIFT-JIS', 'AUTO'));
	// $string = utf8_encode($string);
	// $string = htmlspecialchars($string, ENT_QUOTES, 'UTF-8');
	// $string = mb_substr($string, 0, 10, 'utf-8');
	return $string;
}

public function getDates($date_start, $date_end){
 	$dates = array();
	$day_interval = ((new DateTime($date_start))->diff((new DateTime($date_end))))->days;
	for ($i=0; $i < $day_interval+1; $i++) {
	  array_push($dates, date('Y-m-d', strtotime($date_start. '+'.$i.' day')));
	}

	return $dates;
}

public function loginUser($username,$password){
 	try {

	 	$q = "CALL sp_get_account_login(:p_username, :p_password) ";

	 	$stmt = $this->db->prepare($q);
	 	$stmt->bindparam(":p_username", $username, PDO::PARAM_STR);
	 	$stmt->bindparam(":p_password", $password, PDO::PARAM_STR);
	 	$stmt->execute();
	 	$result = $stmt->fetch();
	 	return $result;

 	} catch (Exception $e) {
 		echo ($e->getMessage());
 		// print_r($e);
 	}
}

#TABLES ARE ORDERED BASED ON DB

#EFF_1_MANPOWER_COUNT
	public function getManpowerOnBatchID($id,$group_id){
		 	try {
		 		
		 		$q = "CALL sp_get_all_manpower_count_on_batch_id(:id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$group_id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getManpowerActualTotalOnBatchID($id,$group_id){
		 	try {
		 		
		 		$q = "CALL sp_get_manpower_actual_total_on_batch_id(:id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$group_id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getManpowerCountOnQuery($p){
		 	try {
		 		
		 		$q = "CALL sp_get_all_manpower_count_on_query(:date, :group, :shift_id, :process_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':date',$p['date'],PDO::PARAM_STR);
		 		$stmt->bindparam(':group',$p['group'],PDO::PARAM_STR);
		 		$stmt->bindparam(':shift_id',$p['shift_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':process_id',$p['process_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function addManpowerCountID($p){
	 	try {

	 		$q = "CALL sp_add_manpower_count_id(:p_prcs_detail_id, :p_actual, :p_absent, :p_support, :p_batch_id, :p_group_id, :p_remarks)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_prcs_detail_id',$p['prc_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_actual',$p['actual'],PDO::PARAM_INT);
			$stmt->bindparam(':p_absent',$p['absent'],PDO::PARAM_INT);
			$stmt->bindparam(':p_support',$p['support'],PDO::PARAM_INT);
			$stmt->bindparam(':p_batch_id',$p['batch_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_remarks',$p['remarks'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function editManpowerCountID($p){
	 	try {

	 		$q = "CALL sp_edit_manpower_count_id(:p_mpc_id, :p_actual, :p_absent, :p_support, :p_remarks)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_mpc_id',$p['mpc_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_actual',$p['actual'],PDO::PARAM_INT);
			$stmt->bindparam(':p_absent',$p['absent'],PDO::PARAM_INT);
			$stmt->bindparam(':p_support',$p['support'],PDO::PARAM_INT);
			$stmt->bindparam(':p_remarks',$p['remarks'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}

#EFF_2_NORMAL_WT
	public function getNormalWTOnBatchID($id, $group_id){
		 	try {
		 		
		 		$q = "CALL sp_get_all_normal_wt_on_batch_id(:id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$group_id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function addNormalWorkID($p){
	 	try {

	 		$q = "CALL sp_add_normal_work_id(:p_batch_id, :p_wt, :p_wbreak, :p_is_line, :p_group_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_batch_id',$p['batch_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_wt',$p['wt'],PDO::PARAM_INT);
			$stmt->bindparam(':p_wbreak',$p['wbreak'],PDO::PARAM_INT);
			$stmt->bindparam(':p_is_line',$p['is_line'],PDO::PARAM_INT);
			$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}

	public function editNormalWorkID($p){
	 	try {

	 		$q = "CALL sp_edit_normal_work_id(:p_nw_id, :p_wt)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_nw_id',$p['nw_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_wt',$p['wt'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_3_EXTENDED_WT
	public function getExtendedOnBatchID($id, $group_id){
		 	try {
		 		
		 		$q = "CALL sp_get_ext_id_on_batch_id(:id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$group_id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getExtendedOnMPCID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_extended_on_mpc_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getExtTotalManMinsOnBatchID($id,$group_id){
		 	try {
		 		
		 		$q = "CALL sp_get_ext_total_man_mins_on_batch_id(:id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$group_id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function editExtendedOnID($p){
	 	try {

	 		$q = "CALL sp_edit_extended_on_id(:p_ext_id, :p_ot_60, :p_ot_120, :p_ot_180)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_ext_id',$p['ext_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_ot_60',$p['ot_60'],PDO::PARAM_INT);
			$stmt->bindparam(':p_ot_120',$p['ot_120'],PDO::PARAM_INT);
			$stmt->bindparam(':p_ot_180',$p['ot_180'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}

#EFF_ACCOUNT
	public function getAllAccountOnAccountType($id,$car_model_id){
	 	try {
	 		
	 		$q = "CALL sp_get_account_on_account_type(:id,:car_model_id)";
	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
	 		$stmt->bindparam(':car_model_id',$car_model_id,PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getAccountOnID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_account_on_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		return $result;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function addAccountID($p){
	 	try {

	 		$q = "CALL sp_add_account_id(:p_name, :p_username, :p_password, :p_car_model_id, :p_shift_id, :p_acc_type, :p_group_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_name',$p['name'],PDO::PARAM_STR);
			$stmt->bindparam(':p_username',$p['username'],PDO::PARAM_STR);
			$stmt->bindparam(':p_password',$p['password'],PDO::PARAM_STR);
			if($p['car_model_id']==''){
				$stmt->bindValue(':p_car_model_id',null,PDO::PARAM_INT);
			}else{
				$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			}
			if($p['shift_id']==''){
				$stmt->bindValue(':p_shift_id',null,PDO::PARAM_INT);
			}else{
				$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
			}
			$stmt->bindparam(':p_acc_type',$p['acc_type'],PDO::PARAM_INT);
			if($p['group_id']==''){
				$stmt->bindValue(':p_group_id',null,PDO::PARAM_INT);
			}else{
				$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
			}
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function editAccountID($p){
	 	try {

	 		$q = "CALL sp_edit_account_id(:p_account_id, :p_name, :p_username, :p_password, :p_car_model_id, :p_shift_id, :p_acc_type, :p_group_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_account_id',$p['account_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_name',$p['name'],PDO::PARAM_STR);
			$stmt->bindparam(':p_username',$p['username'],PDO::PARAM_STR);
			$stmt->bindparam(':p_password',$p['password'],PDO::PARAM_STR);
			if($p['car_model_id']==''){
				$stmt->bindValue(':p_car_model_id',null,PDO::PARAM_INT);
			}else{
				$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			}
			if($p['shift_id']==''){
				$stmt->bindValue(':p_shift_id',null,PDO::PARAM_INT);
			}else{
				$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
			}
			$stmt->bindparam(':p_acc_type',$p['acc_type'],PDO::PARAM_INT);
			if($p['group_id']==''){
				$stmt->bindValue(':p_group_id',null,PDO::PARAM_INT);
			}else{
				$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
			}
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function deleteAccountID($id){
	 	try {

	 		$q = "CALL sp_delete_account_id(:id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':id',$id,PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_ACCOUNT_TYPE
	public function getAllAccountType(){
	 	try {
	 		
	 		$q = "CALL sp_get_all_account_type()";
	 		$stmt = $this->db->prepare($q);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_BATCH_CONTROL
	public function getBatchIDOnQuery($p){
		 	try {
		 		
		 		$q = "CALL sp_get_batch_id_on_query(:p_date, :p_car_model_id, :p_shift_id, :p_process_id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_date',$p['date'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getBatchIDonID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_batch_id_on_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		return $result;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function addBatchIDAndProductNo($p){
		 	try {
		 		
		 		$q = "CALL sp_add_batch_id_and_product_no(:p_date, :p_shift_id, :p_car_model_id, :p_account_id, :p_process_id, :p_product_no, :p_std_time, :p_output_qty)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_date',$p['date'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_shift_id',$p['shift'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_account_id',$p['account_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_product_no',$p['product_no'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_std_time',$p['std_time'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_output_qty',$p['output_qty'],PDO::PARAM_STR);
		 		$stmt->execute();
		 		$result = $stmt->fetchColumn();
		 		return $result;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function editBatchTargetEff($p){
		 	try {
		 		
		 		$q = "CALL sp_edit_batch_target_eff(:p_batch_id, :p_target_eff_line_480,:p_target_eff_acct_480,:p_target_eff_line_450,:p_target_eff_acct_450)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_batch_id',$p['batch_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_target_eff_line_480',$p['target_eff_line_480'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_target_eff_acct_480',$p['target_eff_acct_480'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_target_eff_line_450',$p['target_eff_line_450'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_target_eff_acct_450',$p['target_eff_acct_450'],PDO::PARAM_STR);
		 		$stmt->execute();
		 		return true;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
#EFF_BATCH_GROUP
	public function getTargetEffOnQuery($p){
		 	try {
		 		
		 		$q = "CALL sp_get_target_eff_id_on_query(:p_batch_id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_batch_id',$p['batch_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function addTargetEff($p){
		 	try {
		 		
		 		$q = "CALL sp_add_target_eff_id(:p_batch_id, :p_group_id, :p_line_480, :p_acctg_480, :p_line_450, :p_acctg_450)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_batch_id',$p['batch_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_line_480',$p['line_480'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_acctg_480',$p['acctg_480'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_line_450',$p['line_450'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_acctg_450',$p['acctg_450'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		return true;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function editTargetEff($p){
		 	try {
		 		
		 		$q = "CALL sp_edit_target_eff_id(:p_target_id, :p_line_480, :p_acctg_480, :p_line_450, :p_acctg_450)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_target_id',$p['target_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_line_480',$p['line_480'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_acctg_480',$p['acctg_480'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_line_450',$p['line_450'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_acctg_450',$p['acctg_450'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		return true;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
#EFF_CAR_MODEL
	public function getCarModel(){
		 	try {
		 		
		 		$q = "CALL sp_get_all_car_model()";
		 		$stmt = $this->db->prepare($q);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}

	public function getCarModelID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_car_model_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function editCarModelID($p){
	 	try {

	 		$q = "CALL sp_edit_car_model_id(:p_car_model_id, :p_car_model_name, :p_car_code)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_car_model_name',$p['car_model_name'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_code',$p['car_code'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;
	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_CAR_MODEL_CYCLE
	public function getCycleCarMakerShift($p){
		 	try {
		 		
		 		$q = "CALL sp_get_cycle_car_maker_id_shift_id(:car_model_id, :shift_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':car_model_id',$p['car_model_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':shift_id',$p['shift_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function editCycleID($p){
	 	try {

	 		$q = "CALL sp_edit_cycle_id(:p_cycle_id, :p_cycle)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_cycle_id',$p['cycle_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_cycle',$p['cycle'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_DOWNTIME
	public function getAllDowntimeOnBatchID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_all_downtime_on_batch_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getTotalDowntimeTimeOnBatchID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_total_downtime_time_on_batch_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		return $result;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getDowntimeOnID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_downtime_on_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function editDowntimeID($p){
	 	try {

	 		$q = "CALL sp_edit_downtime_id(:p_reason_id, :p_part_wire, :p_part_term_front, :p_part_term_rear, :p_pic_id, :p_process_detail_id, :p_dimension, :p_time_start, :p_time_end, :p_time_total, :p_mp_r1, :p_mp_r3, :p_dt_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_reason_id',$p['reason_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_part_wire',$p['part_wire'],PDO::PARAM_STR);
			$stmt->bindparam(':p_part_term_front',$p['part_term_front'],PDO::PARAM_STR);
			$stmt->bindparam(':p_part_term_rear',$p['part_term_rear'],PDO::PARAM_STR);
			$stmt->bindparam(':p_pic_id',$p['pic_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_process_detail_id',$p['process_detail_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_dimension',$p['dimension'],PDO::PARAM_STR);
			$stmt->bindparam(':p_time_start',$p['time_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_time_end',$p['time_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_time_total',$p['time_total'],PDO::PARAM_STR);
			$stmt->bindparam(':p_mp_r1',$p['mp_r1'],PDO::PARAM_INT);
			$stmt->bindparam(':p_mp_r3',$p['mp_r3'],PDO::PARAM_INT);
			$stmt->bindparam(':p_dt_id',$p['dt_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function addDowntimeID($p){
	 	try {

	 		$q = "CALL sp_add_downtime_id(:p_reason_id, :p_part_wire, :p_part_term_front, :p_part_term_rear, :p_pic_id, :p_process_detail_id, :p_dimension, :p_time_start, :p_time_end, :p_time_total, :p_mp_r1, :p_mp_r3, :p_batch_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_reason_id',$p['reason_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_part_wire',$p['part_wire'],PDO::PARAM_STR);
			$stmt->bindparam(':p_part_term_front',$p['part_term_front'],PDO::PARAM_STR);
			$stmt->bindparam(':p_part_term_rear',$p['part_term_rear'],PDO::PARAM_STR);
			$stmt->bindparam(':p_pic_id',$p['pic_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_process_detail_id',$p['process_detail_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_dimension',$p['dimension'],PDO::PARAM_STR);
			$stmt->bindparam(':p_time_start',$p['time_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_time_end',$p['time_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_time_total',$p['time_total'],PDO::PARAM_STR);
			$stmt->bindparam(':p_mp_r1',$p['mp_r1'],PDO::PARAM_INT);
			$stmt->bindparam(':p_mp_r3',$p['mp_r3'],PDO::PARAM_INT);
			$stmt->bindparam(':p_batch_id',$p['batch_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function deleteDowntimeID($id){
	 	try {

	 		$q = "CALL sp_delete_downtime_id(:id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':id',$id,PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_GROUP
	public function getAllGroup(){
	 	try {
	 		
	 		$q = "CALL sp_get_all_group()";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getGroupID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_group_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
#EFF_PIC
	public function getAllPICList(){
		 	try {
		 		
		 		$q = "CALL sp_get_pic_list()";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getPICID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_pic_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function addPICID($p){
	 	try {

	 		$q = "CALL sp_add_pic_id(:p_pic_name)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_pic_name',$p['pic_name'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;
	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function editPICID($p){
	 	try {

	 		$q = "CALL sp_edit_pic_id(:p_pic_id, :p_pic_name)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_pic_id',$p['id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_pic_name',$p['pic_name'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;
	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function deletePICID($id){
	 	try {

	 		$q = "CALL sp_delete_pic_id(:id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':id',$id,PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;
	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_PROCESS

#EFF_PROCESS_DETAIL
	public function getAllProcessDetailOnProcessID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_all_process_detail_on_process_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
#EFF_PRODUCT_REP
	public function getAllProductReportOnBatchID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_all_product_report_on_batch_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getAllProductOnDate($p){
		 	try {
		 		
		 		$q = "CALL sp_get_all_product_on_date(:p_car_model_id, :p_date, :p_group_id, :p_shift_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_date',$p['date'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getAllProductOnDateViewer($p){
		 	try {
		 		
		 		$q = "CALL sp_get_all_product_on_date_viewer(:p_car_model_id, :p_date, :p_group_id, :p_shift_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_date',$p['date'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getAllProductOnQuery($p){
		 	try {
		 		
		 		$q = "CALL sp_get_all_product_on_query(:p_date, :p_car_model_id, :p_shift_id, :p_process_id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_date',$p['date'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getProductNoOnID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_product_rep_on_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		return $result;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getTotalOutputMinsOnQuery($p){
		 	try {
		 		
		 		$q = "CALL sp_get_product_rep_total_output_mins_on_batch_query(:p_date, :p_car_model_id, :p_shift_id, :p_process_id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_date',$p['date'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		return $result;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getTotalOutputMinsOnBatchID($id,$group_id){
		 	try {
		 		
		 		$q = "CALL sp_get_product_rep_total_output_mins_on_batch_id(:id, :p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->bindparam(':p_group_id',$group_id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		return $result;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getTotalOutputMinsOnDate($p){
		 	try {
		 		
		 		$q = "CALL sp_get_product_rep_total_output_mins_on_date(:p_car_model_id, :p_date, :p_group_id, :p_shift_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_date',$p['date'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		return $result;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getTotalOutputMinsOnDateViewer($p){
		 	try {
		 		
		 		$q = "CALL sp_get_product_rep_total_output_mins_on_date_viewer(:p_car_model_id, :p_date, :p_group_id, :p_shift_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_date',$p['date'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		return $result;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function editProductNo($p){
		 	try {
		 		
		 		$q = "CALL sp_edit_product_rep_id(:id,:p_product_no,:p_std_time,:p_output_qty)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$p['product_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_product_no',$p['product_no'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_std_time',$p['std_time'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_output_qty',$p['output_qty'],PDO::PARAM_STR);
		 		$stmt->execute();
		 		return true;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function addProductNo($p){
		 	try {
		 		
		 		$q = "CALL sp_add_product_rep_id(:p_batch_id,:p_product_no,:p_std_time,:p_output_qty)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':p_batch_id',$p['batch_id'],PDO::PARAM_INT);
		 		$stmt->bindparam(':p_product_no',$p['product_no'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_std_time',$p['std_time'],PDO::PARAM_STR);
		 		$stmt->bindparam(':p_output_qty',$p['output_qty'],PDO::PARAM_STR);
		 		$stmt->execute();	
		 		return true;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function deleteProductID($id){
		 	try {
		 		
		 		$q = "CALL sp_delete_product_rep_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		return true;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function deleteAllProductOnBatchID($id){
		 	try {
		 		
		 		$q = "CALL sp_delete_all_product_on_batch_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		return true;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function editProductGroup($p){
		 	try {
		 		
		 		$q = "CALL sp_edit_product_group_on_id(:id,:p_group_id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$p['product_id'],PDO::PARAM_INT);
		 		if($p['group_id']!=''){
		 			$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
		 		}else{
		 			$stmt->bindValue(':p_group_id',null,PDO::PARAM_INT);
		 		}
		 		$stmt->execute();
		 		return true;

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function addEditProductNo($p){
	 	try {
	 		
	 		$q = "CALL sp_add_edit_product_no(:p_car_model_id, :p_date, :p_shift_id, :p_process_id, :p_product_no, :p_st, :p_qty)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date',$p['date'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_shift_id',$p['shift_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_product_no',$p['product_no'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_st',$p['st'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_qty',$p['qty'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_PRODUCT_ST
	public function getProductST(){
		 	try {
		 		
		 		$q = "CALL sp_get_all_product_st()";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getSTOnQuery($p){
	 	try {
	 		
	 		$q = "CALL sp_get_st_on_query(:p_product_no, :p_last_update_from, :p_last_update_to, :p_pic, :p_limit)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam('p_product_no',$p['pn'],PDO::PARAM_STR);
	 		$stmt->bindparam('p_last_update_from',$p['lupdate_from'],PDO::PARAM_STR);
	 		$stmt->bindparam('p_last_update_to',$p['lupdate_to'],PDO::PARAM_STR);
	 		$stmt->bindparam('p_pic',$p['pic'],PDO::PARAM_INT);
	 		$stmt->bindparam('p_limit',$p['limit'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getSTOnID($id){
	 	try {
	 		
	 		$q = "CALL sp_get_st_id(:id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetch();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getSTOnPN($pn){
	 	try {
	 		
	 		$q = "CALL sp_get_st_on_product_no(:p_product_no)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_product_no',$pn,PDO::PARAM_STR);
	 		$stmt->execute();
	 		$result = $stmt->fetch();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function addProductST($p){
	 	try {
	 		
	 		$q = "CALL sp_add_product_st_id(:p_product_no, :p_st, :p_account_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_product_no',$p['product_no'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_st',$p['st'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_account_id',$p['account_id'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function editProductST($p){
	 	try {
	 		
	 		$q = "CALL sp_edit_st_id(:p_st_id, :p_product_no, :p_st, :p_account_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_st_id',$p['id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_product_no',$p['product_no'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_st',$p['st'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_account_id',$p['account_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function editProductSTOnPN($p){
	 	try {
	 		
	 		$q = "CALL sp_edit_st_pn(:p_product_no, :p_st)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_product_no',$p['product_no'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_st',$p['st'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function deleteAllSt(){
	 	try {
	 		
	 		$q = "CALL sp_delete_all_st()";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function deleteSTID($id){
	 	try {
	 		
	 		$q = "CALL sp_delete_st_id(:id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function addEditProductST($p){
	 	try {
	 		
	 		$q = "CALL sp_add_edit_product_st(:p_product_no, :p_st, :p_account_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_product_no',$p['product_no'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_st',$p['st'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_account_id',$p['account_id'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_REASON
	public function getAllReason(){
		 	try {
		 		
		 		$q = "CALL sp_get_all_reason()";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function getReasonID($id){
		 	try {
		 		
		 		$q = "CALL sp_get_reason_id(:id)";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->bindparam(':id',$id,PDO::PARAM_INT);
		 		$stmt->execute();
		 		$result = $stmt->fetch();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}
	public function addReasonID($p){
	 	try {

	 		$q = "CALL sp_add_reason_id(:p_reason)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_reason',$p['reason'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;
	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function editReasonID($p){
	 	try {

	 		$q = "CALL sp_edit_reason_id(:p_reason_id, :p_reason)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_reason_id',$p['id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_reason',$p['reason'],PDO::PARAM_STR);
	 		$stmt->execute();
	 		return true;
	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function deleteReasonID($id){
	 	try {

	 		$q = "CALL sp_delete_reason_id(:id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':id',$id,PDO::PARAM_INT);
	 		$stmt->execute();
	 		return true;
	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_SHIFT
	public function getShift(){
	 	try {
	 		
	 		$q = "CALL sp_get_all_shift()";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
#EFF_WORKING_TIME
	public function getAllWorkingTime(){
		 	try {
		 		
		 		$q = "CALL sp_get_all_working_time()";

		 		$stmt = $this->db->prepare($q);
		 		$stmt->execute();
		 		$result = $stmt->fetchAll();
		 		if($result){
		 			return $result;
		 		}

		 	} catch (Exception $e) {
		 		echo ($e->getMessage());
		 	}
	}

#SUMMARY
	public function getReportPN_A($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_summary_001_A(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReportPN_B($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_summary_001_B(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReportPN_AB($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_summary_001_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReport_MP_LineA($p){
		try {
			
			$q = "CALL sp_get_report_summary_002_line_A(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_MP_LineB($p){
		try {
			
			$q = "CALL sp_get_report_summary_002_line_B(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_MP_LineAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_002_line_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_MP_AcctgA($p){
		try {
			
			$q = "CALL sp_get_report_summary_002_acctg_A(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_MP_AcctgB($p){
		try {
			
			$q = "CALL sp_get_report_summary_002_acctg_B(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_MP_AcctgAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_002_acctg_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wbreak_AcctgA($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wbreak_acctg_A(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wbreak_AcctgB($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wbreak_acctg_B(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wbreak_AcctgAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wbreak_acctg_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wobreak_AcctgA($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wobreak_acctg_A(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wobreak_AcctgB($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wobreak_acctg_B(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wobreak_AcctgAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wobreak_acctg_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wbreak_LineA($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wbreak_line_A(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wbreak_LineB($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wbreak_line_B(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wbreak_LineAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wbreak_line_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wobreak_LineA($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wobreak_line_A(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wobreak_LineB($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wobreak_line_B(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_WT_Wobreak_LineAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_003_wobreak_line_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_TargetEff_Wobreak_LineAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_004_wobreak_line_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_TargetEff_Wobreak_AcctgAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_004_wobreak_acctg_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_TargetEff_Wbreak_LineAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_004_wbreak_line_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}
	public function getReport_TargetEff_Wbreak_AcctgAB($p){
		try {
			
			$q = "CALL sp_get_report_summary_004_wbreak_acctg_AB(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id)";

			$stmt = $this->db->prepare($q);
			$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
			$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
			$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
			$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll();
			if($result){
				return $result;
			}

		} catch (Exception $e) {
			echo ($e->getMessage());
		}
	}

#SUMMARY2
	public function getReportPN($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_001_group(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id, :p_group_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReportMPLine($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_002_group_line(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id, :p_group_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReportMPAcctg($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_002_group_acctg(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id, :p_group_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReportWT480Line($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_003_group_wobreak_line(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id, :p_group_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReportWT480Acctg($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_003_group_wobreak_acctg(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id, :p_group_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReportWT450Line($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_003_group_wbreak_line(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id, :p_group_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReportWT450Acctg($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_003_group_wbreak_acctg(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id, :p_group_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}
	public function getReportTarget($p){
	 	try {
	 		
	 		$q = "CALL sp_get_report_004_group(:p_process_id,:p_date_start,:p_date_end,:p_car_model_id, :p_group_id)";

	 		$stmt = $this->db->prepare($q);
	 		$stmt->bindparam(':p_process_id',$p['process_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_date_start',$p['date_start'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_date_end',$p['date_end'],PDO::PARAM_STR);
	 		$stmt->bindparam(':p_car_model_id',$p['car_model_id'],PDO::PARAM_INT);
	 		$stmt->bindparam(':p_group_id',$p['group_id'],PDO::PARAM_INT);
	 		$stmt->execute();
	 		$result = $stmt->fetchAll();
	 		if($result){
	 			return $result;
	 		}

	 	} catch (Exception $e) {
	 		echo ($e->getMessage());
	 	}
	}

public function addStd($p){
 	try {

 		$q = "CALL sp_add_std_schedule(:std_name, :days, :ot, :endorse, :shift)";

		$stmt = $this->db->prepare($q);
		$stmt->bindparam(':std_name',$p['std_name'],PDO::PARAM_STR);
		$stmt->bindparam(':days',$p['days'],PDO::PARAM_INT);
		$stmt->bindparam(':ot',$p['ot'],PDO::PARAM_INT);
		$stmt->bindparam(':endorse',$p['endorse'],PDO::PARAM_INT);
		$stmt->bindparam(':shift',$p['shift'],PDO::PARAM_STR);
 		$stmt->execute();
 		$result = $stmt->fetchColumn();
 		return $result;

 	} catch (Exception $e) {
 		echo ($e->getMessage());
 	}
}

public function rememberUser($user_id, $remember){
 	if($remember!=""){
 		$token = uniqid();
	 	if (session_status() == PHP_SESSION_NONE) {
	 	    session_start();
	 	}

	 	$_SESSION['user_data']['remember_token'] = $token;

	 	$q = "UPDATE ID, remember_token SET remember_token = :remember_token WHERE ID = :user_id";
	 	$stmt = $this->db->prepare($q);
	 	$stmt->bindparam(':remember_token','$remember_token',PDO::PARAM_STR);
	 	$stmt->bindparam(':user_id','$user_id',PDO::PARAM_INT);

	 	$stmt->execute();
 	}else{
 		return false;
 	}
}
 

}
