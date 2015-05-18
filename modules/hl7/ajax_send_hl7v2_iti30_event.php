<?php

/**
 * $Id$
 *
 * @category HL7
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
 */

CCanDo::checkAdmin();

$receiver_guid = CValue::sessionAbs("cn_receiver_guid");

if (!$receiver_guid || $receiver_guid == "none") {
  CAppUI::stepAjax("Aucun destinataire HL7v2", UI_MSG_ERROR);
}

$profil      = "PAM";
$transaction = "ITI30";
$message     = "ADT";

$patient_id    = CValue::get("patient_id");
$event         = CValue::get("event");

/** @var CReceiverHL7v2 $receiver */
$receiver = CMbObject::loadFromGuid($receiver_guid);
$receiver->loadConfigValues();
$receiver->getInternationalizationCode($transaction);

$patient = new CPatient();
$patient->load($patient_id);

$ack_data    = null;
$iti_handler = new CITI30DelegatedHandler();

switch ($event) {
  case "A28" :
    if (!$iti_handler->isMessageSupported($iti_handler->transaction, $iti_handler->message, $event, $receiver)) {
      CAppUI::setMsg("CEAIDispatcher-_family_message_no_supported_for_this_actor", UI_MSG_ERROR, $receiver);
    }

    $patient->_receiver = $receiver;

    // Envoi de l'�v�nement
    $iti_handler->sendITI($iti_handler->profil, $iti_handler->transaction, $iti_handler->message, $event, $patient);

    break;
}

echo CAppUI::getMsg();