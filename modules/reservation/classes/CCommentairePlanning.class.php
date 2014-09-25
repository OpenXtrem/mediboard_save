<?php 
/**
 * $Id$
 * 
 * @package    Mediboard
 * @subpackage reservation
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision$
 */

/**
 * Classe CCommentairePlanning
 * g�re les commentaires sous la forme libell� + description dans le planning de r�servation
 */
class CCommentairePlanning extends CMbObject {
  // DB Table key
  public $commentaire_planning_id;
  
  // DB References
  public $salle_id;
  
  // DB Fields
  public $libelle;
  public $commentaire;
  public $color;
  public $debut;
  public $fin;

  /**
   * Specs
   *
   * @return CMbObjectSpec
   */
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table = 'commentaire_planning';
    $spec->key   = 'commentaire_planning_id';
    return $spec;
  }

  /**
   * Properties
   *
   * @return array
   */
  function getProps() {
    $specs = parent::getProps();
    $specs["salle_id"]    = "ref class|CSalle";
    $specs["libelle"]     = "str autocomplete notNull";
    $specs["commentaire"] = "text helped";
    $specs["color"]       = "color default|DDDDDD";
    $specs["debut"]       = "dateTime notNull";
    $specs["fin"]         = "dateTime notNull moreThan|debut";
    
    return $specs;
  }

  /**
   * updateFormFields
   *
   * @return null
   */
  function updateFormFields() {
    parent::updateFormFields();
    
    $this->_view = $this->libelle;
  }
}
