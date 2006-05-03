<?php /* $Id: vw_full_code.php,v 1.10 2006/04/21 16:56:38 mytto Exp $ */

/**
* @package Mediboard
* @subpackage dPcim10
* @version $Revision: 1.10 $
* @author Romain Ollivier
*/

global $AppUI, $canRead, $canEdit, $m;

if (!$canRead) {
	$AppUI->redirect( "m=system&a=access_denied" );
}

require_once($AppUI->getModuleClass("dPcim10", "codecim10"));

$lang = mbGetValueFromGetOrSession("lang", LANG_FR);

$code = mbGetValueFromGetOrSession("code", "(A00-B99)");
$cim10 = new CCodeCIM10($code);
$cim10->load($lang);
$cim10->loadRefs();

// Cr�ation du template
require_once( $AppUI->getSystemClass ('smartydp' ) );
$smarty = new CSmartyDP;

$smarty->assign('lang', $lang);
$smarty->assign('cim10', $cim10);

$smarty->display('vw_full_code.tpl');

?>