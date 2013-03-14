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
 * A quantity specifying a point on the axis of natural time.
 * A point in time is most often represented as a calendar
 * expression.
 */
class CCDATS extends CCDAQTY{

  /**
	 * Get the properties of our class as strings
	 *
	 * @return array
	 */
  function getProps() {
    $props = parent::getProps();
    $props["value"] = "CCDA_ts xml|attribute";
    return $props;
  }

  function test() {
    $tabTest = parent::test();

    /**
     * Test avec une valeur incorrecte
     */

    $ts = new CCDA_ts();
    $ts->setData("TESTTEST");
    $this->setValue($ts);
    $tabTest[] = $this->sample("Test avec une valeur correcte", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec une valeur correcte
     */

    $ts->setData("24141331462095.812975314545697850652375076363185459409261232419230495159675586");
    $this->setValue($ts);
    $tabTest[] = $this->sample("Test avec une valeur correcte", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    return $tabTest;
  }
}
