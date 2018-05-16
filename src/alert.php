<div class="col-md-12">
	<?php
		if(isset($_GET['alert'])){
			$alert = $_GET['alert'];

			switch ($alert) {
				case '1':
					echo '
					<div class="alert alert-danger alert-dismissable">
					  <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
					  <strong>Failed!</strong> Unknown user.
					</div>
					';
					break;
				
				default:
					# code...
					break;
			}
		}
	?>
</div>