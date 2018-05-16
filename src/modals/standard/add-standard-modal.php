<!-- #GAdd START-->
<div id="Add" class="modal fade" role="dialog">
  <div class="modal-dialog modal-xs">

  <form action="functions/controller.php" id="addFormStandard" class="form-horizontal">
    
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Add Standard</h4>
      </div>
      <div class="modal-body">
        
         <div class="col-sm-12 ">
           <div class="form-group">
              <label class="control-label col-sm-8 text-left"></label>
                <div class="col-sm-4">
                 <select class="form-control" name="s_shift">
                  <option value="day">Day Shift</option>
                  <option value="night">Night Shift</option>
                  <option value="all">Hybrid</option>
                 </select>
                </div>
           </div>               
          </div>

         <div class="form-group">
            <label class="control-label col-sm-3">Standard Name:</label>
                <div class="col-sm-6">
                  <input required type="text" name="s_stname" class="form-control" placeholder="Standard Name">
                </div>
          </div>

          <div class="form-group">
            <label class="control-label col-sm-3">Endorsement:</label>
              <div class="col-sm-6 checkbox">
                <label><input type="checkbox" value="">With</label>
              </div>
          </div>

           <div class="form-group">
            <label class="control-label col-sm-3">Overtime:</label>
              <div class="col-sm-6 checkbox">
                <label><input type="checkbox" value="">With</label>
              </div>
          </div>

          <div class="form-group">
            <label class="control-label col-sm-3">Days:</label>
                <div class="col-sm-6">
                  <input required type="text" name="s_stname" class="form-control" placeholder="Days">
                </div>
          </div>

         <table class="table table-module2">

          <thead>
            <tr>
              <th class="col-md-4" colspan="3"><center>Roles</center></th>
            </tr>
          </thead>
          <tbody>

          </tbody>
          <tfoot>
            <tr>
              <td colspan="3">
                <a href="javascript:void(0)" class="btn btn-info btn-block btn-add-row2"><i class="fa fa-plus-circle fa-fw"></i> ADD ROW</a>
              </td>
            </tr>
          </tfoot>
        </table>

      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-primary">Save</button>
         <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
      </div>
    </div>
  </form>
  </div>
</div>
<!-- #GAdd END-->