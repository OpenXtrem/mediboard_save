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
  /**
   * Construct
   *
   * @param CHL7Event $trigger_event Trigger event
   *
   * @return CHL7v2EventRSP
   */
  function __construct(CHL7Event $trigger_event) {
    $this->profil      = "PDQ";

    $this->event_type  = "RSP";
    $this->version     = $trigger_event->message->version;

    switch ($trigger_event->code) {
      case "Q22" :
        $this->code        = "K22";
        $this->struct_code = "K21";
        break;
      case "ZV1" :
        $this->code = $this->struct_code = "ZV2";
        break;
    }

    $this->msg_codes   = array (
      array(
        $this->event_type, $this->code, "{$this->event_type}_{$this->struct_code}"
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

    $message      = $this->_exchange_ihe->_message;

    $hl7_message_initiator = new CHL7v2Message();
    $hl7_message_initiator->parse($message);

    $this->message->_hl7_message_initiator = $hl7_message_initiator;

    // Message Header 
    $this->addMSH();
    
    // Message Acknowledgment
    $this->addMSA($object);

    // Error
    $trigger_event = $object->event;
    // Validation error
    if ($errors = $trigger_event->message->errors) {
      foreach ($errors as $_error) {
        $this->addERR($object, $_error);
      }
    }

    // Error unrecognized domain
    if ($object->QPD8_error) {
      $error           = new CHL7v2Error();
      $error->code     = CHL7v2Exception::UNKNOWN_KEY_IDENTIFIER;
      $error->location = array(
        "QPD",
        1,
        8,
        1
      );

      $this->addERR($object, $error);
    }

    // Query Acknowledgment
    $this->addQAK($object->objects);

    // Query Parameter Definition
    $this->addQPD();

    $i = 0;
    if (!$object->objects) {
      return;
    }

    // Results
    foreach ($object->objects as $_object) {
      if ($_object instanceof CPatient) {
        $this->addPID($_object, $i);

        $i++;
      }
    }

    //$last = end($object->objects);
    /*if ($last) {
      $last->_id
    }*/
  }

  /**
   * Get the message as a string
   *
   * @return string
   */
  function flatten() {
    $this->msg_hl7 = $this->message->flatten();
    $this->message->validate();
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
   * ERR - Represents an HL7 ERR message segment (Error)
   *
   * @param CHL7Acknowledgment $acknowledgment Acknowledgment
   * @param CHL7v2Error|null   $error          Error HL7
   *
   * @return void
   */
  function addERR(CHL7Acknowledgment $acknowledgment, $error = null) {
    $ERR = CHL7v2Segment::create("ERR", $this->message);
    $ERR->acknowledgment = $acknowledgment;
    $ERR->error = $error;
    $ERR->build($this);
  }

  /**
   * Represents an HL7 QAK message segment (Query Acknowledgment)
   *
   * @param array $objects Objects
   *
   * @return void
   */
  function addQAK($objects = array()) {
    $QAK = CHL7v2Segment::create("QAK", $this->message);
    $QAK->objects = $objects;
    $QAK->build($this);
  }

  /**
   * MSH - Represents an HL7 QPD message segment (Message Header)
   *
   * @return void
   */
  function addQPD() {
    $QPD = CHL7v2Segment::create("QPD_RESP", $this->message);
    $QPD->build($this);
  }

  /**
   * Represents an HL7 PID message segment (Patient Identification)
   *
   * @param CPatient $patient Patient
   * @param string   $set_id  Set ID
   *
   * @return void
   */
  function addPID(CPatient $patient, $set_id) {
    $PID = CHL7v2Segment::create("PID_RESP", $this->message);
    $PID->patient = $patient;
    $patient->getCurrSejour();
    $PID->sejour = reset($patient->_ref_sejours);
    $PID->set_id  = $set_id;
    $PID->build($this);
  }
}