<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage dPccam
 * @version $Revision$
 * @author Alexis Granger
 */


class CActe extends CMbMetaObject {
  
  // DB fields
  var $montant_depassement = null;
  var $montant_base        = null;
  
  // DB References
  var $executant_id        = null;

  // Form fields
  var $_preserve_montant   = null; 
  var $_montant_facture    = null;
  
  // Behaviour fields
  var $_check_coded  = true;
  
  // Distant object
  var $_ref_sejour = null;
  var $_ref_patient = null;
  var $_ref_praticien = null; // Probable user
  var $_ref_executant = null; // Actual user
  
  var $_list_executants = null;
  
  function updateFormFields() {
    parent::updateFormFields();
    $this->_montant_facture = $this->montant_base + $this->montant_depassement;
  }
  
  function loadRefSejour() {
    $this->loadTargetObject();
    $this->_ref_object->loadRefSejour();
    $this->_ref_sejour =& $this->_ref_object->_ref_sejour;
  }
  
  function loadRefPatient() {
    $this->loadTargetObject();
    $this->_ref_object->loadRefPatient();
    $this->_ref_patient =& $this->_ref_object->_ref_patient;
  }
  
  function loadRefPraticien() {
    $this->loadTargetObject();
    $this->_ref_object->loadRefPraticien();
    $this->_ref_praticien =& $this->_ref_object->_ref_praticien;
  }
  
  function loadRefExecutant() {
    $this->_ref_executant = new CMediusers();
    $this->_ref_executant->load($this->executant_id);
    $this->_ref_executant->loadRefFunction();
  }
  
  function loadListExecutants($guess = true) {
    global $AppUI;
    
    $list_executants = new CMediusers;
    $this->_list_executants = $list_executants->loadPraticiens(PERM_READ);
    
    // We guess who is the executant
    if ($guess && $this->executant_id == null && $this->_id == null) {
      if ($this->_ref_object && $this->loadRefPraticien() && $this->_ref_praticien->_id) {
        $this->executant_id = $this->_ref_praticien->_id;
        return;
      }
      else {
        $user = new CMediusers();
        $user->load($AppUI->user_id);
        if ($user->isPraticien()) {
          $this->executant_id = $user->_id;
          return;
        }
      }
    }
  }
  
  function getSpecs() {
    $specs = parent::getSpecs();
    $specs["object_id"]           = "notNull ref class|CCodable meta|object_class";
    $specs["object_class"]        = "notNull enum list|COperation|CSejour|CConsultation";
    $specs["executant_id"]        = "notNull ref class|CMediusers";
    $specs["montant_depassement"] = "currency";
    $specs["montant_base"]        = "currency";
    $specs["_montant_facture"]    = "currency";
    return $specs;
  }
  
  function checkCoded() {
    if(!$this->_check_coded){
        return;
    }
    $object = new $this->object_class;
    $object->load($this->object_id);
    if($object->_coded == "1") {
      return "$object->_class_name d�j� valid�e : Impossible de coter l\'acte";
    }
  }

  function updateMontant(){
    if(!$this->_preserve_montant){
      $object = new $this->object_class;
      $object->load($this->object_id);
      // Permet de mettre a jour le montant dans le cas d'un consultation
      return $object->doUpdateMontants();
    }
  }
  
  function store(){
    if ($msg = parent::store()){
      return $msg;
    }
    return $this->updateMontant();
  }
  
  function delete(){
    if ($msg = parent::delete()){
      return $msg;
    }
    return $this->updateMontant();
  }
}

?>