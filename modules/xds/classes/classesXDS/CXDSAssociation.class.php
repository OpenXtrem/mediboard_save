<?php

/**
 * $Id$
 *  
 * @category XDS
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
 */
 
/**
 * La classe Association XDS represente les associations entre fiches
 * ou entre lot de soumission et fiche
 */
class CXDSAssociation extends CXDSRegistryObject {

  public $associationType;
  public $sourceObject;
  public $targetObject;

  /**
   * Construction de l'instance
   *
   * @param String $id           Identifiant
   * @param String $sourceObject Source
   * @param String $targetObject Cible
   * @param bool   $rplc         Association de type remplacement
   */
  function __construct($id, $sourceObject, $targetObject, $rplc = false) {
    parent::__construct($id);
    $this->associationType = "urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember";
    if ($rplc) {
      $this->associationType = "urn:ihe:iti:2007:AssociationType:RPLC";
    }
    $this->sourceObject = $sourceObject;
    $this->targetObject = $targetObject;
    $this->objectType = "urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association";
  }

  /**
   * @see parent::toXML()
   *
   * @return CXDSXmlDocument
   */
  function toXML() {
    $xml = new CXDSXmlDocument();
    $xml->createAssociationRoot($this->id, $this->associationType, $this->sourceObject, $this->targetObject, $this->objectType);
    return $xml;
  }
}