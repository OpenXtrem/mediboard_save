<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPcompteRendu
* @version $Revision$
* @author Alexis Granger
* @abstract Permet de choisir des mod�les pour constituer des packs
*/

global $AppUI, $can;
$can->needsRead();

// Chargement du user
$user = new CMediusers;
$user->load(CValue::getOrSession("user_id", $AppUI->user_id));
$user->loadRefs();

// Chargement du pack
$pack = new CPack();
if ($pack->load(CValue::getOrSession("pack_id"))) {
  $pack->loadRefsFwd();
} else {
  $pack->chir_id = $user->user_id;
}

// Mod�les de l'utilisateur
$object_class = CValue::getOrSession("object_class");
$modeles = CCompteRendu::loadAllModelesFor($user->_id);

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("modeles", $modeles);
$smarty->assign("pack"   , $pack   );

$smarty->display("inc_list_modeles.tpl");

?>