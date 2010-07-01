<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage dPstock
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */
 
CCanDo::checkEdit();

$category_id = CValue::getOrSession('category_id');

// Loads the expected Category
$category = new CProductCategory();
$category->load($category_id);

// Categories list
$list_categories = $category->loadList();
foreach($list_categories as $_cat) {
  $_cat->countBackRefs("products");
}

// Smarty template
$smarty = new CSmartyDP();

$smarty->assign('category',        $category);
$smarty->assign('list_categories', $list_categories);

$smarty->display('vw_idx_category.tpl');

?>