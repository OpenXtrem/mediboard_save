<?php /* $Id: $ */

/**
 *	@package Mediboard
 *	@subpackage dPprescription
 *	@version $Revision: $
 *  @author Alexis Granger
 */

/**
 * The CPrescription class
 */
class CPrescriptionLineElement extends CPrescriptionLine {
  // DB Table key
  var $prescription_line_element_id = null;
  
  // DB Fields
  var $element_prescription_id = null;
  //var $prescription_id         = null;
  var $commentaire             = null;
  
  var $_ref_element_prescription = null;
    
  function CPrescriptionLineElement() {
    $this->CMbObject("prescription_line_element", "prescription_line_element_id");
    
    $this->loadRefModule(basename(dirname(__FILE__)));
  }
  
  function getSpecs() {
  	$specsParent = parent::getSpecs();
    $specs = array (
      "element_prescription_id" => "notNull ref class|CElementPrescription cascade",
      "commentaire"             => "str"
    );
    return array_merge($specsParent, $specs);
  }
  
  function loadRefElement(){
  	$this->_ref_element_prescription = new CElementPrescription();
  	$this->_ref_element_prescription->load($this->element_prescription_id);	
  }
}

?>