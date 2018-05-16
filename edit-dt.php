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

    <style>
    </style>
</head>

<body>

<div class="">
    <div class="page-header mt-3">
      <div class="">
        <div class="col-12">
          <h3>Update Downtime Record</h3>
          <hr>
        </div>
      </div>
    </div>

    <div class="">
      <div class="col-12">
        <?php
          if(isset($_GET['id'])){
            $dt = $db->getDowntimeOnID($_GET['id'])[0];
            $prcs = $db->getAllProcessDetailOnProcessID($dt['process_id']);
            $rs = $db->getAllReason();
            $pics = $db->getAllPICList();
        ?>

        <?php    
          }
        ?>

        <?php
          if(isset($_GET['success'])){
            if($_GET['success']=='true'){
        ?>
          <div class="alert alert-dismissible alert-success text-center">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <strong><i class="fa fa-check"></i></strong> Downtime record was <strong>updated</strong> successfully.</a>
          </div>
        <?php
            }
          }
        ?>
        <form action="functions/save/save.php" method="post">
          <input type="hidden" name="dt_id" value="<?php echo $dt['ID']; ?>">
          <div class="row">
            <div class="col-3">
              <div class="form-group">
                <label>PIC</label>
                <select name="pic_id" class="form-control" required>
                  <?php
                    if($pics){
                      foreach ($pics as $i => $pic) {
                        echo '<option';
                        if($pic['id'] == $dt['pic_id']){
                          echo ' selected';
                        }
                        echo ' value="'.$pic['id'].'">'.$pic['pic_name'].'</option>';
                      }
                    }
                  ?>
                </select>
              </div>
            </div>

            <div class="col-3">
              <div class="form-group">
                <label>Reason</label>
                <select name="reason_id" class="form-control" required>
                  <?php
                    if($rs){
                      foreach ($rs as $i => $r) {
                        echo '<option';
                        if($r['ID'] == $dt['reason_id']){
                          echo ' selected';
                        }
                        echo ' value="'.$r['ID'].'">'.$r['reason'].'</option>';
                      }
                    }
                  ?>
                </select>
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>Wire</label>
                <input type="text" class="form-control" name="part_wire" value="<?php echo $dt['part_wire']; ?>" required>
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>F Side</label>
                <input type="text" class="form-control" name="part_term_front" value="<?php echo $dt['part_term_front']; ?>" required>
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>R Side</label>
                <input type="text" class="form-control" name="part_term_rear" value="<?php echo $dt['part_term_rear']; ?>" required>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-3">
              <div class="form-group">
                <label>Process</label>
                <select name="process_detail_id" class="form-control" required>
                  <?php
                    if($prcs){
                      foreach ($prcs as $i => $prc) {
                        echo '<option';
                        if($prc['ID'] == $dt['process_detail_id']){
                          echo ' selected';
                        }
                        echo ' value="'.$prc['ID'].'">'.$prc['process_detail_name'].'</option>';
                      }
                    }
                  ?>
                </select>
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>Dimension</label>
                <input type="text" class="form-control" name="dimension" value="<?php echo $dt['dimension']; ?>" required>
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>Start Time</label>
                <input type="text" class="form-control" name="time_start" value="<?php echo $dt['time_start']; ?>" required>
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>End Time</label>
                <input type="text" class="form-control" name="time_end" value="<?php echo $dt['time_end']; ?>" required>
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>Total Time</label>
                <input type="text" class="form-control" name="time_total" value="<?php echo $dt['time_total']; ?>" required>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-2">
              <div class="form-group">
                <label>Rank 1 to 2</label>
                <input type="text" class="form-control" name="mp_r1" value="<?php echo $dt['mp_r1']; ?>" required>
              </div>
            </div>
            <div class="col-2">
              <div class="form-group">
                <label>RANK 3 & above</label>
                <input type="text" class="form-control" name="mp_r3" value="<?php echo $dt['mp_r3']; ?>" required>
              </div>
            </div>
          </div>

          <div class="col-12 text-right">
            <div class="form-group">
              <button type="submit" name="edit-dt" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
            </div>
          </div>
          
        </form>

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
    // $(".selectpicker").selectpicker({
    //   liveSearch: true
    // });

    $('input[name="time_start"]').datetimepicker({
      format: 'HH:mm',
    });
    $('input[name="time_end"]').datetimepicker({
      format: 'HH:mm',
    });
    $(window).on('beforeunload', function(){
      
    });

  });
</script>
</body>

</html>