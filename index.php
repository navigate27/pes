<?php
  include 'db/config.php';
  include 'functions/auth.php';
  header("location: summary.php");
  unset($_SESSION['batch_id']);
?>

<!DOCTYPE html> 
<html lang="en"> 
<head>
    <?php
      include 'src/link.php';
    ?>
    <title>Product Number List</title>
    <style>
    </style>
</head>

<body>

  <style>
    #canvas{
      position: absolute;
      z-index: -5;
      background: transparent;
    }
  </style>
  <canvas id="canvas"></canvas>
    <?php
    include 'src/nav.php';
    ?>

    <?php
      $cms = $db->getCarModel();
      $sh = $db->getShift();
    ?>

<div class="container" id="banner">
  <div class="page-header">
    <div class="row">
      <div class="col-12">
        <h1>Product Number List</h1>
      </div>
    </div>
  </div>

  <hr>
  <div class="section">
    <div class="">
      <div class="col-xs-12">
        <div class="card">
          <div class="card-body">
            <form action=" " id="search-form">
              <div class="row mb-2">
                <div class="col-3">
                  <label>PIC</label>
                  <input type="text" class="form-control" readonly value="<?php echo $_SESSION['login_data']['name']; ?>">
                  <input type="hidden" value="1" name="account_id">
                  <input type="hidden" value="1" name="process_id">
                </div>
                <div class="col">
                  <label>Car Model</label>
                  <select name="car_model_id" class="form-control" required>
                    <?php
                      if($cms){
                        foreach ($cms as $i => $cm) {
                          echo '<option value="'.$cm['ID'].'">'.$cm['car_model_name'].'</option>';
                        }
                      }
                    ?>
                  </select>
                </div>
                <div class="col">
                  <label>Assy Date</label>
                  <input type="text" name="date" class="form-control" onkeydown="return false" id="dp-date" placeholder="Date" required value="<?php echo date('Y-m-d'); ?>" autocomplete="off">
                </div>
                <div class="col">
                  <label>Shift</label>
                  <select name="shift_id" class="form-control" required>
                    <?php
                      if($sh){
                        echo '<option value="0">DS/NS</option>';
                        foreach ($sh as $i => $s) {
                            echo '<option value="'.$s['ID'].'">'.$s['shift'].'</option>';
                        }
                      }
                    ?>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col text-right">
                  <button type="submit" name="search" class="btn btn-lg btn-primary" value="search">
                    <i class="fa fa-search"></i> Search
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
        
      </div>
    </div>
  </div>

  <div class="mt-4 mb-3 section">
    <!-- <div class="col-xs-12 text-right buttons1 d-none">
    <hr>
      <a class="btn btn-danger btn-delete-all text-white"><i class="fa fa-trash"></i> Delete All</a>
      <a class="btn btn-primary btn-add1 text-white"><i class="fa fa-plus"></i> Add</a>
      <a class="btn btn-success text-white btn-import"><i class="fa fa-upload"></i> Import</a>
      <input type="file" name="csv" id="csv" class="d-none">
    </div> -->

    <div class="row mt-2">
      <div class="col-12 d-none" id="tbl-empty">
        <div class="card text-center">
          <div class="card-body">
            <h4 class="card-title mt-2"><i class="fa fa-exclamation-circle text-danger"></i> Batch details not found.</h4>
            <p class="card-text"> It seems that batch details doesn't exists.</p>
            <!-- <a class="btn btn-lg btn-primary btn-add2 text-white add-new"><i class="fa fa-plus"></i> Add Product Now</a> -->
            <a href="product-import.php" class="btn btn-lg btn-primary text-white"><i class="fa fa-plus"></i> Add Product Now</a>
          </div>
        </div>
      </div>
      <div class="col-12" id="pnContent"></div>
    </div>

  </div>

  <?php
      include 'src/footer.php';
  ?>
</div>


<div class="modal fade" tabindex="-1" role="dialog" id="modalDeletePN">
  <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
      <div class="modal-content">
        <form action="functions/delete/delete.php" method="post" id="formDelete">
          <div class="modal-header">
            <h5 class="modal-title">Remove Product Record</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <div class="alert alert-warning text-center">
              <strong><i class="fa fa-exclamation-triangle"></i></strong> Are you sure you want to <strong>remove</strong> the following records?
              <br>
              <strong>The data could not be recovered after deletion.</strong>
            </div>
            <div id="modalDeletePNContent">
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-danger" name="delete-pn">Ok, remove it.</button>
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
          </div>
        </form>
      </div>
  </div>
</div>

<div class="modal" tabindex="-1" role="dialog" id="modalUploadCSV">
  <div class="modal-dialog modal-dialog-centered" role="document">
      <div class="modal-content">
        <form action="functions/delete/delete.php" method="post">
          <div class="modal-header">
            <h5 class="modal-title">Import CSV</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <div class="lead text-center">
              <div id="csv-progress-text">
                Converting file...
              </div>
              <div id="csv-progress-text2" class="d-none">
                Saving data...
              </div>
              <br>
              <div id="csv-results" class="d-none">
                <h4>Done!</h4>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-primary d-none" id="btn-csv">Done</button>
          </div>
        </form>
      </div>
  </div>
</div>

<!-- SCRIPT -->
<?php
      include 'src/script.php';
?>

<script>
  $(document).ready(function(){
    $("#dp-date").datetimepicker({
      format: 'YYYY/MM/DD'
    });

    function saveSession(){
      sessionStorage.setItem('car_model_id',$('select[name="car_model_id"]').val());
      sessionStorage.setItem('date',$('input[name="date"]').val());
      sessionStorage.setItem('shift_id',$('select[name="shift_id"]').val());
    }

    $('#search-form').submit(function(e){
      e.preventDefault();
      // HeartsBackground.initialize();
      var form = $(this).serialize();
      console.log(form);
      getData(form);
    });

    function getData(form){
      $.get('src/pnContent.php?v='+$.now(), {
        form: form
      },function(page){
        if(page.trim()!="false"){
          $('#tbl-empty').addClass('d-none');
          $('#pnContent').html(page);
          $('html, body').animate({
            scrollTop: $("#pnContent").offset().top
          }, 500);

          var batch_id = $('input[name="batch_id"]').val();
          $('.btn-delete-all').attr('data-id',batch_id);
          $('.btn-add1').attr('data-id',batch_id).removeClass('add-new');
          $('.btn-import').attr('data-id',batch_id).removeClass('add-new');
          console.log('success');
        }else{
          $('#tbl-empty').removeClass('d-none');
          $('#pnContent').empty();
          $('.btn-delete-all').removeAttr('data-id');
          $('.btn-add1').removeAttr('data-id').addClass('add-new');
          $('.btn-import').removeAttr('data-id').addClass('add-new');
          console.log('failed');
        }

        $('.buttons1').removeClass('d-none');
        saveSession();
      });
    }


    //init here
    if (sessionStorage.getItem("car_model_id") !== null) {
      $('select[name="car_model_id"] option[value="'+sessionStorage.getItem("car_model_id")+'"]').attr("selected",true);
    }
    if (sessionStorage.getItem("date") !== null) {
      $('input[name="date"]').val(sessionStorage.getItem("date"));
    }
    if (sessionStorage.getItem("shift_id") !== null) {
      $('select[name="shift_id"] option[value="'+sessionStorage.getItem("shift_id")+'"]').attr("selected",true);
    }
    $('button[name="search"]').click();
    saveSession();

    $('.btn-add1').click(function(){
      if($('input[name="date"]').val()!=""){
        addClick($(this));
      }else{
        console.log('pls search first');
      }
    });

    $(document).on('click','.btn-add2', function(){
      addClick($(this));
    });

    $(document).on('click', '.btn-add-pn-req', function(){
      addClick($(this));
    });

    $(document).on('click', '.btn-delete-all', function(){
      var id = $(this).data('id');
      $.post('functions/save/save.php',{
        'delete-all-pn': id
      }, function(response){
        console.log(response);
        if(response==true){
          location.reload();
        }
      });
    });

    function addClick(el){
      if(!el.hasClass('add-new')){
        var id = el.data('id');
        PopupCenter('add-product.php?id='+id,'Add Product Number','900','500');  
      }else{
        var car_model_id = $('select[name="car_model_id"]').val();
        var date = $('input[name="date"]').val();
        var shift_id = $('select[name="shift_id"]').val();
        var account_id = $('input[name="account_id"]').val();
        var process_id = $('input[name="process_id"]').val();
        var batch = "true";
        PopupCenter('add-product.php?batch='+batch+'&car_model_id='+car_model_id+'&date='+date+'&shift='+shift_id+'&account_id='+account_id+'&process_id='+process_id,'Add Product Number','900','500');
      }
    }

    $(document).on('click','.edit-pn', function(){
      var id = $(this).closest('tr').data('id');
      PopupCenter('edit-product.php?id='+id,'Edit Product Number','900','500');
    });

    $(document).on('click','.delete-pn', function(){
      var id = $(this).closest('tr').data('id');

      $.get('src/deletePN.php',{
        id: id 
      }, function(html){
        $('#modalDeletePNContent').html(html);
      });
    });

    $('.btn-import').click(function(){
      $('input[name="csv"]').click();
    });

    $('input[name="csv"]').change(function(evt){
        $('#modalUploadCSV').modal({
            show: true
        });
        var rowCount = 0;
        var files = evt.target.files;
        f = files[0];

        var reader = new FileReader();

        reader.onload = (function(theFile) {
            return function(e) {
              var rows = [];
              var data = Papa.parse(e.target.result, {
                dynamicTyping: true,
                encoding: "UTF-8",
                skipEmptyLines: true,
                header: false,
                worker: true,
                step: function(results){
                  if(results.errors.length==0){
                    rowCount++;
                    rows.push(results.data);
                    console.log(rowCount);
                    console.log("Row data:", results.data);
                    console.log("Row errors:", results.errors);
                  }
                },
                complete: function(results) {
                  console.log("Parsing complete:", results);
                  console.log(rows);
                  $('#csv-progress-text').text('Saving data...');
                  $('input[name="csv"]').val('');
                  for (var i = 0; i < rows.length; i++) {
                    if(i>0){
                      importCSV(rows[i],i, rows.length);
                    }
                  }
                  $('#csv-progress-text').addClass('d-none');
                  $('#csv-progress-text2').removeClass('d-none');
                }
              });
            };
          })(f);

          // Read in the image file as a data URL.
          reader.readAsText(f);
    });

    function importCSV(csv,i,count){

      if(!$('.btn-import').hasClass('add-new')){
        var id = $('.btn-import').data('id');
        var pn = {
          batch_id: id,
          csv: csv
        };
        console.log(pn);
        $.post('functions/save/save.php',{
          'import-pn': pn,
        }, function(response){
          console.log(response);
          if(i==(count-1)){
            var form = $('#search-form').serialize();
            getData(form);
            $('#modalUploadCSV').modal('hide');
            getAlert(1);
          }
        });
      }else{
        var car_model_id = $('select[name="car_model_id"]').val();
        var date = $('input[name="date"]').val();
        var shift_id = $('select[name="shift_id"]').val();
        var account_id = $('input[name="account_id"]').val();
        var process_id = $('input[name="process_id"]').val();
        var batch = {
          car_model_id: car_model_id,
          date: date,
          shift_id: shift_id,
          account_id: account_id,
          process_id: process_id,
          csv: csv,
          index: i
        };
        console.log(batch);
        $.post('functions/save/save.php',{
          'import-batch': batch,
        }, function(response){
          console.log(response);
          if(i==(count-1)){
            var form = $('#search-form').serialize();
            getData(form);
            $('#modalUploadCSV').modal('hide');
            getAlert(1);
          }
        });
      }

    }

    $('#modalUploadCSV').modal({
        backdrop: 'static',
        keyboard: false,
        focus: true,
        show: false
    });

  });
</script>
</body>

</html>