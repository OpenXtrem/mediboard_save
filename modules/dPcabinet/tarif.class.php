<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPcabinet
* @version $Revision$
* @author Romain Ollivier
*/

class CTarif extends CMbObject {
  // DB Table key
  var $tarif_id = null;

  // DB References
  var $chir_id     = null;
  var $function_id = null;

  // DB fields
  var $description = null;
  var $secteur1    = null;
  var $secteur2    = null;
  
  // Form fields
  var $_type = null;

  // Object References
  var $_ref_chir     = null;
  var $_ref_function = null;

  function CTarif() {
    $this->CMbObject("tarifs", "tarif_id");
    
    $this->loadRefModule(basename(dirname(__FILE__)));
    
    $this->_props["chir_id"]     = "ref";
    $this->_props["function_id"] = "ref";
    $this->_props["description"] = "str|notNull|confidential";
    $this->_props["secteur1"]    = "currency|min|0|notNull";
    $this->_props["secteur2"]    = "currency|min|0";

    $this->_seek["description"] = "like";
  }
  
  function updateFormFields() {
    parent::updateFormFields();
    if($this->chir_id == 0)
      $_type = "chir";
    else
      $_type = "function";
  }
  
  function updateDBFields() {
  	if($this->_type !== null) {
      if($this->_type == "chir")
        $this->function_id = 0;
      else
        $this->chir_id = 0;
  	}
  }
  
  function loadRefsFwd() {
    $this->_ref_chir = new CMediusers();
    $this->_ref_chir->load($this->chir_id);
    $this->_ref_function = new CFunctions();
    $this->_ref_function->load($this->function_id);
  }
  
  function getPerm($permType) {
    if(!$this->_ref_chir || !$this->_ref_function) {
      $this->loadRefsFwd();
    }
    return ($this->_ref_chir->getPerm($permType) && $this->_ref_function->getPerm($permType));
  }
}

?>