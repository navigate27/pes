<?php
  include 'db/config.php';
  // include 'functions/auth.php';
  header('Access-Control-Allow-Origin: *'); 

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
          <h3>Update Car Maker Record</h3>
          <hr>
        </div>
      </div>
    </div>

    <div class="">
      <div class="col-12">
        <?php
          if(isset($_GET['id'])){
            $cm = $db->getCarModelID($_GET['id']);  
            $sht = $db->getShift();  
          }
        ?>

        <?php
          if(isset($_GET['success'])){
            if($_GET['success']=='true'){
        ?>
          <div class="alert alert-dismissible alert-success text-center">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <strong><i class="fa fa-check"></i></strong> Car maker record was <strong>updated</strong> successfully.</a>
          </div>
        <?php
            }
          }
        ?>
        <form action="functions/save/save.php" method="post">
          <input type="hidden" name="car_model_id" value="<?php echo $cm['ID']; ?>">
          <div class="row">

            <div class="col">
              <div class="form-group">
                <label>ID</label>
                <input type="text" class="form-control" value="<?php echo $cm['ID']; ?>" disabled>
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>Car Model</label>
                <input type="text" class="form-control" name="car_model_name" value="<?php echo $cm['car_model_name']; ?>">
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>Car Code</label>
                <input type="text" class="form-control" name="car_code" value="<?php echo $cm['car_code']; ?>">
              </div>
            </div>

          </div>
          <h4>CYCLE</h4>
          <hr>
          <div class="alert alert-warning">
            <strong><i class="fa fa-question-circle"></i> </strong> If cycle is more than one, separate it using a <strong><i>comma</i> (,)</strong><i>. (<strong>Ex.</strong> N2,N3,D1)</i><br>
            Put <i>"NA"</i> if cycle is blank.
          </div>
          <div class="row mb-3">
              <?php
                if($sht){
                  foreach ($sht as $i => $s) {
                    $p = array(
                      "car_model_id" => $_GET['id'],
                      "shift_id" => $s['ID']
                    );
                    $cycle = $db->getCycleCarMakerShift($p);

                    echo '
                    <div class="col-3">
                      <div class="form-group">
                        <label>'.$s['shift'].'</label>
                        <input type="hidden" class="form-control" name="cycle_id[]" value="'.$cycle['ID'].'">
                        <input type="hidden" class="form-control" name="shift_id[]" value="'.$s['ID'].'">
                        <input type="text" class="form-control" name="cycle[]" value="'.$cycle['cycle'].'" required>
                      </div>
                    </div>
                    ';
                  }
                }
              ?>
          </div>

          <div class="col-12 text-right">
            <div class="form-group">
              <button type="submit" name="edit-cm" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
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
    
    $(window).on('beforeunload', function(){
      
    });

  });
</script>
</body>

</html>