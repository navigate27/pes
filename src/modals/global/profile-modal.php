<div id="profileModal" class="modal fade" role="dialog" data-keyboard="false" data-backdrop="static">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Profile Information</h4>
      </div>
      <div class="modal-body">
        
        <form class="form-horizontal">

          <div class="form-group">
            <label class="control-label col-sm-4" for="email">Nickname:</label>
            <div class="col-sm-8">
              <p class="form-control-static"><?php echo strtoupper($_SESSION['login_data']['nickname']); ?></p>
            </div>
          </div>
                    
          <div class="form-group">
            <label class="control-label col-sm-4" for="email">Name:</label>
            <div class="col-sm-8">
              <p class="form-control-static"><?php echo strtoupper($_SESSION['login_data']['f_name'])." ".strtoupper($_SESSION['login_data']['l_name']); ?></p>
            </div>
          </div>

          <div class="form-group">
            <label class="control-label col-sm-4" for="email">Car Maker:</label>
            <div class="col-sm-8">
              <p class="form-control-static"><?php echo strtoupper($_SESSION['login_data']['car_maker_detail']); ?></p>
            </div>
          </div>

          <div class="form-group">
            <label class="control-label col-sm-4" for="email">Shift:</label>
            <div class="col-sm-8">
              <p class="form-control-static"><?php echo strtoupper($_SESSION['login_data']['shift']); ?></p>
            </div>
          </div>

          <div class="form-group">
            <label class="control-label col-sm-4" for="email">Account Type:</label>
            <div class="col-sm-8">
              <p class="form-control-static">
                <?php 

                switch ($_SESSION['login_data']['account_type']) {
                  case 'all':
                    echo 'SUPERVISOR';
                    break;

                  case 'control':
                    echo 'CONTROL STAFF';
                    break;
                  
                  default:
                    echo strtoupper($_SESSION['login_data']['account_type']);
                    break;
                }

                ?>
              </p>
            </div>
          </div>

        </form>

      </div>
      <div class="modal-footer">
         <button type="button" class="btn btn-default" data-dismiss="modal">OKAY</button>
      </div>
    </div>
  </div>
</div>