<?php /* $Id $ */

/**
 * @package Mediboard
 * @subpackage ssr
 * @version $Revision: 6148 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */

/**
 * Ligne d'activit�s RHS
 */
class CLigneActivitesRHS extends CMbObject {  
  // DB Table key
  var $ligne_id = null;
  
  // DB Fields
  var $rhs_id                 = null;
  var $executant_id           = null;
  var $code_activite_cdarr    = null;
	var $code_intervenant_cdarr = null;
	
  var $qty_mon = null;
  var $qty_tue = null;
  var $qty_wed = null;
  var $qty_thu = null;
  var $qty_fri = null;
  var $qty_sat = null;
  var $qty_sun = null;

  // Form fields
	var $_qty_total = null;
	var $_executant = null;
	
	// Distant fields

	// References
	var $_ref_rhs                    = null;
	var $_ref_code_activite_cdarr    = null;
	var $_ref_code_intervenant_cdarr = null;
	
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table = 'ligne_activites_rhs';
    $spec->key   = 'ligne_id';
    return $spec;
  }

  function getProps() {
    $props = parent::getProps();

    // DB Fields
    $props["rhs_id"]                 = "ref notNull class|CRHS";
    $props["executant_id"]           = "ref notNull class|CMediusers";
    $props["code_activite_cdarr"]    = "str notNull length|4";
    $props["code_intervenant_cdarr"] = "str length|2";
    $props["qty_mon"]                = "num length|1 min|0 max|9 default|0";
    $props["qty_tue"]                = "num length|1 min|0 max|9 default|0";
    $props["qty_wed"]                = "num length|1 min|0 max|9 default|0";
    $props["qty_thu"]                = "num length|1 min|0 max|9 default|0";
    $props["qty_fri"]                = "num length|1 min|0 max|9 default|0";
    $props["qty_sat"]                = "num length|1 min|0 max|9 default|0";
    $props["qty_sun"]                = "num length|1 min|0 max|9 default|0";

    // Form fields
    $props["_qty_total"]             = "num min|0 max|99";
    $props["_executant"]             = "str maxLength|50";
  
    return $props;
  }
  
  function updateFormFields() {
    parent::updateFormFields();
    $this->loadRefActiviteCdARR();
    $this->_view = $this->_ref_code_activite_cdarr->_view;
    $this->_qty_total = $this->qty_mon + $this->qty_tue + $this->qty_wed + $this->qty_thu +
                        $this->qty_fri + $this->qty_sat + $this->qty_sun;
  }
  
  function loadRefActiviteCdARR() {
    $this->_ref_code_activite_cdarr = new CActiviteCdARR();
    $this->_ref_code_activite_cdarr->load($this->code_activite_cdarr);
  }
  
  function loadRefIntervenantCdARR() {
    $this->_ref_code_intervenant_cdarr = new CIntervenantCdARR();
    $this->_ref_code_intervenant_cdarr->load($this->code_intervenant_cdarr);
  }
	
	function loadRefRHS() {
		$this->_ref_rhs = $this->loadFwdRef("rhs_id");
	}
}

?>