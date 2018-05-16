<?php
	include '../../db/config.php';
	include '../../functions/auth.php';

	if(isset($_POST['mpc'])){
		parse_str($_POST['mpc'], $mpc);
		$batch_id = $mpc['batch_id'];
		$request_type = $mpc['request_type'];
		$group_id = $mpc['group_id'];
		$target_eff_line_480 = $mpc['target_eff_line_480'];
		$target_eff_acct_480 = $mpc['target_eff_acct_480'];
		$target_eff_line_450 = $mpc['target_eff_line_450'];
		$target_eff_acct_450 = $mpc['target_eff_acct_450'];
		// print_r($_POST);
		if($request_type=="add"){
			$prcs = $mpc['process_detail_id'];
			$actual = $mpc['actual'];
			$absent = $mpc['absent'];
			$support = $mpc['support'];
			$remarks = $mpc['remarks'];

			foreach ($prcs as $i => $prc) {
				$req = array(
					"prc_id" => $prc,
					"actual" => $actual[$i],
					"absent" => $absent[$i],
					"support" => $support[$i],
					"remarks" => $remarks[$i],
					"batch_id" => $batch_id,
					"group_id" => $group_id,
				);

				$db->addManpowerCountID($req);
			}

			$req = array(
				"batch_id" => $batch_id,
				"group_id" => $group_id,
				"line_480" => $target_eff_line_480,
				"acctg_480" => $target_eff_acct_480,
				"line_450" => $target_eff_line_450,
				"acctg_450" => $target_eff_acct_450,
			);

			$db->addTargetEff($req);
				
		}else{
			$mpcs = $mpc['mpc_id'];
			$target_id = $mpc['target_id'];
			$actual = $mpc['actual'];
			$absent = $mpc['absent'];
			$support = $mpc['support'];
			$remarks = $mpc['remarks'];

			foreach ($mpcs as $i => $mpc) {
				$req = array(
					"mpc_id" => $mpc,
					"actual" => $actual[$i],
					"absent" => $absent[$i],
					"support" => $support[$i],
					"remarks" => $remarks[$i]
				);

				// print_r($req);
				$db->editManpowerCountID($req);
			}
			
			$p = array(
				"target_id" => $target_id,
				"line_480" => $target_eff_line_480,
				"acctg_480" => $target_eff_acct_480,
				"line_450" => $target_eff_line_450,
				"acctg_450" => $target_eff_acct_450
			);

			$db->editTargetEff($p);
		}

		
		echo true;
		// header("loction: ../../manpower.php");
	}else if(isset($_POST['nwt'])){

		parse_str($_POST['nwt'], $nwt);

		$batch_id = $nwt['batch_id'];
		$request_type = $nwt['request_type'];
		$group_id = $nwt['group_id'];

		if($request_type=="add"){
			$wt1 = $nwt['wt1'];
			$wt2 = $nwt['wt2'];
			$wbreaks = $nwt['wbreak'];
			$is_lines = $nwt['is_line'];

			foreach ($wt1 as $i => $wt) {
				$req = array(
					"batch_id" => $batch_id,
					"wt" => $wt,
					"wbreak" => $wbreaks[$i],
					"is_line" => $is_lines[$i],
					"group_id" => $group_id
				);

				$db->addNormalWorkID($req);
			}

			foreach ($wt2 as $i => $wt) {
				$req = array(
					"batch_id" => $batch_id,
					"wt" => $wt,
					"wbreak" => $wbreaks[$i+2],
					"is_line" => $is_lines[$i+2],
					"group_id" => $group_id
				);

				$db->addNormalWorkID($req);
			}
		}else{

			$nwids = $nwt['nw_id'];
			$wt1 = $nwt['wt1'];
			$wt2 = $nwt['wt2'];

			foreach ($wt1 as $i => $wt) {
				$req = array(
					"nw_id" => $nwids[$i],
					"wt" => $wt,
					"group_id" => $group_id
				);

				$db->editNormalWorkID($req);
			}

			foreach ($wt2 as $i => $wt) {
				$req = array(
					"nw_id" => $nwids[$i+2],
					"wt" => $wt,
					"group_id" => $group_id
				);

				$db->editNormalWorkID($req);
			}

		}

		echo true;

		// header("location: ../../manpower.php");
	}else if(isset($_POST['ext'])){
		parse_str($_POST['ext'], $ext);

		$extsLine = $ext['ext_id_line'];
		$ot_60 = $ext['ot_60'];
		$ot_120 = $ext['ot_120'];
		$ot_180 = $ext['ot_180'];

		foreach ($extsLine as $i => $exLine) {
			$req = array(
				"ext_id" => $exLine,
				"ot_60" => $ot_60[$i],
				"ot_120" => $ot_120[$i],
				"ot_180" => $ot_180[$i]
			);

			$db->editExtendedOnID($req);
		}

		echo true;

		// header("location: ../../manpower.php");
	}else if(isset($_POST['edit-dt'])){
		$dt_id = $_POST['dt_id'];
		$pic_id = $_POST['pic_id'];
		$reason_id = $_POST['reason_id'];
		$part_wire = $_POST['part_wire'];
		$part_term_front = $_POST['part_term_front'];
		$part_term_rear = $_POST['part_term_rear'];
		$process_detail_id = $_POST['process_detail_id'];
		$dimension = $_POST['dimension'];
		$time_start = $_POST['time_start'];
		$time_end = $_POST['time_end'];
		$time_total = $_POST['time_total'];
		$mp_r1 = $_POST['mp_r1'];
		$mp_r3 = $_POST['mp_r3'];


		$req = array(
			"reason_id" => $reason_id,
			"part_wire" => $part_wire,
			"part_term_front" => $part_term_front,
			"part_term_rear" => $part_term_rear,
			"pic_id" => $pic_id,
			"process_detail_id" => $process_detail_id,
			"dimension" => $dimension,
			"time_start" => $time_start,
			"time_end" => $time_end,
			"time_total" => $time_total,
			"mp_r1" => $mp_r1,
			"mp_r3" => $mp_r3,
			"dt_id" => $dt_id
		);
		if($db->editDowntimeID($req)){
			header("location: ../../edit-dt.php?id=".$dt_id."&success=true");
		}else{
			header("location: ../../edit-dt.php?id=".$dt_id."&success=false");
		}
	}else if(isset($_POST['add-dt'])){
		$batch_id = $_POST['batch_id'];
		$pic_id = $_POST['pic_id'];
		$reason_id = $_POST['reason_id'];
		$part_wire = $_POST['part_wire'];
		$part_term_front = $_POST['part_term_front'];
		$part_term_rear = $_POST['part_term_rear'];
		$process_detail_id = $_POST['process_detail_id'];
		$dimension = $_POST['dimension'];
		$time_start = $_POST['time_start'];
		$time_end = $_POST['time_end'];
		$time_total = $_POST['time_total'];
		$mp_r1 = $_POST['mp_r1'];
		$mp_r3 = $_POST['mp_r3'];

		$req = array(
			"reason_id" => $reason_id,
			"part_wire" => $part_wire,
			"part_term_front" => $part_term_front,
			"part_term_rear" => $part_term_rear,
			"pic_id" => $pic_id,
			"process_detail_id" => $process_detail_id,
			"dimension" => $dimension,
			"time_start" => $time_start,
			"time_end" => $time_end,
			"time_total" => $time_total,
			"mp_r1" => $mp_r1,
			"mp_r3" => $mp_r3,
			"batch_id" => $batch_id
		);
		if($db->addDowntimeID($req)){
			header("location: ../../add-dt.php?id=".$batch_id."&success=true");
		}else{
			header("location: ../../add-dt.php?id=".$batch_id."&success=false");
		}
	}else if(isset($_POST['add-product'])){
		$batch_id = $_POST['batch_id'];
		$product_no = $_POST['product_no'];
		$std_time = $_POST['std_time'];
		$output_qty = $_POST['output_qty'];
		$st = $db->getSTOnPN($product_no);
		$req = array(
			"batch_id" => $batch_id,
			"product_no" => $product_no,
			"std_time" => $st['st'],
			"output_qty" => $output_qty
		);
		if($st){
			if($st['st']!=''){
				if($db->addProductNo($req)){
					header("location: ../../add-product.php?id=".$batch_id."&success=true");
				}else{
					header("location: ../../add-product.php?id=".$batch_id."&success=false");
				}
			}else{
				header("location: ../../add-product.php?id=".$batch_id."&success=false2");
			}
		}else{
			header("location: ../../add-product.php?id=".$batch_id."&success=false3");
		}
	}else if(isset($_POST['edit-product'])){
		$product_id = $_POST['product_id'];
		$product_no = $_POST['product_no'];
		$std_time = $_POST['std_time'];
		$output_qty = $_POST['output_qty'];
		$req = array(
			"product_id" => $product_id,
			"product_no" => $product_no,
			"std_time" => $std_time,
			"output_qty" => $output_qty
		);
		if($db->editProductNo($req)){
			header("location: ../../edit-product.php?id=".$product_id."&success=true");
		}else{
			header("location: ../../edit-product.php?id=".$product_id."&success=false");
		}
	}else if(isset($_POST['batch'])){
		$car_model_id = $_POST['car_model_id'];
		$date = $_POST['date'];
		$shift = $_POST['shift'];
		$account_id = $_POST['account_id'];
		$process_id = $_POST['process_id'];
		$product_no = $_POST['product_no'];
		$std_time = $_POST['std_time'];
		$output_qty = $_POST['output_qty'];


		// print_r($req);
		$st = $db->getSTOnPN($product_no);

		$req = array(
			"car_model_id" => $car_model_id,
			"date" => $date,
			"shift" => $shift,
			"account_id" => $account_id,
			"process_id" => $process_id,
			"product_no" => $product_no,
			"std_time" => $st['st'],
			"output_qty" => $output_qty
		);
		if($st){
			if($st['st']!=''){
				if($db->addBatchIDAndProductNo($req)){
					header("location: ../../add-product.php?id=".$batch_id."&success=true");
				}else{
					header("location: ../../add-product.php?id=".$batch_id."&success=false");
				}
			}else{
				header("location: ../../add-product.php?id=".$batch_id."&success=false2");
			}
		}else{
			header("location: ../../add-product.php?id=".$batch_id."&success=false3");
		}
	}else if(isset($_POST['import-pn'])){
		$import = $_POST['import-pn'];
		$batch_id = $import['batch_id'];
		$csv = $import['csv'];
		$req = array(
			"batch_id" => $batch_id,
			"product_no" => $csv[0][0],
			"std_time" => $csv[0][1],
			"output_qty" => $csv[0][2]
		);
		$db->addProductNo($req);
		echo true;
	}else if(isset($_POST['import-batch'])){
		$import = $_POST['import-batch'];
		$car_model_id = $import['car_model_id'];
		$date = $import['date'];
		$shift = $import['shift_id'];
		$account_id = $import['account_id'];
		$process_id = $import['process_id'];
		$index = $import['index'];
		$csv = $import['csv'];

		session_start();
		if($index=='1'){

			$req = array(
				"car_model_id" => $car_model_id,
				"date" => $date,
				"shift" => $shift,
				"account_id" => $account_id,
				"process_id" => $process_id,
				"product_no" => $csv[0][0],
				"std_time" => $csv[0][1],
				"output_qty" => $csv[0][2]
			);
			$batch_id = $db->addBatchIDAndProductNo($req);
			$_SESSION['batch_id'] = trim($batch_id);

		}else{

			if(isset($_SESSION['batch_id'])){
				$batch_id = $_SESSION['batch_id'];
				$req = array(
					"batch_id" => $batch_id,
					"product_no" => $csv[0][0],
					"std_time" => $csv[0][1],
					"output_qty" => $csv[0][2]
				);
				$db->addProductNo($req);
			}else{
				echo 'NO session [batch_id]';
			}

		}

		echo true;
	}else if(isset($_POST['add-account'])){
		$name = $_POST['name'];
		$username = $_POST['username'];
		$password = $_POST['password'];
		$car_model_id = $_POST['car_model_id'];
		$shift_id = $_POST['shift_id'];
		$acc_type = $_POST['acc_type'];
		$group_id = $_POST['group_id'];
		$req = array(
			"name" => $name,
			"username" => $username,
			"password" => $password,
			"car_model_id" => $car_model_id,
			"shift_id" => $shift_id,
			"acc_type" => $acc_type,
			"group_id" => $group_id,
		);
		if($db->addAccountID($req)){
			header("location: ../../add-account.php?success=true");
		}else{
			header("location: ../../add-account.php?success=false");
		}
	}else if(isset($_POST['edit-account'])){
		$account_id = $_POST['account_id'];
		$name = $_POST['name'];
		$username = $_POST['username'];
		$password = $_POST['password'];
		$car_model_id = $_POST['car_model_id'];
		$shift_id = $_POST['shift_id'];
		$acc_type = $_POST['acc_type'];
		$group_id = $_POST['group_id'];

		$req = array(
			"account_id" => $account_id,
			"name" => $name,
			"username" => $username,
			"password" => $password,
			"car_model_id" => $car_model_id,
			"shift_id" => $shift_id,
			"acc_type" => $acc_type,
			"group_id" => $group_id
		);
		if($db->editAccountID($req)){
			header("location: ../../edit-account.php?id=".$account_id."&success=true");
		}else{
			header("location: ../../edit-account.php?id=".$account_id."&success=false");
		}
	}else if(isset($_POST['edit-rsn'])){
		$reason_id = $_POST['reason_id'];
		$reason = $_POST['reason'];

		$req = array(
			'id' => $reason_id,
			'reason' => $reason,
		);

		if($db->editReasonID($req)){
			header("location: ../../edit-rsn.php?id=".$reason_id."&success=true");
		}else{
			header("location: ../../edit-rsn.php?id=".$reason_id."&success=false");
		}
	}else if(isset($_POST['add-rsn'])){
		$reason = $_POST['reason'];

		$req = array(
			'reason' => $reason
		);

		if($db->addReasonID($req)){
			header("location: ../../add-rsn.php?success=true");
		}else{
			header("location: ../../add-rsn.php?success=false");
		}
	}else if(isset($_POST['edit-pic'])){
		$pic_id = $_POST['pic_id'];
		$pic_name = $_POST['pic_name'];

		$req = array(
			'id' => $pic_id,
			'pic_name' => $pic_name,
		);

		if($db->editPICID($req)){
			header("location: ../../edit-pic.php?id=".$pic_id."&success=true");
		}else{
			header("location: ../../edit-pic.php?id=".$pic_id."&success=false");
		}
	}else if(isset($_POST['add-pic'])){
		$pic_name = $_POST['pic_name'];

		$req = array(
			'pic_name' => $pic_name
		);

		if($db->addPICID($req)){
			header("location: ../../add-pic.php?success=true");
		}else{
			header("location: ../../add-pic.php?success=false");
		}
	}else if(isset($_POST['delete-all-pn'])){
		$batch_id = $_POST['delete-all-pn'];

		if($db->deleteAllProductOnBatchID($batch_id)){
			echo true;
		}else{
			echo false;
		}
	}else if(isset($_POST['pn-mp'])){
		parse_str($_POST['pn-mp'], $pn_mp);
		$product_id = $pn_mp['product_id'];
		$group_id = $pn_mp['group_id'];

		foreach ($product_id as $i => $pn_id) {
			$req = array(
				"product_id" => $pn_id,
				"group_id" => $group_id[$i],
			);
			$db->editProductGroup($req);
		}

		echo true;
	}else if(isset($_POST['st'])){
		$st = $_POST['st'];
		foreach ($st as $i => $s) {
			$req = array(
				"product_no" => trim($s[0][0]),
				"st" => trim($s[0][1]),
				"account_id" => $_SESSION['login_data']['ID'],
			);
			$db->addEditProductST($req);
		}

		echo true;
	}else if(isset($_POST['pn'])){
		$pn = $_POST['pn'];
		$cm = $db->getCarModel();
		$sh = $db->getShift();
		// print_r($pn);
		session_start();
		foreach ($pn as $i => $p) {
			//0 = date
			//1 = PN
			//4 = OUTPUT
			//7 = CAR MAKER
			//9 = SHIFT
			$_date = substr($p[0][0], 0, 4).'-'.substr($p[0][0], -4, 2).'-'.substr($p[0][0], -2);
			$_pn = trim($p[0][1]);
			$_output = $p[0][4];
			foreach ($cm as $j => $c) {
				if($c['car_code'] == $p[0][7]){
					$_car_model_id = $c['ID'];
				}
			}
			foreach ($sh as $k => $s) {
				$s_arr = explode(',', $s['shift_code']);
				foreach ($s_arr as $l => $sarr) {
					if($sarr == $p[0][9]){
						$_shift = $s['ID'];
					}
				}
			}
			$_st = $db->getSTOnPN($_pn)['st'];

			// $req = array(
			// 	"date" => $_date,
			// 	"product_no" => trim($_pn),
			// 	"output_qty" => trim($_output),
			// 	"car_model_id" => trim($_car_model_id),
			// 	"shift_id" => trim($_shift),
			// 	"st" => trim($_st)
			// );

			$query = array(
				"date" => $_date,
				"group_id" => 0,
				"shift_id" => trim($_shift),
				"process_id" => "1",
				"car_model_id" => trim($_car_model_id)
			);

			$batch = $db->getBatchIDOnQuery($query);
			if($batch){
				$batch_id = $batch['ID'];
				$req = array(
					"batch_id" => $batch_id,
					"product_no" => trim($_pn),
					"std_time" => trim($_st),
					"output_qty" => trim($_output)
				);
				$db->addProductNo($req);
			}else{
				$req = array(
					"car_model_id" => $_car_model_id,
					"date" => $_date,
					"shift" => $_shift,
					"account_id" => $_SESSION['login_data']['ID'],
					"process_id" => 1,
					"product_no" => trim($_pn),
					"std_time" => trim($_st),
					"output_qty" => trim($_output)
				);
				$db->addBatchIDAndProductNo($req);
			}

		}

		echo true;
	}else if(isset($_POST['add-st'])){
		$product_no = $_POST['product_no'];
		$std_time = $_POST['std_time'];
		$req = array(
			"product_no" => $product_no,
			"st" => $std_time,
			"account_id" => $_SESSION['login_data']['ID']
		);
		if($db->addEditProductST($req)){
			header("location: ../../add-st.php?success=true");
		}else{
			header("location: ../../add-st.php?success=false");
		}
	}else if(isset($_POST['edit-st'])){
		$st_id = $_POST['st_id'];
		$product_no = $_POST['product_no'];
		$std_time = $_POST['std_time'];
		$req = array(
			"id" => $st_id,
			"product_no" => $product_no,
			"st" => $std_time,
			"account_id" => $_SESSION['login_data']['ID']
		);
		if($db->editProductST($req)){
			header("location: ../../edit-st.php?id=".$st_id."&success=true");
		}else{
			header("location: ../../edit-st.php?id=".$st_id."&success=false");
		}
	}else if(isset($_POST['edit-cm'])){
		$id = $_POST['car_model_id'];
		$car_model_name = $_POST['car_model_name'];
		$car_code = $_POST['car_code'];
		$cycle_ids = $_POST['cycle_id'];
		$cycle = $_POST['cycle'];
		$req = array(
			"car_model_id" => $id,
			"car_model_name" => $car_model_name,
			"car_code" => $car_code,
		);
		print_r($req);
		if($db->editCarModelID($req)){
			foreach ($cycle_ids as $i => $cycle_id) {
				$c = array(
					"cycle_id" => $cycle_id,
					"cycle" => $cycle[$i],
				);

				if($db->editCycleID($c)){
					header("location: ../../edit-cm.php?id=".$id."&success=true");
				}else{
					header("location: ../../edit-cm.php?id=".$id."&success=false");
				}
			}
		}else{
			header("location: ../../edit-cm.php?id=".$id."&success=false");
		}
	}else if(isset($_POST['add-pn2'])){
		$car_model_id = $_POST['car_model_id'];
		$shift_id = $_POST['shift_id'];
		$date = $_POST['date'];
		$process_id = $_POST['process_id'];

		$pn = $_POST['PN'];
		$inc = $_POST['include'];
		$qty = $_POST['qty'];
		$st = $_POST['ST'];

		foreach ($pn as $i => $p) {
			if($inc[$i]==1){
				$req = array(
					'car_model_id' => $car_model_id,
					'shift_id' => $shift_id,
					'date' => $date,
					'process_id' => $process_id,
					'product_no' => $p,
					'st' => $st[$i],
					'qty' => $qty[$i]
				);

				if($db->addEditProductNo($req)){
					echo 'true';
				}else{
					echo 'false';
				}
			}
		}

		header("location: ../../manpower.php");

	}
?>