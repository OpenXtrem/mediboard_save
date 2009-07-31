<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPcabinet
* @version $Revision$
* @author Romain Ollivier
*/

global $AppUI, $m;

// Permissions ?
//$module = CModule::getInstalled($m);
//$canModule = $module->canDo();
//$canModule->needsEdit();

// Cas des urgences 
if ($sejour_id = mbGetValueFromPost("sejour_id")) {
  $sejour = new CSejour();
  $sejour->load($sejour_id);
  
  // pr�venir les multiples RPU
  $sejour->loadRefRPU();
  if ($sejour->_ref_rpu->_count_consultations) {
    $AppUI->setMsg("Patient d�j� pris en charge par un praticien", UI_MSG_WARNING);
    $AppUI->redirect();
  }
  
  // Changement de praticien pour le sejour
  $sejour->praticien_id = $_POST["prat_id"];
  $sejour->store();
}


$chir = new CMediusers;
$chir->load($_POST["prat_id"]);
if(!$chir->_id) {
  $AppUI->setMsg("Vous devez choisir un praticien pour la consultation", UI_MSG_WARNING);
  $AppUI->redirect();
}

$day_now = strftime("%Y-%m-%d");
$time_now = strftime("%H:%M:00");
$hour_now = strftime("%H:00:00");
$hour_next = mbTime("+1 HOUR", $hour_now);

$plage = new CPlageconsult();
$plageBefore = new CPlageconsult();
$plageAfter = new CPlageconsult();
// Cas ou une plage correspond
$where = array();
$where["chir_id"] = "= '$chir->user_id'";
$where["date"]    = "= '$day_now'";
$where["debut"]   = "<= '$time_now'";
$where["fin"]     = "> '$time_now'";
$plage->loadObject($where);

if(!$plage->plageconsult_id) {
  // Cas ou on a des plage en collision
	$where = array();
	$where["chir_id"] = "= '$chir->user_id'";
	$where["date"]    = "= '$day_now'";
	$where["debut"]   = "<= '$hour_now'";
	$where["fin"]     = ">= '$hour_now'";
  $plageBefore->loadObject($where);
	$where["debut"]   = "<= '$hour_next'";
	$where["fin"]     = ">= '$hour_next'";
  $plageAfter->loadObject($where);
  if($plageBefore->plageconsult_id) {
    if($plageAfter->plageconsult_id) {
      $plageBefore->fin = $plageAfter->debut;
    } else {
      $plageBefore->fin = max($plageBefore->fin, $hour_next);
    }
    $plage =& $plageBefore;
  } elseif($plageAfter->plageconsult_id) {
    $plageAfter->debut = min($plageAfter->debut, $hour_now);
    $plage =& $plageAfter;
  } else {
    $plage->chir_id = $chir->user_id;
    $plage->date    = $day_now;
    $plage->freq    = "00:".CPlageconsult::$minutes_interval.":00";
    $plage->debut   = $hour_now;
    $plage->fin     = $hour_next;
    $plage->libelle = "automatique";
  }
  $plage->updateFormFields();
  $plage->store();
}

$plage->loadRefsFwd();

$ref_chir = $plage->_ref_chir;

$consult = new CConsultation;
$consult->plageconsult_id = $plage->plageconsult_id;
$consult->sejour_id = $sejour_id;
$consult->patient_id = $_POST["patient_id"];
$consult->heure = $time_now;
$consult->arrivee = $day_now." ".$time_now;
$consult->duree = 1;
$consult->chrono = CConsultation::PATIENT_ARRIVE;
$consult->accident_travail = mbGetValueFromPost("accident_travail");

// Cas des urgences
if ($sejour_id) {
  // Motif de la consultation
  $consult->motif = "";
  if (CAppUI::conf('dPurgences motif_rpu_view')) {
	  $consult->motif .= "RPU: ";
  }
  $consult->motif.= $sejour->_ref_rpu->diag_infirmier;
} 

// Cas standard
else {
  $consult->motif = "Consultation imm�diate";
}

$consult->store();

if ($ref_chir->isFromType(array("Anesth�siste"))) {
  // Un Anesthesiste a �t� choisi 
  $consultAnesth = new CConsultAnesth;
  $where = array();
  $where["consultation_id"] = "= '".$consult->consultation_id."'";
  $consultAnesth->loadObject($where);  
  $consultAnesth->consultation_id = $consult->consultation_id;
  if(isset($_POST["_operation_id"])){
    $consultAnesth->operation_id = $_POST["_operation_id"];      
  } else {
    $consultAnesth->operation_id = "";
  }
  $consultAnesth->store();
}

// Redirect final
if($current_m = mbGetValueFromPost("_m_redirect")) {
  $AppUI->redirect("m=$current_m");
} else {
  $current_m = $sejour_id ? "dPurgences" : "dPcabinet";
  $AppUI->redirect("m=$current_m&tab=edit_consultation&selConsult=$consult->consultation_id&chirSel=$chir->user_id");
}
?>