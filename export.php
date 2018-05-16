<?php

//1-based
//ex: 1 = A
function getColFromNum($num) {
    $numeric = ($num - 1) % 26;
    $letter = chr(65 + $numeric);
    $num2 = intval(($num - 1) / 26);
    if ($num2 > 0) {
        return getColFromNum($num2) . $letter;
    } else {
        return $letter;
    }
}

function setCol1($arr, $style, $val){
	if(count($arr)!=0||$arr){
		global $sheet, $spreadsheet;
		$mergeCells = $arr[0].":".$arr[count($arr)-1];
		$sheet->setCellValue($arr[0], $val);
		$spreadsheet->getActiveSheet()->mergeCells($mergeCells);
		$sheet->getStyle($mergeCells)->applyFromArray($style);
	}
}

require 'phpspreadsheet/vendor/autoload.php';

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Alignment;

include 'db/config.php';

$dn = date('m.d');
$filename = "exports/DOWNTIME $dn.xlsx";

$batch_id = $_GET['batch_id'];

$batch = $db->getBatchIDonID($batch_id);
$dt = $db->getAllDowntimeOnBatchID($batch_id);
$dt_total = $db->getTotalDowntimeTimeOnBatchID($batch_id);

$spreadsheet = new Spreadsheet();
$output = array();

$sheet = $spreadsheet->getActiveSheet();
$spreadsheet->getDefaultStyle()->getFont()->setName('Calibri');
$spreadsheet->getDefaultStyle()->getFont()->setSize(10);

$offRow = 5;

$underline = array(
    'borders' => array(
        'bottom' => array(
            'borderStyle' => Border::BORDER_THIN,
            'color' => array('argb' => 'black'),
        ),
    ),
    'alignment' => array(
        'horizontal' => Alignment::HORIZONTAL_CENTER,
    )
);

$sheet->setCellValue("B".$offRow, 'Date');
$spreadsheet->getActiveSheet()->mergeCells("C".$offRow.":D".$offRow);
$sheet->setCellValue("C".$offRow, $batch['date']);
$sheet->getStyle("C".$offRow.":D".$offRow)->applyFromArray($underline);

$sheet->setCellValue("G".$offRow, 'PIC');
$spreadsheet->getActiveSheet()->mergeCells("H".$offRow.":J".$offRow);
$sheet->setCellValue("H".$offRow, $batch['name']);
$sheet->getStyle("H".$offRow.":J".$offRow)->applyFromArray($underline);

$sheet->setCellValue("L".$offRow, 'Cutting Start Time');
$spreadsheet->getActiveSheet()->mergeCells("M".$offRow.":N".$offRow);
$sheet->setCellValue("M".$offRow, $db->dateParse($batch['cutting_start_time'],'time12'));
$sheet->getStyle("M".$offRow.":N".$offRow)->applyFromArray($underline);

$offRow += 1;

$sheet->setCellValue("B".$offRow, 'Car Model');
$spreadsheet->getActiveSheet()->mergeCells("C".$offRow.":D".$offRow);
$sheet->setCellValue("C".$offRow, $batch['car_model_name']);
$sheet->getStyle("C".$offRow.":D".$offRow)->applyFromArray($underline);

$sheet->setCellValue("G".$offRow, 'Cutting Plan');
$spreadsheet->getActiveSheet()->mergeCells("H".$offRow.":J".$offRow);
$sheet->setCellValue("H".$offRow, $batch['cutting_plan']);
$sheet->getStyle("H".$offRow.":J".$offRow)->applyFromArray($underline);

$sheet->setCellValue("L".$offRow, 'Cutting End Time');
$spreadsheet->getActiveSheet()->mergeCells("M".$offRow.":N".$offRow);
$sheet->setCellValue("M".$offRow, $db->dateParse($batch['cutting_end_time'],'time12'));
$sheet->getStyle("M".$offRow.":N".$offRow)->applyFromArray($underline);

$offRow += 1;

$sheet->setCellValue("B".$offRow, 'Group and Shift');
$spreadsheet->getActiveSheet()->mergeCells("C".$offRow.":D".$offRow);
$sheet->setCellValue("C".$offRow, $batch['shift']);
$sheet->getStyle("C".$offRow.":D".$offRow)->applyFromArray($underline);

$offRow += 3;

$headers = array(
	array(
		"merge" => "B".$offRow.":D".($offRow+2),
		"cell" => "B".$offRow."",
		"value" => "REASON/CAUSE",
		"size" => 16,
		"mergeBool" => true
	),
	array(
		"merge" => "E".$offRow.":H".$offRow,
		"cell" => "E".$offRow."",
		"value" => "PART CODE",
		"size" => 13,
		"mergeBool" => true
	),
	array(
		"merge" => "E".($offRow+1).":F".($offRow+2),
		"cell" => "E".($offRow+1),
		"value" => "WIRE",
		"size" => 42,
		"mergeBool" => true
	),
	array(
		"merge" => "G".($offRow+1).":H".($offRow+1),
		"cell" => "G".($offRow+1),
		"value" => "TERMINAL",
		"size" => 13,
		"mergeBool" => true
	),
	array(
		"merge" => "G".($offRow+2),
		"cell" => "G".($offRow+2),
		"value" => "F SIDE",
		"size" => 35,
		"mergeBool" => false
	),
	array(
		"merge" => "H".($offRow+2),
		"cell" => "H".($offRow+2),
		"value" => "R SIDE",
		"size" => 15,
		"mergeBool" => false
	),
	array(
		"merge" => "I".$offRow.":J".($offRow+2),
		"cell" => "I".$offRow,
		"value" => "PIC",
		"size" => 15,
		"mergeBool" => true
	),
	array(
		"merge" => "K".$offRow.":K".($offRow+2),
		"cell" => "K".$offRow,
		"value" => "PROCESS",
		"size" => 15,
		"mergeBool" => true
	),
	array(
		"merge" => "L".$offRow.":M".($offRow+2),
		"cell" => "L".$offRow,
		"value" => "DIMENSION (mm/pc)",
		"size" => 34,
		"mergeBool" => true
	),
	array(
		"merge" => "N".$offRow.":P".($offRow+1),
		"cell" => "N".$offRow,
		"value" => "TIME (mins)",
		"size" => 18,
		"mergeBool" => true
	),
	array(
		"merge" => "N".($offRow+2),
		"cell" => "N".($offRow+2),
		"value" => "START",
		"size" => 18,
		"mergeBool" => false
	),
	array(
		"merge" => "O".($offRow+2),
		"cell" => "O".($offRow+2),
		"value" => "END",
		"size" => 18,
		"mergeBool" => false
	),
	array(
		"merge" => "P".($offRow+2),
		"cell" => "P".($offRow+2),
		"value" => "TOTAL",
		"size" => 18,
		"mergeBool" => false
	),
	array(
		"merge" => "Q".$offRow.":T".$offRow,
		"cell" => "Q".$offRow,
		"value" => "MANPOWER",
		"size" => 18,
		"mergeBool" => true
	),
	array(
		"merge" => "Q".$offRow.":T".$offRow,
		"cell" => "Q".$offRow,
		"value" => "MANPOWER",
		"size" => 18,
		"mergeBool" => true
	),
	array(
		"merge" => "Q".($offRow+1).":T".($offRow+1),
		"cell" => "Q".($offRow+1),
		"value" => "Note",
		"size" => 18,
		"mergeBool" => true
	),
	array(
		"merge" => "Q".($offRow+2).":R".($offRow+2),
		"cell" => "Q".($offRow+2),
		"value" => "RANK 1 to 2",
		"size" => 18,
		"mergeBool" => true
	),
	array(
		"merge" => "S".($offRow+2).":T".($offRow+2),
		"cell" => "S".($offRow+2),
		"value" => "RANK 3 and Above",
		"size" => 18,
		"mergeBool" => true
	),
);

$headerStyle = array(
    'borders' => array(
        'outline' => array(
            'borderStyle' => Border::BORDER_THIN,
            'color' => array('argb' => 'black'),
        ),
    ),
    'fill' => array(
        // 'fillType' => Fill::FILL_SOLID,
        // 'color' => array('argb' => "FFD5D8DC"),
    ),
    'alignment' => array(
        'vertical' => Alignment::VERTICAL_CENTER,
        'horizontal' => Alignment::HORIZONTAL_CENTER,
    )
);


foreach ($headers as $i => $header) {
	$mergeLet = $header['merge'];
	$cellLet = $header['cell'];
	$cellValue = $header['value'];
	$cellSize = $header['size'];
	$mergeBool = $header['mergeBool'];
	if($mergeBool===true){
		$spreadsheet->getActiveSheet()->mergeCells($mergeLet);
	}
	$sheet->setCellValue($cellLet, $cellValue);
	$sheet->getStyle($mergeLet)->applyFromArray($headerStyle);
	// $spreadsheet->getActiveSheet()->getColumnDimension($cellLet)->setWidth($cellSize);
}

$offRow += 3;

$contentStyle = array(
    'borders' => array(
        'outline' => array(
            'borderStyle' => Border::BORDER_DOTTED,
            'color' => array('argb' => 'black'),
        ),
    ),
    'alignment' => array(
        'vertical' => Alignment::VERTICAL_CENTER,
        'horizontal' => Alignment::HORIZONTAL_CENTER,
    )
);

if($dt){
	foreach ($dt as $i => $d) {

		$cell = "B".$offRow.":D".$offRow; //REASON
		$spreadsheet->getActiveSheet()->mergeCells($cell);
		$sheet->setCellValue("B".$offRow, $d['reason']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "E".$offRow.":F".$offRow; //WIRE
		$spreadsheet->getActiveSheet()->mergeCells($cell);
		$sheet->setCellValue("E".$offRow, $d['part_wire']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "G".$offRow; //F SIDE
		$sheet->setCellValue($cell, $d['part_term_front']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "H".$offRow; //F SIDE
		$sheet->setCellValue($cell, $d['part_term_rear']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "I".$offRow.":J".$offRow; //PIC
		$spreadsheet->getActiveSheet()->mergeCells($cell);
		$sheet->setCellValue("I".$offRow, $d['name']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "K".$offRow; //PROCESS
		$sheet->setCellValue($cell, $d['process_detail_name']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "L".$offRow.":M".$offRow; //DIMENSION
		$spreadsheet->getActiveSheet()->mergeCells($cell);
		$sheet->setCellValue("L".$offRow, $d['dimension']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "N".$offRow; //START
		$sheet->setCellValue($cell, $db->dateParse($d['time_start'],'time12')); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "O".$offRow; //END
		$sheet->setCellValue($cell, $db->dateParse($d['time_end'],'time12')); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "P".$offRow; //TOTAL
		$sheet->setCellValue($cell, $d['time_total']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "Q".$offRow.":R".$offRow; //RANK 1 to 2
		$spreadsheet->getActiveSheet()->mergeCells($cell);
		$sheet->setCellValue("Q".$offRow, $d['mp_r1']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);

		$cell = "S".$offRow.":T".$offRow; //RANK 3 and above
		$spreadsheet->getActiveSheet()->mergeCells($cell);
		$sheet->setCellValue("S".$offRow, $d['mp_r3']); 
		$sheet->getStyle($cell)->applyFromArray($contentStyle);
		$offRow += 1;
	}
	//footer
	$cell = "B".$offRow.":D".$offRow; //REASON
	$spreadsheet->getActiveSheet()->mergeCells($cell);
	$sheet->setCellValue("B".$offRow, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "E".$offRow.":F".$offRow; //WIRE
	$spreadsheet->getActiveSheet()->mergeCells($cell);
	$sheet->setCellValue("E".$offRow, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "G".$offRow; //F SIDE
	$sheet->setCellValue($cell, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "H".$offRow; //F SIDE
	$sheet->setCellValue($cell, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "I".$offRow.":J".$offRow; //PIC
	$spreadsheet->getActiveSheet()->mergeCells($cell);
	$sheet->setCellValue("I".$offRow, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "K".$offRow; //PROCESS
	$sheet->setCellValue($cell, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "L".$offRow.":M".$offRow; //DIMENSION
	$spreadsheet->getActiveSheet()->mergeCells($cell);
	$sheet->setCellValue("L".$offRow, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "N".$offRow; //START
	$sheet->setCellValue($cell, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "O".$offRow; //END
	$sheet->setCellValue($cell, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "P".$offRow; //TOTAL
	$sheet->setCellValue($cell, $dt_total); 
	$spreadsheet->getActiveSheet()->getStyle($cell)->getFont()->setBold( true );
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "Q".$offRow.":R".$offRow; //RANK 1 to 2
	$spreadsheet->getActiveSheet()->mergeCells($cell);
	$sheet->setCellValue("Q".$offRow, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);

	$cell = "S".$offRow.":T".$offRow; //RANK 3 and above
	$spreadsheet->getActiveSheet()->mergeCells($cell);
	$sheet->setCellValue("S".$offRow, ''); 
	$sheet->getStyle($cell)->applyFromArray($contentStyle);


}

// $dates = $db->getDateRangeSchedule();
// $hours = $db->getHour();

// $dateHeader = array();
// $hourHeader = array();
// $col = 10;
// $row = 4;
// foreach ($dates as $index=>$date) {
// 	// $dateHeader = array(
// 	// 	"cell" => 
// 	// );
// 	// array_push($dateHeader, $date['date_sched']);
// 	// array_push($dateHeader, '');
// 	// array_push($dateHeader, '');
// 	$mergeCellsArr = array();
// 	foreach ($hours as $hour) {
// 		$col += 1;
// 		array_push($mergeCellsArr, getColFromNum($col));
// 		array_push($hourHeader, array(
// 				"cell" => getColFromNum($col),
// 				"value" => $hour['hour_name'],
// 				"size" => 22
// 			)
// 		);

// 	}
// 	$mergeCells = $mergeCellsArr[0]."3:".$mergeCellsArr[count($mergeCellsArr)-1]."3";
// 	$spreadsheet->getActiveSheet()->mergeCells($mergeCells);
// 	$sheet->setCellValue($mergeCellsArr[0]."3", $db->dateParse($date['date_sched'], 'word'));
// 	$spreadsheet->getActiveSheet()->getColumnDimension($mergeCellsArr[0]."3")
// 	        ->setAutoSize(true);
// 	$sheet->getStyle($mergeCells)->applyFromArray($headerStyle);

// }

// foreach ($hourHeader as $index=>$h) {
// 	$cellLet = $h['cell'];
// 	$cellValue = $h['value'];
// 	$cellSize = $h['size'];
// 	$sheet->setCellValue(($cellLet."4"), $cellValue);
// 	$sheet->getStyle($cellLet."4")->applyFromArray($headerStyle);
// 	$spreadsheet->getActiveSheet()->getColumnDimension($cellLet)->setWidth($cellSize);
// }

// $col = 10;
// //SET LEFT SIDE INFO
// $genscheds = $db->getGenSchedAllGroupByRnumber('Z');
// $colStyle = array(
// 	'borders' => array(
//         'outline' => array(
//             'borderStyle' => Border::BORDER_THIN,
//             'color' => array('argb' => 'black'),
//         ),
//     ),
//     'alignment' => array(
//         'horizontal' => Alignment::HORIZONTAL_CENTER,
//         'vertical' => Alignment::VERTICAL_CENTER,
//     )
// );
// $defaultStyle = array(
//     'borders' => array(
//         'left' => array(
//             'borderStyle' => Border::BORDER_THIN,
//             'color' => array('argb' => 'black'),
//         ),
//         'right' => array(
//             'borderStyle' => Border::BORDER_THIN,
//             'color' => array('argb' => 'black'),
//         ),
//         'top' => array(
//             'borderStyle' => Border::BORDER_NONE,
//             'color' => array('argb' => 'black'),
//         ),
//         'bottom' => array(
//             'borderStyle' => Border::BORDER_DOTTED,
//             'color' => array('argb' => 'black'),
//         ),
//     ),
//     'alignment' => array(
//         'horizontal' => Alignment::HORIZONTAL_CENTER,
//     )
// );
// if($genscheds){
// 	foreach ($genscheds as $gensched) {
// 		$rnumber = $gensched['R_NUMBER'];

// 		$gs = $db->getGenSchedByRnumber($rnumber);
// 		$rnumber_mergeCells_arr = array();
// 		if($gs){
// 			foreach ($gs as $index => $g) {

// 				$gid = $g['ID'];
// 				$std_id = $g['standard_id'];
// 				$stdroles = $db->getStandardRolesID($std_id);
// 				$car_mergeCells_arr = array();
// 				$model_mergeCells_arr = array();
// 				$content_mergeCells_arr = array();
// 				$progress_mergeCells_arr = array();
// 				$dd_mergeCells_arr = array();
// 				$present_mergeCells_arr = array();
// 				$gua_mergeCells_arr = array();
// 				$info_mergeCells_arr = array();

// 				if($g['shift']!='hybrid'){
// 					if($stdroles){
// 						foreach ($stdroles as $index => $role) {
// 							$row += 1;
// 							$roleStyle = array(
// 							    'borders' => array(
// 							        'left' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'right' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'top' => array(
// 							            'borderStyle' => Border::BORDER_DOTTED,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'bottom' => array(
// 							            'borderStyle' => Border::BORDER_DOTTED,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							    ),
// 							    'fill' => array(
// 							        'fillType' => Fill::FILL_SOLID,
// 							        'color' => array('argb' => "FF".str_replace("#","",$role['color_code'])),
// 							    ),
// 							    'alignment' => array(
// 							        'horizontal' => Alignment::HORIZONTAL_CENTER,
// 							        'vertical' => Alignment::VERTICAL_CENTER,
// 							    )
// 							);

// 							$shift_short = 'DS';
// 							if($g['shift']=='night'){
// 								$shift_short = 'NS';
// 							}
// 							$sheet->setCellValue(("J".$row), $role['role_name']."($shift_short)");
// 							if($g['shift']=='night'){
// 								$spreadsheet->getActiveSheet()->getStyle(("J".$row))->getFont()->setBold( true );
// 							}
// 							$sheet->getStyle("J".$row)->applyFromArray($roleStyle);
// 							array_push($rnumber_mergeCells_arr, "A".$row);
// 							array_push($car_mergeCells_arr, "B".$row);
// 							array_push($model_mergeCells_arr, "C".$row);
// 							array_push($content_mergeCells_arr, "D".$row);
// 							array_push($progress_mergeCells_arr, "E".$row);
// 							array_push($dd_mergeCells_arr, "F".$row);
// 							array_push($present_mergeCells_arr, "G".$row);
// 							array_push($gua_mergeCells_arr, "H".$row);
// 							array_push($info_mergeCells_arr, "I".$row);

// 							//K
// 							$col = 10;
// 							foreach ($dates as $index=>$date) {
// 								foreach ($hours as $hour) {
// 									$col += 1;
// 									$coor = getColFromNum($col)."".$row;
// 									$isFound = false;
// 									$scheds = $db->getFalpStandardSchedule002($gid, $date['date_sched']);
// 									$xsched = array();
// 									if($scheds){
// 										foreach ($scheds as $sched) {
// 										  if(($sched['hour_id']==$hour['ID'])&&($sched['date_sched']==$date['date_sched'])&&$sched['role_id']==$role['role_id']){
// 										    if($sched['roles_sched_shift']==$g['shift']){
// 										      $isFound = true;                                
// 										      array_push($xsched, $sched);
// 										    }
// 										  }
// 										}

// 										if($isFound){
// 										  // if(isset($date['date_sched'])){
// 										  //   $temp_date = $dates['date_sched'];
// 										  // }else{
// 										  //   $temp_date = 'null';
// 										  // }

// 										  if(count($xsched)==1){
// 										  	$sheet->setCellValue($coor, $xsched[0]['action']."".$xsched[0]['nickname']);
// 										  	$sheet->getStyle($coor)->applyFromArray($roleStyle);
// 										  }else{
// 										  	$_x = array();
// 										  	foreach ($xsched as $index => $x) {
// 										  		array_push($_x, $x['action']."".$x['nickname']);
// 										  	}
// 										  	$x = implode('\n', $_x);
// 										    // $spreadsheet->getCell($coor)->setValue($x);
// 										    $sheet->setCellValue($coor, $x);
// 										    $spreadsheet->getActiveSheet()->getStyle($coor)->getAlignment()->setWrapText(true);
// 										    $sheet->getStyle($coor)->applyFromArray($roleStyle);
// 										  }
// 										}else{
// 										    $sheet->setCellValue($coor, '');
// 										    $sheet->getStyle($coor)->applyFromArray($defaultStyle);
// 										}
// 									}else{
// 										$sheet->setCellValue($coor, '');
// 										$sheet->getStyle($coor)->applyFromArray($defaultStyle);
// 									}
// 									$xsched = array();

// 								}

// 							}
// 						}
// 					}
// 					$row += 1;
// 					$col = 10;
// 					foreach ($dates as $index=>$date) {
// 						foreach ($hours as $hour) {
// 							$col += 1;
// 							$coor = getColFromNum($col)."".$row;
// 							$roleStyle = array(
// 							    'borders' => array(
// 							        'left' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'right' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'top' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'bottom' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							    ),
// 							    'alignment' => array(
// 							        'horizontal' => Alignment::HORIZONTAL_CENTER,
// 							    )
// 							);

// 							$sheet->setCellValue(("J".$row), 'OTHER');
// 							$sheet->getStyle("J".$row)->applyFromArray($roleStyle);
// 							$spreadsheet->getActiveSheet()->getRowDimension("J".$row)->setRowHeight(18);
// 							$sheet->setCellValue($coor, '');
// 							$sheet->getStyle($coor)->applyFromArray($defaultStyle);
// 							array_push($rnumber_mergeCells_arr, "A".$row);
// 							array_push($car_mergeCells_arr, "B".$row);
// 							array_push($model_mergeCells_arr, "C".$row);
// 							array_push($content_mergeCells_arr, "D".$row);
// 							array_push($progress_mergeCells_arr, "E".$row);
// 							array_push($dd_mergeCells_arr, "F".$row);
// 							array_push($present_mergeCells_arr, "G".$row);
// 							array_push($gua_mergeCells_arr, "H".$row);
// 							array_push($info_mergeCells_arr, "I".$row);

// 							setCol1($car_mergeCells_arr, $colStyle, $g['C_TYPE']);
// 							setCol1($model_mergeCells_arr, $colStyle, $g['M_NAME']);
// 							setCol1($content_mergeCells_arr, $colStyle, $g['T_KUBUN']);
// 							setCol1($progress_mergeCells_arr, $colStyle, $g['SIN_INFO']);
// 							setCol1($dd_mergeCells_arr, $colStyle, $db->dateParse($g['P_TENKAI'], 'word-trim'));
// 							setCol1($present_mergeCells_arr, $colStyle, $db->dateParse($g['P_GENKO'], 'word-trim'));
// 							setCol1($gua_mergeCells_arr, $colStyle, $db->dateParse($g['P_HOSYOU'], 'word-trim'));
// 							setCol1($info_mergeCells_arr, $colStyle, '');
// 						}
// 					}
// 				}else{
// 					if($stdroles){
// 						foreach ($stdroles as $index => $role) {
// 							$row += 1;
// 							$roleStyle = array(
// 							    'borders' => array(
// 							        'left' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'right' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'top' => array(
// 							            'borderStyle' => Border::BORDER_DOTTED,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'bottom' => array(
// 							            'borderStyle' => Border::BORDER_DOTTED,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							    ),
// 							    'fill' => array(
// 							        'fillType' => Fill::FILL_SOLID,
// 							        'color' => array('argb' => "FF".str_replace("#","",$role['color_code'])),
// 							    ),
// 							    'alignment' => array(
// 							        'horizontal' => Alignment::HORIZONTAL_CENTER,
// 							    )
// 							);

// 							$sheet->setCellValue(("J".$row), $role['role_name']."(DS)");
// 							$sheet->getStyle("J".$row)->applyFromArray($roleStyle);
// 							array_push($rnumber_mergeCells_arr, "A".$row);
// 							array_push($car_mergeCells_arr, "B".$row);
// 							array_push($model_mergeCells_arr, "C".$row);
// 							array_push($content_mergeCells_arr, "D".$row);
// 							array_push($progress_mergeCells_arr, "E".$row);
// 							array_push($dd_mergeCells_arr, "F".$row);
// 							array_push($present_mergeCells_arr, "G".$row);
// 							array_push($gua_mergeCells_arr, "H".$row);
// 							array_push($info_mergeCells_arr, "I".$row);

// 							//K
// 							$col = 10;
// 							foreach ($dates as $index=>$date) {
// 								foreach ($hours as $hour) {
// 									$col += 1;
// 									$coor = getColFromNum($col)."".$row;
// 									$isFound = false;
// 									$scheds = $db->getFalpStandardSchedule002($gid, $date['date_sched']);
// 									$xsched = array();
// 									$defaultStyle = array(
// 									    'borders' => array(
// 									        'left' => array(
// 									            'borderStyle' => Border::BORDER_THIN,
// 									            'color' => array('argb' => 'black'),
// 									        ),
// 									        'right' => array(
// 									            'borderStyle' => Border::BORDER_THIN,
// 									            'color' => array('argb' => 'black'),
// 									        ),
// 									        'top' => array(
// 									            'borderStyle' => Border::BORDER_NONE,
// 									            'color' => array('argb' => 'black'),
// 									        ),
// 									        'bottom' => array(
// 									            'borderStyle' => Border::BORDER_DOTTED,
// 									            'color' => array('argb' => 'black'),
// 									        ),
// 									    ),
// 									    'alignment' => array(
// 									        'horizontal' => Alignment::HORIZONTAL_CENTER,
// 									    )
// 									);
// 									if($scheds){
// 										foreach ($scheds as $sched) {
// 										  if(($sched['hour_id']==$hour['ID'])&&($sched['date_sched']==$date['date_sched'])&&$sched['role_id']==$role['role_id']){
// 										    if($sched['roles_sched_shift']=='day'){
// 										      $isFound = true;                                
// 										      array_push($xsched, $sched);
// 										    }
// 										  }
// 										}

// 										if($isFound){
// 										  // if(isset($date['date_sched'])){
// 										  //   $temp_date = $dates['date_sched'];
// 										  // }else{
// 										  //   $temp_date = 'null';
// 										  // }

// 										  if(count($xsched)==1){
// 										  	$sheet->setCellValue($coor, $xsched[0]['action']."".$xsched[0]['nickname']);
// 										  	$sheet->getStyle($coor)->applyFromArray($roleStyle);
// 										  }else{
// 										    $_x = array();
// 										  	foreach ($xsched as $index => $x) {
// 										  		array_push($_x, $x['action']."".$x['nickname']);
// 										  	}
// 										  	$x = implode('/', $_x);
// 										    $sheet->setCellValue($coor, $x);
// 										    $sheet->getStyle($coor)->applyFromArray($roleStyle);
// 										  }
// 										}else{
// 										    $sheet->setCellValue($coor, '');
// 										    $sheet->getStyle($coor)->applyFromArray($defaultStyle);
// 										}
// 									}else{
// 										$sheet->setCellValue($coor, '');
// 										$sheet->getStyle($coor)->applyFromArray($defaultStyle);
// 									}
// 									$xsched = array();

// 								}

// 							}
// 						}
// 					}
// 					if($stdroles){
// 						foreach ($stdroles as $index => $role) {
// 							$row += 1;
// 							$roleStyle = array(
// 							    'borders' => array(
// 							        'left' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'right' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'top' => array(
// 							            'borderStyle' => Border::BORDER_DOTTED,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'bottom' => array(
// 							            'borderStyle' => Border::BORDER_DOTTED,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							    ),
// 							    'fill' => array(
// 							        'fillType' => Fill::FILL_SOLID,
// 							        'color' => array('argb' => "FF".str_replace("#","",$role['color_code'])),
// 							    ),
// 							    'alignment' => array(
// 							        'horizontal' => Alignment::HORIZONTAL_CENTER,
// 							    )
// 							);


// 							$sheet->setCellValue(("J".$row), $role['role_name']."(NS)");
// 							$spreadsheet->getActiveSheet()->getStyle(("J".$row))->getFont()->setBold( true );
// 							$sheet->getStyle("J".$row)->applyFromArray($roleStyle);
// 							array_push($rnumber_mergeCells_arr, "A".$row);
// 							array_push($car_mergeCells_arr, "B".$row);
// 							array_push($model_mergeCells_arr, "C".$row);
// 							array_push($content_mergeCells_arr, "D".$row);
// 							array_push($progress_mergeCells_arr, "E".$row);
// 							array_push($dd_mergeCells_arr, "F".$row);
// 							array_push($present_mergeCells_arr, "G".$row);
// 							array_push($gua_mergeCells_arr, "H".$row);
// 							array_push($info_mergeCells_arr, "I".$row);

// 							//K
// 							$col = 10;
// 							foreach ($dates as $index=>$date) {
// 								foreach ($hours as $hour) {
// 									$col += 1;
// 									$coor = getColFromNum($col)."".$row;
// 									$isFound = false;
// 									$scheds = $db->getFalpStandardSchedule002($gid, $date['date_sched']);
// 									$xsched = array();
// 									$defaultStyle = array(
// 									    'borders' => array(
// 									        'left' => array(
// 									            'borderStyle' => Border::BORDER_THIN,
// 									            'color' => array('argb' => 'black'),
// 									        ),
// 									        'right' => array(
// 									            'borderStyle' => Border::BORDER_THIN,
// 									            'color' => array('argb' => 'black'),
// 									        ),
// 									        'top' => array(
// 									            'borderStyle' => Border::BORDER_NONE,
// 									            'color' => array('argb' => 'black'),
// 									        ),
// 									        'bottom' => array(
// 									            'borderStyle' => Border::BORDER_DOTTED,
// 									            'color' => array('argb' => 'black'),
// 									        ),
// 									    ),
// 									    'alignment' => array(
// 									        'horizontal' => Alignment::HORIZONTAL_CENTER,
// 									    )
// 									);
// 									if($scheds){
// 										foreach ($scheds as $sched) {
// 										  if(($sched['hour_id']==$hour['ID'])&&($sched['date_sched']==$date['date_sched'])&&$sched['role_id']==$role['role_id']){
// 										    if($sched['roles_sched_shift']=='night'){
// 										      $isFound = true;                                
// 										      array_push($xsched, $sched);
// 										    }
// 										  }
// 										}

// 										if($isFound){
// 										  // if(isset($date['date_sched'])){
// 										  //   $temp_date = $dates['date_sched'];
// 										  // }else{
// 										  //   $temp_date = 'null';
// 										  // }

// 										  if(count($xsched)==1){
// 										  	$sheet->setCellValue($coor, $xsched[0]['action']."".$xsched[0]['nickname']);
// 										  	$sheet->getStyle($coor)->applyFromArray($roleStyle);
// 										  }else{
// 										    $_x = array();
// 										  	foreach ($xsched as $index => $x) {
// 										  		array_push($_x, $x['action']."".$x['nickname']);
// 										  	}
// 										  	$x = implode('/', $_x);
// 										    $sheet->setCellValue($coor, $x);
// 										    $sheet->getStyle($coor)->applyFromArray($roleStyle);
// 										  }
// 										}else{
// 										    $sheet->setCellValue($coor, '');
// 										    $sheet->getStyle($coor)->applyFromArray($defaultStyle);
// 										}
// 									}else{
// 										$sheet->setCellValue($coor, '');
// 										$sheet->getStyle($coor)->applyFromArray($defaultStyle);
// 									}
// 									$xsched = array();

// 								}

// 							}
// 						}
// 					}
// 					$row += 1;
// 					$col = 10;
// 					foreach ($dates as $index=>$date) {
// 						foreach ($hours as $hour) {
// 							$col += 1;
// 							$coor = getColFromNum($col)."".$row;
// 							$roleStyle = array(
// 							    'borders' => array(
// 							        'left' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'right' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'top' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							        'bottom' => array(
// 							            'borderStyle' => Border::BORDER_THIN,
// 							            'color' => array('argb' => 'black'),
// 							        ),
// 							    ),
// 							    'alignment' => array(
// 							        'horizontal' => Alignment::HORIZONTAL_CENTER,
// 							    )
// 							);

// 							$sheet->setCellValue(("J".$row), 'OTHER');
// 							$sheet->getStyle("J".$row)->applyFromArray($roleStyle);
// 							$sheet->setCellValue($coor, '');
// 							$sheet->getStyle($coor)->applyFromArray($defaultStyle);
// 							array_push($rnumber_mergeCells_arr, "A".$row);
// 							array_push($car_mergeCells_arr, "B".$row);
// 							array_push($model_mergeCells_arr, "C".$row);
// 							array_push($content_mergeCells_arr, "D".$row);
// 							array_push($progress_mergeCells_arr, "E".$row);
// 							array_push($dd_mergeCells_arr, "F".$row);
// 							array_push($present_mergeCells_arr, "G".$row);
// 							array_push($gua_mergeCells_arr, "H".$row);
// 							array_push($info_mergeCells_arr, "I".$row);

// 							setCol1($car_mergeCells_arr, $colStyle, $g['C_TYPE']);
// 							setCol1($model_mergeCells_arr, $colStyle, $g['M_NAME']);
// 							setCol1($content_mergeCells_arr, $colStyle, $g['T_KUBUN']);
// 							setCol1($progress_mergeCells_arr, $colStyle, $g['SIN_INFO']);
// 							setCol1($dd_mergeCells_arr, $colStyle, $db->dateParse($g['P_TENKAI'], 'word-trim'));
// 							setCol1($present_mergeCells_arr, $colStyle, $db->dateParse($g['P_GENKO'], 'word-trim'));
// 							setCol1($gua_mergeCells_arr, $colStyle, $db->dateParse($g['P_HOSYOU'], 'word-trim'));
// 							setCol1($info_mergeCells_arr, $colStyle, '');
// 						}
// 					}
// 				}

// 			}
// 		}

// 		setCol1($rnumber_mergeCells_arr, $colStyle, $g['R_NUMBER']);

// 	}
// }

// $spreadsheet->getActiveSheet()->freezePane('K'.$row);

// print_r($hourHeader);
$writer = new Xlsx($spreadsheet);
$writer->save($filename);
header("location: ".$filename);