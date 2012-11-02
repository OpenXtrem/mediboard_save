<?php
/**
 * $Id$
 *
 * @package    Mediboard
 * @subpackage dPcabinet
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version    $Revision$
 */

CCanDo::checkEdit();

// Utilisateur s�lectionn� ou utilisateur courant
$prat_id      = CValue::getOrSession("chirSel", 0);
$selConsult   = CValue::getOrSession("selConsult", null);

// Chargement des banques
$orderBanque = "nom ASC";
$banque = new CBanque();
$banques = $banque->loadList(null,$orderBanque);

$consult = new CConsultation();

// Test compliqu� afin de savoir quelle consultation charger
if (isset($_GET["selConsult"])) {
  if ($consult->load($selConsult) && $consult->patient_id) {
    $consult->loadRefsFwd();
    $prat_id = $consult->_ref_plageconsult->chir_id;
    CValue::setSession("chirSel", $prat_id);
  }
  else {
    $consult = new CConsultation();
    $selConsult = null;
    CValue::setSession("selConsult");
  }
}
else {
  if ($consult->load($selConsult) && $consult->patient_id) {
    $consult->loadRefsFwd();
    if ($prat_id !== $consult->_ref_plageconsult->chir_id) {
      $consult = new CConsultation();
      $selConsult = null;
      CValue::setSession("selConsult");
    }
  }
}

$userSel = CMediusers::get($prat_id);
$userSel->loadRefs();
$canUserSel = $userSel->canDo();

// V�rification des droits sur les praticiens
if (CAppUI::pref("pratOnlyForConsult", 1)) {
  $listChir = $userSel->loadPraticiens(PERM_EDIT);
}
else {
  $listChir = $userSel->loadProfessionnelDeSante(PERM_EDIT);
}

if (!$userSel->isMedical()) {
  CAppUI::setMsg("Vous devez selectionner un personnel de sant�", UI_MSG_ALERT);
  CAppUI::redirect("m=dPcabinet&tab=0");
}

$canUserSel->needsEdit();

// Consultation courante
$consult->_ref_chir = $userSel;
if ($selConsult) {
  $consult->load($selConsult);
  
  CCanDo::checkObject($consult);
  $canConsult = $consult->canDo();
  $canConsult->needsEdit();
  
  // Some Forward references
  $consult->loadRefsFwd();
  $consult->loadRefConsultAnesth();
    
  // Patient
  $patient =& $consult->_ref_patient;
}

if (CModule::getActive("fse")) {
  $fse = CFseFactory::createFSE();
  if ($fse) {
    $fse->loadIdsFSE($consult);
    $fse->makeFSE($consult);
    CFseFactory::createCPS()->loadIdCPS($consult->_ref_chir);
    CFseFactory::createCV()->loadIdVitale($consult->_ref_patient);
  }  
}

$consult->loadRefs();  

// R�cup�ration des tarifs
$tarif = new CTarif;
$tarifs = array();
if (!$consult->tarif || $consult->tarif == "pursue") {
  $order = "description";
  $where = array();
  $where["chir_id"] = "= '$userSel->user_id'";
  $tarifs["user"] = $tarif->loadList($where, $order);
  foreach ($tarifs["user"] as $_tarif) {
    $_tarif->getPrecodeReady();
  }
  
  $where = array();
  $where["function_id"] = "= '$userSel->function_id'";
  $tarifs["func"] = $tarif->loadList($where, $order);
  foreach ($tarifs["func"] as $_tarif) {
    $_tarif->getPrecodeReady();
  }
}

// R�glements
$consult->loadRefsReglements();

// Reglement vide pour le formulaire
$reglement = new CReglement();
$reglement->consultation_id = $consult->_id;
$reglement->montant = round($consult->_du_restant_patient, 2);

// Codes et actes
$consult->loadRefsActesNGAP();
$consult->loadRefsActesTarmed();
$consult->loadRefsActesCaisse();

// Chargement de la facture
$facture = new CFactureConsult();
$facture_patient = new CFactureConsult();
$where = array();
$where["patient_id"] = "= '$consult->patient_id'";
if ($consult->_ref_plageconsult->pour_compte_id) {
  $where["praticien_id"] = "= '".$consult->_ref_plageconsult->pour_compte_id."'";
}
else {
  $where["praticien_id"] = "= '$prat_id'";
}

// On essaie de retrouver une ancienne facture ouverte
$where["cloture"] = " IS NULL";
if ($consult->patient_id && $facture->loadObject($where)) {
  $facture_patient = $facture;
  $facture_patient->loadRefs();
  $facture->_ref_patient->loadRefsCorrespondantsPatient();
}
// [TD] Sinon ???: je ne comprends pas
else { 
  $where["cloture"] = " IS NOT NULL"; 
  if ($consult->patient_id && $factures = $facture->loadList($where)) {
    foreach ($factures as $_facture) {
      $_facture->loadRefs();
      foreach ($_facture->_ref_consults as $consultation) {
        if ($consultation->_id == $consult->_id) {
          $_facture->_ref_patient->loadRefsCorrespondantsPatient();
          $facture_patient = $_facture;
        }
      }
    }  
  }
}

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("banques"  , $banques);
$smarty->assign("facture"  , $facture_patient);
$smarty->assign("consult"  , $consult);
$smarty->assign("reglement", $reglement);
$smarty->assign("tarifs"   , $tarifs);
$smarty->assign("date"     , mbDate());

$smarty->display("inc_vw_reglement.tpl");

?>