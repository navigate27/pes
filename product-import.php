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
    <title>Product ST</title>
    <style>

    </style>
</head>

<body>

    <?php
    include 'src/nav.php';
    $accs = $db->getAllAccountOnAccountType(1,0);
    // print_r($accs);
    ?>

<div class="container" id="banner">
  <div class="page-header">
    <div class="row">
      <div class="col-12">
        <h1>Product ST</h1>
      </div>
    </div>
  </div>

  <hr>
  <div class="section">
    <div class="row">
      <div class="col-12">
        <div class="card">
          <div class="card-header">
            <div class="card-link">
              <i class="fa fa-search"></i> Search Engine
              <a class="pull-right" data-toggle="collapse" href="#search-card">
                <i class="fa fa-chevron-down"></i>
              </a>
            </div>
          </div>

          <div id="search-card" class="collapse show"> 
            <div class="card-body">
              <form action=" " id="search-form">
                <div class="row mb-2">
                  <div class="col">
                    <label>Product No.</label>
                    <input type="text" name="pn" class="form-control">
                  </div>
                  <div class="col-4">
                    <label>Last Update</label>
                    <div class="row">
                      <div class="col-6">
                        <input type="text" name="lupdate_from" class="form-control dp-date" onkeydown="return false" id="dp-date" placeholder="From" required autocomplete="off" readonly>
                      </div>
                      <div class="col-6">
                        <input type="text" name="lupdate_to" class="form-control dp-date" onkeydown="return false" id="dp-date" placeholder="To" required autocomplete="off" readonly>
                      </div>
                    </div>
                    <small class="form-text text-muted">
                      <span class="form-check">
                        <input type="checkbox" class="form-check-input" id="lupdate-chk" checked>
                        <label class="form-check-label" for="lupdate-chk">ALL</label>
                      </span>
                    </small>
                  </div>
                  <div class="col">
                    <label>PIC</label>
                    <select name="pic" class="form-control">
                      <option value="">All</option>
                      <?php
                        if($accs){
                          foreach ($accs as $i => $acc) {
                            echo '<option value="'.$acc['ID'].'">'.$acc['name'].'</option>';
                          }
                        }
                      ?>
                    </select>
                  </div>
                  <div class="col">
                    <label>Limit</label>
                    <select name="limit" class="form-control">
                      <option>10</option>
                      <option>100</option>
                      <option>250</option>
                      <option>2000</option>
                      <option value="999999">2000+</option>
                    </select>
                  </div>
                </div>
                <button type="submit" class="d-none" id="btn-search">SEARCH</button>
              </form>
            </div>
          </div>

        </div>
        
      </div>
    </div>
  </div>

  <div class="section mt-4 mb-3">
    <div class="row">
      <div class="col-12">
        <div class="card">
          <div class="card-body">
            <div class="row">
              <div class="alert alert-danger d-none col-12" id="file-validate">
                <strong>Wrong file type!</strong> 
                <span id="file-validate-text"></span>
              </div>
              <div class="alert alert-danger d-none col-12" id="file-validate2">
                <strong>Error Importing!</strong> 
                <span></span>
              </div>
            </div>
            <div id="search-loading" class="text-center mt-4">
              <h3 class="display-5"><i class="fa fa-spinner fa-pulse fa-fw"></i> LOADING...</h3>
            </div>
            <div id="search-result" class="d-none">
              <div class="row mb-2">
                <div class="col-6">
                  <span class="">
                      <a href="format.csv" class="btn btn-primary" download><i class="fa fa-file-excel-o"></i> FORMAT</a>
                  </span>
                </div>
                <div class="col-6">
                  <span class="pull-right">
                      <a class="btn btn-danger text-white" data-target="#modalDeleteAll" data-toggle="modal"><i class="fa fa-trash"></i> Delete All</a>
                      <a class="btn btn-primary btn-add-st text-white"><i class="fa fa-plus"></i> Add</a>
                      <a class="btn btn-success text-white btn-import"><i class="fa fa-upload"></i> Import ST</a>
                      <input type="file" name="csv" class="d-none" accept=".csv">
                  </span>
                </div>
              </div>
              <div class="row" id="stContent">
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="section mt-4 d-none">
    <div class="row">
      <div class="col-12">
        <div class="card">
          <div class="card-body">
            <div class="row ">
              <div class="col-2 text-left">
                <h5><span class="badge badge-warning">&nbsp;&nbsp;&nbsp;</span> No product exist</h5>
              </div>
              <div class="col-1 text-left">
                <h5><span class="badge badge-danger">&nbsp;&nbsp;&nbsp;</span> No ST</h5>
              </div>
              <div class="col-9 text-right">
                <?php
                  if($st){
                    echo '<a class="btn btn-success text-white btn-import2"><i class="fa fa-upload"></i> Import Products</a>';
                  }else{
                    echo '<a class="btn btn-success text-white disabled"><i class="fa fa-upload"></i> Importing Products disabled</a>';
                  }
                ?>
                <input type="file" name="csv2" class="d-none" multiple>
              </div>
            </div>

            <div id="tbl-preview-pn">
              
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


<div class="modal fade" tabindex="-1" role="dialog" id="modalDeletePN">
  <div class="modal-dialog modal-dialog-centered modal-md" role="document">
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
              <strong>The data will not be recovered after deletion.</strong>
            </div>
            <input type="hidden" name="del_st_id">
            <div class="row">
              <div class="col">
                <div class="form-group">
                  <label>Product Number</label>
                  <p class="form-control-static" id="del-pn"></p>
                </div>
              </div>
              <div class="col">
                <div class="form-group">
                  <label>Standard Time</label>
                  <p class="form-control-static" id="del-st"></p>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-danger" name="del-st">Ok, remove it.</button>
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
          </div>
        </form>
      </div>
  </div>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id="modalDeleteAll">
  <div class="modal-dialog modal-dialog-centered modal-md" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Remove All Record</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="alert alert-warning text-center">
            <strong><i class="fa fa-exclamation-triangle"></i></strong> Are you sure you want to <strong>remove</strong> all records?
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

<div class="modal fade" tabindex="-1" role="dialog" id="modalPreviewST" data-keyboard="false" data-backdrop="static">
  <div class="modal-dialog modal-dialog-centered modal-md" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Preview ST</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="row">
            <div class="col-6 text-left">
              <h5><span class="badge badge-warning">&nbsp;&nbsp;&nbsp;</span> Product will be updated</h5>
            </div>
          </div>
          <div class="row">
            <div class="col-6 text-left">
              <h5><span class="badge badge-info">&nbsp;&nbsp;&nbsp;</span> Product will be added</h5>
            </div>
          </div>
          <div class="row">
            <div class="col-6 text-left">
              <h5><span class="badge badge-secondary legend">&nbsp;&nbsp;&nbsp;</span> No action will occur</h5>
            </div>
          </div>
          <div id="tbl-preview-st" style="max-height: 410px; overflow-y: auto"></div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-import-st">Import</button>
          <button type="button" class="btn btn-primary btn-loading-st disabled d-none">Importing...</button>
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
            <i class="fa fa-spinner fa-pulse fa-2x"></i> Please wait, converting file...
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

<!-- SCRIPT -->
<?php
      include 'src/script.php';
?>

<script>
  $(document).ready(function(){
    var ST = [];
    var PN = [];
    var safe = [];
    var errors = [];
    var errorST = 0;

    $(document).on('click', '#lupdate-chk', function(){
      if($(this).is(':checked')){
        $('input[name="lupdate_from"]').attr('readonly', true).val('');
        $('input[name="lupdate_to"]').attr('readonly', true).val('');
      }else{
        $('input[name="lupdate_from"]').attr('readonly', false).val(moment().format('YYYY/MM/DD'));
        $('input[name="lupdate_to"]').attr('readonly', false).val(moment().format('YYYY/MM/DD'));
      }

      $("#btn-search").click();
    });
    $(document).on('keyup', 'input[name="pn"]', function(){
      $("#btn-search").click();
    });

    $(document).on('change', 'select[name="limit"]', function(){
      $("#btn-search").click();
    });

    $(document).on('change', 'select[name="pic"]', function(){
      $("#btn-search").click();
    });

    $(document).on('submit', '#search-form', function(e){
      e.preventDefault();
      var form = $(this).serialize();
      getData(form);
    });

    function getData(form){
      $("#search-result").addClass("d-none");
      $("#search-loading").removeClass("d-none");
      $.post('src/stContent.php',{
        form: form
      }, function(page){
        console.log(page);
        $("#stContent").html(page);
        $("#tbl-st").DataTable({
          searching: false,
          info: false,      
          scrollY: "280px",
          scrollCollapse: true,
          paging: false,
        });

        $("#search-result").removeClass("d-none");
        $("#search-loading").addClass("d-none");
      });
    }

    $("#btn-search").click();

    $(".dp-date").datetimepicker({
      format: 'YYYY/MM/DD'
    }).on('dp.change', function(e){
      $("#btn-search").click();
    });

    $(document).on('click', '.btn-add-st', function(){
      PopupCenter('add-st.php','Add ST',600, 400);
    });

    $(document).on('click', '.edit-st', function(){
      var id = $(this).closest('tr').data('id');
      PopupCenter('edit-st.php?id='+id,'Edit ST',600, 400);
    });

    $('.btn-import').click(function(){
      $('input[name="csv"]').click();
      ST = [];
    });

    $('input[name="csv"]').change(function(evt){
        
        var files = evt.target.files;
        var f = files[0];
        if(isCSV(f.name)){
          parseFile(f);
          $('#modalImportProgress').modal('show');
        }

        $('input[name="csv"]').val('');
        
    });

    function parseFile(f){
      var rowCount = 0;
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
                if(rowCount>0){
                  rows.push(results.data);
                  ST.push(results.data);
                  console.log(rowCount);
                  console.log("Row data:", results.data);
                  console.log("Row errors:", results.errors);
                }
                rowCount++;
              },
              complete: function(results) {
                console.log("Parsing complete:", rows);
                  // console.log('ST: ');
                  // console.log(ST);
                  previewST();
                  // saveST();

              }
            });
          };
        })(f);

        reader.readAsText(f);
    }

    function previewST(){
      $('#modalImportProgress').modal('hide');
      $("#modalPreviewST").modal('show');
      $.post('src/previewSTForm.php',{
        'ST': ST
      }, function(page){
        console.log(page);
        $("#tbl-preview-st").html(page);
      });
    }

    $(document).on('click', '.btn-import-st', function(parameter){
      $(this).addClass('d-none');
      $('.btn-loading-st').removeClass('d-none');
      saveST();
    });

    function saveST(){
      var STError = false;
      for (var j = 0; j < ST.length; j++) {
        if(ST[j][0][0] == ''){
          STError = true;
          break;
        }
      }

      if(STError){
        console.log('ERROR');
        $("#file-validate2").removeClass("d-none");
        var text = 'Empty product number on file ';
        $("#file-validate2 span").html(text);
        $("#modalPreviewST").modal('hide');
        ST = [];
      }else{
        $('#modalLoadingProgress').modal('show');
        console.log('SAVE ME');
        $.post('functions/save/save.php',{
          st: ST
        }, function(response){
          console.log(response);
          if(response==true){
            console.log('success');
            
            console.log('done all');
            getAlert(1);
            location.reload();
          }
          ST = [];
        });
      }
      
    }

    $('.btn-import2').click(function(){
      $('input[name="csv2"]').click();
      PN = [];
    });

    $('input[name="csv2"]').change(function(evt){
        
      var files = evt.target.files;
      for (var i = 0; i < files.length; i++) {
        var f = files[i];
        if(isCSV(f.name)){
          safe.push(f.name);
          parseFile2(f,i,files.length);
        }else{
          errors.push(f.name);
        }
      }

      safe = [];
      errors = [];
      $('input[name="csv2"]').val('');
      
    });

    function parseFile2(f,i,fileLength){
      var rowCount = 0;
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
                if(rowCount>0){
                  rows.push(results.data);
                  PN.push(results.data);
                  console.log(rowCount);
                  console.log("Row data:", results.data);
                  console.log("Row errors:", results.errors);
                }
                rowCount++;
              },
              complete: function(results) {
                console.log("Parsing complete:", rows);
                  previewPN();
              }
            });
          };
        })(f);

        reader.readAsText(f);
    }

    function previewPN(){
      $.post('src/previewPNForm.php',{
        'PN': PN
      }, function(page){
        console.log(page);
        $("#tbl-preview-pn").html(page);
        scrollToDiv("#tbl-preview-pn");
      });
    }

    $(document).on('click', '#savePn', function(){

      $.post('functions/save/save.php',{
        pn: PN
      }, function(response){
        console.log(response);
        if(response==true){
          console.log('done all');
          getAlert(1);
          location.reload();
        }
        PN = [];
      });

    });

    $(document).on('click', '.btn-delete-all', function(){
      $.post('functions/delete/delete.php',{
          'delete-st': 'st'
        }, function(response){
          console.log(response);
          if(response==true){
            location.reload();
          }
        });
    });

    $(document).on('click', '.delete-st', function(){
      var id = $(this).closest('tr').data('id');
      var pn = $(this).closest('tr').data('pn');
      var st = $(this).closest('tr').data('st');

      $('input[name="del_st_id"]').val(id);
      $('#del-pn').html(pn);
      $('#del-st').html(st);
    });

  });
</script>
</body>

</html>