<?php /* $Id $ */

/**
 * @package Mediboard
 * @subpackage hprimxml
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */

class CDestinataireHprim extends CInteropReceiver {
  // DB Table key
  public $dest_hprim_id;
  
  // DB Fields
  public $register;
  public $code_appli;
  public $code_acteur;
  public $code_syst;
  
  // Form fields
  public $_tag_hprimxml;
    
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table = 'destinataire_hprim';
    $spec->key   = 'dest_hprim_id';
    $spec->messages = array(
      "patients" => array ( 
        "evenementPatient" 
      ),
      "pmsi" => array(
        (CAppUI::conf("hprimxml send_diagnostic") == "evt_serveuretatspatient") ? 
          "evenementServeurEtatsPatient" : "evenementPMSI",
        "evenementServeurActe",
        "evenementFraisDivers",
        "evenementServeurIntervention"
      ),
      "stock" => array ( 
        "evenementMvtStocks"
      )
    );
    return $spec;
  }
  
  function getProps() {
    $props = parent::getProps();
    $props["register"]    = "bool notNull default|1";
    $props["code_appli"]  = "str";
    $props["code_acteur"] = "str";
    $props["code_syst"]   = "str";

    return $props;
  }
  
  function getBackProps() {
    $backProps = parent::getBackProps();
    $backProps['object_configs'] = "CDestinataireHprimConfig object_id";
    $backProps['echanges']       = "CEchangeHprim receiver_id";
    
    return $backProps;
  }
  
  function updateFormFields() {
    parent::updateFormFields();

    $this->code_syst = $this->code_syst ? $this->code_syst : $this->nom;
  }
  
  function sendEvenementPatient(CHPrimXMLEvenementsPatients $dom_evt, CMbObject $mbObject, $referent = null, $initiateur = null) {
    if (!$msg = $dom_evt->generateTypeEvenement($mbObject, $referent, $initiateur)) {
      return;
    }
    
    $source = CExchangeSource::get("$this->_guid-evenementPatient");
    if (!$source->_id || !$source->active) {
      return;
    }
    
    $exchange = $dom_evt->_ref_echange_hprim;

    $source->setData($msg, false, $exchange);
    try {
      $source->send();
    } catch (Exception $e) {
      throw new CMbException("CExchangeSource-no-response");
    }
    
    $exchange->date_echange = CMbDT::dateTime();
    
    $acq = $source->getACQ();
    if (!$acq) {
      $exchange->store();
      return;
    }  
    
    $dom_acq = new CHPrimXMLAcquittementsPatients();
    $dom_acq->loadXML($acq);
    $dom_acq->_ref_echange_hprim = $exchange;
    $doc_valid = $dom_acq->schemaValidate();
    
    $exchange->statut_acquittement = $dom_acq->getStatutAcquittementPatient();
    $exchange->acquittement_valide = $doc_valid ? 1 : 0;
    $exchange->_acquittement = $acq;

    $exchange->store();
  }
  
  function sendEvenementPMSI(CHPrimXMLEvenementsServeurActivitePmsi $dom_evt, CMbObject $mbObject) {
    if (!$msg = $dom_evt->generateTypeEvenement($mbObject)) {
      return;
    }
    
    $source = CExchangeSource::get("$this->_guid-$dom_evt->sous_type");
    if (!$source->_id || !$source->active) {
      return;
    }

    $exchange = $dom_evt->_ref_echange_hprim;
    
    $source->setData($msg, false, $exchange);
    try {
      $source->send();
    } catch (Exception $e) {
      throw new CMbException("CExchangeSource-no-response");
    }
    
    $exchange->date_echange = CMbDT::dateTime();

    $acq = $source->getACQ();
    if (!$acq) {
      $exchange->store();
      return;
    }  
     
    $dom_acq = CHPrimXMLAcquittementsServeurActivitePmsi::getEvtAcquittement($dom_evt);
    $dom_acq->loadXML($acq);
    $dom_acq->_ref_echange_hprim = $exchange;
    $doc_valid = $dom_acq->schemaValidate();
    
    $exchange->statut_acquittement = $dom_acq->getStatutAcquittementServeurActivitePmsi();
    $exchange->acquittement_valide = $doc_valid ? 1 : 0;
    $exchange->_acquittement = $acq;
    
    $exchange->store();
  }
  
  function lastMessage() {
    $echg_hprim = new CEchangeHprim();
    $echg_hprim->_load_content = false;
    $where = array();
    $where["sender_id"] = " = '$this->_id'";    
    $key = $echg_hprim->_spec->key;
    $echg_hprim->loadObject($where, "$key DESC");
    $this->_ref_last_message = $echg_hprim;
  }
  
  function getFormatObjectHandler(CEAIObjectHandler $objectHandler) {
    $hprim_object_handlers = CHprimXML::getObjectHandlers();
    $object_handler_class  = get_class($objectHandler);
    if (array_key_exists($object_handler_class, $hprim_object_handlers)) {
      return new $hprim_object_handlers[$object_handler_class];
    }
  }
}

?>