<?php /* $Id: $ */

/**
* @package Mediboard
* @version $Revision: $
* @author Thomas Despoix
*/

$dPconfig = array();

if (!is_file("./includes/config.php")) {
  header("location: install/");
  die("Redirection vers l'assistant d'installation");
}

require_once("./classes/ui.class.php");
require_once("./classes/chrono.class.php");

$phpChrono = new Chronometer;
$phpChrono->start();

require_once("./includes/config.php");

// Check that the user has correctly set the root directory
is_file( "{$dPconfig['root_dir']}/includes/config.php" ) 
  or die( "ERREUR FATALE: le repertoire racine est probablement mal configuré" );

require_once("./includes/main_functions.php");
require_once("./includes/errors.php");

// PHP Configuration
ini_set("memory_limit", "64M");

// manage the session variable(s)
session_name( 'dotproject' );
if (get_cfg_var( 'session.auto_start' ) > 0) {
	session_write_close();
}
session_start();
session_register( 'AppUI' ); 
  
// write the HTML headers
header ("Expires: Mon, 26 Jul 1997 05:00:00 GMT");	// Date in the past
header ("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");	// always modified
header ("Cache-Control: no-cache, must-revalidate");	// HTTP/1.1
header ("Pragma: no-cache");	// HTTP/1.0

// check if session has previously been initialised
if (!isset( $_SESSION['AppUI'] ) || isset($_GET['logout'])) {
    $_SESSION['AppUI'] = new CAppUI();
}

$AppUI =& $_SESSION['AppUI'];
$AppUI->setConfig( $dPconfig );
$AppUI->checkStyle();
 
// load the commonly used classes
require_once( $AppUI->getSystemClass('date'));
require_once( $AppUI->getSystemClass('dp'));

// load the db handler
require_once( "./includes/db_connect.php" );

// load default preferences if not logged in
if ($AppUI->doLogin()) {
    $AppUI->loadPrefs(0);
}

// check if the user is trying to log in
if (isset($_POST['login'])) {
	$username = dPgetParam( $_POST, 'username', '' );
	$password = dPgetParam( $_POST, 'password', '' );
	$redirect = dPgetParam( $_REQUEST, 'redirect', '' );
	$ok = $AppUI->login( $username, $password );
	if (!$ok) {
		@include_once( "./locales/core.php" );
		$AppUI->setMsg("Login Failed", UI_MSG_ERROR);
	}
	$AppUI->redirect( "$redirect" );
}


// Get the user preference
$uistyle = $AppUI->getPref('UISTYLE');

// clear out main url parameters
$m = '';
$a = '';
$u = '';

// check if we are logged in
if ($AppUI->doLogin()) {
    $AppUI->setUserLocale();
	// load basic locale settings
	@include_once( "./locales/$AppUI->user_locale/locales.php" );
	@include_once( "./locales/core.php" );
	setlocale( LC_TIME, $AppUI->user_locale );

	$redirect = @$_SERVER['QUERY_STRING'];
	if (strpos( $redirect, 'logout' ) !== false) {
		$redirect = '';
	}

	if (isset( $locale_char_set )) {
		header("Content-type: text/html;charset=$locale_char_set");
	}

	require "./style/$uistyle/login.php";
	// destroy the current session and output login page
	session_unset();
	session_destroy();
	exit;
}

// bring in the rest of the support and localisation files
require_once( "./includes/permissions.php" );


// set the module and action from the url
$m = $AppUI->checkFileName(dPgetParam( $_GET, 'm', getReadableModule() ));
$a = $AppUI->checkFileName(dPgetParam( $_GET, 'a', 'index' ));
$u = $AppUI->checkFileName(dPgetParam( $_GET, 'u', '' ));

// load module based locale settings
@include_once( "./locales/$AppUI->user_locale/locales.php" );
@include_once( "./locales/core.php" );

$user_locale = $AppUI->user_locale;
if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
    // This is a server using Windows, locales screwed up, not ISO standard 
    switch ($user_locale) {
    	case "es":
    		$user_locale = "sp";
    		break;
    }
} 	

setlocale( LC_TIME, $user_locale );

// check overall module permissions
// these can be further modified by the included action files
$canRead = isMbModuleVisible($m) and isMbModuleReadAll($m);
$canEdit = isMbModuleVisible($m) and isMbModuleEditAll($m);
$canAuthor = $canEdit;
$canDelete = $canEdit;

// Don't output anything. Usefull for fileviewers, popup dialogs, ajax requests, etc.
$suppressHeaders = dPgetParam( $_GET, 'suppressHeaders');

// Output the charset header in cas of an ajax request
$ajax = dPgetParam( $_GET, 'ajax', false);
 
if (!$suppressHeaders || $ajax) {
	// output the character set header
	if (isset( $locale_char_set )) {
		header("Content-type: text/html;charset=$locale_char_set");
	}
}

// include the module class file
@include_once( $AppUI->getModuleClass( $m ) );
@include_once( "./modules/$m/" . ($u ? "$u/" : "") . "$u.class.php" );

// do some db work if dosql is set
if (isset( $_REQUEST["dosql"]) ) {
    $mDo = isset( $_REQUEST["m"]) ? $_REQUEST["m"] : $m;
    //require("./dosql/" . $_REQUEST["dosql"] . ".php");
    require ("./modules/$mDo/" . $AppUI->checkFileName($_REQUEST["dosql"]) . ".php");
}

// start output proper
include "./style/$uistyle/overrides.php";

ob_start();

if(!$suppressHeaders) {
 require "./style/$uistyle/header.php";
}

require "./modules/$m/" . ($u ? "$u/" : "") . "$a.php";

$phpChrono->stop();

if(!$suppressHeaders) {
 require "./style/$uistyle/footer.php";
}
ob_end_flush();
?>
