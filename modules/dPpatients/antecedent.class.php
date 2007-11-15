<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPpatients
* @version $Revision$
* @author Romain Ollivier
*/

class CAntecedent extends CMbObject {
  // DB Table key
  var $antecedent_id = null;

  // DB fields
  var $type               = null;
  var $date               = null;
  var $rques              = null;
  var $dossier_medical_id = null;
  
  function CAntecedent() {
    $this->CMbObject("antecedent", "antecedent_id");
    
    $this->loadRefModule(basename(dirname(__FILE__)));
  }

  function getSpecs() {
    $specs = parent::getSpecs();
    $specs["type"        ] = "notNull enum list|med|alle|trans|obst|chir|fam|anesth|gyn";
    $specs["date"        ] = "date";
    $specs["rques"       ] = "text";
    $specs["dossier_medical_id"] = "ref class|CDossierMedical";
    return $specs;
  }
  
  function store() {
    // Standard store
    if ($msg = parent::store()) {
      return $msg;
    }
    // DossierMedical store
    $this->checkCodeCim10();
  }
  
  function checkCodeCim10(){
    preg_match_all("/[A-Z]\d{2}\.?\d{0,2}/i", $this->rques, $matches);
    
    foreach($matches as $key => $match_){
      foreach($match_ as &$match){
        // Transformation du code CIM pour le tester
        $match = str_replace(".","",$match);
        $match = strtoupper($match);
        // Chargement du code CIM 10
        $code_cim10 = new CCodeCIM10($match, 1);
    
        if($code_cim10->libelle != "Code CIM inexistant"){
          // Cas du code valide, sauvegarde du code CIM
          $dossier_medical = new CDossierMedical();
          $dossier_medical->load($this->dossier_medical_id);
          
          // si le code n'est pas deja present, on le rajoute
          if(!array_key_exists($match, $dossier_medical->_codes_cim10)){
            if($dossier_medical->listCim10 != ""){
              $dossier_medical->listCim10 .= "|";
            }
            $dossier_medical->listCim10 .= $match;
            $dossier_medical->store();
          }
        }
      }
    }
  }
  
  function loadRefDossierMedical(){ 
    $this->_ref_dossier_medical = new CDossierMedical();
    $this->_ref_dossier_medical->load($this->dossier_medical_id);
  }
  
  function getHelpedFields(){
    return array(
      "rques" => "type"
    );
  }
}

?>