<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPpmsi
* @version $Revision$
* @author Romain Ollivier
*/

global $AppUI, $can, $m;

$can->needsAdmin();

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->display("configure.tpl");

?>