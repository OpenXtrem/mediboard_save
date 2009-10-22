<?php /* $Id $ */

/**
 * @package Mediboard
 * @subpackage hprimxml
 * @version $Revision:$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */

class CSetuphprimxml extends CSetup {
  
  function __construct() {
      parent::__construct();
    
      $this->mod_name = "hprimxml";
      $this->makeRevision("all");
      $this->makeRevision("0.10");
     
      $this->addDependency("sip", "0.15");
      
      $this->mod_version = "0.11";
  }
}

?>