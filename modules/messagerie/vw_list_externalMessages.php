<?php /** $Id$ **/

/**
 * @package Mediboard
 * @subpackage messagerie
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */

CCanDo::checkRead();

$user_connected = CMediusers::get();
$user_id = CValue::get("user_id", $user_connected->_id);
$account_id = CValue::getOrSession("account_id");

//user
$user = new CMediusers();
$user->load($user_id);

//CSourcePOP account
$account = new CSourcePOP();

//getting the list of user with the good rights
$listUsers = $user->loadListWithPerms(PERM_EDIT);
$where = array();
//$where["source_pop.is_private"]   = "= '0'";
$where["source_pop.object_class"] = "= 'CMediusers'";
$where["users_mediboard.user_id"] = CSQLDataSource::prepareIn(array_keys($listUsers));
$ljoin = array();
$ljoin["users_mediboard"] = "source_pop.object_id = users_mediboard.user_id AND source_pop.object_class = 'CMediusers'";

//all accounts linked to a mediuser
//all accounts from an unique mediuser are grouped, in order to have the mediusers list
/** @var CSourcePOP[] $accounts_available */
$accounts_available = $account->loadList($where, null, null, "object_id", $ljoin);

//getting user list
$users = array();
foreach ($accounts_available as $_account) {
  $userPop = $_account->loadRefMetaObject();
  $users[] = $userPop;
}

//all accounts to the selected user
$where["source_pop.object_id"] = " = '$user->_id'";

//if user connected, show the private source pop
/*if ($user_id == $user_connected->_id) {
  $where["source_pop.is_private"] = " IS NOT NULL";
}*/

$accounts_user = $account->loadList($where, null, null, null, $ljoin);

//if no account_id, selecting the first one
if (!$account_id) {
  $account_temp = reset($accounts_available);
  $account_id = $account_temp->_id;
}


//switching account check, if session account_id not in user_account, reset account_id
if (!array_key_exists($account_id, $accounts_user)) {
  $account_temp = reset($accounts_user);
  $account_id = $account_temp->_id;
}

//smarty
$smarty = new CSmartyDP();
$smarty->assign("user",  $user);
$smarty->assign("users", $users);
$smarty->assign("mails", $accounts_user);
$smarty->assign("account_id", $account_id);
$smarty->display("vw_list_externalMessages.tpl");