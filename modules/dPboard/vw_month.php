<?php 

/**
 * $Id$
 *  
 * @category Cabinet
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
 */

CCanDo::checkRead();

$user = CMediusers::get();
$perm_fonct = CAppUI::pref("allow_other_users_board");

$user->isSecretaire();
$user->isPraticien();

$date = CValue::getOrSession('date', CMbDT::date());
$prat_id = CValue::getOrSession('prat_id');
$function_id = CValue::get("function_id");

$prat = new CMediusers();
$prat->load($prat_id);

$function = new CFunctions();
$listFunc = array();
if ($perm_fonct == "only_me" || $perm_fonct == "same_function") {
  $listFunc[$user->function_id] = $user->loadRefFunction();
}
elseif($perm_fonct == "write_right") {
  $listFunc = CMediusers::loadFonctions(PERM_EDIT);
}
else {
  $listFunc = CMediusers::loadFonctions(PERM_READ);
}


/** @var CMediusers[] $listPrat */

if ($perm_fonct == 'only_me') {
  $listPrat[$user->_id] = $user;
  $prat = $user;
}
elseif($perm_fonct == "same_function") {
  $listPrat = $prat->loadProfessionnelDeSante(PERM_READ, $user->function_id);
}
elseif ($perm_fonct == "write_right") {
  $listPrat = $prat->loadProfessionnelDeSante(PERM_EDIT, null);
}
else {
  $listPrat = $prat->loadProfessionnelDeSante(PERM_READ, null);
}


usort(
  $listPrat, function ($a, $b) {
    return strcmp($a->_user_last_name, $b->_user_last_name);
  }
);

$calendar = new CPlanningMonth($date);

// smarty
$smarty = new CSmartyDP();
$smarty->assign("date", $date);
$smarty->assign("prev", $date);
$smarty->assign("next", $date);
$smarty->assign("prat", $prat);
$smarty->assign("listPrat", $listPrat);

$smarty->assign("user", $user);

$smarty->assign("listFunc", $listFunc);
$smarty->assign("function_id", $function_id);

$smarty->display("vw_month.tpl");