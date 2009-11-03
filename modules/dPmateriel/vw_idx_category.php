<?php /* $Id$ */

/**
 *	@package Mediboard
 *	@subpackage dPmateriel
 *	@version $Revision$
 *  @author S�bastien Fillonneau
 */
 
global $AppUI, $can, $m;

$can->needsRead();

$category_id = CValue::getOrSession("category_id");

// Chargement de la cat�gorie demand�
$category=new CCategory;
$category->load($category_id);
$category->loadRefsBack();

// Liste des Cat�gories
$lstCategory = new CCategory;
$listCategory = $lstCategory->loadList();

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("listCategory", $listCategory);
$smarty->assign("category"    , $category    );

$smarty->display("vw_idx_category.tpl");

?>