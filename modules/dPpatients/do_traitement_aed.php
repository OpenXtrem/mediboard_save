<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPpatients
* @version $Revision$
* @author Romain Ollivier
*/

global $AppUI;

$autoadd_default = isset($AppUI->user_prefs["AUTOADDSIGN"]) ? $AppUI->user_prefs["AUTOADDSIGN"] : 1 ;

// Sejour
// si on a un sejour et que l'option d'ajout automatique est activ�e
if(isset($_POST["_sejour_id"]) && ($autoadd_default == 1) && ($_POST["_sejour_id"] != "")){
 
  $doSejour = new CDoObjectAddEdit("CTraitement", "traitement_id");
  $doSejour->createMsg = "Traitement cr��";
  $doSejour->modifyMsg = "Traitement modifi�";
  $doSejour->deleteMsg = "Traitement supprim�";
 
  // Ajout du traitement dans le sejour
  $_POST["dossier_medical_id"] = CDossierMedical::dossierMedicalId($_POST["_sejour_id"],"CSejour");
  $doSejour->redirectStore = null;
  $doSejour->redirect = null;
 
  $doSejour->doIt();
}

// Patient
$doPatient = new CDoObjectAddEdit("CTraitement", "traitement_id");
$doPatient->createMsg = "Traitement cr��";
$doPatient->modifyMsg = "Traitement modifi�";
$doPatient->deleteMsg = "Traitement supprim�";

if($_POST["del"] != 1){
  $_POST["dossier_medical_id"] = CDossierMedical::dossierMedicalId($_POST["_patient_id"],"CPatient");
}
$_POST["ajax"] = 1;
  
$doPatient->doIt();

?>