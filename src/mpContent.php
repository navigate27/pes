<?php
  include '../db/config.php';
  include '../functions/auth.php';
  if(isset($_GET['form'])){
    parse_str($_GET['form'], $arr);
    $p = array(
      "date" => date('Y-m-d', strtotime($arr['date'])),
      // "group_id" => $_SESSION['login_data']['group_id'],
      "group_id" => $arr['group_id'],
      "shift_id" => $arr['shift_id'],
      "process_id" => "1",
      "car_model_id" => $arr['car_model_id']
    );

    $group = $db->getGroupID($_SESSION['login_data']['group_id']);
    $batch = $db->getBatchIDOnQuery($p);
    $grp = $db->getAllGroup();
    $batch_id = $batch['ID'];
    if($batch){
?>

<input type="hidden" id="batch_id" value="<?php echo $batch_id; ?>">
<input type="hidden" id="_car_model_id" value="<?php echo $arr['car_model_id']; ?>">
<input type="hidden" id="_date" value="<?php echo $batch['date']; ?>">
<input type="hidden" id="_group_id" value="<?php echo $_SESSION['login_data']['group_id']; ?>">
<input type="hidden" id="_shift_id" value="<?php echo $arr['shift_id']; ?>">
<div class="col-xs-12">
  <div class="card">
    <div class="card-header">
        <ul class="nav nav-pills nav-menu card-header-pills">
          <li class="nav-item">
            <a class="nav-link active" data-toggle="tab" href="#nav-pn">Product List Number</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" data-toggle="tab" href="#nav-mc">1) Manpower Count</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" data-toggle="tab" href="#nav-nw">2) Normal Working Time</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" data-toggle="tab" href="#nav-ew">3) Extended Working Time</a>
          </li>
          <li class="nav-item ml-auto">
            <a class="nav-link bg-danger text-white" data-toggle="tab" href="#nav-dt">Downtime Monitoring</a>
          </li>
        </ul>
    </div>

    <div class="card-body">
      <div class="tab-content">

        <div class="tab-pane fade show active" id="nav-pn">

          <div class="page-header">
              <div class="col-xs-12">
                <h1>Product List</h1>
              </div>
          </div>

          <div class="row" id="pnMpForm">
            <?php
              if($_SESSION['login_data']['type']!=5){
                $req = array(
                  "car_model_id" => $arr['car_model_id'],
                  "date" => $batch['date'],
                  "group_id" => $_SESSION['login_data']['group_id'],
                  // "group_id" => $arr['group_id'],
                  "shift_id" => $arr['shift_id']
                );
                $reps = $db->getAllProductOnDate($req);
                $total = $db->getTotalOutputMinsOnDate($req);
              }else{
                $req = array(
                  "car_model_id" => $arr['car_model_id'],
                  "date" => $batch['date'],
                  // "group_id" => $_SESSION['login_data']['group_id'],
                  "group_id" => $arr['group_id'],
                  "shift_id" => $arr['shift_id']
                );
                $reps = $db->getAllProductOnDateViewer($req);
                $total = $db->getTotalOutputMinsOnDateViewer($req);
              }
              if($reps){
            ?>

            <div class="col-12 mt-1 mb-5">

              <div class="alert alert-dismissible alert-primary">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <strong><i class="fa fa-exclamation-circle"></i></strong> If something goes wrong, press <strong>F5</strong> to refresh the page. <a href="javascript:void(0)" class="alert-link"><strong class="d-none">Click here to learn more.</strong></a>
              </div>

              <div class="table-responsive">
                <form action="functions/save/save.php" id="pnMp-form">
                  <table class="table table-bordered table-hover mt-2">
                    <thead class="thead-light">
                      <tr>
                        <th>#</th>
                        <th>Product Number</th>
                        <th>Standard Time <span class="text-muted small">(mins)</span></th>
                        <th>Output <span class="text-muted small">(Qty)</span></th>
                        <th>Output Man Minutes <span class="text-muted small">(ST x Output)</span></th>
                        <th>Shift</th>
                        <th>Group</th>
                        <?php
                          if($_SESSION['login_data']['type']!=5){
                            echo '<th></th>';
                          }
                        ?>
                      </tr>
                    </thead>
                    <tbody>
                      <?php
                      if($reps){
                          foreach ($reps as $i => $r) {
                            echo '
                            <tr data-id="'.$r['ID'].'">
                              <th>'.($i+1).'
                                <input type="hidden" name="product_id[]" value="'.$r['ID'].'">
                              </th>
                              <td>'.$r['product_no'].'</td>
                              <td>'.$r['std_time'].'</td>
                              <td>'.$r['output_qty'].'</td>
                              <td>'.$r['output_mins'].'</td>
                              <td>'.$r['shift'].'</td>
                              <td>';

                              if($r['group_id']==NULL){
                                echo '<select class="form-control" name="group_id[]">';
                                echo '<option value="'.$_SESSION['login_data']['group_id'].'">'.$_SESSION['login_data']['group_name'].'</option>';
                                echo '</select>';
                              }else{
                                echo '<input type="hidden" name="group_id[]" class="grp_ctrl" value="'.$r['group_id'].'">';
                                echo $r['group_name'];
                              }
                              
                            echo '</td>';
                            if($_SESSION['login_data']['type']!=5){
                              echo '<td>';
                              if($r['group_id']!=NULL){
                                echo '
                                  <a class="btn btn-primary edit-pn text-white">
                                    <i class="fa fa-pencil"></i>
                                    Edit
                                  </a>
                                  <a class="btn btn-danger delete-pn text-white" data-toggle="modal" data-target="#modalDeletePN">
                                    <i class="fa fa-trash"></i>
                                  </a>
                                ';
                              }

                              echo '</td>';
                            }
                            echo '</tr>';

                          }
                      }
                      ?>
                    </tbody>
                    <tfoot>
                      <th colspan="2">
                        TOTAL
                      </th>
                      <th class="text-right">
                        <?php 
                          if($total){
                            echo $total['total_st'];
                          }
                        ?>
                      </th>
                      <th class="text-right">
                        <?php 
                          if($total){
                            echo $total['total_output'];
                          }
                        ?>
                      </th>
                      <th class="text-right">
                        <?php 
                          if($total){
                            echo $total['total_output_mins'];
                          }
                        ?>
                      </th>
                      <th colspan="3"></th>
                    </tfoot>
                  </table>
                  <?php
                    if($_SESSION['login_data']['type'] == 2){
                  ?>
                    <button type="submit" name="pn-mp" class="btn btn-primary btn-lg pull-right">SAVE & PROCEED NEXT STEP <i class="fa fa-arrow-right"></i></button>
                  <?php
                    }
                  ?>
                </form>
              </div>
            </div>
            <?php
              }else{
            ?>
                <div class="col-12">
                  <div class="card text-center">
                    <div class="card-body">
                      <h4 class="card-title mt-2"><i class="fa fa-exclamation-triangle text-warning"></i> No product(s) found.</h4>
                      <p class="card-text"> Please <strong>add/import</strong> some products first.</p>
                    </div>
                  </div>
                </div> 
            <?php
              }
            ?>
          </div>
        </div>

        <div class="tab-pane fade" id="nav-mc">

          <div class="page-header">
              <div class="col-xs-12">
                <h1>Manpower Count
                <?php
                  if($group){
                    echo '(GROUP '.$group['group_name'].')';
                  }
                ?>
                </h1>
              </div>
          </div>

          <div class="row" id="mcForm">
            <div class="col-12 mt-3 mb-5">

              <div class="alert alert-dismissible alert-primary">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <strong><i class="fa fa-exclamation-circle"></i></strong> If something goes wrong, press <strong>F5</strong> to refresh the page. <a href="javascript:void(0)" class="alert-link"><strong class="d-none">Click here to learn more.</strong></a>
              </div>

              <div class="table-responsive" style="overflow: hidden">
                <form action="functions/save/save.php" method="post" id="mc-form">
                  <div class="form-group">
                    <div class="row">
                      <label class="col-2">Target Efficiency: </label>
                    </div>

                    <?php
                      if($_SESSION['login_data']['type']!=5){
                        $trg_param = array(
                          "batch_id" => $batch_id,
                          "group_id" => $_SESSION['login_data']['group_id']
                        );
                      }else{
                        $trg_param = array(
                          "batch_id" => $batch_id,
                          "group_id" => $arr['group_id'],
                        );
                      }

                      $target = $db->getTargetEffOnQuery($trg_param);
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
                  <input type="hidden" name="group_id" value="<?php echo $_SESSION['login_data']['group_id']; ?>">
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
                        if($_SESSION['login_data']['type']!=5){
                          $mcs = $db->getManpowerOnBatchID($batch_id,$group['ID']);
                        }else{
                          $mcs = $db->getManpowerOnBatchID($batch_id,$arr['group_id']);
                        }
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
                          if($_SESSION['login_data']['type']!=5){
                            $totalManpower = $db->getManpowerActualTotalOnBatchID($batch_id,$group['ID']);
                          }else{
                            $totalManpower = $db->getManpowerActualTotalOnBatchID($batch_id,$arr['group_id']);
                          }
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
          </div>
        </div>

        <div class="tab-pane fade" id="nav-nw"">
          <div class="page-header">
              <div class="col-xs-12">
                <h1>Normal Working Time
                  <?php
                    if($group){
                      echo '(GROUP '.$group['group_name'].')';
                    }
                  ?>
                </h1>
              </div>
          </div>

          <div class="" id="nwForm">
            <div class="">
              <form action="functions/save/save.php" method="post" id="nw-form">
                <input type="hidden" name="batch_id" value="<?php echo $batch_id; ?>">
                <input type="hidden" name="group_id" value="<?php echo $group['ID']; ?>">
                <div class="row mt-3">

                  <?php
                    if($_SESSION['login_data']['type']!=5){
                      $nws = $db->getNormalWTOnBatchID($batch_id,$group['ID']);
                    }else{
                      $nws = $db->getNormalWTOnBatchID($batch_id,$arr['group_id']);
                    }
                  ?>
                  <!-- WITHOUT BREAK -->
                  <div class="col-6">
                    <h4 class="mb-2">480 <!-- <span class="text-muted">(480 BREAK)</span></h4> -->
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
                    <h4 class="mb-2">450 <!-- <span class="text-muted">(450 BREAK)</span></h4> -->
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
          </div>
        </div>

        <div class="tab-pane fade" id="nav-ew"">
          <div class="page-header">
              <div class="col-xs-12">
                <h1>Extended Working Time
                  <?php
                    if($group){
                      echo '(GROUP '.$group['group_name'].')';
                    }
                  ?>
                </h1>
              </div>
          </div>
          
          <div class="col-xs-12 mt-3" id="exForm">
            <?php 
              if($_SESSION['login_data']['type']!=5){
                $total_output_mins = $db->getTotalOutputMinsOnBatchID($batch_id,$group['ID']);
                $totalManMins = $db->getExtTotalManMinsOnBatchID($batch_id,$group['ID']);
                $ext = $db->getExtendedOnBatchID($batch_id,$group['ID']);
              }else{
                $total_output_mins = $db->getTotalOutputMinsOnBatchID($batch_id,$arr['group_id']);
                $totalManMins = $db->getExtTotalManMinsOnBatchID($batch_id,$arr['group_id']);
                $ext = $db->getExtendedOnBatchID($batch_id,$arr['group_id']);
              }
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
          </div>
        </div>

        <div class="tab-pane fade" id="nav-dt">
          <div class="page-header">
              <div class="col-xs-12">
                <h1>Downtime Monitoring</h1>
                <div class="pull-right">
                  <?php
                    if($_SESSION['login_data']['type'] == 2){
                  ?>
                    <a href="javascript:void(0)" class="btn btn-primary mb-2 add-dt" data-id="<?php echo $batch_id; ?>">
                      <i class="fa fa-plus"></i> Add
                    </a>
                  <?php
                    }
                  ?>
                  <a href="export.php?batch_id=<?php echo $batch_id; ?>" class="btn btn-success mb-2" target="_blank">
                    <i class="fa fa-file-excel-o"></i> Export
                  </a>
                </div>
              </div>
          </div>
          
          <div class="col-xs-12 mt-3" id="dtTable">
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
          </div>
        </div>

      </div>
    </div>
  </div>
</div>
<?php
    }else{
      echo "false";
    }
  }
?>