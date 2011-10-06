<?php 
/**
 * Send message
 *  
 * @category EAI
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */

CCanDo::checkRead();

$exchange_guid = CValue::get("exchange_guid");

// Chargement de l'objet
$exchange = CMbObject::loadFromGuid($exchange_guid);
$exchange->loadRefsInteropActor();

if (!$exchange->message_valide) {
  CAppUI::stepAjax("Le message de l'�change est invalide il ne peut pas �tre renvoy�", UI_MSG_ERROR);
}

$receiver = $exchange->_ref_receiver;

$evenement = null;
if ($receiver instanceof CReceiverIHE) {
  if ($exchange->type = "PAM") {
    $evenement = "evenementsPatient";
  }
}

if ($receiver instanceof CDestinataireHprim) {
  if ($exchange->type = "patients") {
    $evenement = "evenementPatient";
  }
  if ($exchange->type = "pmsi") {
    
  }
}

if (!$evenement) {
  CAppUI::stepAjax("Aucun �v�nement d�fini pour cet �change", UI_MSG_ERROR);
}

$source = CExchangeSource::get("$receiver->_guid-$evenement");
if (!$source->_id) {
  CAppUI::stepAjax("Aucune source pour cet acteur", UI_MSG_ERROR);
}

$source->setData($exchange->_message);
$source->send();
if ($acq = $source->getACQ()) {
  if ($exchange instanceof CEchangeHprim) {
    $dom_acq = CHPrimXMLAcquittements::getAcquittementEvenementXML($receiver->_data_format->_family_message);
    $dom_acq->loadXML($acq);
    $doc_valid = $dom_acq->schemaValidate();
    if ($doc_valid) {
      $exchange->statut_acquittement = $dom_acq->getStatutAcquittement();
    }
    $exchange->acquittement_valide = $doc_valid ? 1 : 0;
    $exchange->_acquittement = $acq;
    $exchange->store();
    
    CAppUI::stepAjax("Le message '".CAppUI::tr("$exchange->_class")."' a �t� retrait�");
  }
}

?>