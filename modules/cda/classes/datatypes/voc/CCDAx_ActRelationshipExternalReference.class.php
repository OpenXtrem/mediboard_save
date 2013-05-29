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
 * abstDomain: V19000 (C-0-D10317-V19000-cpt)
 */
class CCDAx_ActRelationshipExternalReference extends CCDA_Datatype_Voc {

  public $_enumeration = array (
    'XCRPT',
    'RPLC',
    'SPRT',
    'ELNK',
    'REFR',
    'SUBJ',
  );
  public $_union = array (
  );


  /**
   * Retourne les propriétés
   *
   * @return array
   */
  function getProps() {
    parent::getProps();
    $props["data"] = "str xml|data enum|".implode("|", $this->getEnumeration(true));
    return $props;
  }
}