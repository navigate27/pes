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
          <h3>Edit Product Number</h3>
          <hr>
        </div>
      </div>
    </div>

    <div class="">
      <div class="col-12">
        <?php
          if(isset($_GET['id'])){
            $pn = $db->getProductNoOnID($_GET['id']);
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
            <strong><i class="fa fa-check"></i></strong> Product Number was <strong>updated</strong> successfully.</a>
          </div>
        <?php
            }
          }
        ?>
          <form action="functions/save/save.php" method="post">
            <input type="hidden" name="product_id" value="<?php echo $pn['ID']; ?>">
            <div class="row">

              <div class="col">
                <div class="form-group">
                  <label>Product Number</label>
                  <input type="text" class="form-control" name="product_no" value="<?php echo $pn['product_no']; ?>">
                </div>
              </div>
              <div class="col">
                <div class="form-group">
                  <label>Standard Time</label>
                  <input type="text" class="form-control" name="std_time" value="<?php echo $pn['std_time']; ?>" readonly>
                </div>
              </div>
              <div class="col">
                <div class="form-group">
                  <label>Output <span class="text-muted small">(Qty)</span></label>
                  <input type="text" class="form-control" name="output_qty" value="<?php echo $pn['output_qty']; ?>">
                </div>
              </div>
              <div class="col">
                <div class="form-group">
                  <label>Output Man Minutes<span class="text-muted small">(ST x Output)</span></label>
                  <input type="text" class="form-control" id="total" disabled>
                </div>
              </div>
            </div>

            <div class="col-12 text-right">
              <div class="form-group">
                <button type="submit" name="edit-product" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
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
    stdXqty();
    $('input[name="std_time"]').keyup(function(){
      stdXqty();
    })

    $('input[name="output_qty"]').keyup(function(){
      stdXqty();
    });

    function stdXqty(){
      var std = $('input[name="std_time"]').val();
      var qty = $('input[name="output_qty"]').val();
      var total = std*qty;
        $('#total').val(total.toFixed(2));
    }

  });
</script>
</body>

</html>