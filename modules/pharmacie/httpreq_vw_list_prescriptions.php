<?php /* $Id: vw_idx_prescriptions_sejour.php 7655 2009-12-18 11:07:12Z alexis_granger $ */

/**
 *  @package Mediboard
 *  @subpackage pharmacie
 *  @version $Revision: 7655 $
 *  @author SARL OpenXtrem
 *  @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

CCanDo::checkRead();

// Recuperation des valeurs
$praticien_id  = CValue::get("praticien_id");
$service_id    = CValue::get("service_id");
$valide_pharma = CValue::get("valide_pharma", 0);  // Par defaut, seulement les prescriptions contenant des lignes non validees

$date = mbDate();
$filter_sejour = new CSejour();
$filter_sejour->_date_entree = CValue::get('_date_entree', CValue::session('_date_min', $date));
$filter_sejour->_date_sortie = CValue::get('_date_sortie', CValue::session('_date_max', $date));

CValue::setSession('_date_min', $filter_sejour->_date_entree);
CValue::setSession('_date_max', $filter_sejour->_date_sortie);

// Initialisations
$lines_medicament = array();
$where = array();
$ljoin = array();

$ljoin["prescription_line_medicament"] = "prescription_line_medicament.prescription_id = prescription.prescription_id";
$ljoin["prescription_line_mix"] = "prescription_line_mix.prescription_id = prescription.prescription_id";
$ljoin["sejour"] = "prescription.object_id = sejour.sejour_id";
  
$where["prescription.object_class"] = " = 'CSejour'";
$where["prescription.type"] = " = 'sejour'";
  
if($valide_pharma == 0){
  $where[] = "(prescription_line_medicament.valide_pharma != '1' AND prescription_line_medicament.variante_active = '1') 
	           OR (prescription_line_mix.signature_pharma != '1' AND prescription_line_mix.variante_active = '1')";
} else {
  $where[] = "prescription_line_medicament.variante_active = '1' OR prescription_line_mix.variante_active = '1'";
}

$where[] = "prescription_line_medicament.child_id IS NULL AND prescription_line_mix.next_line_id IS NULL";

// Filtre sur le praticiens (lignes)
if($praticien_id){
  $where[] = "prescription_line_medicament.praticien_id = '$praticien_id' OR prescription_line_mix.praticien_id = '$praticien_id'";
}

// Filtre sur le service, date des affectations
$min = "$filter_sejour->_date_entree 00:00:00";
$max = "$filter_sejour->_date_sortie 23:59:59";

if($service_id){
  $ljoin["affectation"] = "sejour.sejour_id = affectation.sejour_id";
  $ljoin["lit"]         = "affectation.lit_id = lit.lit_id";
  $ljoin["chambre"]     = "lit.chambre_id = chambre.chambre_id";
  $ljoin["service"]     = "chambre.service_id = service.service_id";

  // Recup�ration de l'affectation courante
  $where[] = "affectation.entree <= '$max'";
  $where[] = "affectation.sortie >= '$min'"; 
  $where["service.service_id"] = " = '$service_id'";
} else {
  // Filtre sur les dates du s�jour
	$where[] = "sejour.entree <= '$max'";
  $where[] = "sejour.sortie >= '$min'";    
}

// filtre sur l'etablissement
$group_id = CGroups::loadCurrent()->_id;
$where["sejour.group_id"] = " = '$group_id'";

$prescriptions = new CPrescription();
$_prescriptions = $prescriptions->loadList($where, null, null, "prescription_id", $ljoin);

$prescriptions = array("0" => array(), "1" => array(), "2" => array(),"none" => array());

$list_prescriptions = array();

foreach($_prescriptions as $_prescription){
	$_prescription->loadRefPatient();
  if(isset($_prescription->score)){
	  $prescriptions[$_prescription->score][$_prescription->_id] = $_prescription;
		$list_prescriptions[$_prescription->score][] = $_prescription->_id;
  } else {
    $prescriptions["none"][$_prescription->_id] = $_prescription;
		$list_prescriptions["none"][] = $_prescription->_id;
  }
}


// Smarty template
$smarty = new CSmartyDP();
$smarty->assign("count_prescriptions", count($_prescriptions));
$smarty->assign("prescriptions", $prescriptions);
$smarty->assign("list_prescriptions", $list_prescriptions);
$smarty->display('inc_list_prescriptions.tpl');

?>