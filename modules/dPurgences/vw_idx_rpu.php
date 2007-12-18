<?php /* $Id: $ */

/**
* @package Mediboard
* @subpackage dPurgences
* @version $Revision: $
* @author Romain Ollivier
*/

global $AppUI, $can, $m, $g;

$can->needsRead();

// Type d'affichage
$selAffichage = mbGetValueFromPostOrSession("selAffichage","tous");

// Parametre de tri
$order_way = mbGetValueFromGetOrSession("order_way", "DESC");
$order_col = mbGetValueFromGetOrSession("order_col", "_entree");

// Selection de la date
$date = mbGetValueFromGetOrSession("date", mbDate());
$today = mbDate();

$group = new CGroups();
$group->load($g);
$user = new CMediusers();
$listPrats = $user->loadPraticiens(PERM_READ, $group->service_urgences_id);

$sejour = new CSejour;
$where = array();
$ljoin["rpu"] = "sejour.sejour_id = rpu.sejour_id";

$where["entree_reelle"] = "LIKE '$date%'";
$where["type"] = "= 'urg'";

if($selAffichage == "prendre_en_charge"){
  $ljoin["consultation"] = "consultation.sejour_id = sejour.sejour_id";
  $where["consultation.consultation_id"] = "IS NULL";
}


if($order_col != "_entree" && $order_col != "ccmu"){
  $order_col = "_entree";  
}

if($order_col == "_entree"){
  $order = "entree_reelle $order_way, rpu.ccmu $order_way";
}
else {
  $order = "rpu.ccmu $order_way, entree_reelle $order_way";
}

$listSejours = $sejour->loadList($where, $order, null, null, $ljoin);

foreach($listSejours as &$curr_sejour) {
  $curr_sejour->loadRefsFwd();
  $curr_sejour->loadRefRPU();
}

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("order_col", $order_col);
$smarty->assign("order_way", $order_way);
$smarty->assign("listPrats"  , $listPrats);
$smarty->assign("listSejours", $listSejours);
$smarty->assign("selAffichage", $selAffichage);
$smarty->assign("date", $date);
$smarty->assign("today", $today);

$smarty->display("vw_idx_rpu.tpl");
?>