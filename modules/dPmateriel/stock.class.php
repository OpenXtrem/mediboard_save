<?php /* $Id: $ */

/**
 *	@package Mediboard
 *	@subpackage dPmateriel
 *	@version $Revision: $
 *  @author Sébastien Fillonneau
 */

/**
 * The CStock class
 */
class CStock extends CMbObject {
  // DB Table key
  var $stock_id = null;
	
  // DB Fields
  var $materiel_id = null;
  var $group_id    = null;
  var $seuil_cmd   = null;
  var $quantite    = null;
  
  // Form fields
  var $_rupture = null;

  // Object References
  var $_ref_group = null;
  var $_ref_materiel = null;

	function CStock() {
	  $this->CMbObject("stock", "stock_id");
    
    $this->loadRefModule(basename(dirname(__FILE__)));
  }

  function getSpecs() {
  	$specsParent = parent::getSpecs();
    $specs = array (
      "materiel_id" => "notNull ref class|CMateriel",
      "group_id"    => "notNull ref class|CGroups",
      "seuil_cmd"   => "notNull num pos",
      "quantite"    => "num min|0"
    );
    return array_merge($specsParent, $specs);
  }
  
  function updateFormFields() {
    parent::updateFormFields();
    $this->loadRefsFwd();
    $this->_view = $this->_ref_materiel->_view;
    $this->_rupture = $this->quantite <= $this->seuil_cmd;
  }
  
  function loadRefsFwd(){  
    $this->_ref_group = new CGroups;
    $this->_ref_group->load($this->group_id);
    
    $this->_ref_materiel = new CMateriel;
    $this->_ref_materiel->load($this->materiel_id);
  }
  
  function getPerm($permType) {
    if(!$this->_ref_group || !$this->_ref_materiel) {
      $this->loadRefsFwd();
    }
    return ($this->_ref_group->getPerm($permType) && $this->_ref_materiel->getPerm($permType));
  }
    
   function check() {
     if(!$this->stock_id) {
       $where["materiel_id"] = "= '$this->materiel_id'";
       $where["group_id"] = "= '$this->group_id'";
       $where["stock_id"] = "!= '$this->stock_id'";
       $VerifDuplicateKey = new CStock(); 
       $ListVerifDuplicateKey = $VerifDuplicateKey->loadList($where);
       if(count($ListVerifDuplicateKey)!=0) {
         return "erreur : stock existe deja";  
       } else {
         return null;  
       }
     }
   }
}
?>