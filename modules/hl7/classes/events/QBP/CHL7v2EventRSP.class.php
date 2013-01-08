<?php

/**
 * Represents a RSP message structure (see chapter 2.14.1) HL7
 *  
 * @category HL7
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */

/**
 * Classe CHL7v2EventRSP
 * Represents a RSP message structure (see chapter 2.14.1)
 */
class CHL7v2EventRSP extends CHL7v2Event implements CHL7EventRSP {
  function __construct(CHL7Event $trigger_event) {
    $this->event_type  = "RSP";
    $this->version     = $trigger_event->message->version;

    switch ($trigger_event->code) {
      case "Q22" :
        $trigger_event_code = "K22";
        $struct_code   = "K21";
        break;
      case "ZV1" :
        $trigger_event_code = $struct_code   = "ZV2";
        break;
    }

    $this->msg_codes   = array (
      array(
        $this->event_type, $trigger_event_code, "{$this->event_type}_{$struct_code}"
      )
    );

    $this->_exchange_ihe = $trigger_event->_exchange_ihe;
    $this->_receiver     = $trigger_event->_exchange_ihe->_ref_receiver;
    $this->_sender       = $trigger_event->_exchange_ihe->_ref_sender;
  }

  /**
   * Build
   *
   * @param CHL7Acknowledgment $object Object
   *
   * @return void
   */
  function build($object) {
    // Cr�ation du message HL7
    $this->message          = new CHL7v2Message();
    $this->message->version = $this->version;
    $this->message->name    = $this->msg_codes;
    
    // Message Header 
    $this->addMSH();
    
    // Message Acknowledgment
    $this->addMSA($object);

    // Query Acknowledgment
    $this->addQAK($object->objects);

    // Query Parameter Definition
    $this->addQPD();

    foreach ($object->objects as $_object) {
      if ($_object instanceof CPatient) {
        $this->addPID($_object);


      }
    }
  }

  /**
   * MSH - Represents an HL7 MSH message segment (Message Header)
   *
   * @return void
   */
  function addMSH() {
    $MSH = CHL7v2Segment::create("MSH", $this->message);
    $MSH->build($this);
  }

  /**
   * MSA - Represents an HL7 MSA message segment (Message Acknowledgment)
   *
   * @param CHL7Acknowledgment $acknowledgment Acknowledgment
   *
   * @return void
   */
  function addMSA(CHL7Acknowledgment $acknowledgment) {
    $MSA = CHL7v2Segment::create("MSA", $this->message);
    $MSA->acknowledgment = $acknowledgment;
    $MSA->build($this);
  }

  /**
   * Represents an HL7 QAK message segment (Query Acknowledgment)
   *
   * @param array $results Results
   *
   * @return void
   */
  function addQAK($objects = array()) {
    $QAK = CHL7v2Segment::create("QAK", $this->message);
    $QAK->_objects = $objects;
    $QAK->build($this);
  }

  /**
   * MSH - Represents an HL7 MSH message segment (Message Header)
   *
   * @return void
   */
  function addQPD() {
    $QPD = CHL7v2Segment::create("QPD", $this->message);
    $QPD->build($this);
  }

  /**
   * Represents an HL7 PID message segment (Patient Identification)
   *
   * @param CPatient $patient Patient
   *
   * @return void
   */
  function addPID(CPatient $patient) {
    $PID = CHL7v2Segment::create("PID", $this->message);
    $PID->patient = $patient;
    $PID->set_id  = 1;
    $PID->build($this);
  }
  
  function flatten() {
    $this->msg_hl7 = $this->message->flatten();
    $this->message->validate();
  }
}

?>