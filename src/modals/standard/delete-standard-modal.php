<!-- #SDelete START -->
<div id="Delete" class="modal fade" role="dialog">
  <div class="modal-dialog modal-sm">

  <form action="functions/controller.php" id="deleteStd" class="form-horizontal">
    
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Delete Standard</h4>
      </div>
      <div class="modal-body">
            <input type="hidden" name="delete_id" id="delete_id">
            <center><label>Are you sure you want to delete this record?</label></center>
          
      </div>
      <div class="modal-footer">
          <button type="submit" class="btn btn-primary">Yes</button>
          <button type="button" class="btn btn-default" data-dismiss="modal">No</button>
      </div>
    </div>
  </form>
  </div>
</div>
<!-- #SDelete END -->