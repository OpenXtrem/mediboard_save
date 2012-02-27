<?php

/**
 * IHE Classes
 *  
 * @category IHE
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */

/**
 * Class CIHE 
 * IHE classes
 */
class CIHE {
  static $object_handlers = array(
    "CSipObjectHandler" => "CITI30DelegatedHandler",
    "CSmpObjectHandler" => "CITI31DelegatedHandler",
  );
  static $versions = array();
  static $evenements = array();

  /**
   * Retrieve handlers list
   * @return array Handlers list
   */
  static function getObjectHandlers() {
    return self::$object_handlers; 
  }
  
  /**
   * Retrieve events list of data format
   * @return array Events list
   */
  function getEvenements() {
    return self::$evenements;
  }
  
  /**
   * Retrieve transaction name
   * @param $code Event code
   * @return string Transaction name
   */
  static function getTransaction($code) {}
  
  /**
   * Return data format object
   * @param exchange Instance of exchange
   * @return object An instance of data format
   */
  static function getEvent(CExchangeDataFormat $exchange) {
    switch ($exchange->type) {
      case "PAM" :
        return CPAM::getEvent($exchange);
        break;
      case "PAM_FR" :
        return CPAM::getEvent($exchange);
        break;
      case "PAM" :
        break;
      default :
        throw new CMbException("CIHE_event-unknown");
        break;
    }
  }
  
  static function getPAMTransaction($code, $i18n = null) {
    switch ($i18n) {
      case "FR" :
        return CPAMFR::getTransaction($this->code);
        break;
      default :
        return CPAM::getTransaction($this->code);
        break;
    }
  }
  
  static function getDECTransaction($code, $i18n = null) {
    return CDEC::getTransaction($this->code);
  }
}
?>