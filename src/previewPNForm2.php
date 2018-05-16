<?php
  include '../db/config.php';
  // ini_set('memory_limit', '-1');
  $hasError = false;
  $pn = json_decode($_POST['pn']);
  $shift_id = $_POST['shift_id'];
  $_date = $_POST['date'];
  $_car_model_id = $_POST['car_model_id'];
  $_process_id = 1;

  $sh = $db->getShift();
  foreach ($sh as $i => $s) {
    if($shift_id == $s['ID']){
      $_shift = $s['shift'];
    }
  }

  $sht_req = array(
    "car_model_id" => $_car_model_id,
    "shift_id" => $shift_id,
  );
  $sht_cycle = $db->getCycleCarMakerShift($sht_req);
  $sht_arr = explode(',', $sht_cycle['cycle']);

  

  $allPN = array();
  $temp_pn = array();
  if($pn){
    foreach ($pn as $i => $p) {
      if(in_array($p[0][68], $sht_arr)){ //shifts
        array_push($allPN, trim($p[0][6]));
      }
    }
  }

  $pn_arr = array_values(array_unique($allPN));

  $pn_wip = array();
  if($pn_arr){
    foreach ($pn_arr as $i => $parr) {
      $wip = "";
      $date_pn = "";
      $shift_0 = "";
      $foundCount = 0;
      foreach ($pn as $j => $p2) {
        $date_pn = substr($p2[0][4],0,10); //start time
        if($date_pn==$_date){
          if($parr==$p2[0][6]){ //pn
            if(in_array($p2[0][68], $sht_arr)){
              if($foundCount==0){
                $wip = $p2[0][8];
                $foundCount += 1;
              }
            }
          }
        }
      }

      $a = array(
        "pn" => $parr,
        "wip" => $wip,
        "date" => $date_pn
      );
      array_push($pn_wip, $a);

    }
  }

    // print_r($pn_wip);
  ?>
  <?php
    if($sht_cycle['cycle']!='NA'){
  ?>
  <form action="functions/save/save.php" method="post">
    <input type="hidden" name="shift_id" value="<?php echo $shift_id; ?>">
    <input type="hidden" name="car_model_id" value="<?php echo $_car_model_id; ?>">
    <input type="hidden" name="date" value="<?php echo $_date; ?>">
    <input type="hidden" name="process_id" value="<?php echo $_process_id; ?>">

    <div class="modal-header">
      <h5 class="modal-title">Preview Product</h5>
      <button type="button" class="close" data-dismiss="modal" aria-label="Close">
        <span aria-hidden="true">&times;</span>
      </button>
    </div>
    <div class="modal-body">
      <div style="max-height: 470px; overflow-y: auto">
        <div class="col-12">
          <div class="row">
            <div class="col-6">
              <div class="col-5 text-left">
                <h5><span class="badge badge-warning">&nbsp;&nbsp;&nbsp;</span> No ST</h5>
              </div>
              <div class="col-7 text-left">
                <h5><span class="badge badge-danger">&nbsp;&nbsp;&nbsp;</span> No product exist</h5>
              </div>
            </div>
            <div class="col-6">
              <div class="row">
                <div class="col-2 text-left">
                  <label>Cycle: </label>
                </div>
                <div class="col-6 text-left">
                  <?php
                    foreach ($sht_arr as $i => $sht_item) {
                      echo '<div class="form-check">';
                      echo '<input class="form-check-input" type="checkbox" value="" id="shift_check'.($i+1).'" checked>
                        <label class="form-check-label" for="shift_check'.($i+1).'">
                          '.$sht_item.'
                        </label>';
                      echo '</div>';
                    }
                  ?>
                </div>
              </div>
            </div>
          </div>
          
          <table class="table table-bordered table-hover mt-2" >
            <thead class="thead-light">
              <tr>
                <th>#</th>
                <th>Assy Date</th>
                <th>Product Number</th>
                <th>WIP No.</th>
                <th>Output <span class="small text-muted">(qty)</span></th>
                <th>ST</th>
                <th>Shift</th>
              </tr>
            </thead>
            <tbody>
              <?php
                if($pn_wip){

                  foreach ($pn_wip as $i => $p3) {

                    foreach($sht_arr as $j => $sht){
                      $qty = 0;
                      foreach ($pn as $k => $p4) {
                        $date_pn = substr($p4[0][4],0,10); //start time
                        if(in_array($p4[0][68], $sht_arr)){ //shift
                          if($p3['pn']==$p4[0][6]&&$sht==$p4[0][68]&&$p3['wip']==$p4[0][8]&&$date_pn==$_date){ //pn
                            $qty += $p4[0][65]; //qty
                          }
                        }
                      }

                      $pn_item = array(
                        "pn" => $p3['pn'],
                        "wip" => $p3['wip'],
                        "date" => $p3['date'],
                        "output" => $qty,
                        "shift" => $sht
                      );
                      array_push($temp_pn, $pn_item);
                    }

                  }

                  $real_pn = array();
                  foreach ($temp_pn as $i => $p5) {
                    if($p5['output']!=""){
                      array_push($real_pn, $p5);
                    }
                  }

                  $real_pn2 = array();
                  foreach ($pn_wip as $i => $p6) {
                    $qty = 0;
                    foreach ($real_pn as $j => $p7) {
                      if($p6['pn']==$p7['pn']){
                        $qty += $p7['output'];
                      }
                    }

                    $pn_item = array(
                      "pn" => $p6['pn'],
                      "wip" => $p6['wip'],
                      "date" => $p6['date'],
                      "output" => $qty,
                      "shift" => $_shift
                    );
                    array_push($real_pn2, $pn_item);
                  }


                  
                  foreach ($real_pn as $i => $pn) {
                    $stPn = $db->getSTOnPN(trim($pn['pn']));
                    $error_color = '';

                    if($stPn){
                      if(!$stPn['st']){
                        $hasError = true;
                        $error_color = 'table-warning';
                      }
                    }else{
                      $error_color = 'table-danger';
                      $hasError = true;
                    }

                    echo '<tr class="'.$error_color.' product-row" data-shift="'.$pn['shift'].'">';
                    echo '<td>'.($i+1).'</td>';
                    echo '<td>'.$pn['date'].'</td>'; //date
                    echo '<td>'.$pn['pn'].'
                      <input type="hidden" name="include[]" value="1" class="include">
                      <input type="hidden" name="PN[]" value="'.$pn['pn'].'">
                    </td>';
                    echo '<td>'.$pn['wip'].'</td>';
                    echo '<td>'.$pn['output'].'
                      <input type="hidden" name="qty[]" value="'.$pn['output'].'">
                    </td>';
                    echo '<td>'.$stPn['st'].'
                      <input type="hidden" name="ST[]" value="'.$stPn['st'].'">
                    </td>'; //st
                    echo '<td>'.$pn['shift'].'</td>'; //shift
                    echo '</tr>';
                  }
                }
              ?>
            </tbody>
          </table>
        
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <?php
        if($hasError){
          echo '<button type="button" class="btn btn-primary disabled">Import</button>';
        }else{
          echo '<button type="submit" name="add-pn2" class="btn btn-primary btn-import-st">Import</button>';
          echo '<button type="button" class="btn btn-primary disabled d-none btn-loading-import">Importing...</button>';
        }
      ?>
      <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
    </div>
  </form>
  
  <?php
    }else{
  ?>
    <div class="modal-header">
      <h5 class="modal-title">Preview Product</h5>
      <button type="button" class="close" data-dismiss="modal" aria-label="Close">
        <span aria-hidden="true">&times;</span>
      </button>
    </div>
    <div class="modal-body">
      <div class="alert alert-warning text-center">
        <strong><i class="fa fa-exclamation-triangle"></i></strong> Could not import data.</a>
        <br>
        The <strong>shift</strong> you selected does not have a <strong>cycle</strong> in database.
      </div>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn btn-secondary" data-dismiss="modal">OK</button>
    </div>
  <?php
    }
  ?>