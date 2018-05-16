<?php
  include '../db/config.php';
  include '../functions/auth.php';
  
  $batch_id = $_GET['batch_id'];
  $group_id = $_GET['group_id'];
  $trg_param = array(
    "batch_id" => $batch_id,
    "group_id" => $group_id
  );
  $target = $db->getTargetEffOnQuery($trg_param);
  $batch = $db->getBatchIDonID($batch_id);
?>
<div class="col-12 mt-3 mb-5">
  <div class="table-responsive" style="overflow: hidden">
    <form action="functions/save/save.php" method="post" id="mc-form">
      <div class="form-group">
        <div class="row">
          <label class="col-2">Target Efficiency: </label>
        </div>
        <?php
          $trg_line_480 = "";
          $trg_acctg_480 = "";
          $trg_line_450 = "";
          $trg_acctg_450 = "";
          if($target){
            $trg_line_480 = $target['target_line_480'];
            $trg_acctg_480 = $target['target_acctg_480'];
            $trg_line_450 = $target['target_line_450'];
            $trg_acctg_450 = $target['target_acctg_450'];
            echo '<input type="hidden" name="target_id" value="'.$target['ID'].'">';
          }
        ?>
        <div class="row">
          <div class="col-3">
            <div class="input-group">
              <div class="input-group-prepend">
                <div class="input-group-text">Line 480</div>
              </div>
              <input type="number" name="target_eff_line_480" class="form-control" value="<?php echo $trg_line_480; ?>" required>
              <div class="input-group-append">
                <div class="input-group-text">%</div>
              </div>
            </div>
          </div>
          <div class="col-3">
            <div class="input-group">
              <div class="input-group-prepend">
                <div class="input-group-text">Accounting 480</div>
              </div>
              <input type="number" name="target_eff_acct_480" class="form-control" value="<?php echo $trg_acctg_480; ?>" required>
              <div class="input-group-append">
                <div class="input-group-text">%</div>
              </div>
            </div>
          </div>
          <div class="col-3">
            <div class="input-group">
              <div class="input-group-prepend">
                <div class="input-group-text">Line 450</div>
              </div>
              <input type="number" name="target_eff_line_450" class="form-control" value="<?php echo $trg_line_450; ?>" required>
              <div class="input-group-append">
                <div class="input-group-text">%</div>
              </div>
            </div>
          </div>
          <div class="col-3">
            <div class="input-group">
              <div class="input-group-prepend">
                <div class="input-group-text">Accounting 450</div>
              </div>
              <input type="number" name="target_eff_acct_450" class="form-control" value="<?php echo $trg_acctg_450; ?>" required>
              <div class="input-group-append">
                <div class="input-group-text">%</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <input type="hidden" name="batch_id" value="<?php echo $batch_id; ?>">
      <input type="hidden" class="form-control" name="group_id" value="<?php echo $group_id; ?>">
      <table class="table table-bordered table-hover" id="table-mc">
        <thead>
          <tr>
            <th class="text-center w-50">PROCESS</th>
            <th class="text-center w-8">ACTUAL</th>
            <th class="text-center w-8">ABSENT</th>
            <th class="text-center w-8">SUPPORT</th>
            <th class="text-center w-12">Remarks</th>
          </tr>
        </thead>
        <tbody>
          <?php
            $prcs_id = 1;
            $mcs = $db->getManpowerOnBatchID($batch_id,$group_id);
            if($mcs){

                foreach ($mcs as $i => $mc) {
                  echo '
                  <tr>
                    <td>'.$mc['process_detail_name'].' <input type="hidden" name="mpc_id[]" value="'.$mc['ID'].'"> <input type="hidden" name="request_type" value="edit"></td>
                    <td class="text-center"><input type="text" name="actual[]" class="form-control" value="'.$mc['actual'].'"></td>
                    <td class="text-center"><input type="text" name="absent[]" class="form-control" value="'.$mc['absent'].'"></td>
                    <td class="text-center"><input type="text" name="support[]" class="form-control" value="'.$mc['support'].'"</td>
                    <td class="text-center"><textarea rows="1" name="remarks[]" class="form-control">'.$mc['remarks'].'</textarea></td>
                  </tr>
                  ';
                }
              
            }else{
              $prcs = $db->getAllProcessDetailOnProcessID($prcs_id);
              if($prcs){
                foreach ($prcs as $i => $prc) {
                  echo '
                  <tr>
                    <td>'.$prc['process_detail_name'].' <input type="hidden" name="process_detail_id[]" value="'.$prc['ID'].'"> <input type="hidden" name="request_type" value="add"></td>
                    <td class="text-center"><input type="text" name="actual[]" class="form-control"></td>
                    <td class="text-center"><input type="text" name="absent[]" class="form-control"></td>
                    <td class="text-center"><input type="text" name="support[]" class="form-control"></td>
                    <td class="text-center"><textarea rows="1" name="remarks[]" class="form-control"></textarea></td>
                  </tr>
                  ';
                }
              }
            }
          ?>
        </tbody>
        <tfoot>
          <th>TOTAL</th>
          <th class="text-right">
            <?php
              $totalManpower = $db->getManpowerActualTotalOnBatchID($batch_id,$group_id);
              if($totalManpower){
                echo $totalManpower['total'];
              }
            ?>
          </th>
          <th class="text-right">
            <?php
              if($totalManpower){
                echo $totalManpower['absent'];
              }
            ?>
          </th>
          <th class="text-right">
            <?php
              if($totalManpower){
                echo $totalManpower['support'];
              }
            ?>
          </th>
          <th></th>
        </tfoot>
      </table>
      <?php
        if($_SESSION['login_data']['type'] == 2){
      ?>
        <button type="submit" name="mpc" class="btn btn-primary btn-lg pull-right">SAVE & PROCEED NEXT STEP <i class="fa fa-arrow-right"></i></button>
      <?php
        }
      ?>
    </form>
  </div>
</div>