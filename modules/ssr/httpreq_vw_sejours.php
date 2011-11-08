<?php /* $Id: httpreq_vw_admissions.php 13224 2011-09-21 12:32:54Z lryo $ */

/**
 * @package Mediboard
 * @subpackage dPadmissions
 * @version $Revision: 13224 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

CCanDo::checkRead();

// Type d'admission
$service_id     = CValue::getOrSession("service_id");
$prat_id        = CValue::getOrSession("prat_id");
$recuse         = CValue::getOrSession("recuse", "-1");
$order_col      = CValue::getOrSession("order_col", "patient_id");
$order_way      = CValue::getOrSession("order_way", "ASC");
$date           = CValue::getOrSession("date", mbDate());
$next           = mbDate("+1 DAY", $date);
$filterFunction = CValue::getOrSession("filterFunction");

$date_actuelle = mbDateTime("00:00:00");
$date_demain   = mbDateTime("00:00:00","+ 1 day");

$hier   = mbDate("- 1 day", $date);
$demain = mbDate("+ 1 day", $date);

$date_min = mbDateTime("00:00:00", $date);
$date_max = mbDateTime("23:59:00", $date);

// Chargement des prestations
$prestations = CPrestation::loadCurrentList();

// Entr�es de la journ�e
$sejour = new CSejour();

$group = CGroups::loadCurrent();

// Lien avec les patients et les praticiens
$ljoin["patients"] = "sejour.patient_id = patients.patient_id";
$ljoin["users"] = "sejour.praticien_id = users.user_id";

// Filtre sur les services
if($service_id) {
  $ljoin["affectation"]        = "affectation.sejour_id = sejour.sejour_id AND affectation.sortie = sejour.sortie_prevue";
  $ljoin["lit"]                = "affectation.lit_id = lit.lit_id";
  $ljoin["chambre"]            = "lit.chambre_id = chambre.chambre_id";
  $ljoin["service"]            = "chambre.service_id = service.service_id";
  $where["service.service_id"] = "= '$service_id'";
}

// Filtre sur le type du s�jour
$where["type"] = "= 'ssr'";

// Filtre sur le praticien
if ($prat_id) {
  $where["sejour.praticien_id"] = " = '$prat_id'";
}

$where["sejour.group_id"] = "= '$group->_id'";
$where["sejour.entree"]   = "BETWEEN '$date' AND '$next'";
$where["sejour.recuse"]   = "= '$recuse'";

if ($order_col != "patient_id" && $order_col != "entree_prevue" && $order_col != "praticien_id"){
	$order_col = "patient_id";	
}

if ($order_col == "patient_id"){
  $order = "patients.nom $order_way, patients.prenom $order_way, sejour.entree_prevue";
}

if ($order_col == "entree_prevue"){
  $order = "sejour.entree_prevue $order_way, patients.nom, patients.prenom";
}

if ($order_col == "praticien_id"){
  $order = "users.user_last_name $order_way, users.user_first_name";
}

$sejours = $sejour->loadList($where, $order, null, null, $ljoin);

CMbObject::massLoadFwdRef($sejours, "patient_id");
$praticiens = CMbObject::massLoadFwdRef($sejours, "praticien_id");
$functions  = CMbObject::massLoadFwdRef($praticiens, "function_id");

foreach ($sejours as $sejour_id => $_sejour) {
  $_sejour->loadRefPraticien(1);
	$praticien =& $_sejour->_ref_praticien;
  
	if ($filterFunction && $filterFunction != $praticien->function_id) {
    unset($sejours[$sejour_id]);
	  continue;
  }
  
  // Chargement du patient
  $_sejour->loadRefPatient(1);
  $_sejour->_ref_patient->loadIPP();
  
  // Chargment du num�ro de dossier
  $_sejour->loadNDA();
  $whereOperations = array("annulee" => "= '0'");

  // Chargement de l'affectation
  $_sejour->loadRefsAffectations();
  $affectation =& $_sejour->_ref_first_affectation;
  if ($affectation->_id) {
    $affectation->loadRefLit(1);
    $affectation->_ref_lit->loadCompleteView();
  }
}

// Si la fonction selectionn�e n'est pas dans la liste des fonction, on la rajoute
if ($filterFunction && !array_key_exists($filterFunction, $functions)){
	$_function = new CFunctions();
	$_function->load($filterFunction);
	$functions[$filterFunction] = $_function;
}

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("hier"          , $hier);
$smarty->assign("demain"        , $demain);
$smarty->assign("date_min"      , $date_min);
$smarty->assign("date_max"      , $date_max);
$smarty->assign("date_demain"   , $date_demain);
$smarty->assign("date_actuelle" , $date_actuelle);
$smarty->assign("date"          , $date);
$smarty->assign("recuse"        , $recuse);
$smarty->assign("order_col"     , $order_col);
$smarty->assign("order_way"     , $order_way);
$smarty->assign("sejours"       , $sejours);
$smarty->assign("prestations"   , $prestations);
$smarty->assign("canAdmissions" , CModule::getCanDo("dPadmissions"));
$smarty->assign("canPatients"   , CModule::getCanDo("dPpatients"));
$smarty->assign("canPlanningOp" , CModule::getCanDo("dPplanningOp"));
$smarty->assign("functions"     , $functions);
$smarty->assign("filterFunction", $filterFunction);

$smarty->display("inc_vw_sejours.tpl");

?>