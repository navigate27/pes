<?php
  include 'db/config.php';
  include 'functions/auth.php';

?>

<!DOCTYPE html> 
<html lang="en"> 
<head>
    <?php
      include 'src/link.php';
    ?>

    <style>
    .tbl-item{
      cursor: pointer;
    }
    .tbl-item.selected{
      background-color: #eee;
      color: #696969;
    }
    </style>
</head>

<body>

    <?php
    include 'src/nav.php';
    ?>

    <?php
      $type = 0;
      $car_model_id = 0;
      if($_SESSION['login_data']['type'] == 1){
        $type = 1;
        $car_model_id = 0;
      }else if($_SESSION['login_data']['type'] == 2){
        $type = 2;
        $car_model_id = $_SESSION['login_data']['car_model_id'];
      }
      $accs = $db->getAllAccountOnAccountType($type,$car_model_id);
    ?>

<div class="container" id="banner">
  <div class="page-header">
    <div class="row">
      <div class="col-12">
        <h1>Account Masterlist</h1>
      </div>
    </div>
  </div>
  <hr>

  <div class="section">
    <div class="col-12 mb-3">
      <a href="javascript:void(0)" class="btn btn-primary btn-add-acc"><i class="fa fa-user-plus"></i> Entry Account</a>
    </div>
    <div class="row">
      <div class="col-12">
        <?php
          if($accs){
        ?>
        <table class="table table-bordered table-hover" id="table-acc">
          <thead>
            <tr>
              <th>#</th>
              <th>ID</th>
              <th>Name</th>
              <th>Username</th>
              <th class="d-none">Password</th>
              <?php
                if($_SESSION['login_data']['type'] == 1){
                  echo '<th>Shift</th>';
                }else if($_SESSION['login_data']['type'] == 2){
                  echo '<th>Car Model</th>';
                  echo '<th>Group</th>';
                }else if($_SESSION['login_data']['type'] == 3){
                  echo '<th>Car Model</th>';
                  echo '<th>Shift</th>';
                  echo '<th>Group</th>';
                }
              ?>
              <th>Account Type</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <?php
              foreach ($accs as $i => $acc) {
                echo '<tr class="tbl-item" data-id="'.$acc['ID'].'">';
                echo '<td>'.($i+1).'</td>';
                echo '<td>'.$acc['ID'].'</td>';
                echo '<td>'.$acc['name'].'</td>';
                echo '<td>'.$acc['username'].'</td>';
                echo '<td data-password="'.$acc['password'].'" class="d-none"><a data-toggle="modal" data-target="#modalShowPass" href="javascript:void(0)" class="btn-pass">click for password</a></td>';
                if($_SESSION['login_data']['type'] == 1){
                  echo '<td>'.$acc['shift'].'</td>';
                }else if($_SESSION['login_data']['type'] == 2){
                  echo '<td>'.$acc['car_model_name'].'</td>';
                  echo '<td>'.$acc['group_name'].'</td>';
                }else if($_SESSION['login_data']['type'] == 3){
                  echo '<td>'.$acc['car_model_name'].'</td>';
                  echo '<td>'.$acc['shift'].'</td>';
                  echo '<td>'.$acc['group_name'].'</td>';
                }
                echo '<td>'.$acc['account_name'].'</td>';
                echo '<td>
                  <a href="javascript:void(0)" class="btn btn-primary btn-edit btn-sm" data-toggle="tooltip" data-placement="top" title="Edit"><i class="fa fa-pencil"></i></a>
                  <a href="javascript:void(0)" data-toggle="modal" data-target="#modalDeleteAcc" class="btn btn-danger btn-delete btn-sm" data-toggle="tooltip" data-placement="top" title="Delete"><i class="fa fa-trash"></i></a>
                </td>';
                echo '</tr>';
              }
            ?>
          </tbody>
        </table>
        <?php
          }
        ?>
      </div>
    </div>
  </div>

  <?php
      include 'src/footer.php';
  ?>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id="modalDeleteAcc">
  <div class="modal-dialog modal-dialog-centered modal" role="document">
      <div class="modal-content">
        <form action="functions/delete/delete.php" method="post">
          <div class="modal-header">
            <h5 class="modal-title">Remove Account Record</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <div class="alert alert-warning text-center">
              <strong><i class="fa fa-exclamation-triangle"></i></strong> Are you sure you want to <strong>remove</strong> the following records?</a>
              <br>
              <strong>The data could not be recovered after deletion.</strong>
            </div>
            <div id="modalDeleteAccContent">
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-danger" name="delete-account">Ok, remove it.</button>
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
          </div>
        </form>
      </div>
  </div>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id="modalShowPass">
  <div class="modal-dialog modal-dialog-centered modal" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="card">
            <div class="card-body">
              <h4 class="text-center"><code><strong class="show-password"></strong></code></h4>
            </div>
          </div>
        </div>
      </div>
  </div>
</div>

<!-- SCRIPT -->
<?php
      include 'src/script.php';
?>
</script>

<script>
  $(document).ready(function(){
    $('#table-acc').DataTable({
      'info': false
    });

    $('#table-acc tbody').on( 'click', '.tbl-item', function () {
        if ( $(this).hasClass('selected') ) {
            $(this).removeClass('selected');
        }
        else {
            $('#table-acc tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });

    $('.btn-add-acc').click(function(){
      PopupCenter('add-account.php','Entry Account',800,400);
    });

    $(document).on('click','.btn-edit', function(){
      var id = $(this).closest('tr').data('id');
      PopupCenter('edit-account.php?id='+id,'Entry Account',800,400);
    });

    $(document).on('click','.btn-delete', function(){
      var id = $(this).closest('tr').data('id');

      $.get('src/deleteAcc.php',{
        id: id 
      }, function(html){
        $('#modalDeleteAccContent').html(html);
      });

    });

    $('.btn-pass').click(function(){
      var pass = $(this).closest('td').data('password');
      $('.show-password').text(pass);
    });

  });
</script>
</body>

</html>