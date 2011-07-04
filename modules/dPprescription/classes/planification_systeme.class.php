<?php /* $Id:  $ */

/**
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision: $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

class CPlanificationSysteme extends CMbMetaObject {
	// DB Fields
  var $planification_systeme_id = null;
  var $dateTime                 = null;
  var $unite_prise              = null;
  var $prise_id                 = null;
  var $sejour_id                = null; 
  
	var $_ref_prise               = null;
	var $_ref_administrations     = null;
	
	static $_calcul_planif = true;
	
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table = 'planification_systeme';
    $spec->key   = 'planification_systeme_id';
		$spec->loggable    = false;
    return $spec;
  }
  
	function getBackProps() {
    $backProps = parent::getBackProps();
    $backProps["administration"] = "CAdministration planification_systeme_id";
    return $backProps;
  }

  function getProps() {
    $specs = parent::getProps();
    $specs["object_id"]         = "ref notNull class|CMbObject meta|object_class cascade";
    $specs["object_class"]      = "enum notNull list|CPrescriptionLineMedicament|CPrescriptionLineElement|CPrescriptionLineMixItem";
    $specs["sejour_id"]         = "ref notNull class|CSejour cascade";
    $specs["prise_id"]          = "ref class|CPrisePosologie cascade";
    $specs["unite_prise"]       = "text";
    $specs["dateTime"]          = "dateTime";
    return $specs;
  }
	
	function loadRefPrise(){
    $this->_ref_prise = new CPrisePosologie();
		$this->_ref_prise = $this->_ref_prise->getCached($this->prise_id);
		$this->_ref_prise->updateQuantite();
	}
	
	function loadRefsAdministrations(){
		$this->_ref_administrations = $this->loadBackRefs("administration");
	}
}

?>