<?php
  include '../db/config.php';
  include '../functions/auth.php';
  
  $batch_id = $_GET['batch_id'];
  $group_id = $_GET['group_id'];
  $tmmLine480 = $_GET['tmmLine480'];
  $tmmAcc480 = $_GET['tmmAcc480'];
  $tmmLine450 = $_GET['tmmLine450'];
  $tmmAcc450 = $_GET['tmmAcc450'];
  $total_output_mins = $db->getTotalOutputMinsOnBatchID($batch_id,$group_id);
  $mcs = $db->getManpowerOnBatchID($batch_id,$group_id);
  $ext = $db->getExtendedOnBatchID($batch_id,$group_id);
?>
<form action="functions/save/save.php" method="post" id="ex-form">
  <input type="hidden" class="form-control" name="group_id" value="<?php echo $group['ID']; ?>">
  <?php
    if(!$total_output_mins){
      ?>
      <div class="alert alert-warning">
        <strong>
          <i class="fa fa-exclamation-triangle"></i>
          Warning! 
        </strong>
        <a class="alert-link">Batch</a> didn't have product record(s).
      </div>
      <?php
    }

    if(!$mcs){
      ?>
      <div class="alert alert-warning">
        <strong>
          <i class="fa fa-exclamation-triangle"></i>
          Warning! 
        </strong>
        <a href="javascript:void(0)" class="alert-link mp-empty">Manpower Count</a> is empty.
      </div>
      <?php
    }
  ?>
  <table class="table table-bordered" id="table-ew">
    <thead>
      <tr>
        <th class="text-center w-50">Process</th>
        <th class="text-center w-10">60 (1hr)</th>
        <th class="text-center w-10">120 (2hrs)</th>
        <th class="text-center w-10">180 (3hrs)</th>
        <th class="text-center w-16">Total Man</th>
      </tr>
    </thead>
    <tbody>
      <?php
        $extMinsLine = 0;
        $extMinsAcc = 0;
        $_tmmLine480 = 0;
        $_tmmAcc480 = 0;
        $_tmmLine450 = 0;
        $_tmmAcc450 = 0;
        if($ext){
          foreach ($ext as $i => $ex) {
            echo '<tr>';
            echo '<td>'.$ex['process_detail_name'].'</td>';
            echo '<td>';
            echo '<input type="hidden" name="ext_id_line[]" value="'.$ex['ID'].'">';
            echo '<input type="number" class="form-control" name="ot_60[]" value="'.$ex['ot_60'].'"></td>';
            echo '<td><input type="number" class="form-control" name="ot_120[]" value="'.$ex['ot_120'].'"></td>';
            echo '<td><input type="number" class="form-control" name="ot_180[]" value="'.$ex['ot_180'].'"></td>';
            echo '<td class="text-center">'.$ex['time_man'].'</td>';
            echo '</tr>';

            if($ex['not_count']==0){
              $extMinsLine += $ex['time_man'];
            }

            $extMinsAcc += $ex['time_man'];
          }

          $_tmmLine480 = $extMinsLine+$tmmLine480;
          $_tmmAcc480 = $extMinsAcc+$tmmAcc480;
          $_tmmLine450 = $extMinsLine+$tmmLine450;
          $_tmmAcc450 = $extMinsAcc+$tmmAcc450;
        }
      ?>
    </tbody>
    <tfoot>
      <tr class="d-none">
        <th colspan="5" class="text-center th-2">Total Extended Minutes <span class="small text-muted">(mins)</span></th>
      </tr>
      <tr class="d-none">
        <th colspan="4">Line</th>
        <th class="text-center"><?php echo $extMinsLine; ?></th>
      </tr>
      <tr class="d-none">
        <th colspan="4">Accounting</th>
        <th class="text-center"><?php echo $extMinsAcc; ?></th>
      </tr>
      <tr>
        <th colspan="5" class="text-center th-2">Total Time Man Minutes <span class="small text-muted">(mins)</span></th>
      </tr>
      <tr>
        <th colspan="4">Line 480</th>
        <th class="text-center"><?php echo $_tmmLine480; ?></th>
      </tr>
      <tr>
        <th colspan="4">Accounting 480</th>
        <th class="text-center"><?php echo $_tmmAcc480; ?></th>
      </tr>
      <tr>
        <th colspan="4">Line 450</th>
        <th class="text-center"><?php echo $_tmmLine450; ?></th>
      </tr>
      <tr>
        <th colspan="4">Accounting 450</th>
        <th class="text-center"><?php echo $_tmmAcc450; ?></th>
      </tr>
      <tr>
        <th colspan="5" class="text-center th-2">Final Efficiency <span class="small text-muted">(%)</span></th>
      </tr>
      <?php
        // $total_output_mins['total_output_mins'] = 14561;
        if(!$total_output_mins['total_output_mins']){
          $total_output_mins['total_output_mins'] = 0;
        }
      ?>
      <tr>
        <th colspan="4">Line 480</th>
        <th class="text-center">
          <?php
            if($_tmmLine480){
              $effLine = round(($total_output_mins['total_output_mins']/$_tmmLine480)*100,2);
              echo $effLine.'%';
            }
          ?>
        </th>
      </tr>
      <tr>
        <th colspan="4">Accounting 480</th>
        <th class="text-center">
          <?php
            if($_tmmAcc480){
              $effAcc = round(($total_output_mins['total_output_mins']/$_tmmAcc480)*100,2);
              echo $effAcc.'%';
            }
          ?>
        </th>
      </tr>
      <tr>
        <th colspan="4">Line 450</th>
        <th class="text-center">
          <?php
            if($_tmmLine450){
              $effLine = round(($total_output_mins['total_output_mins']/$_tmmLine450)*100,2);
              echo $effLine.'%';
            }
          ?>
        </th>
      </tr>
      <tr>
        <th colspan="4">Accounting 450</th>
        <th class="text-center">
          <?php
            if($_tmmAcc450){
              $effAcc = round(($total_output_mins['total_output_mins']/$_tmmAcc450)*100,2);
              echo $effAcc.'%';
            }
          ?>
        </th>
      </tr>
    </tfoot>
  </table>
  <?php
    if($_SESSION['login_data']['type'] == 2){
  ?>
    <button type="submit" name="ext" class="btn btn-primary btn-lg pull-right">SAVE & FINISH <i class="fa fa-check-circle"></i></button>
  <?php
    }
  ?>
</form>