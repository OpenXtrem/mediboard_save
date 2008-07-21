<?php /* $Id: $ */

/**
 *  @package Mediboard
 *  @subpackage pharmacie
 *  @version $Revision: $
 *  @author Alexis Granger
 */

global $g;

$service_id = mbGetValueFromGetOrSession('service_id');

// Calcul de date_max et date_min
$date = mbDate();
$date_min = "$date 00:00:00";
$date_max = "$date 23:59:00";

$date_min = mbGetValueFromGetOrSession('_date_min', $date_min);
$date_max = mbGetValueFromGetOrSession('_date_max', $date_max);

// Recherche des prescriptions dont les dates de sejours correspondent
$where = array();
$ljoin = array();
$ljoin['sejour'] = 'prescription.object_id = sejour.sejour_id';
$ljoin['affectation'] = 'sejour.sejour_id = affectation.sejour_id';
$ljoin['lit'] = 'affectation.lit_id = lit.lit_id';
$ljoin['chambre'] = 'lit.chambre_id = chambre.chambre_id';
$ljoin['service'] = 'chambre.service_id = service.service_id';
$where['prescription.type'] = " = 'sejour'";
$where[] = "(sejour.entree_prevue BETWEEN '$date_min' AND '$date_max') OR 
            (sejour.sortie_prevue BETWEEN '$date_min' AND '$date_max') OR
            (sejour.entree_prevue <= '$date_min' AND sejour.sortie_prevue >= '$date_max')"; 
$where['service.service_id'] = " = '$service_id'";

$dispensations = array();
$delivrances = array();
$prescriptions = array();
$medicaments = array();
$stocks = array();
$quantites_traduites = array();
$quantites = array();

$prescription = new CPrescription();
$prescriptions = $prescription->loadList($where, null, null, null, $ljoin);
foreach($prescriptions as $_prescription){
  $_prescription->loadRefsLinesMed(1,1);

  // Stockage du sejour de la prescription
  $sejour =& $_prescription->_ref_object;
    
  // On borne les dates aux dates du sejour si besoin
  $date_min = ($date_min < $sejour->_entree) ? $sejour->_entree : $date_min;
  $date_max = ($date_max > $sejour->_sortie) ? $sejour->_sortie : $date_max;
      
  foreach($_prescription->_ref_prescription_lines as $_line_med){ 
    $_line_med->_ref_produit->loadConditionnement();
    // On remplit les bornes de la ligne avec les dates du sejour si besoin
    $_line_med->_debut_reel = (!$_line_med->_debut_reel) ? $sejour->_entree : $_line_med->_debut_reel;
    $_line_med->_fin_reelle = (!$_line_med->_fin_reelle) ? $sejour->_sortie : $_line_med->_fin_reelle;
    
    // Si la ligne n'est pas dans les bornes donn�, on en tient pas compte
    if (!($_line_med->_debut_reel >= $date_min && $_line_med->_debut_reel <= $date_max ||
        $_line_med->_fin_reelle >= $date_min && $_line_med->_fin_reelle <= $date_max ||
        $_line_med->_debut_reel <= $date_min && $_line_med->_fin_reelle >= $date_max)){
      continue;     
    }
    
    // Calcul de la quantite en fonction des prises
    $_line_med->calculQuantiteLine($date_min, $date_max);
    foreach($_line_med->_quantites as $unite_prise => $quantite){
      $_unite_prise = str_replace('/kg', '', $unite_prise);
      // Dans le cas d'un unite_prise/kg
      if($_unite_prise != $unite_prise){
        // On recupere le poids du patient pour calculer la quantite
        if(!$_prescription->_ref_object->_ref_patient){
          $_prescription->_ref_object->loadRefPatient();
        }
        $patient =& $_prescription->_ref_object->_ref_patient;
        if(!$patient->_ref_constantes_medicales){
          $patient->loadRefConstantesMedicales();
        }
        $const_med = $patient->_ref_constantes_medicales;
        $poids     = $const_med->poids;
        $quantite  *= $poids;
      }
      if (!isset($dispensations[$_line_med->code_cip])) {
        $dispensations[$_line_med->code_cip] = array();
      }
      if (!isset($dispensations[$_line_med->code_cip][$_unite_prise])) {
        $dispensations[$_line_med->code_cip][$_unite_prise] = 0;
      }
      $dispensations[$_line_med->code_cip][$_unite_prise] += $quantite;  
    }
    if(!array_key_exists($_line_med->code_cip, $medicaments)){
      $medicaments[$_line_med->code_cip] =& $_line_med->_ref_produit;
    }
  }
  
  // Calcul du nombre de boites (unites de presentation)
  foreach($dispensations as $code_cip => $unites){
    $medicament =& $medicaments[$code_cip]; 
    foreach($unites as $unite_prise => $quantite){
      if (!isset($medicament->rapport_unite_prise[$unite_prise][$medicament->libelle_unite_presentation])) {
        $coef = 1;
      } else {
        $coef = $medicament->rapport_unite_prise[$unite_prise][$medicament->libelle_unite_presentation];
      }
      $_quantite = $quantite * $coef;
      // Affichage des quantites traduites en fonction de l'unite de reference
      if($_quantite != $quantite){
        if (!isset($quantites_traduites[$code_cip])) {
          $quantites_traduites[$code_cip] = array();
        }
        if (!isset($quantites_traduites[$code_cip][$unite_prise])) {
          $quantites_traduites[$code_cip][$unite_prise] = 0;
        }
        $quantites_traduites[$code_cip][$unite_prise] += $_quantite;
      }
      $presentation = $_quantite/$medicament->nb_unite_presentation;
      $_presentation = $presentation/$medicament->nb_presentation;
      if (!isset($quantites[$code_cip])) $quantites[$code_cip] = 0;
      $quantites[$code_cip] += $_presentation;
    }
    
    $product = new CProduct();
    $product->code = $code_cip;
    $product->category_id = CAppUI::conf('dPmedicament CBcbProduitLivretTherapeutique product_category_id');
    
    if ($product->loadMatchingObject()) {
      $stocks[$code_cip] = new CProductStockGroup();
      $stocks[$code_cip]->group_id = $g;
      $stocks[$code_cip]->product_id = $product->_id;
      $stocks[$code_cip]->loadMatchingObject();
      
      $delivrances[$code_cip] = new CProductDelivery();
      $delivrances[$code_cip]->stock_id = $stocks[$code_cip]->_id;
      $delivrances[$code_cip]->service_id = $service_id;
    }
  }
}

// On arrondit la quantite de "boites"
foreach($quantites as $code => &$_quantite){
  if(strstr($_quantite, '.')){
    $_quantite = ceil($_quantite);
  }
  if(isset($delivrances[$code])) {
    $delivrances[$code]->quantity = $quantites[$code];
  }
}

// Smarty template
$smarty = new CSmartyDP();
$smarty->assign('dispensations', $dispensations);
$smarty->assign('delivrances', $delivrances);
$smarty->assign('medicaments'  , $medicaments);
$smarty->assign('quantites', $quantites);
$smarty->assign('service_id', $service_id);
$smarty->assign('quantites_traduites', $quantites_traduites);
$smarty->display('inc_dispensations_list.tpl');

?>