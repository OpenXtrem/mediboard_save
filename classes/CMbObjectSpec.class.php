<?php 
/**
 * $Id$
 * 
 * @package    Mediboard
 * @subpackage classes
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version    $Revision$
 */

class CMbObjectSpec {
  // Specification fields
  public $incremented         = true;
  public $loggable            = true;
  public $nullifyEmptyStrings = true;
  public $dsn                 = "std";
  public $table               = null;
  public $key                 = null;
  public $measureable         = false;
  public $uniques             = array();
  public $xor                 = array();
  public $events              = array();
  
  /**
   * @var CSQLDataSource
   */
  public $ds = null;
  
  /**
   * Initialize derivate fields
   */
  public function init() {
    $this->ds = CSQLDataSource::get($this->dsn, $this->dsn != "std");
  }
  
  /**
   * toString method to be used in the HTML for the form className
   * @return string The spec as string
   */
  function __toString(){
    $specs = array();
    foreach($this->xor as $xor) {
      $specs[] = "xor|".implode("|", $xor);
    }
    return implode(" ", $specs);
  }
}
