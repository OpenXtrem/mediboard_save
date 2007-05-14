<?php /* $Id: $ */

/**
* @package Mediboard
* @subpackage dPfacturation
* @version $Revision: $
* @author Alexis / Yohann
*/
 
global $AppUI, $can, $m;

$can->needsRead();

$facture_id = mbGetValueFromGetOrSession("facture_id");

// Chargement de la facture demand�
$facture = new CFacture();
$facture->load($facture_id);
$facture->loadRefs();
//$facture->_ref_sejour->loadRefs();

// R�cup�ration de la liste des factures
$itemFacture = new CFacture;
$listFacture = $itemFacture->loadList();
foreach($listFacture as &$curr_facture) {
  $curr_facture->loadRefs();
}

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("facture", $facture);
$smarty->assign("listFacture", $listFacture);
$smarty->display("vw_idx_facture.tpl");
?>
