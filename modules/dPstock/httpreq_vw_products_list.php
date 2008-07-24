<?php /* $Id: $ */

/**
 *	@package Mediboard
 *	@subpackage dPstock
 *	@version $Revision: $
 *  @author Fabien M�nager
 */
 
global $can;
$can->needsRead();

$category_id = mbGetValueFromGetOrSession('category_id');
$societe_id  = mbGetValueFromGetOrSession('societe_id');
$limit       = mbGetValueFromGet('limit');
$keywords    = mbGetValueFromGet('keywords');

$where = array();
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
$orderby = '`name` ASC';

$product = new CProduct();
$list_products_count = $product->countList($where, $orderby);
$list_products = $product->loadList($where, $orderby, $limit?$limit:20);

foreach($list_products as $prod) {
	$prod->loadRefs();
}

// Smarty template
$smarty = new CSmartyDP();

$smarty->assign('list_products',       $list_products);
$smarty->assign('list_products_count', $list_products_count);

$smarty->display('inc_products_list.tpl');
?>
