<?php /* $Id: $ */

/**
 *  @package Mediboard
 *  @subpackage dPqualite
 *  @version $Revision: $
 *  @author Sébastien Fillonneau
 */

/**
 * The CThemeDoc class
 */
class CThemeDoc extends CMbObject {
  // DB Table key
  var $doc_theme_id = null;
    
  // DB Fields
  var $nom = null;

  function CThemeDoc() {
    $this->CMbObject("doc_themes", "doc_theme_id");
    
    $this->loadRefModule(basename(dirname(__FILE__)));
  }
  
  function getBackRefs() {
      $backRefs = parent::getBackRefs();
      $backRefs["documents_ged"] = "CDocGed doc_theme_id";
     return $backRefs;
  }
  
  function getSpecs() {
    return array (
      "nom" => "notNull str maxLength|50"
    );
  }

  function updateFormFields() {
    parent::updateFormFields();
    $this->_view = $this->nom;
  }
    
  function canDelete(&$msg, $oid = null) {
    $tables[] = array (
      "label"     => "msg-CDocGed-canDelete", 
      "name"      => "doc_ged", 
      "idfield"   => "doc_ged_id", 
      "joinfield" => "doc_theme_id"
    );
    
    return CMbObject::canDelete( $msg, $oid, $tables );
  }
}
?>