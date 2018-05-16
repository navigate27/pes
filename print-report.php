<?php
	include 'db/config.php';
	$stype = $_GET['summary_type'];
	$group_id = $_GET['group_id'];
	$start = $_GET['date_start'];
	$end = $_GET['date_end'];
	$car_model_id = $_GET['car_model_id'];

	$req = array(
		"process_id" => 1,
		"date_start" => $start,
		"date_end" => $end,
		"car_model_id" => $car_model_id,
		"group_id" => $group_id
	);

	$dt = $db->getDates($start,$end);
	$actual_eff_1 = array();
	$actual_eff_2 = array();
	$actual_eff = array();
	$target_eff = array();
	$report_title = $db->getCarModelID($car_model_id)['car_model_name'];
	$report_title .= ' First Process';

	if($group_id!='all'){
		$pn = $db->getReportPN($req);
		$trg = $db->getReportTarget($req);
		switch ($stype) {
			case 'line_wobreak':
				$wt = $db->getReportWT480Line($req);
				$mp = $db->getReportMPLine($req);
				$type_string = "Line";
				$type_string2 = "480";
				$report_title .= " 480 Line";
			break;
			case 'acctg_wobreak':
				$wt = $db->getReportWT480Acctg($req);
				$mp = $db->getReportMPAcctg($req);
				$type_string = "Accounting";
				$type_string2 = "480";
				$report_title .= " 450 Accounting";
			break;
			case 'line_wbreak':
				$wt = $db->getReportWT450Line($req);
				$mp = $db->getReportMPLine($req);
				$type_string = "Line";
				$type_string2 = "450";
				$report_title .= " 450 Line";
			break;
			case 'acctg_wbreak':
				$wt = $db->getReportWT450Acctg($req);
				$mp = $db->getReportMPAcctg($req);
				$type_string = "Accounting";
				$type_string2 = "450";
				$report_title .= " 450 Efficiency";
			break;
			
			default:
				# code...
			break;
		}

		$report_title .= " Efficiency";

	}

?>

<!DOCTYPE html>
<html>
<?php
  include 'src/link.php';
?>
<style>
	@media print{@page {size: landscape}}
</style>
<body class="body-print">
<div class="col-12" style="overflow: auto;" id="canvas-container-print">
  <canvas id="canvas" height="100"></canvas>
</div>
<div class="">
	<div class="">
		<table class="table-report">
			<thead>
				<tr>
					<th>Activitiy</th>
					<?php
						foreach ($dt as $i => $d) {
							echo '<th nowrap>'.$db->dateParse($d,'word-trim').'</th>';
						}
					?>
				</tr>
			</thead>	
			<tbody>
				<tr>
					<td nowrap>Daily Plan <span class="small text-muted">(qty)</span></td>
					<?php
						foreach ($dt as $i => $d) {
							if($pn){
								$isFound = false;
								$data = "";
								foreach ($pn as $j => $output) {
									if($d==$output['date']){
										$isFound = true;
										$data = $output;
									}
								}

								if($isFound){
									echo '<td>'.$data['output_qty_total'].'</td>';
								}else{
									echo '<td></td>';
								}
								$data = "";
							}else{
								echo '<td></td>';
							}
						}
					?>
				</tr>
				<tr>
					<td nowrap>Output x ST <span class="small text-muted">(mins)</span></td>
					<?php
						foreach ($dt as $i => $d) {
							if($pn){
								$isFound = false;
								$data = "";
								$output_mm_total = 0;
								foreach ($pn as $j => $output) {
									if($d==$output['date']){
										$isFound = true;
										$data = $output;
									}
								}

								if($isFound){
									$output_mm_total = $data['output_mm_total'];
									echo '<td>'.round($output_mm_total,2).'</td>';
								}else{
									echo '<td></td>';
								}
								array_push($actual_eff_1, $output_mm_total);
								$data = "";
								
							}else{
								echo '<td></td>';
							}
						}
					?>
				</tr>
				<tr>
					<td>Actual MP</td>
					<?php
						foreach ($dt as $i => $d) {
							if($mp){
								$isFound = false;
								$data = "";
								foreach ($mp as $j => $output) {
									if($d==$output['date']){
										$isFound = true;
										$data = $output;
									}
								}

								if($isFound){
									echo '<td>'.$data['actual_total'].'</td>';
								}else{
									echo '<td></td>';
								}
								$data = "";
								
							}else{
								echo '<td></td>';
							}
						}
					?>
				</tr>
				<tr>
					<td>Support MP</td>
					<?php
						foreach ($dt as $i => $d) {
							if($mp){
								$isFound = false;
								$data = "";
								foreach ($mp as $j => $output) {
									if($d==$output['date']){
										$isFound = true;
										$data = $output;
									}
								}

								if($isFound){
									echo '<td>'.$data['support_total'].'</td>';
								}else{
									echo '<td></td>';
								}
								$data = "";
								
							}else{
								echo '<td></td>';
							}
						}
					?>
				</tr>
				<tr>
					<td>OJT</td>
					<?php
						foreach ($dt as $i => $d) {
							if($mp){
								$isFound = false;
								$data = "";
								foreach ($mp as $j => $output) {
									if($d==$output['date']){
										$isFound = true;
										$data = $output;
									}
								}

								if($isFound){
									echo '<td>'.$data['ojt_total'].'</td>';
								}else{
									echo '<td></td>';
								}
								$data = "";
								
							}else{
								echo '<td></td>';
							}
						}
					?>
				</tr>
				<tr>
					<td>Total MP</td>
					<?php
						foreach ($dt as $i => $d) {
							if($mp){
								$isFound = false;
								$data = "";
								foreach ($mp as $j => $output) {
									if($d==$output['date']){
										$isFound = true;
										$data = $output;
									}
								}

								if($isFound){
									echo '<td>'.$data['manpower_total'].'</td>';
								}else{
									echo '<td></td>';
								}
								$data = "";
								
							}else{
								echo '<td></td>';
							}
						}
					?>
				</tr>
				<tr>
					<td>Absent MP</td>
					<?php
						foreach ($dt as $i => $d) {
							if($mp){
								$isFound = false;
								$data = "";
								foreach ($mp as $j => $output) {
									if($d==$output['date']){
										$isFound = true;
										$data = $output;
									}
								}

								if($isFound){
									echo '<td>'.$data['absent_total'].'</td>';
								}else{
									echo '<td></td>';
								}
								$data = "";
								
							}else{
								echo '<td></td>';
							}
						}
					?>
				</tr>
				<tr>
					<td>MP x WT</td>
					<?php
						foreach ($dt as $i => $d) {
							if($wt){
								$isFound = false;
								$data = "";
								$mp_wt = 0;
								foreach ($wt as $j => $output) {
									if($d==$output['date']){
										$isFound = true;
										$data = $output;
									}
								}

								if($isFound){
									$mp_wt = $data['actual_total']*$data['wt_total'];
									echo '<td>'.($mp_wt).'</td>';
								}else{
									echo '<td></td>';
								}

								array_push($actual_eff_2, $mp_wt);
								$data = "";
								
							}else{
								echo '<td></td>';
							}
						}
					?>
				</tr>
				<tr>
					<td nowrap>Target <?php echo $type_string; ?> <br>Efficiency <?php echo $type_string2; ?></td>
					<?php
						foreach ($dt as $i => $d) {
							if($trg){
								$isFound = false;
								$data = "";
								$target = 0;
								foreach ($trg as $j => $tg) {
									if($d==$tg['date']){
										$isFound = true;
										switch ($stype) {
											case 'line_wobreak':
												$data = $tg['target_line_480'];
											break;
											case 'acctg_wobreak':
												$data = $tg['target_acctg_480'];
											break;
											case 'line_wbreak':
												$data = $tg['target_line_450'];
											break;
											case 'acctg_wbreak':
												$data = $tg['target_acctg_450'];
											break;
										}
									}
								}

								if($isFound){
									if($data){
										$target = $data;
										echo '<th>'.$target.'%</th>';
									}else{
										echo '<td></td>';
									}
								}else{
									echo '<td></td>';
								}

								array_push($target_eff, $target);
								$data = "";
								
							}else{
								echo '<td></td>';
							}
						}
					?>
				</tr>
				<tr>
				<td nowrap>Actual <?php echo $type_string; ?> <br>Efficiency <?php echo $type_string2; ?></td>
				<?php
					$dt_format = array();
					foreach ($dt as $i => $d) {
						array_push($dt_format, $db->dateParse($d,'word-trim'));
						if($actual_eff_1&&$actual_eff_2){
							$final_eff = 0;
							$final_eff_graph = 0;
							$final_eff_str = '';
							if(!$actual_eff_2[$i]==0){
								$final_eff = round(($actual_eff_1[$i]/$actual_eff_2[$i])*100,2);
								$final_eff_str = $final_eff.'%';
							}
							$txt_class = '';
							if($final_eff>200){
								$txt_class = 'text-warning';
								$final_eff = 200;
							}
							echo '<th class="'.$txt_class.'">'.$final_eff_str.'</th>';

							array_push($actual_eff, $final_eff);
						}else{
							echo '<td></td>';
						}
					}
				?>
			</tr>
			</tbody>
			<tfoot>
				
			</tfoot>
		</table>
	</div>
</div>
<input type="hidden" id="dt" value="<?php echo implode($dt_format,','); ?>">
<input type="hidden" id="actual_eff" value="<?php echo implode($actual_eff,','); ?>">
<input type="hidden" id="target_eff" value="<?php echo implode($target_eff,','); ?>">
<input type="hidden" id="report_title" value="<?php echo $report_title; ?>">
</body>
<?php
	include 'src/script.php';

	$dt_quotes = "'" .implode("', '", $dt_format) . "'";

?>

<script>
	var report_title = "<?php echo $report_title; ?>";
	var ctx = document.getElementById("canvas").getContext("2d");
	var barChartData = {
	  labels : [<?php echo $dt_quotes; ?>],
	  datasets : [
	    {
	      label: 'Target',
	      borderColor : "rgb(255, 0, 0)",
	      borderWidth: 2,
	      backgroundColor: "rgba(255, 0, 0, 0)", 
	      // fill: false,
	      pointStyle: 'triangle',
	      hoverborderColor : "rgb(255, 0, 0)",
	      data : [<?php echo implode($target_eff,','); ?>],
	      type: 'line',
	    },
	    {
	      label: 'Actual',
	      backgroundColor: "rgb(0, 191, 255)",
	      hoverBackgroundColor: "rgba(0, 191, 255, 0.8)",
	      data : [<?php echo implode($actual_eff,','); ?>]
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
	        align: '-45',
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
	          weight: 'bold'
	        },
	      }
	    },
	  },
	});
	console.log(browserDetect());

	function beforePrint () {
		if(browserDetect()=='chrome'){
		  const id = 0;
		  for (id in Chart.instances) {
		    Chart.instances[id].resize();
		  }
		}else{
		  for (var i = 0; i < Chart.instances.length; i++) {
		  	  Chart.instances[i].resize();
		  }
		}
	}

	if (window.matchMedia) {
		if(browserDetect()=='chrome'){
		  let mediaQueryList = window.matchMedia('print')
		  mediaQueryList.addListener((mql) => {
		    if (mql.matches) {
		      beforePrint();
		    }
		  });
		}else{
		  var mediaQueryList = window.matchMedia('print');
		  mediaQueryList.addListener(function(mql){
		  	  if (mql.matches) {
		  	    beforePrint();
		  	  }
		  });
		}
	}


	window.onbeforeprint = beforePrint();
	window.print();

</script>
</html>