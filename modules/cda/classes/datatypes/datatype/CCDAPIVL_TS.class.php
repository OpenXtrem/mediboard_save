<?php

/**
 * $Id$
 *
 * @category CDA
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @link     http://www.mediboard.org */

/**
 * CCDAPIVL_TS class
 *
 * Note: because this type is defined as an extension of SXCM_T,
 * all of the attributes and elements accepted for T are also
 * accepted by this definition.  However, they are NOT allowed
 * by the normative description of this type.  Unfortunately,
 * we cannot write a general purpose schematron contraints to
 * provide that extra validation, thus applications must be
 * aware that instance (fragments) that pass validation with
 * this might might still not be legal.
 *
 */
class CCDAPIVL_TS extends CCDASXCM_TS {

  /**
   * A prototype of the repeating interval specifying the
   * duration of each occurrence and anchors the periodic
   * interval sequence at a certain point in time.
   *
   * @var CCDAIVL_TS
   */
  public $phase;

  /**
   * A time duration specifying a reciprocal measure of
   * the frequency at which the periodic interval repeats.
   *
   * @var CCDAPQ
   */
  public $period;

  /**
   * Specifies if and how the repetitions are aligned to
   * the cycles of the underlying calendar (e.g., to
   * distinguish every 30 days from "the 5th of every
   * month".) A non-aligned periodic interval recurs
   * independently from the calendar. An aligned periodic
   * interval is synchronized with the calendar.
   *
   * @var CCDACalendarCycle
   */
  public $alignment;

  /**
   * Indicates whether the exact timing is up to the party
   * executing the schedule (e.g., to distinguish "every 8
   * hours" from "3 times a day".)
   *
   * @var CCDA_base_bl
   */
  public $institutionSpecified;

  /**
   * Setter Alignment
   *
   * @param String $alignment String
   *
   * @return void
   */
  public function setAlignment($alignment) {
    if (!$alignment) {
      $this->alignment = null;
      return;
    }
    $cale = new CCDACalendarCycle();
    $cale->setData($alignment);
    $this->alignment = $cale;
  }

  /**
   * Getter Alignment
   *
   * @return \CCDACalendarCycle
   */
  public function getAlignment() {
    return $this->alignment;
  }

  /**
   * Setter InstitutionSpecified
   *
   * @param String $institutionSpecified String
   *
   * @return void
   */
  public function setInstitutionSpecified($institutionSpecified) {
    if (!$institutionSpecified) {
      $this->institutionSpecified = null;
      return;
    }
    $bl = new CCDA_base_bl();
    $bl->setData($institutionSpecified);
    $this->institutionSpecified = $bl;
  }

  /**
   * Getter InstitutionSpecified
   *
   * @return \CCDA_base_bl
   */
  public function getInstitutionSpecified() {
    return $this->institutionSpecified;
  }

  /**
   * Setter Period
   *
   * @param \CCDAPQ $period \CCDAPQ
   *
   * @return void
   */
  public function setPeriod($period) {
    $this->period = $period;
  }

  /**
   * Getter Period
   *
   * @return \CCDAPQ
   */
  public function getPeriod() {
    return $this->period;
  }

  /**
   * Setter Phase
   *
   * @param \CCDAIVL_TS $phase \CCDAIVL_TS
   *
   * @return void
   */
  public function setPhase($phase) {
    $this->phase = $phase;
  }

  /**
   * Getter Phase
   *
   * @return \CCDAIVL_TS
   */
  public function getPhase() {
    return $this->phase;
  }

  /**
   * Get the properties of our class as strings
   *
   * @return array
   */
  function getProps() {
    $props = parent::getProps();
    $props["phase"] = "CCDAIVL_TS xml|element max|1";
    $props["period"] = "CCDAPQ xml|element max|1";
    $props["alignment"] = "CCDACalendarCycle xml|attribute";
    $props["institutionSpecified"] = "CCDA_base_bl xml|attribute default|false";
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
     * Test avec un alignment incorrecte
     */

    $this->setAlignment(" ");
    $tabTest[] = $this->sample("Test avec un alignment incorrecte", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un alignment correcte
     */

    $this->setAlignment("CD");
    $tabTest[] = $this->sample("Test avec un alignment correcte", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un institutionSpecified incorrecte
     */

    $this->setInstitutionSpecified("CD");
    $tabTest[] = $this->sample("Test avec un institutionSpecified incorrecte", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un institutionSpecified correcte
     */

    $this->setInstitutionSpecified("true");
    $tabTest[] = $this->sample("Test avec un institutionSpecified correcte", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un phase incorrecte
     */

    $ivl = new CCDAIVL_TS();
    $xbts = new CCDAIVXB_TS();
    $xbts->setValue("TESTTEST");
    $ivl->setLow($xbts);
    $this->setPhase($ivl);
    $tabTest[] = $this->sample("Test avec une phase incorrecte", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un phase correcte
     */

    $xbts->setValue("75679245900741.869627871786625715081550660290154484483335306381809807748522068");
    $ivl->setLow($xbts);
    $this->setPhase($ivl);
    $tabTest[] = $this->sample("Test avec une phase correcte", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un period incorrecte
     */

    $pq = new CCDAPQ;
    $pq->setUnit(" ");
    $this->setPeriod($pq);
    $tabTest[] = $this->sample("Test avec une period incorrecte", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un period correcte
     */

    $pq->setUnit("TEST");
    $this->setPeriod($pq);
    $tabTest[] = $this->sample("Test avec une period correcte", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    return $tabTest;
  }
}
