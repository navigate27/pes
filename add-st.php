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
          <h3>Add Product ST</h3>
          <hr>
        </div>
      </div>
    </div>

    <div class="">
      <div class="col-12">
        <?php
          if(isset($_GET['success'])){
            if($_GET['success']=='true'){
        ?>
          <div class="alert alert-dismissible alert-success text-center">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <strong><i class="fa fa-check"></i></strong> Product ST was <strong>added</strong> successfully.</a>
          </div>

          <div class="col-4 offset-4 text-center">
            <a href="#" class="btn btn-primary btn-block btn-outline btn-lg btn-ok">OK</a>
          </div>
        <?php
            }
          }else{
        ?>
          <form action="functions/save/save.php" method="post">
            <div class="row">

              <div class="col">
                <div class="form-group">
                  <label>Product Number</label>
                  <input type="text" class="form-control" name="product_no" required>
                </div>
              </div>
              <div class="col">
                <div class="form-group">
                  <label>Standard Time</label>
                  <input type="text" class="form-control" name="std_time" required>
                </div>
              </div>
            </div>

            <div class="col-12 text-right">
              <div class="form-group">
                  <button type="submit" name="add-st" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
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

  });
</script>
</body>

</html>