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
 * A monetary amount is a quantity expressing the amount of
 * money in some currency. Currencies are the units in which
 * monetary amounts are denominated in different economic
 * regions. While the monetary amount is a single kind of
 * quantity (money) the exchange rates between the different
 * units are variable.  This is the principle difference
 * between physical quantity and monetary amounts, and the
 * reason why currency units are not physical units.
 */
class CCDAMO extends CCDAQTY {

  /**
   * The currency unit as defined in ISO 4217.
   *
   * @var CCDA_base_cs
   */
  public $currency;

  /**
   * Setter currency
   *
   * @param String $currency String
   *
   * @return void
   */
  public function setCurrency($currency) {
    if (!$currency) {
      $this->currency = null;
      return;
    }
    $cs = new CCDA_base_cs();
    $cs->setData($currency);
    $this->currency = $cs;
  }

  /**
   * Getter currency
   *
   * @return \CCDA_base_cs
   */
  public function getCurrency() {
    return $this->currency;
  }

  /**
   * Setter value
   *
   * @param String $value String
   *
   * @return void
   */
  public function setValue($value) {
    if (!$value) {
      $this->value = null;
      return;
    }
    $real = new CCDA_base_real();
    $real->setData($value);
    $this->value = $real;
  }

  /**
   * Get the properties of our class as strings
   *
   * @return array
   */
  function getProps() {
    $props = parent::getProps();
    $props["value"] = "CCDA_base_real xml|attribute";
    $props["currency"] = "CCDA_base_cs xml|attribute";
    return $props;
  }

  /**
   * fonction permettant de tester la validit� de la classe
   *
   * @return array()
   */
  function test() {
    $tabTest = parent::test();

    /**
     * Test avec une valeur incorrecte
     */

    $this->setValue("test");
    $tabTest[] = $this->sample("Test avec une valeur incorrecte", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec une valeur correcte
     */

    $this->setValue("10.25");
    $tabTest[] = $this->sample("Test avec une valeur correcte", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un currency incorrecte
     */

    $this->setCurrency(" ");
    $tabTest[] = $this->sample("Test avec un currency incorrecte", "Document invalide");

    /*-------------------------------------------------------------------------------------*/

    /**
     * Test avec un currency correcte
     */

    $this->setCurrency("test");
    $tabTest[] = $this->sample("Test avec un currency correcte", "Document valide");

    /*-------------------------------------------------------------------------------------*/

    return $tabTest;
  }
}
