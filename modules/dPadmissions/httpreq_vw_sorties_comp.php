<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPadmissions
* @version $Revision$
* @author Romain Ollivier
*/

global $AppUI, $canRead, $canEdit, $m;

if (!$canRead) {
  $AppUI->redirect( "m=system&a=access_denied" );
}

// Type d'affichage
$vue = mbGetValueFromGetOrSession("vue", 0);

// Récupération des dates
$date = mbGetValueFromGetOrSession("date", mbDate());

$now  = mbDate();

// Récupération des sorties du jour
$list = new CAffectation;
$limit1 = $date." 00:00:00";
$limit2 = $date." 23:59:59";
$ljoin["sejour"] = "sejour.sejour_id = affectation.sejour_id";
$ljoin["lit"] = "lit.lit_id = affectation.lit_id";
$ljoin["chambre"] = "chambre.chambre_id = lit.chambre_id";
$ljoin["service"] = "service.service_id = chambre.service_id";
$ljoin["patients"] = "sejour.patient_id = patients.patient_id";
$where["sortie"] = "BETWEEN '$limit1' AND '$limit2'";
if($vue) {
  $where["effectue"] = "= '0'";
}
$order = "patients.nom, patients.prenom";
$where["type"] = "= 'comp'";
$listComp = $list->loadList($where, $order, null, null, $ljoin);
foreach($listComp as $key => $value) {
  $listComp[$key]->loadRefsFwd();
  if($listComp[$key]->_ref_next->affectation_id) {
    unset($listComp[$key]);
  } else {
    $listComp[$key]->_ref_sejour->loadRefsFwd();
    $listComp[$key]->_ref_lit->loadCompleteView();
  }
}

// Création du template
$smarty = new CSmartyDP(1);
$smarty->assign("date"     , $date );
$smarty->assign("now"      , $now );
$smarty->assign("vue"      , $vue );
$smarty->assign("listComp" , $listComp );

$smarty->display("inc_vw_sorties_comp.tpl");

?>