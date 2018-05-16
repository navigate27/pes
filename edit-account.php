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
    <title>Edit Account</title>
    <style>
    </style>
</head>

<body>

<div class="">
    <div class="page-header mt-3">
      <div class="">
        <div class="col-12">
          <h3>Edit Account (<?php echo $_SESSION['login_data']['account_name']; ?>)</h3>
          <hr>
        </div>
      </div>
    </div>

    <div class="">
      <div class="col-12">

      <?php
      if(isset($_GET['id'])){
        $id = $_GET['id'];
        $accs = $db->getAccountOnID($id);
        $acct = $db->getAllAccountType();
        $cms = $db->getCarModel();
        $shf = $db->getShift();
        $grp = $db->getAllGroup();
      ?>

        <?php
          if(isset($_GET['success'])){
            if($_GET['success']=='true'){
        ?>
          <div class="alert alert-dismissible alert-success text-center">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <strong><i class="fa fa-check"></i></strong> Account record was <strong>updated</strong> successfully.</a>
          </div>
        <?php
            }
          }
        ?>
          <form action="functions/save/save.php" method="post">
            <input type="hidden" name="account_id" value="<?php echo $id; ?>">
            <div class="row">
              <div class="col">
                <div class="form-group">
                  <label>Name</label>
                  <input type="text" class="form-control" name="name" autofocus required value="<?php echo $accs['name']; ?>">
                </div>
              </div>

              <div class="col">
                <div class="form-group">
                  <label>Username</label>
                  <input type="text" class="form-control" name="username" required value="<?php echo $accs['username']; ?>">
                </div>
              </div>

              <div class="col">
                <div class="form-group">
                  <label>Password</label>
                  <input type="password" class="form-control" name="password" required value="<?php echo $accs['password']; ?>">
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
                        if($cms){
                          foreach ($cms as $i => $cm) {
                            if($cm['ID']==$accs['car_model_id']){
                              echo '<option value="'.$cm['ID'].'" selected>'.$cm['car_model_name'].'</option>';
                            }else{
                              echo '<option value="'.$cm['ID'].'">'.$cm['car_model_name'].'</option>';
                            }
                          }
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
                            if($sh['ID']==$accs['shift_id']){
                              echo '<option value="'.$sh['ID'].'" selected>'.$sh['shift'].'</option>';
                            }else{
                              echo '<option value="'.$sh['ID'].'">'.$sh['shift'].'</option>';
                            }
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
                            if($accs['group_id']==$gr['ID']){
                              echo '<option value="'.$gr['ID'].'" selected>'.$gr['group_name'].'</option>';
                            }else{
                              echo '<option value="'.$gr['ID'].'">'.$gr['group_name'].'</option>';
                            }
                          }
                        }
                      ?>
                    </select>
                  </div>
                </div>
              <?php
                }else{
                  echo '<input type="hidden" name="group_id" value="">';
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
                              if($acc['ID']==$accs['type']){
                                echo '<option value="'.$acc['ID'].'" selected>'.$acc['account_name'].'</option>';
                              }else{
                                echo '<option value="'.$acc['ID'].'">'.$acc['account_name'].'</option>';
                              }
                            }
                          }else{
                              if($acc['ID']==$accs['type']){
                                echo '<option value="'.$acc['ID'].'" selected>'.$acc['account_name'].'</option>';
                              }else{
                                echo '<option value="'.$acc['ID'].'">'.$acc['account_name'].'</option>';
                              }
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
                <button type="submit" name="edit-account" class="btn btn-primary">Save <i class="fa fa-send"></i></button>
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

  });
</script>
</body>

</html>