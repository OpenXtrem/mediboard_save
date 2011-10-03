<?php /* $Id $ */

/**
 * @package Mediboard
 * @subpackage hprimxml
 * @version $Revision:$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */

class CHPrimXMLFusionVenue extends CHPrimXMLEvenementsPatients { 
  var $actions = array(
    'fusion' => "fusion"
  );
  
  function __construct() {    
    $this->sous_type = "fusionVenue";
            
    parent::__construct();
  }
  
  function generateFromOperation(CSejour $mbVenue, $referent) {  
    $evenementsPatients = $this->documentElement;
    $evenementPatient = $this->addElement($evenementsPatients, "evenementPatient");
    
    $fusionVenue = $this->addElement($evenementPatient, "fusionVenue");
    $this->addAttribute($fusionVenue, "action", "fusion");
          
    // Ajout du patient
    $patient = $this->addElement($fusionVenue, "patient");
    $this->addPatient($patient, $mbVenue->_ref_patient, $referent);
    
    // Ajout de la venue   
    $venue = $this->addElement($fusionVenue, "venue");
    $this->addVenue($venue, $mbVenue, $referent);

    $venueEliminee = $this->addElement($fusionVenue, "venueEliminee");
    // Ajout de la venue a eliminer
    $this->addVenue($venueEliminee, $mbVenue->_sejour_eliminee, $referent);
        
    // Traitement final
    $this->purgeEmptyElements();
  }
  
  function getContentsXML() {
    $xpath = new CHPrimXPath($this);

    $query = "/hprim:evenementsPatients/hprim:evenementPatient";

    $evenementPatient = $xpath->queryUniqueNode($query);
    $fusionVenue = $xpath->queryUniqueNode("hprim:fusionVenue", $evenementPatient);

    $data['action']  = $this->getActionEvenement("hprim:fusionVenue", $evenementPatient);
  
    $data['patient']  = $xpath->queryUniqueNode("hprim:patient", $fusionVenue);
    $data['idSourcePatient'] = $this->getIdSource($data['patient']);
    $data['idCiblePatient']  = $this->getIdCible($data['patient']);
    
    $data['venue']         = $xpath->queryUniqueNode("hprim:venue", $fusionVenue);
    $data['idSourceVenue'] = $this->getIdSource($data['venue']);
    $data['idCibleVenue']  = $this->getIdCible($data['venue']);
    
    $data['venueEliminee']         = $xpath->queryUniqueNode("hprim:venueEliminee", $fusionVenue);
    $data['idSourceVenueEliminee'] = $this->getIdSource($data['venueEliminee']);
    $data['idCibleVenueEliminee']  = $this->getIdCible($data['venueEliminee']);
        
    return $data;
  }
  
  /**
   * Fusion and recording a stay with an num_dos in the system
   * @param CHPrimXMLAcquittementsPatients $dom_acq
   * @param CEchangeHprim $echg_hprim.
   * @param CPatient $newPatient
   * @param array $data
   * @return string acquittement 
   **/
  function fusionVenue($dom_acq, $newPatient, $data) {
    $echg_hprim = $this->_ref_echange_hprim;
    
    // Traitement du patient
    $domEnregistrementPatient = new CHPrimXMLEnregistrementPatient();
    $domEnregistrementPatient->_ref_echange_hprim = $echg_hprim;
    $msgAcq = $domEnregistrementPatient->enregistrementPatient($dom_acq, $newPatient, $data);
    if ($echg_hprim->statut_acquittement != "OK") {
      return $msgAcq;
    }
    
    $dom_acq = new CHPrimXMLAcquittementsPatients();
    $dom_acq->_identifiant_acquitte = $data['identifiantMessage'];
    $dom_acq->_sous_type_evt        = $this->sous_type;
    $dom_acq->_ref_echange_hprim    = $echg_hprim;
    
     // Si CIP
    if (!CAppUI::conf('smp server')) {
      $mbVenueEliminee = new CSejour();
      $mbVenue = new CSejour();
     
      $sender = $echg_hprim->_ref_sender;
      
      // Acquittement d'erreur : identifiants source et cible non fournis pour le venue / venueEliminee
      if (!$data['idSourceVenue'] && !$data['idCibleVenue'] && !$data['idSourceVenueEliminee'] && !$data['idCibleVenueEliminee']) {
        return $dom_acq->generateAcquittementsError("E100", $commentaire, $newVenue);
      }
      
      $etatVenue         = CHPrimXMLEvenementsPatients::getEtatVenue($data['venue']);
      $etatVenueEliminee = CHPrimXMLEvenementsPatients::getEtatVenue($data['venueEliminee']);
     
      $id400Venue = CIdSante400::getMatch("CSejour", 
        ($etatVenue == "pr�admission") ? CAppUI::conf('dPplanningOp CSejour tag_dossier_pa').$sender->_tag_sejour : 
                                         $sender->_tag_sejour, $data['idSourceVenue']);
      if ($mbVenue->load($data['idCibleVenue'])) {
        // Pas de test dans le cas ou la fusion correspond � un changement de num�ro de dossier
        if (($etatVenue == "pr�admission") || ($etatVenueEliminee != "pr�admission")) {
          if ($id400Venue->object_id && ($mbVenue->_id != $id400Venue->object_id)) {
            $commentaire = "L'identifiant source fait r�f�rence au s�jour : $id400Venue->object_id et l'identifiant cible au s�jour : $mbVenue->_id.";
            return $dom_acq->generateAcquittementsError("E104", $commentaire, $newVenue);
          }
        }
      } 
      if (!$mbVenue->_id) {
        $mbVenue->_id = $id400Venue->object_id;
      }
      
      $id400VenueEliminee = CIdSante400::getMatch("CSejour", 
        ($etatVenue == "pr�admission") ? CAppUI::conf('dPplanningOp CSejour tag_dossier_pa').$sender->_tag_sejour : 
                                         $sender->_tag_sejour, $data['idSourceVenueEliminee']);
      if ($mbVenueEliminee->load($data['idCibleVenueEliminee'])) {
        if ($id400VenueEliminee->object_id && ($mbVenueEliminee->_id != $id400VenueEliminee->object_id)) {
          $commentaire = "L'identifiant source fait r�f�rence au s�jour : $id400VenueEliminee->object_id et l'identifiant cible au s�jour : $mbVenueEliminee->_id.";
          return $dom_acq->generateAcquittementsError("E141", $commentaire, $mbVenueEliminee);
        }
      }
      if (!$mbVenueEliminee->_id) {
        $mbVenueEliminee->_id = $id400VenueEliminee->object_id;
      }
      
      $messages = array();
      $avertissement = null;
      
      $newVenue = new CSejour();
      // Cas 0 : Aucun s�jour
      if (!$mbVenue->_id && !$mbVenueEliminee->_id) {
        $newVenue->patient_id = $newPatient->_id; 
        $newVenue->group_id   = CGroups::loadCurrent()->_id;
        $messages = $this->mapAndStoreVenue($newVenue, $data, $etatVenueEliminee, $id400Venue, $id400VenueEliminee);
      }
      // Cas 1 : 1 s�jour
      else if ($mbVenue->_id || $mbVenueEliminee->_id) {
        // Suppression de l'identifiant du s�jour trouv�
        if ($mbVenue->_id) {
          $newVenue->load($mbVenue->_id);
          $messages['msgNumDosVenue'] = $id400Venue->delete();
        } else if ($mbVenueEliminee->_id) {
          $newVenue->load($mbVenueEliminee->_id);
          $messages['msgNumDosVenueEliminee'] = $id400VenueEliminee->delete();
        }
        // Cas 0
        $messages = $this->mapAndStoreVenue($newVenue, $data, $etatVenueEliminee, $id400Venue, $id400VenueEliminee);
        
        $commentaire = "S�jour modifi� : $newVenue->_id.";
      }
      // Cas 2 : 2 S�jour
      else if ($mbVenue->_id && $mbVenueEliminee->_id) {
        // Suppression des identifiants des s�jours trouv�s
        $messages['msgNumDosVenue'] = $id400Venue->delete();
        $messages['msgNumDosVenueEliminee'] = $id400VenueEliminee->delete();
        
        // Transfert des backsref
        $mbVenueEliminee->transferBackRefsFrom($mbVenue);
         
        // Suppression de la venue a �liminer
        $msgDelete = $mbVenueEliminee->delete();
        
        // Cas 0
        $newVenue->load($mbVenue->_id);
        $messages = $this->mapAndStoreVenue($newVenue, $data, $etatVenueEliminee, $id400Venue, $id400VenueEliminee);
      }
      
      $codes = array ($messages['msgVenue'] ? (($messages['_code_Venue'] == "store") ? "A103" : "A102") : 
                                              (($messages['_code_Venue'] == "store") ? "I102" : "I101"), 
                      $messages['msgNumDosVenue'] ? "A105" : $messages['_code_NumDos']);

      if ($messages['msgVenue']) {
        $avertissement = $messages['msgVenue'];
      }
      
      $commentaire = "S�jour $newVenue->_id fusionn�";
    }
    
    return $echg_hprim->setAck($dom_acq, $codes, $avertissement, $commentaire, $newVenue);
  }
  
  private function mapAndStoreVenue(&$newVenue, $data, $etatVenueEliminee, &$id400Venue, &$id400VenueEliminee) {
    $sender = new CDestinataireHprim();
    $sender->nom = $data['idClient'];
    $sender->loadMatchingObject();
    
    $messages = array();
    // Mapping de la venue a �liminer
    $newVenue = $this->mappingVenue($data['venueEliminee'], $newVenue);
    // Mapping de la venue a garder
    $newVenue = $this->mappingVenue($data['venue'], $newVenue);

    // Notifier les autres destinataires
    $newVenue->_eai_initiateur_group_id = $sender->group_id;

    // S�jour retrouv�
    if ($newVenue->loadMatchingSejour() || $newVenue->_id) {
      $messages['msgVenue'] = $newVenue->store();

      $newVenue->loadLogs();
      $modified_fields = "";
      if (is_array($newVenue->_ref_last_log->_fields)) {
        foreach ($newVenue->_ref_last_log->_fields as $field) {
          $modified_fields .= "$field \n";
        }
      }
      $messages['_code_NumDos'] = "A121";
      $messages['_code_Venue'] = "store";
      $messages['commentaire'] = "S�jour modifi�e : $newVenue->_id.  Les champs mis � jour sont les suivants : $modified_fields.";           
    } else {
      $messages['_code_NumDos'] = "I122";
      $messages['_code_Venue']  = "create";
      $messages['msgVenue'] = $newVenue->store();
      $messages['commentaire'] = "S�jour cr�� : $newVenue->_id. ";
    }

    $id400Venue->object_id = $newVenue->_id;
    $id400Venue->last_update = mbDateTime();
    $messages['msgNumDosVenue'] = $id400Venue->store();
    
    $id400VenueEliminee->tag = ($etatVenueEliminee != "pr�admission") ? 
      CAppUI::conf('dPplanningOp CSejour tag_dossier_cancel').$sender->_tag_sejour :
      CAppUI::conf('dPplanningOp CSejour tag_dossier_pa').$sender->_tag_sejour;
        
    $id400VenueEliminee->object_id = $newVenue->_id;
    $id400VenueEliminee->last_update = mbDateTime();
    $messages['msgNumDosVenueEliminee'] = $id400VenueEliminee->store();
    
    return $messages;
  }
}
?>