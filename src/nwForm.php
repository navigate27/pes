<?php
  include '../db/config.php';
  include '../functions/auth.php';
  
  $batch_id = $_GET['batch_id'];
  $group_id = $_GET['group_id'];
?>

<div class="">
  <form action="functions/save/save.php" method="post" id="nw-form">
    <input type="hidden" name="batch_id" value="<?php echo $batch_id; ?>">
    <input type="hidden" name="group_id" value="<?php echo $group_id; ?>">
    <div class="row mt-3">

      <?php
        $nws = $db->getNormalWTOnBatchID($batch_id,$group_id);
      ?>
      <!-- WITHOUT BREAK -->
      <div class="col-6">
        <h4 class="mb-2">480 BREAK <!-- <span class="text-muted">(480 BREAK)</span></h4> -->
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>WORKING TIME <span class="text-muted small">(mins)</span></th>
              <th>MANPOWER</th>
              <th>TIME MAN MINUTES</th>
              <th>EFFICIENCY <span class="text-muted small">(%)</span></th>
            </tr>
          </thead>
          <tbody>
            <?php
              //required outside condition for 3rd step
              $tmmLine480 = 0;
              $tmmAcc480 = 0;
              $tmmLine450 = 0;
              $tmmAcc450 = 0;
              if($nws){
                $xwt = 0;
                $nwLineID = 0;
                $nwAccID = 0;
                $mpLine1 = 0;
                $mpAcc1 = 0;
                $effLine1 = 0;
                $effAcc1 = 0;
                foreach ($nws as $nw) {
                  if($nw['wbreak'] == 0 && $nw['is_line'] == 1){
                    $nwLineID = $nw['ID'];
                    $xwt = $nw['wt'];
                    $mpLine1 = $nw['mp'];
                    $tmmLine480 = $nw['tm_mins'];
                    $effLine1 = $nw['efficiency'];;
                  }else if($nw['wbreak'] == 0 && $nw['is_line'] == 0){
                    $nwAccID = $nw['ID'];
                    $xwt = $nw['wt'];
                    $mpAcc1 = $nw['mp'];
                    $tmmAcc480 = $nw['tm_mins'];
                    $effAcc1 = $nw['efficiency'];;
                  }
                }
            ?>
              <tr>
                <td rowspan="6" class="align-middle">
                  <input type="hidden" name="request_type" value="edit">
                  <input type="hidden" name="nw_id[]" value="<?php echo $nwLineID; ?>">
                  <input type="hidden" name="wt1[]" value="<?php echo $xwt; ?>">
                  <input type="hidden" name="nw_id[]" value="<?php echo $nwAccID; ?>">
                  <input type="hidden" name="wt1[]" value="<?php echo $xwt; ?>">
                  <select class="form-control" id="wt-control">
                    <option value=""></option>
                    <?php
                      $wts = $db->getAllWorkingTime();
                      if($wts){
                        foreach ($wts as $i => $wt) {
                          echo '<option value='.$wt['wobreak'];
                          if($wt['wobreak']==$xwt){
                            echo ' selected';
                          }
                          echo '>('.$wt['time'].') '.$wt['wobreak'].' mins</option>';
                        }
                      }
                    ?>
                  </select>
                </td>
                <th colspan="3" class="text-center th-2">Line Efficiency</th>
              </tr>
              <tr colspan="3">
                <td><?php echo $mpLine1; ?></td> <!-- w/o JR total -->
                <td><?php echo $tmmLine480; ?></td> <!-- wt x Manpower -->
                <td><?php echo $effLine1; ?></td> <!-- (st x mp) / (wt x Manpower) -->
              </tr>
              <tr>
                <th colspan="3" class="text-center th-2">Accounting Efficiency</th>
              </tr>
              <tr colspan="3">
                <td><?php echo $mpAcc1; ?></td>  <!-- w JR total -->
                <td><?php echo $tmmAcc480; ?></td> <!-- wt x Manpower -->
                <td><?php echo $effAcc1; ?></td> <!-- (st x mp) / (wt x Manpower) -->
              </tr>
            <?php
              }else{
            ?>
              <tr>
                <td rowspan="6" class="align-middle">
                  <input type="hidden" name="batch_id" value="<?php echo $batch_id; ?>">
                  <input type="hidden" name="group_id" value="<?php echo $group['ID']; ?>">
                  <input type="hidden" name="request_type" value="add">
                  <input type="hidden" name="wt1[]">
                  <input type="hidden" name="wbreak[]" value="0">
                  <input type="hidden" name="is_line[]" value="1">
                  <input type="hidden" name="wt1[]">
                  <input type="hidden" name="wbreak[]" value="0">
                  <input type="hidden" name="is_line[]" value="0">
                  <select class="form-control" id="wt-control">
                    <option value=""></option>
                    <?php
                      $wts = $db->getAllWorkingTime();
                      if($wts){
                        foreach ($wts as $i => $wt) {
                          echo '<option value='.$wt['wobreak'].'>('.$wt['time'].') '.$wt['wobreak'].' mins</option>';
                        }
                      }
                    ?>
                  </select>
                </td>
                <th colspan="3" class="text-center th-2">Line Efficiency</th>
              </tr>
              <tr colspan="3">
                <td></td> <!-- w/o JR total -->
                <td></td> <!-- wt x Manpower -->
                <td></td> <!-- (st x mp) / (wt x Manpower) -->
              </tr>
              <tr>
                <th colspan="3" class="text-center th-2">Accounting Efficiency</th>
              </tr>
              <tr colspan="3">
                <td></td> <!-- w JR total -->
                <td></td> <!-- wt x Manpower -->
                <td></td> <!-- (st x mp) / (wt x Manpower) -->
              </tr>
            <?php
              }
            ?>
          </tbody>
        </table>
      </div>
      
      <!-- WITH BREAK -->
      <div class="col-6">
        <h4 class="mb-2">450 BREAK <!-- <span class="text-muted">(450 BREAK)</span></h4> -->
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>WORKING TIME <span class="text-muted small">(mins)</span></th>
              <th>MANPOWER</th>
              <th>TIME MAN MINUTES</th>
              <th>EFFICIENCY <span class="text-muted small">(%)</span></th>
            </tr>
          </thead>
          <tbody>
            <?php
            if($nws){
              $xwt = 0;
              $nwLineID = 0;
              $nwAccID = 0;
              $mpLine2 = 0;
              $mpAcc2 = 0;
              $effLine2 = 0;
              $effAcc2 = 0;
              foreach ($nws as $nw) {
                if($nw['wbreak'] == 1 && $nw['is_line'] == 1){
                  $nwLineID = $nw['ID'];
                  $xwt = $nw['wt'];
                  $mpLine2 = $nw['mp'];
                  $tmmLine450 = $nw['tm_mins'];
                  $effLine2 = $nw['efficiency'];;
                }else if($nw['wbreak'] == 1 && $nw['is_line'] == 0){
                  $nwAccID = $nw['ID'];
                  $xwt = $nw['wt'];
                  $mpAcc2 = $nw['mp'];
                  $tmmAcc450 = $nw['tm_mins'];
                  $effAcc2 = $nw['efficiency'];
                }
              }
            ?>
            <tr>
                <td rowspan="6" class="text-center align-middle">
                  <input type="hidden" name="nw_id[]" value="<?php echo $nwLineID; ?>">
                  <input type="hidden" name="wt2[]" value="<?php echo $xwt; ?>">
                  <input type="hidden" name="nw_id[]" value="<?php echo $nwAccID; ?>">
                  <input type="hidden" name="wt2[]" value="<?php echo $xwt; ?>">
                  <span id="wt-control-text"><?php echo $xwt; ?></span>
                </td>
                <th colspan="3" class="text-center th-2">Line Efficiency</th>
            </tr>
            <tr colspan="3">
              <td><?php echo $mpLine2; ?></td> <!-- w/o JR total -->
              <td><?php echo $tmmLine450; ?></td> <!-- wt x Manpower -->
              <td><?php echo $effLine2; ?></td> <!-- (st x mp) / (wt x Manpower) -->
            </tr>
            <tr>
              <th colspan="3" class="text-center th-2">Accounting Efficiency</th>
            </tr>
            <tr colspan="3">
              <td><?php echo $mpAcc2; ?></td>  <!-- w JR total -->
              <td><?php echo $tmmAcc450; ?></td> <!-- wt x Manpower -->
              <td><?php echo $effAcc2; ?></td> <!-- (st x mp) / (wt x Manpower) -->
            </tr>
            <?php
              }else{
            ?>
              <tr>
                  <td rowspan="6" class="text-center align-middle">
                    <input type="hidden" name="wt2[]">
                    <input type="hidden" name="wbreak[]" value="1">
                    <input type="hidden" name="is_line[]" value="1">
                    <input type="hidden" name="wt2[]">
                    <input type="hidden" name="wbreak[]" value="1">
                    <input type="hidden" name="is_line[]" value="0">
                    <span id="wt-control-text"></span>
                  </td>
                  <th colspan="3" class="text-center th-2">Line Efficiency</th>
                </tr>
              <tr colspan="3">
                <td></td> <!-- w/o JR total -->
                <td></td> <!-- wt x Manpower -->
                <td></td> <!-- (st x mp) / (wt x Manpower) -->
              </tr>
              <tr>
                <th colspan="3" class="text-center th-2">Accounting Efficiency</th>
              </tr>
              <tr colspan="3">
                <td></td>  <!-- w JR total -->
                <td></td> <!-- wt x Manpower -->
                <td></td> <!-- (st x mp) / (wt x Manpower) -->
              </tr>
            <?php
              }
            ?>
          </tbody>
        </table>
        <?php
          if($_SESSION['login_data']['type'] == 2){
        ?>
          <button type="submit" name="nwt" class="btn btn-primary btn-lg pull-right">SAVE & PROCEED NEXT STEP <i class="fa fa-arrow-right"></i></button>
        <?php
          }
        ?>
      </div>
  </div>
  </form>
  <input type="hidden" id="tmmLine480" value="<?php echo $tmmLine480; ?>">
  <input type="hidden" id="tmmAcc480" value="<?php echo $tmmAcc480; ?>">
  <input type="hidden" id="tmmLine450" value="<?php echo $tmmLine450; ?>">
  <input type="hidden" id="tmmAcc450" value="<?php echo $tmmAcc450; ?>">
</div>