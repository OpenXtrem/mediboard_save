<?php

include "../modules/system/classes/CHTTPTunnel.class.php";

declare(ticks = 1);
set_time_limit(0);

// CLI or die
PHP_SAPI === "cli" or die;

global $pid_file;

$argv = $_SERVER["argv"];
$argc = $_SERVER["argc"];

if ($argc != 2 || !file_exists($argv[1])) {
  echo <<<EOT
Usage: {$argv[0]} <File_of_configuration>
<fichier_de_configuration> : Contain the parameters for configurate the tunnel
EOT;
  exit(0);
}

if (!$configuration = parse_ini_file($argv[1])) {
  echo "Specified file does not conform for the function 'parse_ini_file'";
  exit(0);
}

$target            = $configuration["TARGET"];
$listen            = $configuration["LISTEN"];
$cert_target       = $configuration["CERT_TARGET"];
$passphrase_target = $configuration["PASSWORD_TARGET"];
$ca_target         = $configuration["CA_TARGET"];
$cert_listen       = $configuration["CERT_LISTEN"];
$passphrase_listen = $configuration["PASSWORD_LISTEN"];
$ca_listen         = $configuration["CA_LISTEN"];

$pid_file = "../tmp/tunnel.pid";
file_put_contents($pid_file, getmypid());

$proxy = new CHTTPTunnel($target, $listen, $cert_listen, $passphrase_listen, $ca_listen);

register_shutdown_function(array($proxy, "onShutdown"));
if (function_exists("pcntl_signal")) {
  pcntl_signal(SIGTERM, array($proxy, "sigHandler"));
  pcntl_signal(SIGINT , array($proxy, "sigHandler")); // Sent when hitting ctrl+c in the cli
  pcntl_signal(SIGHUP , array($proxy, "sigHandler")); // Restart
}

$proxy->setAuthentificationCertificate($cert_target, $passphrase_target, $ca_target);
$proxy->run();