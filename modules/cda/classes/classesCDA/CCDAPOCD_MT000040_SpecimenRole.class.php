<?php

/**
 * $Id$
 *
 * @category CDA
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @link     http://www.mediboard.org
 */

/**
 * POCD_MT000040_SpecimenRole Class
 */
class CCDAPOCD_MT000040_SpecimenRole extends CCDARIMRole {

  /**
   * @var CCDAPOCD_MT000040_PlayingEntity
   */
  public $specimenPlayingEntity;

  /**
   * Ajoute l'instance sp�cifi� dans le tableau
   *
   * @param CCDAII $inst CCDAII
   *
   * @return void
   */
  function appendId(CCDAII $inst) {
    array_push($this->id, $inst);
  }

  /**
   * Efface le tableau
   *
   * @return void
   */
  function resetListId() {
    $this->id = array();
  }

  /**
   * Getter id
   *
   * @return CCDAII[]
   */
  function getId() {
    return $this->id;
  }

  /**
   * Setter specimenPlayingEntity
   *
   * @param CCDAPOCD_MT000040_PlayingEntity $inst CCDAPOCD_MT000040_PlayingEntity
   *
   * @return void
   */
  function setSpecimenPlayingEntity(CCDAPOCD_MT000040_PlayingEntity $inst) {
    $this->specimenPlayingEntity = $inst;
  }

  /**
   * Getter specimenPlayingEntity
   *
   * @return CCDAPOCD_MT000040_PlayingEntity
   */
  function getSpecimenPlayingEntity() {
    return $this->specimenPlayingEntity;
  }

  /**
   * Assigne classCode � SPEC
   *
   * @return void
   */
  function setClassCode() {
    $roleClass = new CCDARoleClassSpecimen();
    $roleClass->setData("SPEC");
    $this->classCode = $roleClass;
  }

  /**
   * Getter classCode
   *
   * @return CCDARoleClassSpecimen
   */
  function getClassCode() {
    return $this->classCode;
  }


  /**
   * Retourne les propri�t�s
   *
   * @return array
   */
  function getProps() {
    $props = parent::getProps();
    $props["typeId"]                = "CCDAPOCD_MT000040_InfrastructureRoot_typeId xml|element max|1";
    $props["id"]                    = "CCDAII xml|element";
    $props["specimenPlayingEntity"] = "CCDAPOCD_MT000040_PlayingEntity xml|element max|1";
    $props["classCode"]             = "CCDARoleClassSpecimen xml|attribute fixed|SPEC";
    return $props;
  }

  /**
   * Fonction permettant de tester la classe
   *
   * @return array
   */
  function test() {
    $tabTest = array();

    /**
     * Test avec les valeurs null
     */

    $tabTest[] = $this->sample("Test avec les valeurs null", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un typeId correct
     */

    $this->setTypeId();
    $tabTest[] = $this->sample("Test avec un typeId correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un realmCode incorrect
     */

    $cs = new CCDACS();
    $cs->setCode(" ");
    $this->appendRealmCode($cs);
    $tabTest[] = $this->sample("Test avec un realmCode incorrect", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un realmCode correct
     */

    $cs->setCode("FR");
    $this->resetListRealmCode();
    $this->appendRealmCode($cs);
    $tabTest[] = $this->sample("Test avec un realmCode correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un templateId incorrect
     */

    $ii = new CCDAII();
    $ii->setRoot("4TESTTEST");
    $this->appendTemplateId($ii);
    $tabTest[] = $this->sample("Test avec un templateId incorrect", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un templateId correct
     */

    $ii->setRoot("1.2.250.1.213.1.1.1.1");
    $this->resetListTemplateId();
    $this->appendTemplateId($ii);
    $tabTest[] = $this->sample("Test avec un templateId correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un classCode correct
     */

    $this->setClassCode();
    $tabTest[] = $this->sample("Test avec un classCode correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un Id incorrect
     */

    $ii = new CCDAII();
    $ii->setRoot("4TESTTEST");
    $this->appendId($ii);
    $tabTest[] = $this->sample("Test avec un Id incorrect", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un Id correct
     */

    $ii->setRoot("1.2.250.1.213.1.1.9");
    $this->resetListId();
    $this->appendId($ii);
    $tabTest[] = $this->sample("Test avec un Id correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un specimenPlayingEntity correct
     */

    $playing = new CCDAPOCD_MT000040_PlayingEntity();
    $playing->setDeterminerCode();
    $this->setSpecimenPlayingEntity($playing);
    $tabTest[] = $this->sample("Test avec un specimenPlayingEntity correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    return $tabTest;
  }
}