<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPcabinet
* @version $Revision$
* @author S�bastien Fillonneau
*/

global $AppUI, $can, $m;
  
$can->needsEdit();

$selConsult  = CValue::getOrSession("selConsult", 0);

$consult = new CConsultation();
$consult->load($selConsult);
$consult->loadRefsBack();

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("consult", $consult);

$smarty->display("exam_comp.tpl");
?>