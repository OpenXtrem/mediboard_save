<?php
/**
 * $Id$
 *
 * @category Files
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
 */

CCanDo::checkAdmin();

$category_id        = CValue::getOrSession("category_id", 0);
$page               = intval(CValue::get('page', 0));
$filter             = CValue::getOrSession("filter", "");
$eligible_file_view = CValue::getOrSession("eligible_file_view");
$class              = CValue::getOrSession("class");

$listClass = CApp::getChildClasses();

$smarty = new CSmartyDP();
$smarty->assign("category_id"       , $category_id);
$smarty->assign("page"              , $page);
$smarty->assign("listClass"         , $listClass);
$smarty->assign("filter"            , $filter);
$smarty->assign("class"             , $class);
$smarty->assign("eligible_file_view", $eligible_file_view);
$smarty->display("vw_categories.tpl");

