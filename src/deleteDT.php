<?php
	include '../db/config.php';
	if(isset($_GET['id'])){
		$dt = $db->getDowntimeOnID($_GET['id'])[0];
	}
?>
  <input type="hidden" name="dt_id" value="<?php echo $dt['ID']; ?>">
  <div class="row">
    <div class="col-3">
      <div class="form-group">
        <label>PIC</label>
        <p class="form-control-static"><?php echo $dt['pic_name']; ?></p>
      </div>
    </div>

    <div class="col-3">
      <div class="form-group">
        <label>Reason</label>
        <p class="form-control-static"><?php echo $dt['reason']; ?></p>
      </div>
    </div>
    <div class="col">
      <div class="form-group">
        <label>Wire</label>
        <p class="form-control-static"><?php echo $dt['part_wire']; ?></p>
      </div>
    </div>
    <div class="col">
      <div class="form-group">
        <label>F Side</label>
        <p class="form-control-static"><?php echo $dt['part_term_front']; ?></p>
      </div>
    </div>
    <div class="col">
      <div class="form-group">
        <label>R Side</label>
        <p class="form-control-static"><?php echo $dt['part_term_rear']; ?></p>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-3">
      <div class="form-group">
        <label>Process</label>
        <p class="form-control-static"><?php echo $dt['process_detail_name']; ?></p>
      </div>
    </div>
    <div class="col">
      <div class="form-group">
        <label>Dimension</label>
        <p class="form-control-static"><?php echo $dt['dimension']; ?></p>
      </div>
    </div>
    <div class="col">
      <div class="form-group">
        <label>Start Time</label>
        <p class="form-control-static"><?php echo $dt['time_start']; ?></p>
      </div>
    </div>
    <div class="col">
      <div class="form-group">
        <label>End Time</label>
        <p class="form-control-static"><?php echo $dt['time_end']; ?></p>
      </div>
    </div>
    <div class="col">
      <div class="form-group">
        <label>Total Time</label>
        <p class="form-control-static"><?php echo $dt['time_total']; ?></p>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-2">
      <div class="form-group">
        <label>Rank 1 to 2</label>
        <p class="form-control-static"><?php echo $dt['mp_r1']; ?></p>
      </div>
    </div>
    <div class="col-2">
      <div class="form-group">
        <label>RANK 3 & above</label>
        <p class="form-control-static"><?php echo $dt['mp_r3']; ?></p>
      </div>
    </div>
  </div>
