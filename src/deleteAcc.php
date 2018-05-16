<?php
	include '../db/config.php';
	if(isset($_GET['id'])){
		$acc = $db->getAccountOnID($_GET['id']);
	}
?>
  <input type="hidden" name="account_id" value="<?php echo $acc['ID']; ?>">
  <div class="row">
    <div class="col-3">
      <div class="form-group">
        <label>Name</label>
        <p class="form-control-static"><?php echo $acc['name']; ?></p>
      </div>
    </div>

    <div class="col-3">
      <div class="form-group">
        <label>Username</label>
        <p class="form-control-static"><?php echo $acc['username']; ?></p>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-3">
      <div class="form-group">
        <label>Car Model</label>
        <p class="form-control-static"><?php echo $acc['car_model_name']; ?></p>
      </div>
    </div>
    <div class="col-3">
      <div class="form-group">
        <label>Shift</label>
        <p class="form-control-static"><?php echo $acc['shift']; ?></p>
      </div>
    </div>
    <div class="col-3">
      <div class="form-group">
        <label>Account Name</label>
        <p class="form-control-static"><?php echo $acc['account_name']; ?></p>
      </div>
    </div>
  </div>
