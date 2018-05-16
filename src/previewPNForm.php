<?php
	include '../db/config.php';
	$pn = $_POST['PN'];
	$cm = $db->getCarModel();
	$sh = $db->getShift();


?>

<table class="table table-bordered table-hover mt-2" >
  <thead class="thead-light">
    <tr>
      <th>#</th>
      <th>Assy Date</th>
      <th>Product Number</th>
      <th>Output <span class="small text-muted">(qty)</span></th>
      <th>Car Maker</th>
      <th>Shift</th>
      <th>ST</th>
    </tr>
  </thead>
  <tbody>
  	<?php
  		if($pn){
  			$hasError = false;
  			foreach ($pn as $i => $p) {
  				$_date = substr($p[0][0], 0, 4).'-'.substr($p[0][0], -4, 2).'-'.substr($p[0][0], -2);
  				$_pn = trim($p[0][1]);
  				$_output = $p[0][4];
  				foreach ($cm as $j => $c) {
  					if($c['car_code'] == $p[0][7]){
  						$_car_model_id = $c['ID'];
  						$_car_model_name = $c['car_model_name'];
  					}
  				}
  				foreach ($sh as $k => $s) {
  					$s_arr = explode(',', $s['shift_code']);
  					foreach ($s_arr as $l => $sarr) {
  						if($sarr == $p[0][9]){
  							$_shift_id = $s['ID'];
  							$_shift = $s['shift'];
  						}
  					}
  				}
  				$stPn = $db->getSTOnPN(trim($_pn));
  				$_st = $stPn['st'];

  				$noPN = 'table-warning';
  				if($stPn){
  					$noPN = '';
  				}else{
  					$hasError = true;
  				}

  				$noST = 'table-danger';
  				if($_st){
  					$noST = '';
  				}else{
  					$hasError = true;
  				}

  				echo '<tr class="'.$noPN.' '.$noST.'">';
  				echo '<td>'.($i+1).'</td>';
  				echo '<td>'.$_date.'</td>';
  				echo '<td>'.$_pn.'</td>';
  				echo '<td>'.$_output.'</td>';
  				echo '<td>'.$_car_model_name.'</td>';
  				echo '<td>'.$_shift.'</td>';
  				echo '<td>'.$_st.'</td>';
  				echo '</tr>';
  			}
  		}
  	?>
  </tbody>
</table>

<?php
	if(!$hasError){
		echo '<a class="btn text-white btn-primary btn-lg pull-right" id="savePn"><i class="fa fa-check-circle"></i> SUBMIT</a>';
	}else{
		echo '<a class="btn text-white btn-primary btn-lg pull-right disabled"><i class="fa fa-check-circle"></i> SUBMIT DISABLED</a>';
	}
?>