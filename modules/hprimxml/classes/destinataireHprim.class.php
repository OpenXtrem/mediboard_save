<?php /* $Id $ */

/**
 * @package Mediboard
 * @subpackage hprimxml
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */

CAppUI::requireModuleClass("eai", "interop_receiver");

class CDestinataireHprim extends CInteropReceiver {
  // DB Table key
  var $dest_hprim_id  = null;
  
  // DB Fields
  var $register    = null;
  var $code_appli  = null;
  var $code_acteur = null;
  var $code_syst   = null;
	  
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
        "evenementFraisDivers"
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
    
	function loadRefsExchangesSources() {
	  if (!$this->_ref_msg_supported_family) {
	    $this->getMessagesSupportedByFamily();
	  }

		$this->_ref_exchanges_sources = array();
		foreach ($this->_ref_msg_supported_family as $_evenement) {
      $this->_ref_exchanges_sources[$_evenement] = CExchangeSource::get("$this->_guid-$_evenement", null, true, $this->_type_echange);
		}
	}
  
  function updateFormFields() {
    parent::updateFormFields();

		$this->code_syst = $this->code_syst ? $this->code_syst : $this->nom;
  }  
  
  function sendEvenementPatient(CHPrimXMLEvenementsPatients $dom_evt, CMbObject $mbObject, $referent = null, $initiateur = null) {
    $msg = $dom_evt->generateTypeEvenement($mbObject, $referent, $initiateur);
    
    if ($this->actif) {
      $source = CExchangeSource::get("$this->_guid-evenementPatient");
      if ($source->_id) {
        $source->setData($msg);
        try {
          $source->send();
        } catch (Exception $e) {
          throw new CMbException("CExchangeSource-no-response");
        }
        $acq = $source->getACQ();

        if ($acq) {
          $echg_hprim = $dom_evt->_ref_echange_hprim;
          $echg_hprim->date_echange = mbDateTime();
          
          $dom_acq = new CHPrimXMLAcquittementsPatients();
          $dom_acq->loadXML($acq);
          $dom_acq->_ref_echange_hprim = $echg_hprim;
          $doc_valid = $dom_acq->schemaValidate();
          
          $echg_hprim->statut_acquittement = $dom_acq->getStatutAcquittementPatient();
          $echg_hprim->acquittement_valide = $doc_valid ? 1 : 0;
          $echg_hprim->_acquittement = $acq;
      
          $echg_hprim->store();
        } 
      }      
    }
  }
  
  function sendEvenementPMSI(CHPrimXMLEvenementsServeurActivitePmsi $dom_evt, CMbObject $mbObject) {
    $msg = $dom_evt->generateTypeEvenement($mbObject);
    
    if ($this->actif) {
      $source = CExchangeSource::get("$this->_guid-$dom_evt->sous_type");
      if ($source->_id) {
        $source->setData($msg);
        try {
          $source->send();
        } catch (Exception $e) {
          throw new CMbException("CExchangeSource-no-response");
        }
        $acq = $source->getACQ();

        if ($acq) {
          $echg_hprim = $dom_evt->_ref_echange_hprim;
          $echg_hprim->date_echange = mbDateTime();
          
          $dom_acq = CHPrimXMLAcquittementsServeurActivitePmsi::getEvtAcquittement($dom_evt);
          if (!$dom_acq) {
            $echg_hprim->_acquittement = $acq;
            $echg_hprim->store();
            return;
          }
          $dom_acq->loadXML($acq);
          $dom_acq->_ref_echange_hprim = $echg_hprim;
          $doc_valid = $dom_acq->schemaValidate();
          
          $echg_hprim->statut_acquittement = $dom_acq->getStatutAcquittementServeurActivitePmsi();
          $echg_hprim->acquittement_valide = $doc_valid ? 1 : 0;
          $echg_hprim->_acquittement = $acq;
      
          $echg_hprim->store();
        } 
      }      
    }
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