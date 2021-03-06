<!-- #GEdit START-->
<div id="GEdit" class="modal fade" role="dialog">
  <div class="modal-dialog modal-xs"> 

  <form action="functions/controller.php" id="editFormGroup" class="form-horizontal">
    
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Edit Group</h4>
      </div>
      <div class="modal-body"> 
        <input type="hidden" name="group_id" id="group_id" >
         <div class="col-sm-12 ">
           <div class="form-group">
              <label class="control-label col-sm-8 text-left"></label>
                <div class="col-sm-4">
                 <select class="form-control" name="gshift" id="gshift">
                  <option value="day">Day Shift</option>
                  <option value="night">Night Shift</option>
                 </select>
                </div>
           </div>               
          </div>

        <div class="form-group">
            <label class="control-label col-sm-3">Team Name:</label>
                <div class="col-sm-6">
                  <input required type="text" name="g_name" id="g_name" class="form-control" placeholder="Team Name">
                </div>
          </div>

          <div class="form-group">
            <label class="control-label col-sm-3">Leader:</label>
                <div class="col-sm-6">
                  <select required name="leader" id="leader" class="form-control">
                  </select>
                </div>
          </div>

         <table class="table table-module">

          <thead>
            <tr>
              <th class="col-md-4" colspan="3"><center>Members</center></th>
            </tr>
          </thead>
          <tbody>

          </tbody>
          <tfoot>
            <tr>
              <td colspan="3">
                <a href="javascript:void(0)" class="btn btn-info btn-block btn-add-row"><i class="fa fa-plus-circle fa-fw"></i> ADD ROW</a>
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
<!-- #GEdit END-->