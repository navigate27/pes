<?php
  $color_options = array();

  array_push($color_options, '<option value="#fff" style="background-color: #fff"></option>');
  array_push($color_options, '<option value="#ff0000" style="background-color: #ff0000"></option>');
  array_push($color_options, '<option value="#00ff00" style="background-color: #00ff00"></option>');
  array_push($color_options, '<option value="#0000ff" style="background-color: #0000ff"></option>');
  array_push($color_options, '<option value="#ffff00" style="background-color: #ffff00"></option>');
  array_push($color_options, '<option value="#ff00ff " style="background-color: #ff00ff"></option>');

  $color_options = implode('', $color_options);
?>
<!-- #SEdit START-->
<div id="SEdit" class="modal fade" role="dialog">
  <div class="modal-dialog modal-lg">
    <form action="functions/controller.php" id="form1">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">&times;</button>
          <h4 class="modal-title">Edit Summary</h4>
        </div>

        <div class="modal-body">
          <input required type="hidden" name="summary_id">
          <span>
            <div class="col-xs-4">
              <div class="form-group">
                <label>Car Type:</label>
                <input required type="text" name="c_type" class="form-control" placeholder="Car Type" readonly>
              </div>
            </div>

            <div class="col-xs-4">
              <div class="form-group">
                <label>Model Name:</label>
                <input required type="text" name="m_name" class="form-control" placeholder="Model Name" readonly>
              </div>
            </div>
                    
            <div class="col-xs-4">
              <div class="form-group">
                <label>Request No.:</label>
                <input required type="text" name="r_number" class="form-control" placeholder="Request Number" readonly>
              </div>
            </div>

            <div class="col-xs-2 no-pad-right">
              <div class="form-group">
                <label>Issuing Drawing:</label>
                <input type="text" name="issue_drawing" class="form-control">
              </div>
            </div>

            <div class="col-xs-1 no-pad-left">
              <div class="form-group">
                <label>&nbsp;</label>
                <select name="issue_drawing_color" class="form-control color-select">
                  <?php
                    echo $color_options;
                  ?>
                </select>
              </div>
            </div>

            <div class="col-xs-2 no-pad-right">
              <div class="form-group">
                <label>Adding Memo(B):</label>
                <input type="text" name="adding_memo_big" class="form-control">
              </div>
            </div>

            <div class="col-xs-1 no-pad-left">
              <div class="form-group">
                <label>&nbsp;</label>
                <select name="adding_memo_big_color" class="form-control color-select">
                  <?php
                    echo $color_options;
                  ?>
                </select>
              </div>
            </div>

            <div class="col-xs-2 no-pad-right">
              <div class="form-group">
                <label>Adding Memo(S):</label>
                <input type="text" name="adding_memo_small" class="form-control">
              </div>
            </div>

            <div class="col-xs-1 no-pad-left">
              <div class="form-group">
                <label>&nbsp;</label>
                <select name="adding_memo_small_color" class="form-control color-select">
                  <?php
                    echo $color_options;
                  ?>
                </select>
              </div>
            </div>

            <div class="col-xs-2 no-pad-right">
              <div class="form-group">
                <label>Req Densan Ok:</label>
                <input type="text" name="req_densan_ok" class="form-control">
              </div>
            </div>

            <div class="col-xs-1 no-pad-left">
              <div class="form-group">
                <label>&nbsp;</label>
                <select name="req_densan_ok_color" class="form-control color-select">
                  <?php
                    echo $color_options;
                  ?>
                </select>
              </div>
            </div>

            <div class="col-xs-3 no-pad-right">
              <div class="form-group">
                <label>Req FALP due date:</label>
                <input type="text" name="req_falp_dd" class="form-control">
              </div>
            </div>

            <div class="col-xs-1 no-pad-left">
              <div class="form-group">
                <label>&nbsp;</label>
                <select name="req_falp_dd_color" class="form-control color-select">
                  <?php
                    echo $color_options;
                  ?>
                </select>
              </div>
            </div>
            
            <div class="col-xs-3 no-pad-right">
              <div class="form-group">
                <label>FALP due date ff sched:</label>
                <input type="text" name="falp_dd_ff_sched" class="form-control">
              </div>
            </div>

            <div class="col-xs-1 no-pad-left">
              <div class="form-group">
                <label>&nbsp;</label>
                <select name="falp_dd_ff_sched_color" class="form-control color-select">
                  <?php
                    echo $color_options;
                  ?>
                </select>
              </div>
            </div>
          </span>

          <div class="modal-footer">
            <div class="col-xs-12 no-pad-bot">
              <button type="submit" class="btn btn-primary">Save</button>
              <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
            </div>
          </div>
        </div>

        
      </div>
    </form>
  </div>
</div>
<!-- #SEdit END-->