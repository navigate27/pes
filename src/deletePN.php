<?php
	include '../db/config.php';
	if(isset($_GET['id'])){
		$pn = $db->getProductNoOnID($_GET['id']);
	}
?>

<input type="hidden" name="product_id" value="<?php echo $pn['ID']; ?>">
<div class="row">
  <div class="col">
    <div class="form-group">
      <label>Product Number</label>
      <p class="form-control-static"><?php echo $pn['product_no']; ?></p>
    </div>
  </div>
  <div class="col">
    <div class="form-group">
      <label>Standard Time</label>
      <p class="form-control-static"><?php echo $pn['std_time']; ?></p>
    </div>
  </div>
  <div class="col">
    <div class="form-group">
      <label>Output <span class="text-muted small">(Qty)</span></label>
      <p class="form-control-static"><?php echo $pn['output_qty']; ?></p>
    </div>
  </div>
</div>