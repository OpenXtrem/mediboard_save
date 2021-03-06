<?php

/**
 * Device Enterprise Communication HL7
 *  
 * @category HL7
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */

/**
 * Interface CHL7EventDEC 
 * Device Enterprise Communication
 */
interface CHL7EventDEC {
  /**
   * Construct
   *
   * @return CHL7EventDEC
   */
  function __construct();

  /**
   * Build DEC message
   *
   * @param CMbObject $object object
   *
   * @return mixed
   */
  function build($object);
}