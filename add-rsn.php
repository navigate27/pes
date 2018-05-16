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
          <h3>Add Reason Record</h3>
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
            <strong><i class="fa fa-check"></i></strong> Downtime reason record was <strong>added</strong> successfully.</a>
          </div>
        <?php
            }
          }
        ?>
        <form action="functions/save/save.php" method="post">
          <div class="row">
            <div class="col-8">
              <div class="form-group">
                <label>Reason</label>
                <input type="text" class="form-control" name="reason" autofocus>
              </div>
            </div>
          </div>

          <div class="col-12 text-right">
            <div class="form-group">
              <button type="submit" name="add-rsn" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
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