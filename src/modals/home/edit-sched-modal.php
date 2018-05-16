<!-- #Edit START-->
<div id="Edit" class="modal fade" role="dialog" data-keyboard="false" data-backdrop="static">
  <div class="modal-dialog modal-lg">

  <form action="request.php" id="editForm" >
    
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Advanced Information - Update</h4>
      </div>
      <div class="modal-body">
        
        <input type="hidden" name="falp_id">
        
        <div class="row">
          <div class="col-xs-12">
            <div class="col-sm-3">
              <label>SYNC ID:</label>
              <div class="form-group">
                  <input required type="text" name="sync_id" class="form-control" placeholder="SYNC ID" readonly>
              </div>
            </div>
          </div>
        </div>

        <div class="col-sm-3">
            <label>Request Number:</label>
                <div class="form-group">
                    <input required type="text" name="reqno" class="form-control" placeholder="Request Number">
                </div>
        </div>

        <div class="col-sm-3">
          <label>Model Name:</label>
          <div class="form-group">
              <input required type="text" name="mname" class="form-control" placeholder="Model Name">
          </div>
        </div>

        <div class="col-sm-3">
            <label>Car Kind:</label>
                <div class="form-group">
                    <input required type="text" name="car_kind" class="form-control" placeholder="Car Kind">
                </div>
        </div>

        <div class="col-sm-3">
            <label>Car Maker:</label>
                <div class="form-group">
                    <input type="text"  name="car_maker" class="form-control" placeholder="" value="<?php echo $_SESSION['login_data']['car_maker']; ?>" disabled>
                </div>
        </div>

        <div class="col-sm-3">
            <label>Development Content:</label>
                <div class="form-group">
                    <input required type="text" name="t_kubun" class="form-control" placeholder="Development Content">
                </div>
        </div>

        <div class="col-sm-6">
            <label>Progress:</label>
                <div class="form-group">
                    <input type="text" name="sin_info" class="form-control" placeholder="Progress">
                </div>
        </div>

        <div class="col-sm-3">
            <label>Date Received:</label>
                <div class="form-group">
                    <input type="text" name="date_receive" class="form-control" placeholder="Date Received" pattern="(?:19|20)[0-9]{2}/(?:(?:0[1-9]|1[0-2])/(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])/(?:30))|(?:(?:0[13578]|1[02])-31))">
                </div>
        </div>
      
      <div class="form-group">
        <div class="col-sm-3">
            <label>Start Design:</label>
            <input type="text" name="tstart" class="form-control" placeholder="Start Design" required pattern="(?:19|20)[0-9]{2}/(?:(?:0[1-9]|1[0-2])/(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])/(?:30))|(?:(?:0[13578]|1[02])-31))">
        </div>
      </div>

      <div class="col-sm-3">
        <div class="form-group">
            <label >FALP Due Date:</label>
            <input type="text" name="p_tenkai" class="form-control" placeholder="FALP" required pattern="(?:19|20)[0-9]{2}/(?:(?:0[1-9]|1[0-2])/(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])/(?:30))|(?:(?:0[13578]|1[02])-31))">
        </div>
      </div>

      <div class="col-sm-3">
        <div class="form-group">
          <label>Guarantee Due Date:</label>
          <input type="text" name="p_hosyou" class="form-control" placeholder="Guarantee" pattern="(?:19|20)[0-9]{2}/(?:(?:0[1-9]|1[0-2])/(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])/(?:30))|(?:(?:0[13578]|1[02])-31))">
        </div>
      </div>

      <div class="col-sm-3">
         <div class="form-group">
            <label>Present Process:</label>
            <input type="text" name="p_genko" class="form-control" placeholder="Present Process" pattern="(?:19|20)[0-9]{2}/(?:(?:0[1-9]|1[0-2])/(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])/(?:30))|(?:(?:0[13578]|1[02])-31))">
        </div>
      </div>
      
    </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-primary">Save</button>
        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
      </div>
    </div>
  </form>
  </div>
</div>
<!-- #Edit END -->