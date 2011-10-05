<?php

/**
 * A28 - Add person information - HL7
 *  
 * @category HL7
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */

/**
 * Class CHL7v2EventADTA28 
 * A28 - Add person information
 */
class CHL7v2EventADTA28 extends CHL7v2EventADT implements CHL7EventADTA05 {
  function __construct() {
    parent::__construct();
        
    $this->code      = "A28";
    $this->msg_codes = array ( 
      array(
        $this->event_type, $this->code, "{$this->event_type}_A05"
      )
    );
  }
  
  function build($patient) {
    parent::build($patient);
    
    // Patient Identification
    $this->addPID($patient);
    
    // Patient Additional Demographic
    $this->addPD1($patient);
    
    // Doctors
    $this->addROLs($patient);
    
    // Next of Kin / Associated Parties
    $this->addNK1s($patient);
    
    // Patient Visit
    $this->addPV1();
  }
  
}

?>