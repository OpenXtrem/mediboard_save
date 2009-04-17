<?php
/**
 *  @package Mediboard
 *  @subpackage sip
 *  @version $Revision$
 *  @author SARL OpenXtrem
 *  @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */
global $AppUI;

$echange_hprim_id         = mbGetValueFromGet("echange_hprim_id");
$echange_hprim_classname  = mbGetValueFromGet("echange_hprim_classname");

$where = '';
if (!$echange_hprim_id) {
	$echange_hprim = new CEchangeHprim();
	$where['date_echange'] = "IS NULL";
	$where['message_valide'] = " = '1'";
	$limit = CAppUI::conf('sip batch_count');
  $notifications = $echange_hprim->loadList($where, null, $limit);
  
  foreach ($notifications as $notification) {
  	$notification->date_echange = mbDateTime();
    $notification->store();
    
    $dest_hprim = new CDestinataireHprim();
	  $dest_hprim->destinataire = $notification->destinataire;
	  
	  $dest_hprim->loadMatchingObject();
	  
	  // Chrono stop
		$chrono = new Chronometer;
		$chrono->stop();

	  if (!$client = CMbSOAPClient::make($dest_hprim->url, $dest_hprim->username, $dest_hprim->password)) {
	    trigger_error("Impossible de joindre le destinataire : ".$dest_hprim->url);
	  }
	  
	  // R�cup�re le message d'acquittement apr�s l'execution de l'enregistrement d'un evenement patient
	  if (null == $acquittement = $client->evenementPatient($notification->message)) {
	    trigger_error("Evenement patient impossible : ".$dest_hprim->url);
	  }
	  
	  // Chrono start
	  $chrono->start();
	  
	  $domGetAcquittement = new CHPrimXMLAcquittementsPatients();
	  $domGetAcquittement->loadXML(utf8_decode($acquittement));
    $doc_valid = $domGetAcquittement->schemaValidate();
    if ($doc_valid) {
    	$notification->statut_acquittement = $domGetAcquittement->getStatutAcquittementPatient();
    }
    $notification->acquittement_valide = $doc_valid ? 1 : 0;
    
	  $notification->date_echange = mbDateTime();
	  $notification->acquittement = $acquittement;
	  $notification->store();
  }
} else {
	// Chargement de l'objet
	$echange_hprim = new $echange_hprim_classname;
	$echange_hprim->load($echange_hprim_id);
	
	$dest_hprim = new CDestinataireHprim();
	$dest_hprim->destinataire = $echange_hprim->destinataire;
	$dest_hprim->loadMatchingObject();

	if (!$client = CMbSOAPClient::make($dest_hprim->url, $dest_hprim->username, $dest_hprim->password)) {
	  trigger_error("Impossible de joindre le destinataire : ".$dest_hprim->url);
	  $AppUI->setMsg("Impossible de joindre le destinataire", UI_MSG_ERROR);
	}
	
	// R�cup�re le message d'acquittement apr�s l'execution de l'enregistrement d'un evenement patient
	if (null == $acquittement = $client->evenementPatient($echange_hprim->message)) {
	  trigger_error("Evenement patient impossible : ".$dest_hprim->url);
	  $AppUI->setMsg("Evenement patient impossible", UI_MSG_ERROR);
	}

	$domGetAcquittement = new CHPrimXMLAcquittementsPatients();
  $domGetAcquittement->loadXML(utf8_decode($acquittement));
  $doc_valid = $domGetAcquittement->schemaValidate();
  if ($doc_valid) {
    $echange_hprim->statut_acquittement = $domGetAcquittement->getStatutAcquittementPatient();
  }
  $echange_hprim->acquittement_valide = $doc_valid ? 1 : 0;
    
	$echange_hprim->date_echange = mbDateTime();
	$echange_hprim->acquittement = $acquittement;

	$echange_hprim->store();
	
	$AppUI->setMsg("Message HPRIM envoy�", UI_MSG_OK);
	
	echo $AppUI->getMsg();
}

?>