<?php
	include '../db/config.php';

	parse_str($_POST['form'], $p);
	$req = array(
		"pn" => $p['pn'],
		"lupdate_from" => $p['lupdate_from'],
		"lupdate_to" => $p['lupdate_to'],
		"pic" => $p['pic'],
		"limit" => $p['limit'],
	);
	$st = $db->getSTOnQuery($req);

?>	

  <table class="table table-bordered table-hover mt-2" id="tbl-st">
    <thead class="thead-light">
      <tr>
        <th>#</th>
        <th>Product Number</th>
        <th>Standard Time <span class="small text-muted">(st)</span></th>
        <th>Last Update</th>
        <th>PIC</th>
        <th class="w-14"></th>
      </tr>
    </thead>
    <tbody>
      <?php
        if($st){
          foreach ($st as $i => $s) {
            echo '
            <tr data-pn="'.$s['product_no'].'" data-st="'.$s['st'].'" data-id="'.$s['ID'].'">
              <td>'.($i+1).'</td>
              <td>'.$s['product_no'].'</td>
              <td>'.$s['st'].'</td>
              <td>'.$db->dateParse($s['last_update'],'word-trim').' '.$db->dateParse($s['last_update'],'time12').'</td>
              <td>'.$s['name'].'</td>
              <td>
                <a class="btn btn-primary edit-st text-white">
                  <i class="fa fa-pencil"></i>
                  Edit
                </a>
                <a class="btn btn-danger delete-st text-white" data-toggle="modal" data-target="#modalDeletePN">
                  <i class="fa fa-trash"></i>
                </a>
              </td>
            </tr>
            ';
          }
        }
      ?>
    </tbody>
  </table>