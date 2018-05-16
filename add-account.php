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
    <title>Entry Account</title>
    <style>
    </style>
</head>

<body>

  <?php
    $acct = $db->getAllAccountType();
    $cms = $db->getCarModel();
    $shf = $db->getShift();
    $grp = $db->getAllGroup();
  ?>

<div class="">
    <div class="page-header mt-3">
      <div class="">
        <div class="col-12">
          <h3>Entry Account</h3>
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
            <strong><i class="fa fa-check"></i></strong> Account record was <strong>added</strong> successfully.</a>
          </div>
        <?php
            }
          }
        ?>
          <form action="functions/save/save.php" method="post">
            <div class="row">
              <div class="col">
                <div class="form-group">
                  <label>Name</label>
                  <input type="text" class="form-control" name="name" autofocus required>
                </div>
              </div>

              <div class="col">
                <div class="form-group">
                  <label>Username</label>
                  <input type="text" class="form-control" name="username" required>
                </div>
              </div>

              <div class="col">
                <div class="form-group">
                  <label>Password</label>
                  <input type="password" class="form-control" name="password" required>
                </div>
              </div>
            </div>

            <div class="row">
              <?php
                if($_SESSION['login_data']['type'] == 3){
              ?>
              <div class="col">
                <div class="form-group">
                  <label>Car Model</label>
                  <select name="car_model_id" class="form-control">
                    <?php
                      if($_SESSION['login_data']['type'] == 1 || $_SESSION['login_data']['type'] == 3){
                        echo '<option value="">-none-</option>';
                      }
                      if($_SESSION['login_data']['type'] != 2){
                        if($cms){
                          foreach ($cms as $i => $cm) {
                            echo '<option value="'.$cm['ID'].'">'.$cm['car_model_name'].'</option>';
                          }
                        }
                      }else{
                        echo '<option value="'.$_SESSION['login_data']['car_model_id'].'">'.$_SESSION['login_data']['car_model_name'].'</option>';
                      }
                    ?>
                  </select>
                </div>
              </div>
              <?php
                }else if($_SESSION['login_data']['type']==2){
              ?>
                <div class="col">
                  <div class="form-group">
                    <label>Car Model</label>
                    <select name="car_model_id" class="form-control">
                      <?php
                          echo '<option value="'.$_SESSION['login_data']['car_model_id'].'">'.$_SESSION['login_data']['car_model_name'].'</option>';
                      ?>
                    </select>
                  </div>
                </div>
              <?php
                }
              ?>

              <?php
                if($_SESSION['login_data']['type'] != 2){
              ?>
                <div class="col">
                  <div class="form-group">
                    <label>Shift</label>
                    <select name="shift_id" class="form-control">
                      <?php
                        if($_SESSION['login_data']['type'] == 1 || $_SESSION['login_data']['type'] == 3){
                          echo '<option value="">-none-</option>';
                        }
                        if($shf){
                          foreach ($shf as $i => $sh) {
                            echo '<option value="'.$sh['ID'].'">'.$sh['shift'].'</option>';
                          }
                        }
                      ?>
                    </select>
                  </div>
                </div>
              <?php
                }else{
                  echo '<input type="hidden" name="shift_id">';
                }
              ?>

              <?php
                if($_SESSION['login_data']['type'] != 1){
              ?>
                <div class="col">
                  <div class="form-group">
                    <label>Group</label>
                    <select name="group_id" class="form-control">
                      <?php
                        if($_SESSION['login_data']['type'] == 3){
                          echo '<option value="">-none-</option>';
                        }
                        if($grp){
                          foreach ($grp as $i => $gr) {
                            echo '<option value="'.$gr['ID'].'">'.$gr['group_name'].'</option>';
                          }
                        }
                      ?>
                    </select>
                  </div>
                </div>
              <?php
                }else{
                  echo '<input type="hidden" name="group_id" value="0">';
                }
              ?>
              

              <div class="col">
                <div class="form-group">
                  <label>Account Type</label>
                  <select name="acc_type" class="form-control" required>
                    <?php
                      if($acct){
                        foreach ($acct as $i => $acc) {
                          if($_SESSION['login_data']['type']!=3){
                            if($acc['ID']==$_SESSION['login_data']['type']&&$acc['ID']!=3){
                              echo '<option value="'.$acc['ID'].'">'.$acc['account_name'].'</option>';
                            }
                          }else{
                              echo '<option value="'.$acc['ID'].'">'.$acc['account_name'].'</option>';
                          }
                        }
                      }
                    ?>
                  </select>
                </div>
              </div>
            </div>

            <div class="col-12 text-right">
              <div class="form-group">
                <button type="submit" name="add-account" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
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