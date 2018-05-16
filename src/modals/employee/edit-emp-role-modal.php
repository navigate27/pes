<!-- #EAdd START-->
<div id="ERole" class="modal fade" role="dialog" data-keyboard="false" data-backdrop="static">
  <div class="modal-dialog modal-xs">

  <form action="functions/controller.php" id="updateRoleForm" class="form-horizontal">
    
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Update Roles</h4>
      </div>
      <div class="modal-body">
          <input type="hidden" name="role_account_id">
          <table class="table table-roles">
           <thead>
             <tr>
                <th class="col-md-1">No.</th>
                <th class="col-md-3">Roles</th>
                <th class="col-md-1"></th>
             </tr>
           </thead>
           <tbody>
           </tbody>
           <tfoot>
              <tr>                
                <td colspan="3">
                  <a href="javascript:void(0)" class="btn btn-info btn-block btn-add-role"><i class="fa fa-plus-circle fa-fw"></i> ADD ROLE</a>
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
<!-- #EAdd END -->

<script>
  
</script>