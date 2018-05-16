<!-- #EEdit START-->
<div id="EEdit" class="modal fade" role="dialog">
  <div class="modal-dialog modal-xs">

  <form action="functions/controller.php" id="editForm" class="form-horizontal">
    
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Edit Designer</h4>
      </div>
      <div class="modal-body">

        <input type="hidden" id="employee_id" name="employee_id">

         <div class="form-group">
          <label class="control-label col-sm-4">Nickname:</label>
              <div class="col-sm-6">
                  <input required type="text" name="nn" id="nn" class="form-control" placeholder="Nickname">
              </div>
        </div>
        
        <div class="form-group">
          <label class="control-label col-sm-4">First Name:</label>
              <div class="col-sm-6">
                  <input required type="text" name="fn" id="fn" class="form-control" placeholder="First Name">
              </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Last Name:</label>
              <div class="col-sm-6">
                  <input required type="text" name="ln" id="dc" class="form-control" placeholder="Last Name">
              </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Pass Code:</label>
              <div class="col-sm-6">
                  <input required type="text" name="pc" id="pc" class="form-control" placeholder="Pass Code">
              </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Shift:</label>
            <div class="col-sm-6">
              <select class="form-control" name="shift" id="shift">
                <option value="day">Day Shift</option>
                <option value="night">Night Shift</option>
              </select>
            </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Car Maker:</label>
            <div class="col-sm-6">
              <select class="form-control" name="carm" id="carm">
                <option value="1">Mazda</option>
                <option value="2">Daihatsu</option>
                <option value="3">Honda</option>
                <option value="4">Toyota</option>
                <option value="5">All</option>
              </select>
            </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Account Type:</label>
            <div class="col-sm-6">
              <select class="form-control" name="accttype" id="accttype">
                <option value="all">Supervisor</option>
                <option value="control">Control Staff</option>
                <option value="designer">Designer</option>
              </select>
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
<!-- #EEdit END-->