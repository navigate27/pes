<?php
  include 'db/config.php';
  include 'functions/auth.php';

  header('Access-Control-Allow-Origin: *'); 

?>

<!DOCTYPE html> 
<html lang="en"> 
<head>
    <?php
      include 'src/link.php';
    ?>
    <title>Production Efficiency System</title>
    <style>
    </style>
</head>

<body>

    <?php
    include 'src/nav.php';
    ?>
    
    <?php
      $cms = $db->getCarModel();
      $sh = $db->getShift();
      $grp = $db->getAllGroup();

      // print_r(ini_get_all());

    ?>
<div class="container" id="banner">

  <div class="section mb-3">
    <div class="row">
      <div class="col-12">
        <div class="card">
            <div class="card-header">
              <div class="card-link">
                <i class="fa fa-search"></i> Search Engine
                <a class="pull-right" data-toggle="collapse" href="#batchInfo">
                  <i class="fa fa-chevron-down"></i>
                </a>
              </div>
            </div>
            <div id="batchInfo" class="collapse show">
              <div class="card-body">
                <form action=" " id="search-form">
                  <div class="row mb-2">
                    <input type="hidden" value="<?php echo $_SESSION['login_data']['ID']; ?>" name="account_id">
                    <input type="hidden" value="1" name="process_id">
                    <div class="col">
                      <label>Car Model</label>

                      <?php
                        if($_SESSION['login_data']['type'] == 5){
                      ?>
                        <select name="car_model_id" class="form-control">
                          <?php
                            if($cms){
                              foreach ($cms as $i => $cm) {
                                echo '<option value="'.$cm['ID'].'">'.$cm['car_model_name'].'</option>';
                              }
                            }
                          ?>
                        </select>
                      <?php
                        }else{
                      ?>
                        <input type="text" class="form-control" name="car_model_name" value="<?php echo $_SESSION['login_data']['car_model_name']; ?>" readonly>
                        <input type="hidden" name="car_model_id" value="<?php echo $_SESSION['login_data']['car_model_id']; ?>">
                      <?php
                        }
                      ?>


                    </div>
                    <div class="col">
                      <label>Cutting Date</label>
                      <input type="text" name="date" class="form-control" onkeydown="return false" id="dp-date" placeholder="Date" required value="<?php echo date('Y-m-d'); ?>" autocomplete="off">
                    </div>
                    <div class="col">
                      <label>Shift</label>
                      <select name="shift_id" class="form-control">
                        <!-- <option value="0">-DS/NS-</option> -->
                        <?php
                          if($sh){
                            foreach ($sh as $i => $s) {
                              echo '<option value="'.$s['ID'].'">'.$s['shift'].'</option>';
                            }
                          }
                        ?>
                      </select>
                      <!-- <input type="text" class="form-control" name="shift_name" value="<?php echo $_SESSION['login_data']['shift']; ?>" readonly>
                      <input type="hidden" name="shift_id" value="<?php echo $_SESSION['login_data']['shift_id']; ?>"> -->
                    </div>
                    <div class="col">
                      <label>Group</label>
                        <?php
                          if($_SESSION['login_data']['type']==5){
                            if($grp){
                              echo '<select name="group_id" class="form-control">';
                              foreach ($grp as $i => $gp) {
                                echo '<option value='.$gp['ID'].'>'.$gp['group_name'].'</option>';
                              }
                              echo '</select>';
                            }
                          }else{
                        ?>
                          <select name="group_id" class="form-control" readonly>
                            <option value="<?php echo $_SESSION['login_data']['group_id']; ?>"><?php echo $_SESSION['login_data']['group_name']; ?></option>
                          </select>
                        <?php
                          }
                        ?>
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
  </div>

  <div class="section">
    <?php
      $hide = '';
      if($_SESSION['login_data']['type'] != 2){
        $hide = 'd-none';
      }
    ?>
    <span class="<?php echo $hide; ?>">
      <div class="col-xs-12 text-right buttons1">
        <hr>
        <a class="btn btn-danger text-white" data-target="#modalDeleteAll" data-toggle="modal"><i class="fa fa-trash"></i> Delete All</a>
        <a class="btn btn-primary btn-add1 text-white"><i class="fa fa-plus"></i> Add</a>
        <a class="btn btn-success text-white btn-import"><i class="fa fa-upload"></i> Import</a>
        <input type="file" name="csv" id="csv" class="d-none" accept=".csv">
      </div>
    </span>
    <div class="row">
      <div class="mt-2 col-12">
        <div class="card text-center d-none" id="tbl-empty">
          <div class="card-body">
            <h4 class="card-title mt-2">No records found.</h4>
            <p class="card-text"> It seems that it didn't have an entry yet.</p>
            <a class="btn btn-lg btn-primary btn-no-result text-white"><i class="fa fa-search"></i> Try different query instead.</a>
          </div>
        </div>
      </div>
      <div class="col-12" id="mpContent"></div>
    </div>
  </div>
  
  <?php
      include 'src/footer.php';
  ?>

</div>

<div class="modal fade" tabindex="-1" role="dialog" id="modalDeleteDT">
  <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
      <div class="modal-content">
        <form action="functions/delete/delete.php" method="post">
          <div class="modal-header">
            <h5 class="modal-title">Remove Downtime Record</h5>
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
            <div id="modalDeleteDTContent">
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-danger" name="delete-dt">Ok, remove it.</button>
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
          </div>
        </form>
      </div>
  </div>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id="modalPreviewPN">
  <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
      <div class="modal-content" id="tbl-preview-pn">
      </div>
  </div>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id="modalDeleteAll">
  <div class="modal-dialog modal-dialog-centered modal-md" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Remove All Product</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="alert alert-warning text-center">
            <strong><i class="fa fa-exclamation-triangle"></i></strong> Are you sure you want to <strong>remove</strong> all products?
            <br>
            <strong>The data will not be recovered after deletion.</strong>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-danger btn-delete-all">Ok, remove it.</button>
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        </div>
      </div>
  </div>
</div>

<div class="modal" tabindex="-1" role="dialog" id="modalImportProgress" data-keyboard="false" data-backdrop="static">
  <div class="modal-dialog modal-dialog-centered modal-md" role="document">
      <div class="modal-content">
        <div class="modal-body">
          <h3 class="text-center progress-count">
            <i class="fa fa-spinner fa-pulse fa-2x"></i> <div><h3 id="progress-msg">Converting file...</h3></div>
          </h3>
        </div>
      </div>
  </div>
</div>

<div class="modal" tabindex="-1" role="dialog" id="modalLoadingProgress" data-keyboard="false" data-backdrop="static">
  <div class="modal-dialog modal-dialog-centered modal-md" role="document">
      <div class="modal-content">
        <div class="modal-body">
          <h3 class="text-center progress-count">
            <i class="fa fa-spinner fa-pulse fa-2x"></i> Please wait, saving...
          </h3>
        </div>
      </div>
  </div>
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

<!-- SCRIPT -->
<?php
      include 'src/script.php';
?>

<script>
  $(document).ready(function(){
    var PN = [];
    $("#dp-date").datetimepicker({
      viewMode: 'days',
      format: 'YYYY/MM/DD'
    }).on('dp.change', function(e){
      $('#search-form button[type="submit"]').click();
    });

    $('#search-form').submit(function(e){
      e.preventDefault();
      // HeartsBackground.initialize();
      var form = $(this).serialize();
      console.log(form);
      sessionStorage.setItem("mp_date", $('input[name="date"]').val());
      sessionStorage.setItem("mp_shift", $('select[name="shift_id"]').val());
      sessionStorage.setItem("mp_group", $('select[name="group_id"]').val());

      var currentTab = $('.nav-menu li .active').attr('href');
      getData(form);
    });

    $('select[name="shift_id"]').change(function(){
      $('#search-form button[type="submit"]').click();
    });

    $('select[name="group_id"]').change(function(){
      $('#search-form button[type="submit"]').click();
    });

    $('select[name="car_model_id"]').change(function(){
      $('#search-form button[type="submit"]').click();
    });

    function getData(form){
      $.get('src/mpContent.php', {
        form: form
      },function(page){
        if(page.trim()!="false"){
          $('#tbl-empty').addClass('d-none');
          $('#mpContent').html(page);
          scrollToDiv('#mpContent');

          var batch_id = $('input[name="batch_id"]').val();
          $('.btn-delete-all').attr('data-id',batch_id);
          $('.btn-add1').attr('data-id',batch_id).removeClass('add-new');
          $('.btn-import').attr('data-id',batch_id).removeClass('add-new');
        }else{
          $('#tbl-empty').removeClass('d-none');
          $('#mpContent').empty();
          $('.btn-delete-all').removeAttr('data-id');
          $('.btn-add1').removeAttr('data-id').addClass('add-new');
          $('.btn-import').removeAttr('data-id').addClass('add-new');
        }

        $('.buttons1').removeClass('d-none');

        if (sessionStorage.getItem("tab") !== null) {
          if(sessionStorage.getItem("tab")=='nav-mc'||sessionStorage.getItem("tab")=='nav-nw'||sessionStorage.getItem("tab")=='nav-ew'){
            if($('select[name="group_id"]').val() == 0){
              alert('Invalid group selection..');
              sessionStorage.setItem('tab','nav-pn');
            }else{
              $('.nav-menu a[href="#'+sessionStorage.getItem("tab")+'"]').tab('show');
            }
          }
        }else{
          sessionStorage.setItem('tab','nav-pn');
        }

        arrowTableEvent();
        
      });
    }

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
    
    function addClick(el){
      if(!el.hasClass('add-new')){
        var id = el.data('id');
        PopupCenter('add-product.php?id='+id,'Add Product Number','900','500');  
      }else{
        var car_model_id = $('input[name="car_model_id"]').val();
        var date = $('input[name="date"]').val();
        var shift_id = $('select[name="shift_id"]').val();
        var account_id = $('input[name="account_id"]').val();
        var process_id = $('input[name="process_id"]').val();
        var batch = "true";
        PopupCenter('add-product.php?batch='+batch+'&car_model_id='+car_model_id+'&date='+date+'&shift='+shift_id+'&account_id='+account_id+'&process_id='+process_id,'Add Product Number','900','500');
      }
    }

    $('.btn-import').click(function(){
      $('input[name="csv"]').click();
    });

    $('input[name="csv"]').change(function(evt){
        var files = evt.target.files;
        f = files[0];
        console.log(f);
        if(isCSV(f.name)){
          var size = f.size / 1024 / 1024;
          console.log(size.toFixed());
          parseFile(f,size.toFixed());
        }else{
          alert("Incorrect file format. Only CSV file allowed.");
        }
        
    });

    function parseFile(file,size){
      $('#modalImportProgress').modal('show');
      if(size>=25){
        $("#progress-msg").html('Converting file...<br><small>File too large, this may take up to 2 mins..</small>');
      }else if(size<=6){
        $("#progress-msg").html('Converting file<br><small>This may take less than a minute..</small>');
      }

      var reader = new FileReader();
      reader.onload = (function(theFile) {
          return function(e) {
            var rows = 0;
            var data = Papa.parse(e.target.result, {
              dynamicTyping: true,
              encoding: "UTF-8",
              skipEmptyLines: true,
              header: false,
              // worker: true,
              step: function(results){
                if(results.errors.length==0){
                  if(rows>0){
                    PN.push(results.data);
                    console.log("Row data:", results.data);
                    console.log("Row errors:", results.errors);
                  }
                  rows++;
                  console.log(rows);
                }
              },
              complete: function(results) {
                console.log("Parsing complete:", results);
                console.log(PN);
                previewCSV();
              }
            });
          };
        })(f);

        // Read in the image file as a data URL.
        reader.readAsText(f);
    }

    function previewCSV(){
      console.log(PN[0][0].length);
      if(PN[0][0].length!=159){
        alert("Incorrect CSV file.");
        $('#modalImportProgress').modal('hide');
      }else{
        $("#progress-msg").text("Getting ST...");
        $.post('src/previewPNForm2.php',{
          pn: JSON.stringify(PN),
          shift_id: $('select[name="shift_id"]').val(),
          date: $('input[name="date"]').val(),
          car_model_id: $('input[name="car_model_id"]').val()
        }, function(page){
          console.log(page);
          $('#tbl-preview-pn').html(page);
          $('#modalPreviewPN').modal({
            backdrop: 'static',
            keyboard: false,
            show: true
          });
          $('#modalImportProgress').modal('hide');
          $("#progress-msg").text("Please wait, converting file...");
          PN = [];
          $('input[name="csv"]').val('');
        });
      }
    }

    $(document).on('click', '.btn-import-st', function(){;
      $('.btn-loading-import').removeClass('d-none');
      $(this).addClass('d-none');
      $("#modalLoadingProgress").modal('show');
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

    $(document).on('change','#wt-control', function(){
      var wt = $(this).val();
      $('input[name="wt1[]"]').val(wt);
      $('input[name="wt2[]"]').val(parseInt(wt)-30);
      $('#wt-control-text').text(parseInt(wt)-30);
    });

    $(document).on('click','.edit-dt', function(){
      var id = $(this).closest('tr').data('id');
      PopupCenter('edit-dt.php?id='+id,'Downtime Monitoring','900','500');  
    });

    $(document).on('click','.add-dt', function(){
        var id = $(this).data('id');
        PopupCenter('add-dt.php?id='+id,'Downtime Monitoring','900','500');  
    });

    $(document).on('click','.delete-dt', function(){
      var id = $(this).closest('tr').data('id');

      $.get('src/deleteDT.php',{
        id: id 
      }, function(html){
        $('#modalDeleteDTContent').html(html);
      });

    });
    
    $(document).on('click', '.btn-no-result', function(){
      $('input[name="date"]').focus().click();
    });

    $(document).on('click', '.mp-empty', function(){
      $('.nav-menu a[href="#nav-mc"]').tab('show');
    });

    //init here
    if (sessionStorage.getItem("mp_date") !== null) {
      $('input[name="date"]').val(sessionStorage.getItem("mp_date"));
    }
    if (sessionStorage.getItem("mp_shift") !== null) {
      $('select[name="shift_id"] option[value="'+sessionStorage.getItem("mp_shift")+'"]').attr('selected',true);
    }
    if (sessionStorage.getItem("mp_group") !== null) {
      $('select[name="group_id"] option[value="'+sessionStorage.getItem("mp_group")+'"]').attr('selected',true);
    }
    
    $('button[name="search"]').click();
    //arrow events
    function arrowTableEvent(){
      var tab;
      if (sessionStorage.getItem("tab") !== null) {
        tab = sessionStorage.getItem("tab");
      }

      switch(tab){
        case 'nav-mc':
          $('#table-mc').arrowTable();
        break;
        case 'nav-ew':
          $('#table-ew').arrowTable();
        break;
      }
    }

    $(document).on('submit', '#pnMp-form', function(e){
      e.preventDefault();
      $("#modalLoadingProgress").modal('show');
      var el = $(this);
      var form = el.serialize();
      var link = el.attr("action");
      console.log(link);
      $.post(link,{
        'pn-mp': form
      }, function(response){
        console.log(response);
        if(response.trim()==true){
          console.log('success');
          loadPnMpForm();
        }
      });
    });

    $(document).on('submit', '#mc-form', function(e){
      e.preventDefault();
      $("#modalLoadingProgress").modal('show');
      var form = $(this).serialize();
      var link = $(this).attr("action");
      console.log(link);
      $.post(link,{
        mpc: form
      }, function(response){
        console.log(response);
        if(response.trim()==true){
          console.log('success');
          loadMcForm();
          getAlert(1);
        }
      });
    });

    $(document).on('submit', '#nw-form', function(e){
      e.preventDefault();
      $("#modalLoadingProgress").modal('show');
      var form = $(this).serialize();
      var link = $(this).attr("action");
      console.log(link);

      $.post(link,{
        nwt: form
      }, function(response){
        console.log(response);
        if(response.trim()==true){
          console.log('success');
          loadNwForm();
          getAlert(1);
        }
      });

    });

    $(document).on('submit', '#ex-form', function(e){
      e.preventDefault();
      $("#modalLoadingProgress").modal('show');
      var form = $(this).serialize();
      var link = $(this).attr("action");
      console.log(link);

      $.post(link,{
        ext: form
      }, function(response){
        console.log(response);
        if(response.trim()==true){
          console.log('success');
          loadExForm();
          getAlert(1);
        }
      });

    });

    function loadPnMpForm(){
      $.get('src/pnMpForm.php',{
        car_model_id: $('input[name="car_model_id"]').val(),
        date: $('input[name="date"]').val(),
        group_id: $('select[name="group_id"]').val(),
        shift_id: $('select[name="shift_id"]').val()
      }, function(page){
        console.log(page);
        $('#pnMpForm').html(page);
        $('.nav-menu a[href="#nav-mc"]').tab('show');
        getAlert(1);
        scrollToDiv('#mpContent');
        $("#modalLoadingProgress").modal('hide');
      });
    }

    function loadMcForm(){
      $.get('src/mcForm.php',{
        batch_id: $('#batch_id').val(),
        group_id: $('select[name="group_id"]').val()
      }, function(page){
        $('#mcForm').html(page);
        $('.nav-menu a[href="#nav-nw"]').tab('show');
        scrollToDiv('#mpContent');
        $("#modalLoadingProgress").modal('hide');
      });
    }

    function loadNwForm(){
      $.get('src/nwForm.php',{
        batch_id: $('#batch_id').val(),
        group_id: $('select[name="group_id"]').val()
      }, function(page){
        $('#nwForm').html(page);
        $('.nav-menu a[href="#nav-ew"]').tab('show');
        scrollToDiv('#mpContent');
        loadExForm();
        $("#modalLoadingProgress").modal('hide');
      });
    }

    function loadExForm(){
      $.get('src/exForm.php',{
        batch_id: $('#batch_id').val(),
        group_id: $('select[name="group_id"]').val(),
        tmmLine480: $('#tmmLine480').val(),
        tmmAcc480: $('#tmmAcc480').val(),
        tmmLine450: $('#tmmLine450').val(),
        tmmAcc450: $('#tmmAcc450').val(),
      }, function(page){
        $('#exForm').html(page);
        scrollToDiv('#mpContent');
        $("#modalLoadingProgress").modal('hide');
      });
    }

    function loadDtTable(){
      $.get('src/dtTable.php',{
        batch_id: $('#batch_id').val()
      }, function(page){
        $('#dtTable').html(page);
        scrollToDiv('#mpContent');
      });
    }

    $(document).on('show.bs.tab', '.nav-pills a', function(e) {
        var tab = $(this).attr('href');
        switch(tab){
          case '#nav-pn':
            sessionStorage.setItem('tab','nav-pn');
            $('.buttons1').removeClass('d-none');
          break;
          case '#nav-mc':
            if($('.grp_ctrl').length!=0){
              $('.buttons1').addClass('d-none');
              sessionStorage.setItem('tab','nav-mc');
            }else{
              sessionStorage.setItem('tab','nav-pn');
              e.preventDefault();
              getAlert(2);
            }
          break;
          case '#nav-nw':
            if($('.grp_ctrl').length!=0){
              $('.buttons1').addClass('d-none');
              sessionStorage.setItem('tab','nav-nw');
            }else{
              sessionStorage.setItem('tab','nav-pn');
              e.preventDefault();
              getAlert(2);
            }
          break;
          case '#nav-ew':
            if($('.grp_ctrl').length!=0){
              $('.buttons1').addClass('d-none');
              sessionStorage.setItem('tab','nav-ew');
            }else{
              sessionStorage.setItem('tab','nav-pn');
              e.preventDefault();
              getAlert(2);
            }
          break;
          case '#nav-dt':
            $('.buttons1').addClass('d-none');
            sessionStorage.setItem('tab','nav-dt');
            // if($('.grp_ctrl').length!=0){
            // }else{
            //   sessionStorage.setItem('tab','nav-pn');
            //   e.preventDefault();
            //   getAlert(2);
            // }
          break;
        }
    });

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

    $(document).on('click', '#shift_check1', function(parameter){
      filterShiftPreview($(this));
    });

    $(document).on('click', '#shift_check2', function(parameter){
      filterShiftPreview($(this));
    });

    function filterShiftPreview(chkbox){
      var shift = $(chkbox).closest('.form-check').find('label').text().trim();
      console.log(shift);
      if($(chkbox).is(':checked')){
        $('.product-row').each(function(){
          if($(this).data('shift')==shift){
            $(this).removeClass('d-none').find('.include').val(1);
          }
        });
      }else{
        $('.product-row').each(function(){
          if($(this).data('shift')==shift){
            $(this).addClass('d-none').find('.include').val(0);
          }
        });
      }
    }

  });
</script>
</body>

</html>