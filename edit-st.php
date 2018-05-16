<?php
  include 'db/config.php';
  include 'functions/auth.php';

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
            $pn = $db->getSTOnID($_GET['id']);
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
            <input type="hidden" name="st_id" value="<?php echo $pn['ID']; ?>">
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
                  <input type="text" class="form-control" name="std_time" value="<?php echo $pn['st']; ?>">
                </div>
              </div>
            </div>

            <div class="col-12 text-right">
              <div class="form-group">
                <button type="submit" name="edit-st" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
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

  });
</script>
</body>

</html>