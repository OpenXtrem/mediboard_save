<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

class CPrescriptionProtocolePack extends CMbObject {
  // DB Table key
  var $prescription_protocole_pack_id = null;
  
  // DB Fields
  var $libelle      = null;
  var $praticien_id = null;  // Pack associ� � un praticien
  var $function_id  = null;  // Pack associ� � un cabinet
  var $object_class = null;
  
  // FwdRefs
  var $_ref_praticien = null;
  var $_ref_function  = null;
  
  // BackRefs
  var $_ref_protocole_pack_items = null;
	
	var $_counts_by_chapitre = null;
  
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table = 'prescription_protocole_pack';
    $spec->key   = 'prescription_protocole_pack_id';
    $spec->xor["owner"] = array("function_id", "praticien_id");
    return $spec;
  }
    
  function getProps() {
  	$specs = parent::getProps();
    $specs["praticien_id"]  = "ref class|CMediusers";
    $specs["function_id"]   = "ref class|CFunctions";  
    $specs["libelle"]       = "str notNull";
    $specs["object_class"]  = "enum notNull list|CSejour|CConsultation";
    return $specs;
  }
  
  function getBackProps() {
    $backProps = parent::getBackProps();
    $backProps["prescription_protocole_pack_items"] = "CPrescriptionProtocolePackItem prescription_protocole_pack_id";
    return $backProps;
  }
  
  function updateFormFields(){
    parent::updateFormFields();
    $this->_view = $this->libelle;
  }
  
  /*
   * Chargement des item de packs (protocoles)
   */
  function loadRefsPackItems(){
    $this->_ref_protocole_pack_items = $this->loadBackRefs("prescription_protocole_pack_items");
  }
  
  function loadRefsBack(){
    parent::loadRefsBack();
    $this->loadRefsPackItems();
  }

  function loadRefPraticien(){
    $this->_ref_praticien = new CMediusers();
    $this->_ref_praticien->load($this->praticien_id);  
  }
  
  function loadRefFunction(){
    $this->_ref_function = new CFunctions();
    $this->_ref_function->load($this->function_id);
  }

  function loadRefsFwd(){
    parent::loadRefsFwd();
    $this->loadRefPraticien();
    $this->loadRefFunction();
  }
	
	function countElementsByChapitre(){
		$this->loadRefsPackItems();
	  foreach($this->_ref_protocole_pack_items as $_pack_item){
	    $_pack_item->loadRefPrescription();
	    $_prescription =& $_pack_item->_ref_prescription; 
	    $_prescription->countLinesMedsElements();
	    foreach($_prescription->_counts_by_chapitre as $chapitre => $_count_chapitre){
	      if($_count_chapitre){
	        if(!isset($_pack->_counts_by_chapitre[$chapitre])){
	          $this->_counts_by_chapitre[$chapitre] = 0;
	        }
	        $this->_counts_by_chapitre[$chapitre] += $_count_chapitre;
	      }
	    }
	  }
	}
}

?>