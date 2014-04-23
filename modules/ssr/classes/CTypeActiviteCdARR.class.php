<?php
/**
 * $Id$
 *
 * @package    Mediboard
 * @subpackage SSR
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision$
 */

/**
 * Cat�gorie d'activit� CdARR
 */
class CTypeActiviteCdARR extends CCdARRObject {
  public $code;
  public $libelle;
  public $libelle_court;

  static $cached = array();

  /**
   * @see parent::getSpec()
   */
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table       = 'type_activite';
    $spec->key         = 'code';
    return $spec;
  }

  /**
   * @see parent::getProps()
   */
  function getProps() {
    $props = parent::getProps();

    // DB Fields
    $props["code"]          = "str notNull length|4";
    $props["libelle"]       = "str notNull maxLength|50";
    $props["libelle_court"] = "str notNull maxLength|50";

    return $props;
  }

  /**
   * @see parent::updateFormFields()
   */
  function updateFormFields() {
    parent::updateFormFields();
    $this->_view      = "($this->code) $this->libelle";
    $this->_shortview = "($this->code) $this->libelle_court";
  }

  /**
   * Get an instance from the code
   *
   * @param string $code Code CdARR
   *
   * @return CTypeActiviteCdARR
   **/
  static function get($code) {
    if (!$code) {
      return new self();
    }

    if ($type = SHM::get("type_activite_$code")) {
      return $type;
    }

    $type = new self();
    $type->load($code);
    SHM::put("type_activite_$code", $type);

    return $type;
  }
}