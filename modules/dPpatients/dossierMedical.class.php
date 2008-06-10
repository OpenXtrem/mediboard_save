<?php /* $Id: patients.class.php 2242 2007-07-11 10:21:19Z mytto $ */

/**
* @package Mediboard
* @subpackage dPpatients
* @version $Revision: 2242 $
* @author Romain Ollivier
*/


/**
 * Dossier M�dical li�s aux notions d'ant�c�dents, traitements, addictions et diagnostics
 */
class CDossierMedical extends CMbMetaObject {
  // DB Fields
  var $dossier_medical_id = null;
  var $codes_cim          = null;
  
  // Form Fields
  var $_added_code_cim   = null;
  var $_deleted_code_cim = null;
  var $_codes_cim        = null;
  var $_ext_codes_cim    = null;

  // Back references
  var $_ref_antecedents = null;
  var $_ref_traitements = null;
  var $_ref_addictions  = null;
  var $_ref_etats_dents = null;
  
  // Derived back references
  var $_ref_types_addiction  = null;
  var $_count_antecedents = null;
  
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table = 'dossier_medical';
    $spec->key   = 'dossier_medical_id';
    return $spec;
  }
  
  function getSpecs() {
    $specs = parent::getSpecs();
    $specs["codes_cim"] = "text";
    return $specs;
  }  
  function getBackRefs() {
    $backRefs = parent::getBackRefs();
    $backRefs["antecedents"] = "CAntecedent dossier_medical_id";
    $backRefs["addictions" ] = "CAddiction dossier_medical_id";
    $backRefs["traitements"] = "CTraitement dossier_medical_id";
    return $backRefs;
  }

  function loadRefsBack() {
    parent::loadRefsBack();
    $this->loadRefsAntecedents();
    $this->loadRefsTraitements();
    $this->loadRefsAddictions();
  }
  
  function loadRefObject(){  
    $this->_ref_object = new $this->object_class;
    $this->_ref_object->load($this->object_id);
  }
  
  function updateFormFields() {
    parent::updateFormFields();
    
    // Tokens CIM
    $this->codes_cim = strtoupper($this->codes_cim);
    $this->_codes_cim = $this->codes_cim ? explode("|", $this->codes_cim) : array();
  
    // Objets CIM
    $this->_ext_codes_cim = array();
    foreach ($this->_codes_cim as $code_cim) {
      $this->_ext_codes_cim[$code_cim] = new CCodeCIM10($code_cim, 1);
    }
  }

  function updateDBFields() {
    parent::updateDBFields();
    if(!$listCodesCim = $this->codes_cim) {
      $oldDossier = new CDossierMedical();
      $oldDossier->load($this->_id);
      $listCodesCim = $oldDossier->codes_cim;
    }
    if($this->_added_code_cim) {
      if($listCodesCim) {
        $this->codes_cim = "$listCodesCim|$this->_added_code_cim";
      } else {
        $this->codes_cim = $this->_added_code_cim;
      }
    }
    if($this->_deleted_code_cim) {
      $arrayCodesCim = explode("|", $listCodesCim);
      CMbArray::removeValue($this->_deleted_code_cim, $arrayCodesCim);
      $this->codes_cim = implode("|", $arrayCodesCim);
    }
  }
    
  function loadRefsAntecedents() {
    // Initialisation du classement
    $ant = new CAntecedent();
    foreach (explode("|", $ant->_specs["type"]->list) as $type) {
      $this->_ref_antecedents[$type] = array();
    }

    $order = "type ASC";
    if (null == $antecedents = $this->loadBackRefs("antecedents", $order)) {
      return;
    }

    // Classements des ant�c�dents
    foreach ($antecedents as $_antecedent) {
      $this->_ref_antecedents[$_antecedent->type][$_antecedent->_id] = $_antecedent;
    }
  }
  
  function loadRefsEtatsDents() {
    $etat_dent = new CEtatDent();
    if ($this->_id) {
      $etat_dent->dossier_medical_id = $this->_id;
      $this->_ref_etats_dents = $etat_dent->loadMatchingList();
    }
  }

  function countAntecedents(){
  	$antedecent = new CAntecedent();
  	$where = array();
  	$where["type"] = " != 'alle'";
  	$where["dossier_medical_id"] = " = '$this->_id'";
  	$this->_count_antecedents = $antedecent->countList($where);
  }
  
  function loadRefsTraitements() {
    $order = "fin DESC, debut DESC";
    if (CAppUI::conf("dPpatients CTraitement enabled")) {
      $this->_ref_traitements = $this->loadBackRefs("traitements", $order);
    }
  }
  
  function loadRefsAddictions() {
    // Initialisation du classement
    $add = new CAddiction();
    foreach (explode("|", $add->_specs["type"]->list) as $type) {
      $this->_ref_types_addiction[$type] = array();
    }

    $order = "type ASC";
    if (null == $this->_ref_addictions = $this->loadBackRefs("addictions", $order)) {
      return;
    }

    // Classement des addictions
    $this->_ref_types_addiction = array();
    foreach ($this->_ref_addictions as $_addiction) {
      $this->_ref_types_addiction[$_addiction->type][$_addiction->_id] = $_addiction;
    }
  }
  
  /**
   * Identifiant de dossier m�dical li� � l'objet fourni. 
   * Cr�e le dossier m�dical si n�cessaire
   * @param $object_id ref Identifiant de l'objet
   * @param $object_class str Classe de l'objet
   * @return ref|CDossierMedical
   */
  static function dossierMedicalId($object_id, $object_class) {
    $dossier = new CDossierMedical();
    $dossier->object_id    = $object_id;
    $dossier->object_class = $object_class;
    $dossier->loadMatchingObject();
    if(!$dossier->_id) {
      $dossier->store();
    }
    return $dossier->_id;
  }

  function fillTemplate(&$template, $champ = "Patient") {
    // Ant�c�dents
    $this->loadRefsAntecedents();
    if (is_array($this->_ref_antecedents)){
      $sAntecedents = "";
      foreach ($this->_ref_antecedents as $keyAnt => $currTypeAnt) {
        $sAntecedentsParType = "";
        $sType =  CAppUI::tr("CAntecedent.type.".$keyAnt);
        foreach ($currTypeAnt as $currAnt) {
          $sAntecedentsParType .= "<br /> &bull; ";
          if ($currAnt->date) { 
            $sAntecedentsParType .= mbDateToLocale($currAnt->date) . " : ";
          }
          $sAntecedentsParType .= $currAnt->rques;
        }

        $template->addProperty("$champ - Ant�c�dents - $sType", $sAntecedentsParType);
        
        if (count($currTypeAnt)) {
	        $sAntecedents .="<br />";
	        $sAntecedents .= $sType;
	        $sAntecedents .= $sAntecedentsParType;
        }
      }
      
      $template->addProperty("$champ - Ant�c�dents -- tous", $sAntecedents !== "" ? $sAntecedents : null);
    }
    
    // Traitements
    $this->loadRefsTraitements();
    if (is_array($this->_ref_traitements)) {
      $sTraitements = "";
      foreach($this->_ref_traitements as $curr_trmt){
        $sTraitements.="<br /> &bull; ";
        if ($curr_trmt->fin){
          $sTraitements .= "Du ";
          $sTraitements .= mbDateToLocale($curr_trmt->debut) ;
          $sTraitements .= " au ";
          $sTraitements .= mbDateToLocale($curr_trmt->fin);
          $sTraitements .= " : ";
        }
        elseif($curr_trmt->debut){
          $sTraitements .= "Depuis le ";
          $sTraitements .= mbDateToLocale($curr_trmt->debut);
          $sTraitements .= " : ";
        }
        
        $sTraitements .= $curr_trmt->traitement;
      }
      $template->addProperty("$champ - Traitements", $sTraitements !== "" ? $sTraitements : null);
    }
    
    // Addictions
    $this->loadRefsAddictions();
    if (is_array($this->_ref_addictions)) {
      $sAddictions = "";
      foreach ($this->_ref_types_addiction as $keyAdd => $currTypeAdd) {
        $sAddictionsParType = "";
        $sType =  CAppUI::tr("CAddiction.type.".$keyAdd);
        foreach ($currTypeAdd as $currAdd) {
          $sAddictionsParType .= "<br /> &bull; ";
          $sAddictionsParType .= $currAdd->addiction;
        }

        $template->addProperty("$champ - Addictions - $sType", $sAddictionsParType);
        
        if (count($currTypeAdd)) {
	        $sAddictions .="<br />";
	        $sAddictions .= $sType;
	        $sAddictions .= $sAddictionsParType;
        }
      }
      
      $template->addProperty("$champ - Addictions -- toutes", $sAddictions !== "" ? $sAddictions : null);
    }
    
    // Etat dentaire
    $this->loadRefsEtatsDents();
    $etats = array();
    if (is_array($this->_ref_etats_dents)) {
      foreach($this->_ref_etats_dents as $etat) {
        if ($etat->etat != null) {
          switch ($etat->dent) {
            case 10: 
            case 30: $position = 'Central haut'; break;
            case 50: 
            case 70: $position = 'Central bas'; break;
            default: $position = $etat->dent;
          }
          if (!isset ($etats[$etat->etat])) {
            $etats[$etat->etat] = array();
          }
          $etats[$etat->etat][] = $position;
        }
      }
    }
    $sEtatsDents = '';
    foreach ($etats as $key => $list) {
      sort($list);
      $sEtatsDents .= '&bull; '.ucfirst($key).' : '.implode(', ', $list).'<br />';
    }
    $template->addProperty("$champ - Etat dentaire", $sEtatsDents);
    
    
    // Codes CIM10
    $aCim10 = array();
    if ($this->_ext_codes_cim){
      foreach ($this->_ext_codes_cim as $curr_code){
        $aCim10[] = "<br />&bull; $curr_code->code : $curr_code->libelle";
      }
    }
    
    $template->addProperty("$champ - Diagnostics", join("", $aCim10));
  }
}

?>