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
    <title>Maintenance</title>
    <style>
      .list-group-item:hover .list-buttons{
        visibility: visible;
        transition: visibility 1s;
      }
      .list-buttons{
        visibility: hidden;
      }
      .list-group-flush{
        max-height: 380px;
        overflow: auto;
      }
      .cm-list{
        background-color: #ddd;
      }
    </style>
</head>

<body>

    <?php
    include 'src/nav.php';
    ?>

    <?php
      $prcs = $db->getAllProcessDetailOnProcessID('1');
      $rsn = $db->getAllReason();
      $pic = $db->getAllPICList();
      $cms = $db->getCarModel();
    ?>

<div class="container" id="banner">
  <div class="page-header">
    <div class="row">
      <div class="col-12">
        <h1>Maintenance</h1>
      </div>
    </div>
  </div>
  <hr>

  <div class="section">
    <div class="row">
      <div class="col-4">

        <div class="list-group" id="list-tab" role="tablist">
          <a class="list-group-item list-group-item-primary active" id="list-settings-list" data-toggle="list" href="#list-cms" role="tab" aria-controls="settings">Car Model</a>
          <a class="list-group-item list-group-item-warning" id="list-home-list" data-toggle="list" href="#list-prcs" role="tab" aria-controls="home">Production Process</a>
          <a class="list-group-item list-group-item-danger" id="list-profile-list" data-toggle="list" href="#list-rsn" role="tab" aria-controls="profile">Downtime Reason</a>
          <a class="list-group-item list-group-item-success" id="list-messages-list" data-toggle="list" href="#list-pic" role="tab" aria-controls="messages">PIC List</a>
        </div>

      </div>

      <div class="col">
        <div class="tab-content" id="nav-tabContent">
          <div class="tab-pane fade" id="list-prcs" role="tabpanel" aria-labelledby="list-home-list">
            <div class="card border-warning">
              <div class="card-header">
                  Production Process (First Process)
              </div>
              <div class="card-body">
                <ul class="list-group list-group-flush">
                  <?php
                    if($prcs){
                      foreach ($prcs as $i => $prc) {
                        echo '<li class="list-group-item">'.$prc['process_detail_name'].'</li>';
                      }
                    }else{
                      echo '<li class="list-group-item"><span class="text-danger"><strong>Empty records!</strong></span</li>';
                    }
                  ?>
                </ul>
              </div>
            </div>
          </div>
          <div class="tab-pane fade" id="list-rsn" role="tabpanel" aria-labelledby="list-profile-list">
            <div class="card border-danger">
              <div class="card-header">
                  Downtime Reason
              </div>
              <div class="card-body">
                <div class="row col-12 mb-2">
                  <a href="javascript:void(0)" class="btn btn-add-reason btn-danger"><i class="fa fa-plus"></i> Add Reason</a>
                </div>
                <ul class="list-group list-group-flush">
                  <?php
                    if($rsn){
                      foreach ($rsn as $i => $rs) {
                        echo '<li class="list-group-item" data-id="'.$rs['ID'].'">'.$rs['reason'].' 
                          <span class="pull-right list-buttons">
                            <a href="javascript:void(0)" class="btn btn-sm btn-edit-reason btn-link"><i class="fa fa-pencil fa-2x"></i></a>
                            <a href="javascript:void(0)" class="btn btn-sm btn-delete-reason btn-link text-danger"><i class="fa fa-trash-o fa-2x"></i></a>
                          </span>
                        </li>';
                      }
                    }else{
                      echo '<li class="list-group-item"><span class="text-danger"><strong>Empty records!</strong></span</li>';
                    }
                  ?>
                </ul>
              </div>
            </div>
          </div>
          <div class="tab-pane fade" id="list-pic" role="tabpanel" aria-labelledby="list-messages-list">
            <div class="card border-success">
              <div class="card-header">
                  PIC List
              </div>
              <div class="card-body">
                <div class="row col-12 mb-2">
                  <a href="javascript:void(0)" class="btn btn-add-pic btn-success"><i class="fa fa-plus"></i> Add PIC</a>
                </div>
                <ul class="list-group list-group-flush">
                  <?php
                    if($pic){
                      foreach ($pic as $i => $p) {
                        echo '<li class="list-group-item" data-id="'.$p['id'].'">'.$p['pic_name'].'
                        <span class="pull-right list-buttons">
                          <a href="javascript:void(0)" class="btn btn-sm btn-edit-pic btn-link"><i class="fa fa-pencil fa-2x"></i></a>
                          <a href="javascript:void(0)" class="btn btn-sm btn-delete-pic btn-link text-danger"><i class="fa fa-trash-o fa-2x"></i></a>
                        </span>
                        </li>';
                      }
                    }else{
                      echo '<li class="list-group-item"><span class="text-danger"><strong>Empty records!</strong></span</li>';
                    }
                  ?>
                </ul>
              </div>
            </div>
          </div>
          <div class="tab-pane fade show active" id="list-cms" role="tabpanel" aria-labelledby="list-settings-list">
            <div class="card border-primary">
              <div class="card-header">
                  Car Model List
              </div>
              <div class="card-body">
                <ul class="list-group list-group-flush">
                  <?php
                    if($cms){
                      foreach ($cms as $i => $cm) {
                        $cm_class = "cm-list";
                        if($_SESSION['login_data']['car_model_id']==$cm['ID']&&$_SESSION['login_data']['type']==2){
                          $cm_class = "";
                        }else if($_SESSION['login_data']['type']==3){
                          $cm_class = "";
                        }
                        echo '<li class="list-group-item '.$cm_class.'" data-id="'.$cm['ID'].'">'.$cm['car_model_name'].' ('.$cm['car_code'].')';
                        if($_SESSION['login_data']['car_model_id']==$cm['ID']&&$_SESSION['login_data']['type']==2){
                          echo '<span class="pull-right list-buttons">
                            <a href="javascript:void(0)" class="btn btn-sm btn-edit-cm btn-link"><i class="fa fa-pencil fa-2x"></i></a>
                          </span>';
                        }else if($_SESSION['login_data']['type']==3){
                          echo '<span class="pull-right list-buttons">
                            <a href="javascript:void(0)" class="btn btn-sm btn-edit-cm btn-link"><i class="fa fa-pencil fa-2x"></i></a>
                          </span>';
                        }
                        echo '</li>';
                      }
                    }else{
                      echo '<li class="list-group-item"><span class="text-danger"><strong>Empty records!</strong></span</li>';
                    }
                  ?>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <?php
      include 'src/footer.php';
  ?>
</div>

<!-- SCRIPT -->
<?php
      include 'src/script.php';
?>
</script>

<script>
  $(document).ready(function(){
    if (sessionStorage.getItem("tab-main") !== null) {
      $('#list-tab a[href="#'+sessionStorage.getItem("tab-main")+'"]').tab('show');
    }else{
      sessionStorage.setItem('tab-main','list-cms');
    }

    $(document).on('click', 'a[href="#list-cms"]', function(){
      sessionStorage.setItem('tab-main','nav-cms');
      console.log('list-cms');
    });
    $(document).on('click', 'a[href="#list-prcs"]', function(){
      sessionStorage.setItem('tab-main','list-prcs');
    });
    $(document).on('click', 'a[href="#list-rsn"]', function(){
      sessionStorage.setItem('tab-main','list-rsn');
    });
    $(document).on('click', 'a[href="#list-pic"]', function(){
      sessionStorage.setItem('tab-main','list-pic');
    });

    $('.btn-edit-reason').click(function(){
      var id = $(this).closest('li').data('id');
      PopupCenter('edit-rsn.php?id='+id,'Update Downtime Reason',500,400);
    });

    $('.btn-add-reason').click(function(){
      PopupCenter('add-rsn.php','Entry Downtime Reason',500,400);
    });

    $('.btn-edit-pic').click(function(){
      var id = $(this).closest('li').data('id');
      PopupCenter('edit-pic.php?id='+id,'Update PIC List',500,400);
    });

    $('.btn-add-pic').click(function(){
      PopupCenter('add-pic.php','Entry PIC',500,400);
    });

    $('.btn-edit-cm').click(function(){
      var id = $(this).closest('li').data('id');
      PopupCenter('edit-cm.php?id='+id,'Update Car Model',600,450);
    });

    $(document).on('click', '.btn-delete-pic', function(){
      var id = $(this).closest('li').data('id');
      console.log(id);
      $.post('functions/delete/delete.php',{
        'delete-pic': id
      }, function(response){
        console.log(response);
        if(response==true){
          location.reload();
        }
      });
    });

    $(document).on('click', '.btn-delete-reason', function(){
      var id = $(this).closest('li').data('id');
      $.post('functions/delete/delete.php',{
        'delete-rsn': id
      }, function(response){
        console.log(response);
        if(response==true){
          location.reload();
        }
      });
    });

  });
</script>
</body>

</html>