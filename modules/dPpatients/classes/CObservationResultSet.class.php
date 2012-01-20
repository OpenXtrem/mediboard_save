<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage classes
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

/**
 * Observation result set, based on the HL7 OBR message
 * http://www.interfaceware.com/hl7-standard/hl7-segment-OBR.html
 */
class CObservationResultSet extends CMbObject {
  var $observation_result_set_id = null;
  
  var $patient_id            = null;
  var $datetime              = null;
  var $context_class         = null;
  var $context_id            = null;
  
  var $_ref_context          = null;
  var $_ref_patient          = null;
  var $_ref_results          = null;
  
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table = "observation_result_set";
    $spec->key   = "observation_result_set_id";
    $spec->measureable = true;
    return $spec;
  }
  
  function getProps() {
    $props = parent::getProps();
    $props["patient_id"]    = "ref notNull class|CPatient";
    $props["datetime"]      = "dateTime notNull";
    $props["context_class"] = "str notNull";
    $props["context_id"]    = "ref class|CMbObject meta|context_class";
    return $props;
  }
  
  function getBackProps() {
    $backProps = parent::getBackProps();
    $backProps["observation_results"] = "CObservationResult observation_result_set_id";
    return $backProps;
  }
  
  function updateFormFields(){
    parent::updateFormFields();
    
    $this->_view = $this->getFormattedValue("datetime");
  }
  
  /**
   * @return CMbObject
   */
  function loadRefContext($cache = true) {
    return $this->_ref_context = $this->loadFwdRef("context_id", $cache);
  }
  
  /**
   * @return CPatient
   */
  function loadRefPatient($cache = true) {
    return $this->_ref_patient = $this->loadFwdRef("patient_id", $cache);
  }
  
  function loadRefsResults(){
    return $this->_ref_results = $this->loadBackRefs("observation_results");
  }
  
  static function getResultsFor(CMbObject $object) {
    $request = new CRequest;
    $request->addTable("observation_result");
    $request->addSelect("*");
    $request->addLJoin(array(
      "observation_result_set" => "observation_result_set.observation_result_set_id = observation_result.observation_result_set_id",
    ));
    $request->addWhere(array(
      "observation_result_set.context_class" => "= '$object->_class'",
      "observation_result_set.context_id"    => "= '$object->_id'",
    ));
    
    $results = $object->_spec->ds->loadList($request->getRequest());
    
    $times = array();
    $data = array();
    
    foreach($results as $_result) {
      $_time = CMbDate::toUTCTimestamp($_result["datetime"]);
      $times[$_time] = $_time;
      
      $data[$_result["value_type_id"]][$_result["unit_id"]][] = array(
        $_time,
        floatval($_result["value"]),
      );
    }
    
    return array($data, array_values($times));
  }
}
