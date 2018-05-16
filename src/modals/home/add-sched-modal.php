<!-- #myModal START -->
<div id="myModal" class="modal fade" role="dialog" data-keyboard="false" data-backdrop="static">
  <div class="modal-dialog modal-lg">

  <form action="functions/controller.php" id="form1" class="form-horizontal">
    
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Advanced Information - Add</h4>
      </div>
      <div class="modal-body">
        
        <div class="form-group">
          <label class="control-label col-sm-2">Req.Number:</label>
              <div class="col-sm-4">
                  <input required type="text" name="reqn" class="form-control" placeholder="Request Number">
              </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-2">Dev. Content:</label>
              <div class="col-sm-4">
                  <input required type="text" name="dc" class="form-control" placeholder="Development Control">
              </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-2">Car Kind:</label>
              <div class="col-sm-4">
                  <input required type="text" name="carkind" class="form-control" placeholder="Car Kind">
              </div>
        </div>
 
         <div class="col-sm-12 row">
             <div class="form-group">
              <div class="control-label col-sm-3">
                <label>Start Design:</label>
              </div>
              <div class="control-label col-sm-3">
                <label >FALP Due Date:</label>
              </div>
              <div class="control-label col-sm-3">
                <label>Guarantee Due Date:</label>
              </div>
              <div class="control-label col-sm-3">
                <label>Present Process:</label>
              </div>
             </div>
        </div>

        <div class="col-sm-12 row">
             <div class="form-group">
                    <div class="col-sm-3">
                        <input required type="date" name="ssd" class="form-control" placeholder="Start Design">
                    </div>
                    <div class="col-sm-3">
                        <input type="date" name="falpd" class="form-control" placeholder="FALP">
                    </div>
                    <div class="col-sm-3">
                      <input type="date" name="gd" class="form-control" placeholder="Guarantee">
                    </div>
                     <div class="col-sm-3">
                      <input type="date" name="ppd" class="form-control" placeholder="Present Process">
                    </div>
             </div>
        </div>
 
        <table class="table table-module">

          <thead>
            <tr>
              <th class="col-md-3">Harness No.</th>
              <th class="col-md-2">DR/CP</th>
              <!-- <th class="col-md-2">DR (Drawing)/CP (Change Point)</th> -->
              <th class="col-md-3">Suggested Team</th>
              <th class="col-md-2">Availability</th>
              <th class="col-md-1"></th>
            </tr>
          </thead>
          <tbody>
            <tr class="harness_row">
              <td>
                <select required name="hn[]" class="form-control selectpicker" data-live-search="true" data-harness_no>
              </td>
              <td>
                <select class="form-control dr_cp" name="dr_cp[]" required data-dr_cp>
                </select>
              </td>
              <td>
                <!-- <a href="#" class="remove_row btn btn-danger">
                  <i class="fa fa-times fa-fw"></i>
                </a> -->
              </td>
            </tr>
            <tr>
              <td colspan="5">
                <a href="javascript:void(0)" class="btn btn-info btn-block btn-add-row"><i class="fa fa-plus-circle fa-fw"></i> ADD ROW</a>
              </td>
            </tr>
          </tbody>
        </table>

        </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-primary btn-save-add">Save</button>
         <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
      </div>
    </div>
  </form>
  </div>
</div>
<!-- #myModal END