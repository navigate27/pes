<?php
  include '../db/config.php';
	$st = $_POST['ST'];
?>

<table class="table table-bordered table-hover">
  <thead class="thead-light">
    <tr>
      <th>#</th>
      <th>Product Number</th>
      <th>Standard Time <span class="small text-muted">(st)</span></th>
    </tr>
  </thead>
  <tbody>
  	<?php
  		if($st){
  			foreach ($st as $i => $s) {

          $haveChange = 'table-warning';
          $newPN = 'table-primary';

          $pnst = $db->getSTOnPN($s[0][0]);
          if($pnst){
            $newPN = '';
            if($pnst['st']==$s[0][1]){
                $haveChange = '';
            }
          }else{
            $haveChange = '';
          }

  				echo '<tr class="'.$haveChange.' '.$newPN.'">';
  				echo '<td>'.($i+1).'</td>';
  				echo '<td>'.$s[0][0].'</td>';
  				echo '<td>'.$s[0][1].'</td>';
  				echo '</tr>';
  			}
  		}
  	?>
  </tbody>
</table>