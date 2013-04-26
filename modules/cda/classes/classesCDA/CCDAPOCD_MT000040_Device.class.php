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
 * POCD_MT000040_Device Class
 */
class CCDAPOCD_MT000040_Device extends CCDARIMDevice {

  /**
   * Setter code
   *
   * @param CCDACE $inst CCDACE
   *
   * @return void
   */
  function setCode(CCDACE $inst) {
    $this->code = $inst;
  }

  /**
   * Getter code
   *
   * @return CCDACE
   */
  function getCode() {
    return $this->code;
  }

  /**
   * Setter manufacturerModelName
   *
   * @param CCDASC $inst CCDASC
   *
   * @return void
   */
  function setManufacturerModelName(CCDASC $inst) {
    $this->manufacturerModelName = $inst;
  }

  /**
   * Getter manufacturerModelName
   *
   * @return CCDASC
   */
  function getManufacturerModelName() {
    return $this->manufacturerModelName;
  }

  /**
   * Setter softwareName
   *
   * @param CCDASC $inst CCDASC
   *
   * @return void
   */
  function setSoftwareName(CCDASC $inst) {
    $this->softwareName = $inst;
  }

  /**
   * Getter softwareName
   *
   * @return CCDASC
   */
  function getSoftwareName() {
    return $this->softwareName;
  }

  /**
   * Setter classCode
   *
   * @param String $inst String
   *
   * @return void
   */
  function setClassCode($inst) {
    if (!$inst) {
      $this->classCode = null;
      return;
    }
    $act = new CCDAEntityClassDevice();
    $act->setData($inst);
    $this->classCode = $act;
  }

  /**
   * Getter classCode
   *
   * @return CCDAEntityClassDevice
   */
  function getClassCode() {
    return $this->classCode;
  }

  /**
   * Assigne determinerCode � INSTANCE
   *
   * @return void
   */
  function setDeterminerCode() {
    $entity = new CCDAEntityDeterminer();
    $entity->setData("INSTANCE");
    $this->determinerCode = $entity;
  }

  /**
   * Getter determinerCode
   *
   * @return CCDAEntityDeterminer
   */
  function getDeterminerCode() {
    return $this->determinerCode;
  }


  /**
   * Retourne les propri�t�s
   *
   * @return array
   */
  function getProps() {
    $props = parent::getProps();
    $props["typeId"]                = "CCDAPOCD_MT000040_InfrastructureRoot_typeId xml|element max|1";
    $props["code"]                  = "CCDACE xml|element max|1";
    $props["manufacturerModelName"] = "CCDASC xml|element max|1";
    $props["softwareName"]          = "CCDASC xml|element max|1";
    $props["classCode"]             = "CCDAEntityClassDevice xml|attribute default|DEV";
    $props["determinerCode"]        = "CCDAEntityDeterminer xml|attribute fixed|INSTANCE";
    return $props;
  }

  /**
   * Fonction permettant de tester la classe
   *
   * @return array
   */
  function test() {
    $tabTest = parent::test();

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
     * Test avec un classCode incorrect
     */

    $this->setClassCode("TESTTEST");
    $tabTest[] = $this->sample("Test avec un classCode incorrect", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un classCode incorrect
     */

    $this->setClassCode("CER");
    $tabTest[] = $this->sample("Test avec un classCode correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un determinerCode correct
     */

    $this->setDeterminerCode();
    $tabTest[] = $this->sample("Test avec un determinerCode correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un code incorrect
     */

    $ce = new CCDACE();
    $ce->setCode(" ");
    $this->setCode($ce);
    $tabTest[] = $this->sample("Test avec un code incorrect", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un code correct
     */

    $ce->setCode("TESTTEST");
    $this->setCode($ce);
    $tabTest[] = $this->sample("Test avec un code correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un manufacturerModelName incorrect
     */

    $sc = new CCDASC();
    $sc->setCode(" ");
    $this->setManufacturerModelName($sc);
    $tabTest[] = $this->sample("Test avec un manufacturerModelName incorrect", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un manufacturerModelName correct
     */

    $sc->setCode("TEST");
    $this->setManufacturerModelName($sc);
    $tabTest[] = $this->sample("Test avec un manufacturerModelName correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un softwareName incorrect
     */

    $sc = new CCDASC();
    $sc->setCode(" ");
    $this->setSoftwareName($sc);
    $tabTest[] = $this->sample("Test avec un softwareName incorrect", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un softwareName correct
     */

    $sc->setCode("TEST");
    $this->setSoftwareName($sc);
    $tabTest[] = $this->sample("Test avec un softwareName correct", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    return $tabTest;
  }
}