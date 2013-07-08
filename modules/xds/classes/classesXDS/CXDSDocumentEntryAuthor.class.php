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
 * Classe Classification représentant le tableau de variables DocumentEntryAuthor
 */
class CXDSDocumentEntryAuthor extends CXDSClassification {

  /** @var  CXDSSlot */
  public $authorInstitution;
  /** @var  CXDSSlot */
  public $authorPerson;
  /** @var  CXDSSlot[] */
  public $authorRole = array();
  /** @var  CXDSSlot */
  public $authorSpecialty;

  /**
   * Construction de l'instance
   *
   * @param String $id               String
   * @param String $classifiedObject String
   * @param bool   $registry         false
   */
  function __construct($id, $classifiedObject, $registry = false) {
    parent::__construct($id);
    $this->classifiedObject = $classifiedObject;
    $this->classificationScheme = "urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d";
    if ($registry) {
      $this->classificationScheme = "urn:uuid:a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d";
    }
    $this->nodeRepresentation = "";
  }

  /**
   * Setter Author Institution
   *
   * @param String[] $value String[]
   *
   * @return void
   */
  function setAuthorInstitution($value) {
    $this->authorInstitution = new CXDSSlot("authorInstitution", $value);
  }

  /**
   * Setter AuthorPerson
   *
   * @param String[] $value String[]
   *
   * @return void
   */
  function setAuthorPerson($value) {
    $this->authorPerson = new CXDSSlot("authorPerson", $value);
  }

  /**
   * Setter AuthorRole
   *
   * @param String[] $value String[]
   *
   * @return void
   */
  function appendAuthorRole($value) {
    array_push($this->authorRole, new CXDSSlot("authorRole", $value));
  }

  /**
   * Setter AuthorSpecialty
   *
   * @param String[] $value String[]
   *
   * @return void
   */
  function setAuthorSpecialty($value) {
    $this->authorSpecialty = new CXDSSlot("authorSpecialty", $value);
  }

  /**
   * @see parent::toXML()
   *
   * @return CXDSXmlDocument
   */
  function toXML() {
    $xml = parent::toXML();
    $base_xml = $xml->documentElement;

    if ($this->authorInstitution) {
      $xml->importDOMDocument($base_xml, $this->authorInstitution->toXML());
    }

    if ($this->authorPerson) {
      $xml->importDOMDocument($base_xml, $this->authorPerson->toXML());
    }

    foreach ($this->authorRole as $_authorRole) {
      $xml->importDOMDocument($base_xml, $_authorRole->toXML());
    }

    if ($this->authorSpecialty) {
      $xml->importDOMDocument($base_xml, $this->authorSpecialty->toXML());
    }

    return $xml;
  }
}
