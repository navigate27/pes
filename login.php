<?php
    include 'db/config.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <?php
        include 'src/link.php';
    ?>
    <title>First Process Efficiency System</title>
    <style>
    </style>
</head>
<body>
    <br><br><br><br><br>
<div class="container">
    <div class="row">
    	<div class ="col-md-4 offset-md-4">
    		<div class="card border-primary">
                <div class="card-header text-white bg-primary">
                    LOGIN
                </div>
			  	<div class="card-body">
                    <?php
                        include 'src/alert.php';
                    ?>
                    <img src="img/eff_logo.png" class="rounded mx-auto d-block" width="128" height="128">
                    <span class="col-12">
                        <h4 class="text-center"><strong>First Process<br>Efficiency System</strong></h4>
                    </span>
                    <div class="col-12">
                        <form accept-charset="UTF-8" role="form" method="post" action="functions/login/login.php" id="form-login">
                        <fieldset>
                            <div class="form-group">
                                <input class="form-control" placeholder="Username" name="username" type="text" required autofocus>
                            </div>
                            <div class="form-group">
                                <input class="form-control" placeholder="Password" name="password" type="password" required>
                            </div>
                            <input class="btn btn-primary btn-block" type="submit" name="login" value="Login">
                        </fieldset>
                        </form>
                    </div>
			    </div>
			</div>
		</div>
	</div>
    
    <?php
        include 'src/footer.php';
    ?>
    
</div>
<?php
    include 'src/script.php';
?>

<script>
    sessionStorage.clear();
</script>

</body>
</html>
