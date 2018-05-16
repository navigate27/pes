<?php
  include '../db/config.php';
    include '../functions/auth.php';
  $req = array(
    "car_model_id" => $_GET['car_model_id'],
    "date" => $_GET['date'],
    "group_id" => $_GET['group_id'],
    "shift_id" => $_GET['shift_id']
  );
  $reps = $db->getAllProductOnDate($req);
  $total = $db->getTotalOutputMinsOnDate($req);
  if($reps){
?>
<div class="col-12 mt-1 mb-5">
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
      <div class="row">
        <div class="col-12">
          <div class="card text-center">
            <div class="card-body">
              <h4 class="card-title mt-2"><i class="fa fa-exclamation-triangle text-warning"></i> No product(s) found.</h4>
              <p class="card-text"> Please <strong>add/import</strong> some product first.</p>
            </div>
          </div>
        </div>
      </div>  
<?php
  }
?>