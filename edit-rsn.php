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
          <h3>Update Reason Record</h3>
          <hr>
        </div>
      </div>
    </div>

    <div class="">
      <div class="col-12">
        <?php
          if(isset($_GET['id'])){
            $rsn = $db->getReasonID($_GET['id']);
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
            <strong><i class="fa fa-check"></i></strong> Downtime reason record was <strong>updated</strong> successfully.</a>
          </div>
        <?php
            }
          }
        ?>
        <form action="functions/save/save.php" method="post">
          <input type="hidden" name="reason_id" value="<?php echo $rsn['ID']; ?>">
          <div class="row">

            <div class="col">
              <div class="form-group">
                <label>ID</label>
                <input type="text" class="form-control" value="<?php echo $rsn['ID']; ?>" disabled>
              </div>
            </div>
            <div class="col">
              <div class="form-group">
                <label>Reason</label>
                <input type="text" class="form-control" name="reason" value="<?php echo $rsn['reason']; ?>">
              </div>
            </div>
          </div>

          <div class="col-12 text-right">
            <div class="form-group">
              <button type="submit" name="edit-rsn" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
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