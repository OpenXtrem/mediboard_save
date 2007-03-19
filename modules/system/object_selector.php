<?php /* $Id: $ */

/**
* @package Mediboard
* @subpackage system
* @version $Revision: $
* @author S�bastien Fillonneau
*/

global $AppUI, $can, $m;

$selClass = mbGetValueFromGetOrSession("selClass", null);
$keywords = mbGetValueFromGetOrSession("keywords", null);

// Liste des Class
$listClass = getInstalledClasses();

$keywords = trim($keywords);
$keywords_search = explode(" ", $keywords);
$keywords_search = array_filter($keywords_search);

if($selClass){
  $object = new $selClass;
  $list = $object->seek($keywords_search);
  foreach($list as $key => $value) {
    $list[$key]->loadRefsFwd();
    if(!$list[$key]->canRead()) {
      unset($list[$key]);
    }
  }
  $key = $object->_tbl_key;
}

// Cr�ation du template
$smarty = new CSmartyDP();

if($selClass){
  $smarty->assign("key"        , $key);
  $smarty->assign("list"       , $list);
}
$smarty->assign("listClass"  , $listClass );
$smarty->assign("keywords"   , $keywords  );
$smarty->assign("selClass"   , $selClass  );

$smarty->display("object_selector.tpl");
?>
