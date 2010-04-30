<?php /* $Id $ */

/**
 * @package Mediboard
 * @subpackage ssr
 * @version $Revision: $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */

class CEvenementSSR extends CMbObject {
  // DB Table key
	var $evenement_ssr_id        = null;
	
	// DB Fields
	var $element_prescription_id = null;
	var $code                    = null; // Code Cdarr
	var $sejour_id               = null;
	var $debut                   = null; // DateTime
	var $duree                   = null; // Dur�e en minutes
	var $therapeute_id           = null;
	var $equipement_id           = null;
  var $realise                 = null;
	
	var $_heure                  = null;
	var $_ref_element_prescription = null;
	var $_nb_decalage_min_debut = null;
	var $_nb_decalage_heure_debut = null;
  var $_nb_decalage_jour_debut = null;
  
	var $_nb_decalage_duree = null;
	
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table       = 'evenement_ssr';
    $spec->key         = 'evenement_ssr_id';
    return $spec;
  }

  function getProps() {
    $props = parent::getProps();
    $props["element_prescription_id"] = "ref notNull class|CElementPrescription";
    $props["code"]          = "str notNull length|4";
    $props["sejour_id"]     = "ref notNull class|CSejour";
    $props["debut"]         = "dateTime notNull";
    $props["duree"]         = "num notNull min|0";
		$props["therapeute_id"] = "ref notNull class|CMediusers";
		$props["equipement_id"] = "ref class|CEquipement";
		$props["realise"]       = "bool default|0";
		$props["_heure"]        = "time";
    $props["_nb_decalage_min_debut"]   = "num";
		$props["_nb_decalage_heure_debut"] = "num";
    $props["_nb_decalage_jour_debut"]  = "num";
		$props["_nb_decalage_duree"]   = "num";
    return $props;
  }
	
  function loadRefElementPrescription() {
    $this->_ref_element_prescription = new CElementPrescription();
    $this->_ref_element_prescription = $this->_ref_element_prescription->getCached($this->element_prescription_id); 
  }
	
	function loadRefSejour(){
		$this->_ref_sejour = new CSejour();
		$this->_ref_sejour = $this->_ref_sejour->getCached($this->sejour_id);
	}
	
	function loadRefTherapeute(){
	  $this->_ref_therapeute = new CMediusers();
    $this->_ref_therapeute = $this->_ref_therapeute->getCached($this->therapeute_id);
	}
}

?>