<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage dPccam
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

class CCodable extends CMbObject {
	
  // DB Fields
  var $codes_ccam          = null;
  var $facture             = null; // S�jour factur� ou non
  
  // Form fields
  var $_acte_execution          = null;
  var $_acte_depassement        = null;
  var $_acte_depassement_anesth = null;
  var $_ref_anesth              = null;
  var $_anesth                  = null;
  var $_associationCodesActes   = null;
  var $_count_actes             = null;
  
  // Abstract fields
  var $_praticien_id       = null;
  var $_coded              = 0;    // Initialisation � 0 => codable qui peut etre cod� !
  
  // Actes CCAM
  var $_text_codes_ccam    = null;
  var $_codes_ccam         = null;
  var $_tokens_ccam        = array();
  var $_ref_actes_ccam     = null;
  var $_ext_codes_ccam     = null;
  
  // Actes NGAP
  var $_store_ngap     = null;
  var $_ref_actes_ngap = null;
  var $_codes_ngap     = null;
  var $_tokens_ngap    = null;

  // Back references
  var $_ref_actes = null;
  var $_ref_prescriptions = null;
  
  // Distant references
  var $_ref_sejour = null;
  var $_ref_patient = null;
  var $_ref_praticien = null;
  
  // Behaviour fields
  var $_delete_actes   = null;
  
  /**
   * D�truit les actes CCAM et NGAP
   * @return string Store-like message
   */  
  function deleteActes() {
    $this->_delete_actes = false;

    // Suppression des anciens actes CCAM
    $this->loadRefsActesCCAM();
    foreach ($this->_ref_actes_ccam as $acte) {
      if ($msg = $acte->delete()) {
        return $msg;
      }
    }
    $this->codes_ccam = "";
    
    // Suppression des anciens actes NGAP
    $this->loadRefsActesNGAP();
    foreach ($this->_ref_actes_ngap as $acte) { 
      if ($msg = $acte->delete()) {
        return $msg;
      }
    }
    $this->_tokens_ngap = "";
  }  
  
  /**
   * Store redefinition
   * @return string Store-like message
   */
  function store() {
    // Standard store
    if ($msg = parent::store()) {
      return $msg;
    }
    
    if ($this->_delete_actes && $this->_id){
      if ($msg = $this->deleteActes()){
        return $msg;    
      }
    }
  }
  
  function loadRefSejour() {
  }
  
  function loadRefPatient() {
  }
  
  function loadRefPraticien() {
  }
  
  function loadView() {
    parent::loadView();
    $this->loadRefsActesCCAM();
    $this->loadExtCodesCCAM(true);
  }
	
  function getActeExecution() {
    $this->_acte_execution = mbDateTime();
  }
  
  function isCoded() {
    return $this->_coded;
  }
  
  function updateFormFields() {
  	parent::updateFormFields();
    
    $this->codes_ccam = strtoupper($this->codes_ccam);
    $this->_text_codes_ccam = str_replace("|", ", ", $this->codes_ccam);
    $this->_codes_ccam = $this->codes_ccam ? 
      explode("|", $this->codes_ccam) : 
      array();
  }
  
  function getProps() {
    $props = parent::getProps();
    $props["codes_ccam"]   = "str show|0";
    $props["facture"]      = "bool default|0";

    $props["_tokens_ccam"] = "";
    $props["_tokens_ngap"] = "";
    $props["_codes_ccam"]  = "";
    $props["_codes_ngap"]  = "";

    $props["_count_actes"] = "num min|0";
    return $props;
  }
  
  function getBackProps() {
    $backProps = parent::getBackProps();
    $backProps["actes_ngap"]    = "CActeNGAP object_id";
    $backProps["actes_ccam"]    = "CActeCCAM object_id";
    $backProps["frais_divers"]  = "CFraisDivers object_id";
    return $backProps;
  }

  /*
  function loadRefPrescription() {
  	$this->_ref_prescription = $this->loadUniqueBackRef("prescriptions");
  }
  */
  function getAssociationCodesActes() {
    $this->updateFormFields();
    $this->loadRefsActesCCAM();
    if($this->_ref_actes_ccam){
      foreach ($this->_ref_actes_ccam as &$acte_ccam) {
        $acte_ccam->loadRefExecutant();
      }
    }
    $this->_associationCodesActes = array();
    $listCodes = $this->_codes_ccam;
    $listCodes = $this->_ext_codes_ccam;
    $listActes = $this->_ref_actes_ccam;
    foreach($listCodes as $key_code => $curr_code) {
      $ccam     = $curr_code->code;
      $phase    = $curr_code->_phase;
      $activite = $curr_code->_activite;
      $this->_associationCodesActes[$key_code]["code"]    = $curr_code->code;
      $this->_associationCodesActes[$key_code]["nbActes"] = 0;
      $this->_associationCodesActes[$key_code]["ids"]     = "";
      foreach($listActes as $key_acte => $curr_acte) {
        $test = ($curr_acte->code_acte == $ccam);
        $test = $test && ($phase === null || $curr_acte->code_phase == $phase);
        $test = $test && ($activite === null || $curr_acte->code_activite == $activite);
        $test = $test && (!isset($this->_associationCodesActes[$key_code]["actes"][$curr_acte->code_phase][$curr_acte->code_activite]));
        if($test) {
          $this->_associationCodesActes[$key_code]["actes"][$curr_acte->code_phase][$curr_acte->code_activite] = $curr_acte;
          $this->_associationCodesActes[$key_code]["nbActes"]++;
          $this->_associationCodesActes[$key_code]["ids"] .= "$curr_acte->_id|";
          unset($listActes[$key_acte]);
        }
      }
    }
  }
  
  function updateDBCodesCCAMField() {
    if (null !== $this->_codes_ccam) {
      $this->codes_ccam = implode("|", $this->_codes_ccam);
    }
  }
  
  
  function doUpdateMontants(){
    
  }
  
  function updateDBFields() {
    // Should update codes CCAM. Very sensible, test a lot before uncommenting
    // $this->updateDBCodesCCAMField();
  }
  
  function preparePossibleActes() {
  }
  
  function getExecutantId($code_activite) {
    return null;
  }
  
  function countActes() {
    $this->_count_actes = $this->countBackRefs("actes_ngap") + $this->countBackRefs("actes_ccam");
  }

  function correctActes() {
    $this->loadRefsActes();
    foreach($this->_ref_actes_ccam as $_acte) {
      $_acte->guessAssociation();
      if($_acte->_guess_association != "X") {
        $_acte->code_association = $_acte->_guess_association;
        $_acte->store();
      }
    }
  }
  
  function loadRefsActes(){
  	$this->_ref_actes = array();
  	
    $this->loadRefsActesCCAM();
    $this->loadRefsActesNGAP();  
    
    foreach($this->_ref_actes_ccam as $acte_ccam){
      $this->_ref_actes[] = $acte_ccam;
    }
    foreach($this->_ref_actes_ngap as $acte_ngap){
      $this->_ref_actes[] = $acte_ngap;
    }
    
    $this->_count_actes = count($this->_ref_actes);
  }
  
  /**
   * Charge les actes CCAM cod�s
   */
  function loadRefsActesCCAM() {
    if ($this->_ref_actes_ccam) {
      return;
    }

  	$order = array();
  	$order[] = "code_association";
  	$order[] = "code_acte";
  	$order[] = "code_activite";
  	$order[] = "code_phase";
  	$order[] = "acte_id";
  	
    if (null === $this->_ref_actes_ccam = $this->loadBackRefs("actes_ccam", $order)) {
      return;
    }
  	
    $this->_temp_ccam = array();
    foreach ($this->_ref_actes_ccam as $_acte_ccam) {
      $this->_temp_ccam[] = $_acte_ccam->makeFullCode();
    }
    
    $this->_tokens_ccam = implode("|", $this->_temp_ccam);
  }
  
  /**
   * Charge les actes NGAP cod�s
   */
  function loadRefsActesNGAP() {
    if (null === $this->_ref_actes_ngap = $this->loadBackRefs("actes_ngap")) {
      return;
    }
    
    $this->_codes_ngap = array();
    foreach ($this->_ref_actes_ngap as $_acte_ngap){
      $this->_codes_ngap[] = $_acte_ngap->makeFullCode(); 
      $_acte_ngap->loadRefExecutant();
      $_acte_ngap->getLibelle();
    }
    $this->_tokens_ngap = implode("|", $this->_codes_ngap);
  }
  
  /**
   * Charge les codes CCAM en tant qu'objets externes
   */
  function loadExtCodesCCAM($full = false) {
    $this->_ext_codes_ccam = array();
    if ($this->_codes_ccam !== null) {
      foreach ($this->_codes_ccam as $code) {
        $this->_ext_codes_ccam[] = CCodeCCAM::get($code, $full ? CCodeCCAM::FULL : CCodeCCAM::LITE);
      }
    }
  }
  
  function loadRefsFraisDivers(){
    $this->_ref_frais_divers = $this->loadBackRefs("frais_divers");
    foreach($this->_ref_frais_divers as $_frais) {
      $_frais->loadRefType();
    }
    return $this->_ref_frais_divers;
  }

  function getMaxCodagesActes() {
    if(!$this->_id || $this->codes_ccam === null || $this->_forwardRefMerging) {
      return;
    }

    $oldObject = new $this->_class_name;
	  $oldObject->load($this->_id);
	  $oldObject->codes_ccam = $this->codes_ccam;
	  $oldObject->updateFormFields();
	    
	  $oldObject->loadRefsActesCCAM();
			    
    // Creation du tableau minimal de codes ccam
    $codes_ccam_minimal = array();
    foreach ($oldObject->_ref_actes_ccam as $key => $acte) {
      $codes_ccam_minimal[$acte->code_acte] = true;
    }

	  // Transformation du tableau de codes ccam
	  $codes_ccam = array();
	  foreach($oldObject->_codes_ccam as $key => $code) {
	    if (strlen($code) > 7){
	      // si le code est de la forme code-activite-phase
        $detailCode = explode("-", $code);
        $code = $detailCode[0];
	    }
	    $codes_ccam[$code] = true;
	  }
	  
	  // Test entre les deux tableaux
	  foreach(array_keys($codes_ccam_minimal) as $_code ){
	    if (!array_key_exists($_code, $codes_ccam)){
	      return "Impossible de supprimer le code";
	    }
	  }
  }
  
  function checkCodeCcam() {
    $codes_ccam = explode("|", $this->codes_ccam);
    CMbArray::removeValue("", $codes_ccam);
    foreach ($codes_ccam as $_code_ccam) {
      if (!preg_match("/[A-Z]{4}[0-9]{3}/i", $_code_ccam)) {
        return "Le code CCAM '$_code_ccam' n'est pas valide";
      }
    }
  }
  
  function check(){
    if ($msg = $this->checkCodeCcam()) {
      return $msg;
    }
    
  	//@todo: why not use $this->_old ?
    $oldObject = new $this->_class_name;
    if($this->_id) {
      $oldObject->load($this->_id);
    }
    
    if(CAppUI::conf("dPccam CCodable use_getMaxCodagesActes")){
	    if($this->codes_ccam != $oldObject->codes_ccam){
	      if ($msg = $this->getMaxCodagesActes()) {
	        return $msg;
	      }
	    }   
    }
    return parent::check();
  }
    
  /**
   * Charge les actes CCAM codables en fonction des code CCAM fournis
   */
  function loadPossibleActes () {
    $this->preparePossibleActes();
    $depassement_affecte        = false;
    $depassement_anesth_affecte = false;
    // existing acts may only be affected once to possible acts
    $used_actes = array();
    
    $this->loadExtCodesCCAM(true);
    foreach ($this->_ext_codes_ccam as $code_ccam) {
      foreach ($code_ccam->activites as &$activite) {
        foreach ($activite->phases as &$phase) {
          $possible_acte = new CActeCCAM;
          $possible_acte->montant_depassement = "";
          $possible_acte->code_acte = $code_ccam->code;
          $possible_acte->code_activite = $activite->numero;
          
          $possible_acte->_anesth = ($activite->numero == 4);
          
          $possible_acte->code_phase = $phase->phase;
          $possible_acte->execution = $this->_acte_execution;
          
          // Affectation du d�passement au premier acte de chirugie
          if (!$depassement_affecte and $possible_acte->code_activite == 1) {
            $depassement_affecte = true;     	
            $possible_acte->montant_depassement = $this->_acte_depassement;
          }
          
          // Affectation du d�passement au premier acte d'anesth�sie
          if (!$depassement_anesth_affecte and $possible_acte->code_activite == 4) {
            $depassement_anesth_affecte = true;      
            $possible_acte->montant_depassement = $this->_acte_depassement_anesth;
          }
          
          $possible_acte->executant_id = $this->getExecutantId($possible_acte->code_activite);
          $possible_acte->updateFormFields();
          $possible_acte->loadRefs();
          $possible_acte->getAnesthAssocie();
                    
          // Affect a loaded acte if exists
          foreach ($this->_ref_actes_ccam as $curr_acte) {
            if ($curr_acte->code_acte     == $possible_acte->code_acte 
             && $curr_acte->code_activite == $possible_acte->code_activite 
             && $curr_acte->code_phase    == $possible_acte->code_phase) {
              if (!isset($used_actes[$curr_acte->acte_id])) {
                $possible_acte = $curr_acte;
                $used_actes[$curr_acte->acte_id] = true;
                break;
              }
            }
          }
          
          $possible_acte->guessAssociation();
          $possible_acte->getTarif();
          
          // Keep references !
          $phase->_connected_acte = $possible_acte;
          
          foreach ($phase->_modificateurs as &$modificateur) {
            if (strpos($phase->_connected_acte->modificateurs, $modificateur->code) !== false) {
              $modificateur->_value = $modificateur->code;
            } else {
              $modificateur->_value = "";              
            }
          }
        }
      }
    } 
  }
}
?>