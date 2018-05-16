
<?php

$dbName = "eff_db";
// error_reporting(E_ERROR | E_PARSE);
// $conn = new PDO("odbc:Driver={Microsoft Access Driver (*.mdb, *.accdb)};Dbq=".$dir.";Uid=;Pwd=;");
$conn = new PDO('mysql:host=localhost;dbname='.$dbName, 'root', '');
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
// ini_set("max_execution_time", 300);
// ini_set("memory_limit","1024M"); //MB
// ini_set("max_input_vars",1000000000);
ini_set("display_errors","On");
ini_set("html_errors","Off");
// ini_set("post_max_size","1024M"); //MB
// ini_set("upload_max_filesize","100M"); //MB
// ini_set("max_file_uploads","20"); //qty
// ini_set("session.gc_maxlifetime","1440"); //secs

include 'class.db.php';

$db = new DB($conn);


