<?php 

/**
 * $Id$
 *  
 * @category EAI
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
 */

CCanDo::checkRead();

$receiver_guid = CValue::get("receiver_guid");
/** @var CReceiverHL7v2 $receiver */
$receiver = CMbObject::loadFromGuid($receiver_guid);

if (!$receiver && !$receiver->_id && !$receiver->actif) {
  return;
}
$receiver->loadConfigValues();

$where = '';

$echange_hl7v2 = new CExchangeHL7v2();
$where['statut_acquittement']     = "IS NULL";
$where['sender_id']               = "IS NULL";
$where['receiver_id']             = "= '$receiver->_id'";
$where['message_valide']          = "= '1'";
$where['date_echange']            = "IS NULL";
$where['date_production']         = "BETWEEN '".CMbDT::dateTime("-3 DAYS")."' AND '".CMbDT::dateTime("+1 DAYS")."'";

/** @var CExchangeHL7v2[] $exchanges */
$exchanges = $echange_hl7v2->loadList($where, null);

// Effectue le traitement d'enregistrement des notifications sur lequel le cron vient de passer
// ce qui permet la gestion des doublons
foreach ($exchanges as $_exchange) {
  $_exchange->date_echange = CMbDT::dateTime();
  $_exchange->store();
}

$receiver->synchronous = "1";

foreach ($exchanges as $_exchange) {
  try {
    $_exchange->_ref_receiver = $receiver;
    $object = CMbObject::loadFromGuid("$_exchange->object_class-$_exchange->object_id");
    if (!$object) {
      $_exchange->date_echange = "";
      $_exchange->store();
      continue;
    }

    //R�cup�ration du s�jour et du patient en fonction de l'objet
    switch ($_exchange->object_class) {
      case "CPatient":
        /** @var CPatient $patient */
        $patient = $object;
        //Recherche du s�jour en cours
        $sejour = reset($patient->getCurrSejour());
        //R�cup�ration du dernier s�jour
        if (!$sejour) {
          $sejour = reset($patient->loadRefsSejours());
        }
        break;
      case "CSejour":
        /** @var CSejour $sejour */
        $sejour = $object;
        $patient = $sejour->loadRefPatient();
        break;
      default:
        $_exchange->date_echange = "";
        $_exchange->store();
        continue;
    }

    $patient->loadIPP();
    if (!$patient->_IPP) {
      $_exchange->date_echange = "";
      $_exchange->store();
      continue;
    }

    if ($_exchange->sous_type == "ITI30" && $_exchange->code != "A08") {
      $present_sejour = true;
      $present_patient = $patient && !$patient->_id;
    }
    else {
      $present_patient = $patient && !$patient->_id;
      $present_sejour = $sejour && !$sejour->_id;

      $sejour->loadNDA();
      if (!$sejour->_NDA) {
        $_exchange->date_echange = "";
        $_exchange->store();
        continue;
      }
    }

    //S'il n'y a pas de s�jour ou de patient en focntion de la transaction, on passe au prochaine �change
    if ($present_sejour && $present_patient) {
      $_exchange->date_echange = "";
      $_exchange->store();
      continue;
    }

    $object->_receiver = $receiver;

    /** @var CHL7v2Event $data_format */
    $data_format = CIHE::getEvent($_exchange);
    $data_format->handle($_exchange->_message);
    $data_format->_exchange_hl7v2 = $_exchange;
    $data_format->_receiver = $receiver;
    /** @var CHL7v2MessageXML $xml */
    $xml = $data_format->message->toXML();

    $PID = $xml->queryNode("PID");
    $ipp = $xml->queryNode("PID.3", $PID);

    $PV1 = $xml->queryNode("PV1");
    $nda = $xml->queryNode("PV1.19", $PV1);

    if ($_exchange->code != "A40" &&
        (((!$ipp && !$ipp->nodeValue) || $ipp->nodeValue == "0") ||
        (($_exchange->sous_type != "ITI30" ||
        ($_exchange->sous_type == "ITI30" && $_exchange->code == "A08"))  && !$nda && empty($nda->nodeValue)))
    ) {

      CHL7v2Message::setBuildMode($receiver->_configs["build_mode"]);
      $data_format->build($object);
      CHL7v2Message::resetBuildMode();

      $data_format->flatten();
      if (!$data_format->message->isOK(CHL7v2Error::E_ERROR)) {
        $_exchange->date_echange = "";
        $_exchange->store();
        continue;
      }
    }

    $evt    = $receiver->getEventMessage($data_format->profil);
    $source = CExchangeSource::get("$receiver->_guid-$evt");

    if (!$source->_id || !$source->active) {
      new CMbException("Source inactive");
    }

    $msg = $data_format->msg_hl7 ? $data_format->msg_hl7 : $_exchange->_message;
    if ($receiver->_configs["encoding"] == "UTF-8") {
      $msg = utf8_encode($msg);
    }

    $source->setData($msg, null, $_exchange);
    $source->send();
  }
  catch (Exception $e) {
    $_exchange->date_echange = "";
    $_exchange->store();
    continue;
  }
}