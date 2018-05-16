<!-- #GEdit START-->
<div id="Edit" class="modal fade" role="dialog">
  <div class="modal-dialog modal-sm"> 

  <form action="functions/controller.php" id="editFormStandard" class="form-horizontal">
    
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Edit Basic Standard Info</h4>
      </div>
      <div class="modal-body"> 
        <input type="hidden" name="std_id">

          <div class="form-group">
            <div class="col-sm-6">
                <label>Standard Name:</label>
                <input required type="text" name="std_name" class="form-control" placeholder="Standard Name">
            </div>
            <div class="col-sm-6">
                <label>Shift:</label>
                <select class="form-control" name="shift">
                  <option value="day">Day Shift</option>
                  <option value="night">Night Shift</option>
                  <option value="hybrid">Hybrid</option>
                </select>
            </div>
          </div>

          <div class="form-group">
              <div class="col-sm-6 checkbox">
                <label><input type="checkbox" name="endorse">Endorsment</label>
              </div>
          </div>

          <div class="form-group">
              <div class="col-sm-6 checkbox">
                <label><input type="checkbox" name="ot">Overtime</label>
              </div>
          </div>

          <div class="form-group">
            <div class="col-sm-6">
              <label>Days:</label>
              <input required type="text" name="days" class="form-control" readonly>
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
<!-- #GEdit END-->