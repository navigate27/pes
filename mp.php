<?php
  include 'db/config.php';
  // include 'functions/auth.php';

?>

<!DOCTYPE html> 
<html lang="en"> 
<head>
    <?php
      include 'src/link.php';
    ?>
    <title>WTF</title>
    <style>
    </style>
</head>

<body>

    <?php
    include 'src/nav.php';
    ?>
    
    <?php
      $p = array(
        "date" => "2018-02-06",
        "group" => "A",
        "shift_id" => "1",
        "process_id" => "1"
      );
      $batch_id = $db->getBatchIDOnQuery($p);
    ?>
<div class="container" id="banner">
  <div class="section">
    <div class="">
      <div class="col-xs-12">

        <nav>
          <div class="nav nav-pills">
            <a class="nav-item nav-link active" data-toggle="tab" href="#nav-mc">Manpower Count</a>
            <a class="nav-item nav-link" data-toggle="tab" href="#nav-nw">Normal Working Time</a>
            <a class="nav-item nav-link" data-toggle="tab" href="#nav-ew">Extended Working Time</a>
            <a class="nav-item nav-link" data-toggle="tab" href="#nav-dt">Downtime Monitoring</a>
          </div>
        </nav>

        <div class="tab-content">
          <div class="tab-pane fade show active" id="nav-mc">

            <div class="page-header mt-3">
                <div class="col-xs-12">
                  <h1>Manpower Count</h1>
                </div>
            </div>

            <div class="row">
              <div class="col-10 mt-3 mb-5">
                <div class="table-responsive">
                  <form action="functions/save/save.php" method="post">
                    <input type="hidden" name="batch_id" value="<?php echo $batch_id; ?>">
                    <table class="table table-bordered table-dark">
                      <thead>
                        <tr>
                          <th class="text-center col-4">PROCESS</th>
                          <th class="text-center col-4">ACTUAL</th>
                          <th class="text-center col-4">ABSENT</th>
                          <th class="text-center col-4">SUPPORT</th>
                        </tr>
                      </thead>
                      <tbody>
                        <?php

                          // $tActual = 0;
                          // $tAbsent = 0;
                          // $tSupport = 0;
                          // $tActual2 = 0;
                          // $tAbsent2 = 0;
                          // $tSupport2 = 0;

                          // $mcs = $db->getManpowerOnBatchID($batch_id);
                          // if($mcs){
                          //   foreach ($mcs as $i => $mc) {
                          //     echo '
                          //     <tr>
                          //       <td>'.$mc['process_detail_name'].'</td>
                          //       <td class="text-center"><span contenteditable>'.$mc['actual'].'</span></td>
                          //       <td class="text-center"><span contenteditable>'.$mc['absent'].'</span></td>
                          //       <td class="text-center"><span contenteditable>'.$mc['support'].'</span></td>
                          //     </tr>
                          //     ';

                          //     if($mc['not_count']!=1){
                          //       $tActual += $mc['actual'];
                          //       $tAbsent += $mc['absent'];
                          //       $tSupport += $mc['support'];
                          //     }
                          //     $tActual2 += $mc['actual'];
                          //     $tAbsent2 += $mc['absent'];
                          //     $tSupport2 += $mc['support'];
                          //   }
                          // }

                          $prcs_id = 1;
                          $prcs = $db->getAllProcessDetailOnProcessID($prcs_id);
                          if($prcs){
                            foreach ($prcs as $i => $prc) {
                              echo '
                              <tr>
                                <td>'.$prc['process_detail_name'].' <input type="hidden" name="process_detail_id[]" value="'.$prc['ID'].'"></td>
                                <td class="text-center"><input type="number" name="actual[]" class="form-control"></td>
                                <td class="text-center"><input type="number" name="absent[]" class="form-control"></td>
                                <td class="text-center"><input type="number" name="support[]" class="form-control"></td>
                              </tr>
                              ';
                            }
                          }
                        ?>
                      </tbody>
                      <tfoot>
                        <th>TOTAL</th>
                        <th class="text-right"><span></span></th>
                        <th class="text-right"><span></span></th>
                        <th class="text-right"><span></span></th>
                      </tfoot>
                    </table>
                    <button type="submit" name="mpc" class="btn btn-primary btn-lg pull-right">SAVE</button>
                  </form>
                </div>
              </div>
            </div>
          </div>

          <div class="tab-pane fade" id="nav-nw"">
            <div class="page-header mt-3">
                <div class="col-xs-12">
                  <h1>Normal Working Time</h1>
                </div>
            </div>
            <div class="row mt-3">
              <!-- WITHOUT BREAK -->
              <div class="col-6">
                <table class="table table-bordered table-dark">
                  <thead>
                    <tr>
                      <th>WORKING TIME <span class="text-muted small">(mins)</span></th>
                      <th>MANPOWER</th>
                      <th>TIME MAN MINUTES</th>
                      <th>EFFICIENCY <span class="text-muted small">(%)</span></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td rowspan="6">
                        <select class="form-control">
                          <option value="">SELECT</option>
                          <?php
                            $wts = $db->getAllWorkingTime();
                            if($wts){
                              foreach ($wts as $i => $wt) {
                                echo '<option value='.$wt['wobreak'].'>'.$wt['time'].' - '.$wt['wobreak'].'</option>';
                              }
                            }
                          ?>
                        </select>
                      </td>
                      <th colspan="3" class="text-center">Line Efficiency</th>
                    </tr>
                    <tr colspan="3">
                      <td></td> <!-- w/o JR total -->
                      <td></td> <!-- wt x Manpower -->
                      <td></td> <!-- (st x mp) / (wt x Manpower) -->
                    </tr>
                    <tr>
                      <th colspan="3" class="text-center">Accouting Efficiency</th>
                    </tr>
                    <tr colspan="3">
                      <td></td> <!-- w JR total -->
                      <td></td> <!-- wt x Manpower -->
                      <td></td> <!-- (st x mp) / (wt x Manpower) -->
                    </tr>
                  </tbody>
                </table>
              </div>
              
              <!-- WITH BREAK -->
              <div class="col-6">
                <table class="table table-bordered table-dark">
                  <thead>
                    <tr>
                      <th>WORKING TIME <span class="text-muted small">(mins)</span></th>
                      <th>MANPOWER</th>
                      <th>TIME MAN MINUTES</th>
                      <th>EFFICIENCY <span class="text-muted small">(%)</span></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td rowspan="6"></td>
                      <th colspan="3" class="text-center">Line Efficiency</th>
                    </tr>
                    <tr colspan="3">
                      <td></td>
                      <td></td>
                      <td></td>
                    </tr>
                    <tr>
                      <th colspan="3" class="text-center">Accouting Efficiency</th>
                    </tr>
                    <tr colspan="3">
                      <td></td>
                      <td></td>
                      <td></td>
                    </tr>
                  </tbody>
                </table>
              </div>

            </div>
          </div>
          <div class="tab-pane fade" id="nav-ew"">
            <div class="page-header mt-3">
                <div class="col-xs-12">
                  <h1>Extended Working Time</h1>
                </div>
            </div>
            
            <div class="col-xs-12 mt-3">
              <table class="table table-bordered table-dark">
                <thead>
                  <tr>
                    <th colspan="4" class="text-center">LINE EFFICIENCY</th>
                    <th colspan="4" class="text-center">ACCOUNTING EFFICIENCY</th>
                  </tr>
                  <tr>
                    <th colspan="3" class="text-center">MANPOWER</th>
                    <th rowspan="2" class="text-center">TIME MAN</th>
                    <th colspan="3" class="text-center">MANPOWER</th>
                    <th rowspan="2" class="text-center">TIME MAN</th>
                  </tr>
                  <tr>
                    <th class="text-center">60</th>
                    <th class="text-center">120</th>
                    <th class="text-center">180</th>
                    <th class="text-center">60</th>
                    <th class="text-center">120</th>
                    <th class="text-center">180</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>TRD Operators</td>
                    <td>15</td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
                  <tr>
                    <td>Point Making</td>
                    <td>1</td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
                  <tr>
                    <td>ZAIHAI</td>
                    <td>5</td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr>
                    <th colspan="3" class="text-center">TOTAL MAN MINUTES <span class="text-muted small">(mins)</span></th>
                    <th class="text-center"></th>
                    <th colspan="3" class="text-center">TOTAL MAN MINUTES <span class="text-muted small">(mins)</span></th>
                    <th class="text-center"></th>
                  </tr>
                  <tr>
                    <th rowspan="2" class="text-center">FINAL</th>
                    <th colspan="3" class="text-center">LINE EFFICIENCY <span class="text-muted small">(%)</span></th>
                    <th colspan="4" class="text-center">ACCOUNTING EFFICIENCY <span class="text-muted small">(%)</span></th>
                  </tr>
                  <tr>
                    <th colspan="3"></th>
                    <th colspan="4"></th>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
          <div class="tab-pane fade" id="nav-dt"">
            <div class="page-header mt-3">
                <div class="col-xs-12">
                  <h1>Downtime Monitoring</h1>
                </div>
            </div>
            
            <div class="col-xs-12 mt-3">
              <table class="table table-bordered table-dark">
                <thead>
                  <tr>
                    <th rowspan="3" class="text-center">REASON</th>
                    <th colspan="3" class="text-center">PART CODE</th>
                    <th rowspan="3" class="text-center">PIC</th>
                    <th rowspan="3" class="text-center">PROCESS</th>
                    <th rowspan="3" class="text-center">DIMENSION <span class="text-muted small">(mm/pc)</span></th>
                    <th rowspan="2" class="text-center" colspan="3">TIME <span class="text-muted small">(mins)</span></th>
                    <th colspan="2" class="text-center">MANPOWER</th>
                  </tr>
                  <tr>
                    <th rowspan="2" class="text-center">WIRE</th>
                    <th colspan="2" class="text-center">Terminal</th>
                    <th colspan="2" class="text-center"></th>
                  </tr>
                  <tr>
                    <th class="text-center">F SIDE</th>
                    <th class="text-center">R SIDE</th>
                    <th class="text-center">START</th>
                    <th class="text-center">END</th>
                    <th class="text-center">TOTAL</th>
                    <th class="text-center">RANK 1 to 2</th>
                    <th class="text-center">RANK 3 & above</th>
                  </tr>
                </thead>
                <tbody>
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
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
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
                    <td>0</td>
                    <td></td>
                    <td></td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
        </div>
        
      </div>
    </div>
  </div>

</div>

<!-- SCRIPT -->
<?php
      include 'src/script.php';
?>
</script>

<script>
  $(document).ready(function(){

  });
</script>
</body>

</html>