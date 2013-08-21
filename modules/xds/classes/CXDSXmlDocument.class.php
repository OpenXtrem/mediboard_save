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
 * Document xml du XDS
 */
class CXDSXmlDocument extends CMbXMLDocument {

  /**
   * @see parent::__construct()
   */
  function __construct() {
    parent::__construct("UTF-8");
  }

  /**
   * Cr�ation d'�l�ment RIM
   *
   * @param String  $name        Nom du noeud
   * @param String  $value       Valeur du noeud
   * @param DOMNode $contextNode Noeud de r�f�rence
   *
   * @return DOMElement
   */
  function createRimRoot($name, $value = null, DOMNode $contextNode = null) {
    $elParent = $contextNode ? $contextNode : $this;

    return parent::addElement($elParent, "rim:$name", $value, "urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0");
  }

  /**
   * Cr�ation d'�l�ment racine lcm
   *
   * @param String $name  Nom du noeud
   * @param String $value Valeur du noeud
   *
   * @return DOMElement
   */
  function createLcmRoot($name, $value = null) {
    return parent::addElement($this, "lcm:$name", $value, "urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0");
  }

  /**
   * Cr�ation d'un noeud pour l'entrep�t
   *
   * @param String $name  String
   * @param String $value Valeur du noeud
   *
   * @return DOMElement
   */
  function createDocumentRepositoryElement($name, $value) {
    return parent::addElement($this, "xds:$name", $value, "urn:ihe:iti:xds-b:2007");
  }

  /**
   * Cr�ation de la racine Slot
   *
   * @param String $name Nom du noeud
   *
   * @return void
   */
  function createSlotRoot($name) {
    $element = $this->createRimRoot("Slot");
    $this->addAttribute($element, "name", $name);
  }

  /**
   * Cr�ation de la racine RegistryPackageRoot
   *
   * @param String $id Identifiant
   *
   * @return void
   */
  function createRegistryPackageRoot($id) {
    $element = $this->createRimRoot("RegistryPackage");
    $this->addAttribute($element, "id", $id);
  }

  /**
   * Cr�ation de valeurs Slot
   *
   * @param String[] $data Donn�es du slot
   *
   * @return void
   */
  function createSlotValue($data) {
    $valueList = $this->createRimRoot("ValueList", null, $this->documentElement);
    foreach ($data as $_data) {
      $this->createRimRoot("Value", htmlspecialchars($_data), $valueList);
    }
  }

  /**
   * Cr�ation de la racine pour le Name et Description
   *
   * @param String $name Nom du noeud
   *
   * @return void
   */
  function createNameDescriptionRoot($name) {
    $this->createRimRoot($name);
  }

  /**
   * Cr�ation du Localized
   *
   * @param String $value   Valeur
   * @param String $charset Charset
   * @param String $lang    Langue
   *
   * @return void
   */
  function createLocalized($value, $charset, $lang) {
    $element = $this->createRimRoot("LocalizedString");
    $this->addAttribute($element, "value"  , $value);
    $this->addAttribute($element, "charset", $charset);
    $this->addAttribute($element, "lang"   , $lang);
  }

  /**
   * Cr�ation du Version Info
   *
   * @param String $value Valeur
   *
   * @return void
   */
  function createVersionInfo($value) {
    $element = $this->createRimRoot("VersionInfo");
    $this->addAttribute($element, "VersionName", $value);
  }

  /**
   * Cr�ation de la racine de classification
   *
   * @param String $id                 Identifiant
   * @param String $classification     ClassificationScheme
   * @param String $classified         ClassifiedObject
   * @param String $nodeRepresentation Noderepresentation
   *
   * @return void
   */
  function createClassificationRoot($id, $classification, $classified, $nodeRepresentation) {
    $element = $this->createRimRoot("Classification");
    $this->addAttribute($element, "id"                  , $id);
    $this->addAttribute($element, "classificationScheme", $classification);
    $this->addAttribute($element, "classifiedObject"    , $classified);
    $this->addAttribute($element, "nodeRepresentation"  , $nodeRepresentation);
  }

  /**
   * Cr�ation de la racine ExternalIdentifier
   *
   * @param String $id             Identifiant
   * @param String $identification Identificationscheme
   * @param String $registry       registryObject
   * @param String $value          Valeur
   *
   * @return void
   */
  function createExternalIdentifierRoot($id, $identification, $registry, $value) {
    $element = $this->createRimRoot("ExternalIdentifier");
    $this->addAttribute($element, "id"                  , $id);
    $this->addAttribute($element, "identificationScheme", $identification);
    $this->addAttribute($element, "registryObject"      , $registry);
    $this->addAttribute($element, "value"               , $value);
  }

  /**
   * Cr�ation de la racine ExtrinsicObject
   *
   * @param String $id         Identifiant
   * @param String $mimeType   MimeType
   * @param String $objectType ObjectType
   *
   * @return void
   */
  function createExtrinsicObjectRoot($id, $mimeType, $objectType) {
    $element = $this->createRimRoot("ExtrinsicObject");
    $this->addAttribute($element, "id"        , $id);
    $this->addAttribute($element, "mimeType"  , $mimeType);
    $this->addAttribute($element, "objectType", $objectType);
  }

  /**
   * Cr�ation de la racine Submission
   *
   * @param String $id                 Identifiant
   * @param String $classificationNode ClassificationNode
   * @param String $classifiedObject   ClassifiedObject
   *
   * @return void
   */
  function createSubmissionRoot($id, $classificationNode, $classifiedObject) {
    $element = $this->createRimRoot("Classification");
    $this->addAttribute($element, "id"                , $id);
    $this->addAttribute($element, "classificationNode", $classificationNode);
    $this->addAttribute($element, "classifiedObject"  , $classifiedObject);
  }

  /**
   * Cr�ation de la racine association
   *
   * @param String $id           Identifiant
   * @param String $type         associationType
   * @param String $sourceObject SourceObject
   * @param String $targetObject TargetObject
   * @param String $objectType   ObjectType
   *
   * @return void
   */
  function createAssociationRoot($id, $type, $sourceObject, $targetObject, $objectType) {
    $element = $this->createRimRoot("Association");
    $this->addAttribute($element, "id"             , $id);
    $this->addAttribute($element, "associationType", $type);
    $this->addAttribute($element, "objectType"     , $objectType);
    $this->addAttribute($element, "sourceObject"   , $sourceObject);
    $this->addAttribute($element, "targetObject"   , $targetObject);
  }

  /**
   * Cr�ation de la racine ObjectList
   *
   * @return void
   */
  function createRegistryObjectListRoot() {
    $this->createRimRoot("RegistryObjectList");
  }

  /**
   * Cr�ation de la racine XDS
   *
   * @return void
   */
  function createSubmitObjectsRequestRoot() {
    $element = $this->createLcmRoot("SubmitObjectsRequest");
    $element->appendChild($this->documentElement);
    $this->appendChild($element);
  }
}