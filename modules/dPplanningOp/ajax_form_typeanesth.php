<?php
/**
 * $Id:$
 *
 * @package    Mediboard
 * @subpackage PlanningOp
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision:$
 */

CCanDo::checkEdit();
$type_anesth_id = CValue::get("type_anesth");

$type_anesth = new CTypeAnesth();
$type_anesth->load($type_anesth_id);

if (!$type_anesth->_id) {
  $type_anesth->group_id = CGroups::loadCurrent()->_id;
}

// Récupération des groups
$groups = CGroups::loadGroups(PERM_EDIT);

//smarty
$smarty = new CSmartyDP();
$smarty->assign("type_anesth", $type_anesth);
$smarty->assign("groups"     , $groups);
$smarty->display("vw_form_typeanesth.tpl");