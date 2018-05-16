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

require 'phpspreadsheet/vendor/autoload.php';
include 'db/config.php';

// $yr = $_GET['yr'];
// $yr = $_GET['month'];
// $stype = $_GET['summary_type'];
// $shift = $_GET['shift'];

$filename = "excel-format/format-28.xlsx";

// $reader = new \PhpOffice\PhpSpreadsheet\Reader\Xlsx();
// $spreadsheet = $reader->load($filename);
$spreadsheet = \PhpOffice\PhpSpreadsheet\IOFactory::load($filename);
$sheet = $spreadsheet->getActiveSheet();
$sheet->setCellValue("C31",'100');

$writer = new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet);
$writer->save($filename);