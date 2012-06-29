<?php 
require_once ("utils.php");
require_once ("update.php");
require_once( "Procedure.php" );

function rsyncupdate($action, $revision) {

  /*if (!(function_exists("ssh2_connect"))) {
   
   cecho("PECL module SSH2 required\n", "red", "bold");
   exit();
   }*/

  $currentDir = dirname(__FILE__);
  
  announce_script("Mediboard SVN updater and rsyncer");
  
  if ($revision === "") {
  
    $revision = "HEAD";
  }
  
  // Choose the target revision
  switch ($action) {
  
    case "info":
    
      update("info", $revision);
      break;
      
    case "real":
    
      update("real", $revision);
      break;
  }
  
  // File must exists (touch doesn't override)
  touch("rsyncupdate.exclude");
  
  if ($action != "info") {
  
    // Rsyncing -- Parsing rsyncupdate.conf
    $lines = file($currentDir."/rsyncupdate.conf");
    
    foreach ($lines as $line_num=>$line) {
    
      // Skip comment lines and empty lines
      if ((trim(substr($line, 0, 1)) != "#") && (trim(substr($line, 0, 1)) != "")) {
      
        $line = trim($line);
        
        echo "Do you want to update ".$line." (y or n) [default n] ? ";
        $answer = trim(fgets(STDIN));
        
        if ($answer === "y") {
          echo "-- Rsync ".$line." --\n";
          
          $usernamePOS = strpos($line, "@");
          
          if ($usernamePOS) {
          
            $hostnamePOS = strpos($line, ":", $usernamePOS);
            
            if ($hostnamePOS) {
            
              $username = substr($line, 0, $usernamePOS);
              $hostname = substr($line, $usernamePOS + 1, $hostnamePOS - ($usernamePOS + 1));
            }
          }
          
          if ($usernamePOS == false) {
          
            // Local folder
            $dirName = $line;
            
            $rsync = shell_exec("rsync -avpz --stats ".$currentDir."/.. --delete ".$line." --exclude-from=".$currentDir."/rsyncupdate.exclude --exclude includes/config_overload.php --exclude tmp --exclude lib --exclude files --exclude includes/config.php --exclude images/pictures/logo_custom.png");
            
            echo $rsync."\n";
            
            check_errs($rsync, NULL, "Failed to rsync ".$line, "Successfully rsync-ed ".$line);
            
            // Test for same files
            if (realpath($currentDir."/../tmp/svnlog.txt") != realpath($dirName."/tmp/svnlog.txt")) {
            
              copy($currentDir."/../tmp/svnlog.txt", $dirName."/tmp/svnlog.txt");
            }
            
            // Test for same files
            if (realpath($currentDir."/../tmp/svnstatus.txt") != realpath($dirName."/tmp/svnstatus.txt")) {
            
              copy($currentDir."/../tmp/svnstatus.txt", $dirName."/tmp/svnstatus.txt");
            }
          } else {
          
            $dirName = substr($line, $hostnamePOS + 1);
            
            $rsync = shell_exec("rsync -avpz --stats ".$currentDir."/.. --delete ".$line." --exclude-from=".$currentDir."/rsyncupdate.exclude --exclude includes/config_overload.php --exclude tmp --exclude lib --exclude files --exclude includes/config.php --exclude images/pictures/logo_custom.png");
            
            echo $rsync."\n";
            
            check_errs($rsync, NULL, "Failed to rsync ".$line, "Successfully rsync-ed ".$line);
            
            $scp = shell_exec("scp ".$currentDir."/../tmp/svnlog.txt ".$line."/tmp/svnlog.txt");
            $scp = shell_exec("scp ".$currentDir."/../tmp/svnstatus.txt ".$line."/tmp/svnstatus.txt");
          }
        }

        
      }
    }
  }
}

function rsyncUpdateProcedure( $backMenu ) {
  $procedure = new Procedure();
  
  echo "Action to perform:\n\n";
  echo "[1] Show the update log\n";
  echo "[2] Perform the actual update\n";
  echo "[3] No update, only rsync\n";
  echo "--------------------------------\n";
  
  $choice = "0";
  $procedure->showReturnChoice( $choice );
  
  $qt_action = $procedure->createQuestion("\nSelected action: " );
  $action = $procedure->askQuestion( $qt_action );
  
  switch ( $action ) {
    case "1":
      $action = "info";
      break;
      
    case "2":
      $action = "real";
      break;
      
    case "3":
      $action = "noup";
      break;
      
    case $choice:
      $procedure->clearScreen();
      $procedure->showMenu( $backMenu, true );
      
    default:
      $procedure->clearScreen();
      cecho( "Incorrect input", "red" );
      echo "\n";
      setupProcedure( $backMenu );
  }
  
  $qt_revision = $procedure->createQuestion("\nRevision number [default HEAD]: ", "HEAD");
  $revision = $procedure->askQuestion( $qt_revision );
  
  echo "\n";
  rsyncupdate( $action, $revision );
}

function rsyncupdateCall( $command, $argv ) {
  if (count($argv) == 2) {
    $action   = $argv[0];
    $revision = $argv[1];
    
    rsyncupdate($action, $revision);
    return 0;
  }
  else {
    echo "\nUsage : $command rsyncupdate <action> [<revision>]\n
<action>      : action to perform: info|real|noup
  info        : shows the update log, no rsync
  real        : performs the actual update and the rsync
  noup        : no update, only rsync\n
Option:
[<revision>]  : revision number you want to update to, default HEAD\n\n";        
    return 1;
  }
}
?>
