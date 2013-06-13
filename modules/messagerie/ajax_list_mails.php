<?php /** $Id$ **/

/**
 * @package    Mediboard
 * @subpackage messagerie
 * @version    $Revision$
 * @author     SARL OpenXtrem
 */

CCanDo::checkRead();

$account = CValue::get("account");
$favorite = CValue::get("favorite", 0);
$archived = CValue::get("archived", 0);
$page = CValue::get("page", 0);
$limit_list = CAppUI::pref("nbMailList", 20);

$user = CMediusers::get();

$mail = new CUserMail();
$mail->account_id = $account;
$mail->favorite = ($favorite) ? '1' : null;
$mail->archived = ($archived) ? '1' : '0';

$order = "date_inbox DESC";

$account_pop = new CSourcePOP();
$account_pop->_id = $account;
$account_pop->load();

$limit= "$page, $limit_list";

$nb_mails = $mail->countMatchingList();
$mails = $mail->loadMatchingList($order, $limit);

/** @var $mails CUserMail[] */
foreach ($mails as $_mail) {
  $_mail->loadReadableHeader();
  $_mail->loadRefsFwd();
  $_mail->checkApicrypt();
}


$smarty = new CSmartyDP();
$smarty->assign("mails", $mails);
$smarty->assign("page", $page);
$smarty->assign("nb_mails", $nb_mails);
$smarty->assign("account", $account);
$smarty->assign("favorite", $favorite);
$smarty->assign("archived", $archived);
$smarty->assign("account_pop", $account_pop);
$smarty->display("inc_list_mails.tpl");