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
    <title>Summary</title>

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
    ?>

<div class="col-12" id="banner">

  <div class="section mb-3">
    <div class="row">
      <div class="col-12">
        <div class="card">
            <div class="card-header">
              <div class="card-link">
                <i class="fa fa-search"></i> Filter Summary
                <a class="pull-right" data-toggle="collapse" href="#batchInfo">
                  <i class="fa fa-chevron-down"></i>
                </a>
              </div>
            </div>
            <div id="batchInfo" class="collapse show">
              <div class="card-body">
                <form action="src/summaryContent.php" id="search-form">
                  <div class="row mb-2">
                    <input type="hidden" value="1" name="account_id">
                    <input type="hidden" value="1" name="process_id">
                    <div class="col">
                      <label>Summary Type</label>
                      <select name="summary_type" class="form-control">
                        <optgroup label="480 break">
                          <option value="line_wobreak">Line Efficiency 480</option>
                          <option value="acctg_wobreak">Accounting Efficiency 480</option>
                        </optgroup>
                        <optgroup label="450 break">
                          <option value="line_wbreak">Line Efficiency 450</option>
                          <option value="acctg_wbreak">Accounting Efficiency 450</option>
                        </optgroup>
                      </select>
                    </div>
                    <div class="col-2">
                      <label>Car Model</label>
                      <select name="car_model_id" class="form-control">
                        <?php
                          if($cms){
                            //echo '<option value="0">All</option>';
                            foreach ($cms as $i => $cm) {
                              echo '<option value="'.$cm['ID'].'">'.$cm['car_model_name'].'</option>';
                            }
                          }
                        ?>
                      </select>
                    </div>
                    <div class="col-2">
                      <label>Group</label>
                      <select name="group_id" class="form-control">
                        <?php
                          if($grp){
                            foreach ($grp as $i => $gr) {
                              echo '<option value="'.$gr['ID'].'">'.$gr['group_name'].'</option>';
                            }
                          }
                        ?>
                      </select>
                    </div>
                    <div class="col">
                      <label>Start Date</label>
                      <input type="text" name="date_start" class="form-control dp-date" onkeydown="return false" placeholder="Date" required value="<?php echo date('Y-m-\01'); ?>" autocomplete="off">
                    </div>
                    <div class="col">
                      <label>End Date</label>
                      <input type="text" name="date_end" class="form-control dp-date" onkeydown="return false" placeholder="Date" required value="<?php $d=cal_days_in_month(CAL_GREGORIAN,date('n'),date('Y')); echo date('Y-m-'.$d); ?>" autocomplete="off">
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
    <div class="col-12 text-right">
      <a href="javascript:void(0)" class="btn btn-success btn-print d-none"><i class="fa fa-print"></i> Print</a>
    </div>
    <div class="col-12" style="overflow: auto;" id="canvas-container">
      <canvas id="canvas" height="25"></canvas>
    </div>
    <div class="row">
      <div class="col-12" id="summaryContent"></div>
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

<script>

    function getReportGraph(){
      var dt = $("#dt").val();
      var dt_arr = dt.split(',');
      var actual_eff = $("#actual_eff").val();
      var actual_eff_arr = actual_eff.split(',');
      var target_eff = $("#target_eff").val();
      var target_eff_arr = target_eff.split(',');
      var report_title = $("#report_title").val();
      $('#canvas').remove();
      $('#canvas-container').html('<canvas id="canvas" ></canvas>');

      var ctx = document.getElementById("canvas").getContext("2d");
      
      var barChartData = {
        labels : dt_arr,
        datasets : [
          {
            label: 'Target',
            borderColor : "rgb(255, 0, 0)",
            borderWidth: 2,
            backgroundColor: "rgba(255, 0, 0, 0)", 
            // fill: false,
            pointStyle: 'triangle',
            hoverborderColor : "rgb(255, 0, 0)",
            data : target_eff_arr,
            type: 'line',
          },
          {
            label: 'Actual',
            backgroundColor: "rgb(0, 191, 255)",
            hoverBackgroundColor: "rgba(0, 191, 255, 0.8)",
            data : actual_eff_arr
          },

        ]

      }

      var barChart = new Chart(ctx, {
        type: 'bar',
        data: barChartData,
        options: {
          legend: {
              position: 'bottom',
          },
          title: {
              display: true,
              text: report_title
          },
          scales: {
              yAxes: [
              {
                ticks: {
                  min: 0,
                  // max: 100,
                  stepSize: 20,
                  callback: function(value, index, values){
                    return value + '%';
                  }
                }
              }
            ]
          },
          plugins: {
            datalabels: {
              anchor: 'end',
              align: 'top',
              offset: 5,
              backgroundColor: function(context) {
                console.log(context);
                if(context.datasetIndex==0){ //line
                  return 'rgb(255, 0, 0)';
                }else{ //bar
                  return 'rgb(0, 128, 255)';
                }
                // return context.dataset.backgroundColor;
              },
              formatter: function(value, context){
                return value + '%';
              },
              borderRadius: 4,
              color: 'white',
              font: {
                weight: 'bold',
                size: '9'
              },
            }
          },
        },

      });

      // ctx.height = 300;

    }

    $('.dp-date').datetimepicker({
      format: 'YYYY-MM-DD'
    });

    $('#search-form').submit(function(e){
      e.preventDefault();

      sessionStorage.setItem("s_stype",$('select[name="summary_type"]').val());
      sessionStorage.setItem("s_grp",$('select[name="group_id"]').val());
      sessionStorage.setItem("s_cm",$('select[name="car_model_id"]').val());
      sessionStorage.setItem("s_date_start",$('input[name="date_start"]').val());
      sessionStorage.setItem("s_date_end",$('input[name="date_end"]').val());

      var form = $(this).serialize();
      var link = $(this).attr('action');
      $.post(link,{
        form: form
      }, function(page){
        console.log(page);
        $('#summaryContent').html(page);
        getReportGraph();
        scrollToDiv("#canvas-container");
        $('.d-none').removeClass('d-none');
      });
    });

    //init here
    if(sessionStorage.getItem("s_stype")!==null){
      $('select[name="summary_type"] option[value="'+sessionStorage.getItem("s_stype")+'"]').prop('selected',true);
    }

    if(sessionStorage.getItem("s_cm")!==null){
      $('select[name="car_model_id"] option[value="'+sessionStorage.getItem("s_cm")+'"]').prop('selected',true);
    }

    if(sessionStorage.getItem("s_grp")!==null){
      $('select[name="group_id"] option[value="'+sessionStorage.getItem("s_grp")+'"]').prop('selected',true);
    }

    if(sessionStorage.getItem("s_date_start")!==null){
      $('input[name="date_start"]').val(sessionStorage.getItem("s_date_start"));
    }

    if(sessionStorage.getItem("s_date_end")!==null){
      $('input[name="date_end"]').val(sessionStorage.getItem("s_date_end"));
    }

    $('#search-form').submit();

    $('.btn-print').click(function(){
      var stype = $('select[name="summary_type"]').val();
      var group_id = $('select[name="group_id"]').val();
      var date_start = $('input[name="date_start"]').val();
      var date_end = $('input[name="date_end"]').val();
      var car_model_id = $('select[name="car_model_id"]').val();
      var url = 'print-report.php?summary_type='+stype+'&group_id='+group_id+'&date_start='+date_start+'&date_end='+date_end+'&car_model_id='+car_model_id;
      PopupCenter(url, 'Print Report', 1200, 700) //PopupCenter('link.html', 'title', '970', '600');

    });
    
</script>
</body>

</html>