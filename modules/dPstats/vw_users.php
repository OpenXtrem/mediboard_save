<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPstats
* @version $Revision$
* @author Romain Ollivier
*/

global $AppUI, $can, $m;

$can->needsEdit();

$user_id = mbGetValueFromGetOrSession("user_id", $AppUI->user_id);
$user    = new CMediusers;
$user->load($user_id);
$listUsers = $user->loadListFromType();
$debutlog  = mbGetValueFromGetOrSession("debutlog", mbDate("-1 WEEK"));
$finlog    = mbGetValueFromGetOrSession("finlog", mbDate());

$debutact      = mbGetValueFromGetOrSession("debutact", mbDate());
$finact        = mbGetValueFromGetOrSession("finact", mbDate());

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("user_id"  , $user_id  );
$smarty->assign("listUsers", $listUsers);
$smarty->assign("debutlog" , $debutlog );
$smarty->assign("finlog"   , $finlog   );

$smarty->assign("debutact", $debutact);
$smarty->assign("finact", $finact);

$smarty->display("vw_users.tpl");

?>