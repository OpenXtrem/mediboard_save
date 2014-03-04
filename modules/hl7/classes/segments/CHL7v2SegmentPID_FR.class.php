<?php

/**
 * Represents an HL7 PID message segment (Patient Identification) - HL7
 *  
 * @category HL7
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */

/**
 * Class CHL7v2SegmentPID 
 * PID - Represents an HL7 PID message segment (Patient Identification)
 */

class CHL7v2SegmentPID_FR extends CHL7v2SegmentPID {
  /**
   * Fill other identifiers
   *
   * @param array         &$identifiers Identifiers
   * @param CPatient      $patient      Person
   * @param CInteropActor $actor        Interop actor
   *
   * @return null
   */
  function fillOtherIdentifiers(&$identifiers, CPatient $patient, CInteropActor $actor = null) {
    //@todo recup�r� l'insc avec la fonction loadLastINS
    /*if ($patient->INSC) {
      $identifiers[] = array(
        $patient->INSC,
        null,
        null,
        // PID-3-4 Autorit� d'affectation
        $this->getAssigningAuthority("INS-C"),
        "INS-C",
        null,
        CMbDT::date($patient->INSC_date)
      );
    }*/

    if ($actor->_configs["send_own_identifier"]) {
      $identifiers[] = array(
        $patient->_id,
        null,
        null,
        // PID-3-4 Autorit� d'affectation
        $this->getAssigningAuthority("mediboard"),
        $actor->_configs["build_identifier_authority"] == "PI_AN" ? "PI": "RI"
      );
    }
  }
}
