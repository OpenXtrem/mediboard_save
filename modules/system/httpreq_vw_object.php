<?php /* $Id: $ */

/**
* @package Mediboard
* @subpackage system
* @version $Revision: $
* @author Romain Ollivier
*/

global $AppUI, $can, $m, $ajax;

$object_class = mbGetValueFromGet("object_class");
$object_id    = mbGetValueFromGet("object_id");

if (!$object_class || !$object_id) {
  return;
}

$object = new $object_class;
$object->load($object_id);
if (!$object->_id) {
  $AppUI->redirect("?ajax=$ajax&suppressHeaders=1&m=$m&a=object_not_found&object_classname=$object_class");
}

$object->loadView();

//$canModule = CModule::getCanDo($object->_ref_module->mod_name);
//$can->read = $canModule->read && $object->canRead();
//$can->needsRead();
$can = CModule::getCanDo($object->_ref_module->mod_name);
$can->read = $can->read && $object->canRead();
$can->edit = $can->edit && $object->canEdit();
$can->needsRead();

// If no template is defined, use generic
$template = is_file("modules/$object->_view_template") ?
  $object->_view_template : 
  "system/templates/CMbObject_view.tpl";

// Cr�ation du template
$smarty = new CSmartyDP();
$smarty->assign("object", $object);
$smarty->assign("props", $object->getDBFields());

$smarty->display("../../$template");
?>