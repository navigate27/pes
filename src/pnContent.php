<?php
  include '../db/config.php';
  if(isset($_GET['form'])){
    parse_str($_GET['form'], $arr);
    $p = array(
      "date" => date('Y-m-d', strtotime($arr['date'])),
      "car_model_id" => $arr['car_model_id'],
      "shift_id" => $arr['shift_id'],
      "process_id" => "1",
      "group_id" => 0,
    );
    $batch = $db->getBatchIDOnQuery($p);

    $batch_id = $batch['ID'];
    // $reps = $db->getAllProductReportOnBatchID($batch_id);
    $reps = $db->getAllProductOnQuery($p);
    if($batch){
      echo '<input type="hidden" name="batch_id" value="'.$batch_id.'">';
        if($reps){
?>
  <table class="table table-bordered table-hover mt-2">
    <thead class="thead-light">
      <tr>
        <th>#</th>
        <th>Product Number</th>
        <th>Standard Time <span class="text-muted small">(mins)</span></th>
        <th>Output <span class="text-muted small">(Qty)</span></th>
        <th>Output Man Minutes <span class="text-muted small">(ST x Output)</span></th>
        <th>Shift</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <?php
          foreach ($reps as $i => $r) {

            echo '
            <tr data-id="'.$r['ID'].'">
              <th>'.($i+1).'</th>
              <td>'.$r['product_no'].'</td>
              <td>'.$r['std_time'].'</td>
              <td>'.$r['output_qty'].'</td>
              <td>'.$r['output_mins'].'</td>
              <td>'.$r['shift'].'</td>
              <td>
                <a class="btn btn-primary edit-pn text-white">
                  <i class="fa fa-pencil"></i>
                  Edit
                </a>
                <a class="btn btn-danger delete-pn text-white" data-toggle="modal" data-target="#modalDeletePN">
                  <i class="fa fa-trash"></i>
                </a>
              </td>
            </tr>
            ';

          }
      ?>
    </tbody>
    <tfoot>
      <th colspan="2">
        TOTAL
      </th>
      <th class="text-right">
        <?php 
          // $total = $db->getTotalOutputMinsOnBatchID($batch_id,0);
          $total = $db->getTotalOutputMinsOnQuery($p);
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
      <th></th>
      <th></th>
    </tfoot>
  </table>

<?php
        }else{
        ?>
          <div class="row ">
            <div class="col-12">
              <div class="card text-center">
                <div class="card-body">
                  <h4 class="card-title mt-2"><i class="fa fa-exclamation-triangle text-warning"></i> No product(s) found.</h4>
                  <p class="card-text"> It seems that you didn't entry a product yet.</p>
                  <!-- <a class="btn btn-lg btn-primary text-white btn-add-pn-req" data-id="<?php echo $batch_id; ?>"><i class="fa fa-plus"></i> Add Product Now</a> -->
                  <a href="product-import.php" class="btn btn-lg btn-primary text-white"><i class="fa fa-plus"></i> Add Product Now</a>
                </div>
              </div>
            </div>
          </div>
        <?php
        }
    }else{
      echo "false";
    }
  }
?>

 
