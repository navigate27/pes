<?php
  if($_SESSION['login_data']['type'] == 1){
    $nav = "navbar-dark bg-primary";
    $home = 'product-import.php';
  }else if($_SESSION['login_data']['type'] == 2){
    $nav = "navbar-dark bg-success";
    $home = 'manpower.php';
  }else if($_SESSION['login_data']['type'] == 3){
    $nav = "navbar-light bg-light";
    $home = 'summary.php';
  }else if($_SESSION['login_data']['type'] == 4){
    $nav = "navbar-dark bg-danger";
    $home = 'summary.php';
  }else if($_SESSION['login_data']['type'] == 5){
    $nav = "navbar-dark bg-dark";
    $home = 'manpower.php';
  }

?>
<nav class="navbar navbar-expand-lg <?php echo $nav; ?>">
  <div class="container">
    <a class="navbar-brand" href="<?php echo $home; ?>">First Process Efficiency System</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavAltMarkup" aria-controls="navbarNavAltMarkup" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNavAltMarkup">
      <div class="navbar-nav mr-auto">
        <li class="nav-item">
          <a href="<?php echo $home; ?>" class="nav-link">Home</a>
        </li>
        <?php
          if($_SESSION['login_data']['type'] == 2 || $_SESSION['login_data']['type'] == 3){
        ?>
          <!-- <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-toggle="dropdown" aria-haspopup="true">
              Maintenance
            </a>
            <div class="dropdown-menu">
              <a class="dropdown-item" data-list="list-rsn" href="maintenance.php">Dowtinme Reason</a>
              <a class="dropdown-item" data-list="list-pic" href="maintenance.php">PIC List</a>
              <div class="dropdown-divider"></div>
              <a class="dropdown-item" href="account-list.php">Account List</a>
            </div>
          </li> -->
          <li class="nav-item">
            <a href="maintenance.php" class="nav-link">Maintenance</a>
          </li>
        <?php
          }

          if($_SESSION['login_data']['type'] == 2 || $_SESSION['login_data']['type'] == 1 || $_SESSION['login_data']['type'] == 3){
        ?>
          <li class="nav-item">
            <a href="account-list.php" class="nav-link">Account List</a>
          </li>
        <?php
          }
        ?>

        <?php
          if($_SESSION['login_data']['type'] != 3){
        ?>
        <li class="nav-item">
          <a href="summary.php" class="nav-link">Summary</a>
        </li>
        <?php
          }
        ?>

        <?php
          if($_SESSION['login_data']['type'] == 1){
        ?>
          <li class="nav-item">
            <a href="help/WI-PC.pdf" class="nav-link" target="_blank">
              <i class="fa fa-question-circle"></i> Help
            </a>
          </li>
        <?php
          }else if($_SESSION['login_data']['type'] == 2 || $_SESSION['login_data']['type'] == 4){
        ?>
          <li class="nav-item">
            <a href="help/WI-PD.pdf" class="nav-link" target="_blank">
              <i class="fa fa-question-circle"></i> Help
            </a>
          </li>
        <?php
          }else if($_SESSION['login_data']['type'] == 3){
        ?>
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-toggle="dropdown" aria-haspopup="true">
              Help
            </a>
            <div class="dropdown-menu">
              <a class="dropdown-item" href="help/WI-PD.pdf" target="_blank">Production</a>
              <a class="dropdown-item" href="help/WI-PC.pdf" target="_blank">Production Control</a>
            </div>
          </li>
        <?php
          }
        ?>

      </div>
      <div class="navbar-nav">
        <li class="nav-item">
          <a href="javascript:void(0)" class="nav-link">
            <?php echo $_SESSION['login_data']['name']; ?>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="functions/login/logout.php">
            <i class="fa fa-power-off"></i> Log Out
          </a>
        </li>
      </div>
    </div>
  </div>
</nav>