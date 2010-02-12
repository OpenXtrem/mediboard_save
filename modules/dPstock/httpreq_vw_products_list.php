<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage dPstock
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */
 
global $can;
$can->needsRead();

$category_id = CValue::getOrSession('category_id');
$societe_id  = CValue::getOrSession('societe_id');
$product_id  = CValue::getOrSession('product_id');
$start       = CValue::getOrSession('start');
$keywords    = CValue::getOrSession('keywords');
$letter      = CValue::getOrSession('letter', "A");
$show_all    = CValue::get('show_all');

// Don't user getOrSession as we don't want to get it from session
CValue::setSession("show_all", $show_all);

$where = array();
$where["name"] = ($letter === "#" ? "RLIKE '^[^A-Z]'" : "LIKE '$letter%'");

if ($category_id) {
  $where['category_id'] = " = '$category_id'";
}
if ($societe_id) {
  $where['societe_id'] = " = '$societe_id'";
}
if ($keywords) {
  $where[] = "`code` LIKE '%$keywords%' OR 
              `name` LIKE '%$keywords%' OR 
              `description` LIKE '%$keywords%'";
}
if (!$show_all) {
  $where[] = "cancelled = '0' OR cancelled IS NULL";
}
$orderby = 'name, code';

$product = new CProduct();
$total = $product->countList($where);
$list_products = $product->loadList($where, $orderby, intval($start).",15");

foreach($list_products as $prod) {
	$prod->loadRefs();
}

// Smarty template
$smarty = new CSmartyDP();

$smarty->assign('list_products', $list_products);
$smarty->assign('product_id', $product_id);
$smarty->assign('total', $total);
$smarty->assign('start', $start);
$smarty->assign('letter', $letter);

$smarty->display('inc_products_list.tpl');
?>
