<?php /* $Id: $ */

/**
 *	@package Mediboard
 *	@subpackage dPprescription
 *	@version $Revision: $
 *  @author Romain Ollivier
 */

global $can, $dialog;
$can->needsRead();

$filter = new CPrescription();
$filter->prescription_id = mbGetValueFromGetOrSession("prescription_id");
$filter->object_class    = mbGetValueFromGet("object_class", "CSejour");
$filter->object_id       = mbGetValueFromGet("object_id");
$filter->type            = mbGetValueFromGet("type", "externe");
$filter->loadRefsFwd();
$filter->_ref_object->loadRefsFwd();

$popup = mbGetValueFromGet("popup");
$categories = array();

if(!$filter->prescription_id && $popup){
	$new_prescription = new CPrescription();
	$new_prescription->object_id = $filter->object_id;
	$new_prescription->object_class = $filter->object_class;
	$new_prescription->praticien_id = mbGetValueFromGet("praticien_id");
  if($filter->object_class == "CSejour" && $filter->type){
  	$new_prescription->type = $filter->type;
  } else {
	  $new_prescription->type = "externe";
  }
	$msg = $new_prescription->store();
	$prescription = $new_prescription;
} else {
	// Chargement de la prescription demand�
  $prescription = new CPrescription();
  $prescription->load($filter->_id);
}


$protocoles = array();
$listFavoris = array();
$praticien = new CMediusers();


// Cas d'un protocole => il faut selectionner un object
if($prescription->_id && !$prescription->object_id){
	$prescription->_id = "";
}

if (!$prescription->_id) {
  $prescription->object_class = $filter->object_class;
  $prescription->object_id    = $filter->object_id;
}


if ($prescription->object_id) {
  $prescription->loadRefsFwd();
  $prescription->_ref_object->loadRefSejour();
  $prescription->_ref_object->loadRefPatient();
  $prescription->_ref_object->_ref_patient->loadRefDossierMedical();
  $prescription->_ref_object->_ref_patient->_ref_dossier_medical->updateFormFields();
  $prescription->_ref_object->_ref_patient->_ref_dossier_medical->loadRefsAntecedents();
  $prescription->_ref_object->_ref_patient->_ref_dossier_medical->loadRefsTraitements();
  $prescription->_ref_object->_ref_patient->_ref_dossier_medical->loadRefsAddictions();
  $prescription->_ref_object->loadRefsPrescriptions();
  
  
  // Chargement des protocoles
  $protocole = new CPrescription();
  $where = array();
  $where["praticien_id"] = " = '$prescription->praticien_id'";
  $where["object_id"] = "IS NULL";
  $protocoles = $protocole->loadList($where);
}

// Liste des alertes
$listProduits = array();
$alertesAllergies    = array();
$alertesInteractions = array();
$alertesIPC          = array();
$alertesProfil       = array();
if ($prescription->_id) {
  // Chargement des medicaments et commentaire
  $prescription->loadRefsLinesMedComments();
  // Chargement des elements et commentaires
  $prescription->loadRefsLinesElementsComments();
  
  $prescription->loadRefPraticien();
  
  // Gestion des alertes
  $allergies    = new CBcbControleAllergie();
  $allergies->setPatient($prescription->_ref_object->_ref_patient);
  $interactions = new CBcbControleInteraction();
  $IPC          = new CBcbControleIPC();
  $profil       = new CBcbControleProfil();
  $profil->setPatient($prescription->_ref_object->_ref_patient);
  
  foreach ($prescription->_ref_prescription_lines as &$line) {
    // Chargement de la posologie
    $line->_ref_produit->loadRefPosologies();
    // Ajout des produits pour les alertes
    $allergies->addProduit($line->code_cip);
    $interactions->addProduit($line->code_cip);
    $IPC->addProduit($line->code_cip);
    $profil->addProduit($line->code_cip);
  }
  $alertesAllergies    = $allergies->getAllergies();
  $alertesInteractions = $interactions->getInteractions();
  $alertesIPC          = $IPC->getIPC();
  $alertesProfil       = $profil->getProfil();
  foreach ($prescription->_ref_prescription_lines as &$line) {
    $line->checkAllergies($alertesAllergies);
    $line->checkInteractions($alertesInteractions);
    $line->checkIPC($alertesIPC);
    $line->checkProfil($alertesProfil);
  }

  // Liste des favoris
  $listFavoris = CPrescription::getFavorisPraticien($prescription->praticien_id);
  
  // Chargement du praticien
  $praticien->load($prescription->praticien_id);


  // Chargement des categories pour chaque chapitre
  $category = new CCategoryPrescription();
  $categories = $category->loadCategoriesByChap();
}

$moments = CMomentUnitaire::loadAllMoments();
$executants = CExecutantPrescriptionLine::getAllExecutants();

// Chargement de toutes les categories
$categorie = new CCategoryPrescription();
$cats = $categorie->loadList();
foreach($cats as $key => $cat){
	$categories["cat".$key] = $cat;
}

// Liste des praticiens
$user = new CMediusers();
$listPrats = $user->loadPraticiens(PERM_EDIT);



// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("contexteType"       , "");
$smarty->assign("today"              , mbDate());
$smarty->assign("categories"         , $categories);
$smarty->assign("executants"         , $executants);
$smarty->assign("prise_posologie"    , new CPrisePosologie());
$smarty->assign("categories"         , $categories);
$smarty->assign("category"           , "medicament");
$smarty->assign("alertesAllergies"   , $alertesAllergies);
$smarty->assign("alertesInteractions", $alertesInteractions);
$smarty->assign("alertesIPC"         , $alertesIPC);
$smarty->assign("alertesProfil"      , $alertesProfil);

$smarty->assign("prescription", $prescription);
$smarty->assign("filter"      , $filter);
$smarty->assign("listPrats"   , $listPrats);
$smarty->assign("listFavoris", $listFavoris);
$smarty->assign("protocoles", $protocoles);
$smarty->assign("praticien", $praticien);
$smarty->assign("moments", $moments);
if($dialog == 1) {
  $smarty->display("vw_edit_prescription_popup.tpl");
} else {
  $smarty->display("vw_edit_prescription.tpl");
  
}

?>