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
          <h3>Add Product Number</h3>
          <hr>
        </div>
      </div>
    </div>

    <div class="">
      <div class="col-12">
        <?php
          if(isset($_GET['id'])){
            $batch = $db->getBatchIDonID($_GET['id']);
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
            <strong><i class="fa fa-check"></i></strong> Product was <strong>added</strong> successfully.</a>
          </div>

          <div class="col-4 offset-4 text-center">
            <a href="#" class="btn btn-primary btn-block btn-outline btn-lg btn-ok">OK</a>
          </div>
        <?php
            }else if($_GET['success']=='false3'){
        ?>
            <div class="alert alert-dismissible alert-danger text-center">
              <button type="button" class="close" data-dismiss="alert">&times;</button>
              <strong><i class="fa fa-times"></i></strong> Product doesn't exist.</a>
            </div>

            <div class="col-4 offset-4 text-center">
              <a href="#" class="btn btn-primary btn-block btn-outline btn-lg" onclick="history.back()">Return</a>
            </div>
        <?php
            }else if($_GET['success']=='false2'){
        ?>
          <div class="alert alert-danger text-center">
            <strong><i class="fa fa-times"></i></strong> Standard Time (st) of the Product is blank.</a>
          </div>

          <div class="col-4 offset-4 text-center">
            <a href="#" class="btn btn-primary btn-block btn-outline btn-lg" onclick="history.back()">Return</a>
          </div>
        <?php
            }
          }else{
        ?>
          <form action="functions/save/save.php" method="post">
            <?php
              if(isset($_GET['id'])){
            ?>
              <input type="hidden" name="batch_id" value="<?php echo $batch['ID']; ?>">
            <?php
              }else if(isset($_GET['batch'])){
            ?>
              <input type="hidden" name="car_model_id" value="<?php echo $_GET['car_model_id']; ?>">
              <input type="hidden" name="date" value="<?php echo $_GET['date']; ?>">
              <input type="hidden" name="shift" value="<?php echo $_GET['shift']; ?>">
              <input type="hidden" name="account_id" value="<?php echo $_GET['account_id']; ?>">
              <input type="hidden" name="process_id" value="<?php echo $_GET['process_id']; ?>">
            <?php
              }
            ?>
            <div class="row">

              <div class="col">
                <div class="form-group">
                  <label>Product Number</label>
                  <input type="text" class="form-control" name="product_no" required>
                </div>
              </div>
              <input type="hidden" class="form-control" name="std_time">
              <div class="col">
                <div class="form-group">
                  <label>Output <span class="text-muted small">(Qty)</span></label>
                  <input type="text" class="form-control" name="output_qty" required>
                </div>
              </div>
              <div class="col d-none">
                <div class="form-group">
                  <label>Output Man Minutes<span class="text-muted small">(ST x Output)</span></label>
                  <input type="text" class="form-control" id="total" disabled>
                </div>
              </div>
            </div>

            <div class="col-12 text-right">
              <div class="form-group">
                <?php
                  if(isset($_GET['id'])){
                ?>
                  <button type="submit" name="add-product" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
                <?php
                  }else if(isset($_GET['batch'])){
                ?>
                  <button type="submit" name="batch" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
                <?php
                  }
                ?>
              </div>
            </div>
            
          </form>
        <?php
          }
        ?>

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
    $('.btn-ok').click(function(){
      window.opener.location.reload();
      window.close();
    });

    $('input[name="std_time"]').keyup(function(){
      stdXqty($(this).val(),$('input[name="output_qty"]').val());
    })

    $('input[name="output_qty"]').keyup(function(){
      stdXqty($(this).val(),$('input[name="std_time"]').val());
    });

    function stdXqty(std,qty){
      var std = $('input[name="std_time"]').val();
      var qty = $('input[name="output_qty"]').val();
      var total = std*qty;
        $('#total').val(total.toFixed(2));
    }

  });
</script>
</body>

</html>