<?php /* $Id: $ */

/**
* @package Mediboard
* @subpackage dPpatients
* @version $Revision: $
* @author Romain Ollivier
*/

global $AppUI, $can, $m;

$can->needsRead();

$patient_id = mbGetValueFromGetOrSession("patient_id", 0);

if(!$patient_id) {
  $AppUI->setMsg("Vous devez selectionner un patient", UI_MSG_ALERT);
  $AppUI->redirect("m=dPpatients&tab=0");
}

$diagnosticsInstall = CModule::getActive("dPImeds") && CModule::getActive("dPsante400");

// Liste des Praticiens
$listPrat = new CMediusers();
$listPrat = $listPrat->loadPraticiens(PERM_READ);

// Récuperation du patient sélectionné
$patient = new CPatient;
$patient->load($patient_id);
$patient->loadDossierComplet(PERM_READ);

$moduleCabinet = CModule::getInstalled("dPcabinet");
$canCabinet    = $moduleCabinet->canDo();

// Création du template
$smarty = new CSmartyDP();

$smarty->assign("patient"           , $patient         );
$smarty->assign("canCabinet"        , $canCabinet      );
$smarty->assign("listPrat"          , $listPrat        );

$smarty->assign("object"            , $patient         );

$smarty->assign("diagnosticsInstall", $diagnosticsInstall);

$smarty->display("vw_full_patients.tpl");

?>