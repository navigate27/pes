<?php
  include '../db/config.php';
  $batch_id = $_GET['batch_id'];
?>
<table class="table table-bordered table-hover">
  <thead>
    <tr>
      <th rowspan="3" class="text-center align-middle">REASON</th>
      <th colspan="3" class="text-center">PART CODE</th>
      <th rowspan="3" class="text-center align-middle">PIC</th>
      <th rowspan="3" class="text-center align-middle">PROCESS</th>
      <th rowspan="3" class="text-center align-middle">DIMENSION <span class="text-muted small">(mm/pc)</span></th>
      <th rowspan="2" class="text-center" colspan="3">TIME <span class="text-muted small">(mins)</span></th>
      <th colspan="2" class="text-center">MANPOWER</th>
      <?php
        if($_SESSION['login_data']['type']!=5){
          echo '<th rowspan="3"></th>';
        }
      ?>
    </tr>
    <tr>
      <th rowspan="2" class="text-center align-middle">WIRE</th>
      <th colspan="2" class="text-center th-2">Terminal</th>
      <th colspan="2" class="text-center"></th>
    </tr>
    <tr>
      <th class="text-center align-middle" nowrap>F SIDE</th>
      <th class="text-center align-middle" nowrap>R SIDE</th>
      <th class="text-center">START</th>
      <th class="text-center">END</th>
      <th class="text-center">TOTAL</th>
      <th class="text-center" nowrap>RANK 1 to 2</th>
      <th class="text-center" nowrap>RANK 3 & above</th>
    </tr>
  </thead>
  <tbody>
  <?php
    $dts = $db->getAllDowntimeOnBatchID($batch_id);
    if($dts){
      foreach ($dts as $i => $dt) {
        echo '
        <tr data-id="'.$dt['ID'].'">
          <td>'.$dt['reason'].'</td>
          <td>'.$dt['part_wire'].'</td>
          <td>'.$dt['part_term_front'].'</td>
          <td>'.$dt['part_term_rear'].'</td>
          <td>'.$dt['pic_name'].'</td>
          <td>'.$dt['process_detail_name'].'</td>
          <td>'.$dt['dimension'].'</td>
          <td nowrap>'.$db->dateParse($dt['time_start'],'time12').'</td>
          <td nowrap>'.$db->dateParse($dt['time_end'],'time12').'</td>
          <td>'.$dt['time_total'].'</td>
          <td>'.$dt['mp_r1'].'</td>
          <td>'.$dt['mp_r3'].'</td>';
          if($_SESSION['login_data']['type']!=5){
            echo '
            <td nowrap>
              <a class="btn btn-primary text-white edit-dt">
                <i class="fa fa-pencil"></i>
                Edit
              </a>
              <a class="btn btn-danger text-white delete-dt" data-toggle="modal" data-target="#modalDeleteDT">
                <i class="fa fa-trash"></i>
              </a>
            </td>';
          }
        echo '</tr>';
      }
    }
  ?>
  </tbody>
  <tfoot>
    <tr>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <th>
        <?php
          $sum_time = $db->getTotalDowntimeTimeOnBatchID($batch_id);
          if($sum_time){
            echo $sum_time['total_time'];
          }else{
            echo 0;
          }
        ?>
      </th>
      <td></td>
      <td></td>
      <?php
        if($_SESSION['login_data']['type']!=5){
          echo '<td></td>';
        }
      ?>
    </tr>
  </tfoot>
</table>