<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage mediusers
* @version $Revision$
* @author Romain Ollivier
*/

CCanDo::checkRead();

$page       = intval(CValue::get('page', 0));
$pro_sante  = CValue::get("pro_sante", array());
$inactif    = CValue::get("inactif", array());
$ldap_bound = CValue::get("ldap_bound", array());
$filter     = CValue::getOrSession("filter", "");
$order_way  = CValue::getOrSession("order_way", "ASC");
$order_col  = CValue::getOrSession("order_col", "function_id");

$step = 25;

// Récupération des fonctions
$group = CGroups::loadCurrent();
$group->loadFunctions();

// Liste des utilisateurs
$mediuser = new CMediusers();

$ljoin = array();
$ljoin["users"] = "users.user_id = users_mediboard.user_id";
$ljoin["functions_mediboard"] = "functions_mediboard.function_id = users_mediboard.function_id";

$where = array();
$where["functions_mediboard.group_id"] = "= '$group->_id'";

// FIXME: utiliser le seek
if ($filter) {
  $where[] = "functions_mediboard.text LIKE '%$filter%' OR 
              users.user_last_name LIKE '$filter%' OR 
              users.user_first_name LIKE '$filter%' OR 
              users.user_username LIKE '$filter%'";
}
if ($pro_sante) {
	$user_types = array("Chirurgien", "Anesthésiste", "Médecin", "Infirmière", "Kinesitherapeute", "Sage Femme");
	$utypes_flip = array_flip(CUser::$types);
  if (is_array($user_types)) {
    foreach ($user_types as $key => $value) {
      $user_types[$key] = $utypes_flip[$value];
    }

    $where["users.user_type"] = CSQLDataSource::prepareIn($user_types);
  }
}

if ($inactif) {
  $where["users_mediboard.actif"] = "!= '1'";
}

if ($ldap_bound) {
  $ljoin["id_sante400"] = "id_sante400.object_id = users.user_id";
  $where["id_sante400.object_class"] = " = 'CUser'"; 
  $where["id_sante400.tag"] = " = '".CAppUI::conf("admin LDAP ldap_tag")."'";
}

$order = null;
if ($order_col == "function_id") {
  $order = "functions_mediboard.text $order_way, users.user_last_name ASC, users.user_first_name ASC";
} 
if ($order_col == "user_username") {
  $order = "users.user_username $order_way, users.user_last_name ASC, users.user_first_name ASC";
} 
if ($order_col == "user_last_name") {
  $order = "users.user_last_name $order_way, users.user_first_name ASC";
} 
if ($order_col == "user_first_name") {
  $order = "users.user_first_name $order_way, users.user_last_name ASC";
} 
if ($order_col == "user_type") {
  $order = "users.user_type $order_way, users.user_last_name ASC, users.user_first_name ASC";
} 
if ($order_col == "user_last_login") {
  $order = "users.user_last_login ";
  $order .= $order_way == "ASC" ? "DESC" : "ASC";
  $order .= ", users.user_last_name ASC, users.user_first_name ASC";
}

$total_mediuser = $mediuser->countList($where, $order, null, null, $ljoin);
$mediusers = $mediuser->loadList($where, $order, "$page, $step", null, $ljoin);
foreach($mediusers as &$_mediuser) {
  $_mediuser->loadRefFunction();
  $_mediuser->loadRefProfile();
  $_mediuser->_ref_user->isLDAPLinked();
}

// Chargement des banques
$banques = array();
if (class_exists("CBanque")) {
	$order = "nom ASC";
	$banque = new CBanque();
	$banques = $banque->loadList(null, $order);
}

// Récupération des disciplines
$disciplines = new CDiscipline;
$disciplines = $disciplines->loadList();

// Récupération des spécialités CPAM
$spec_cpam = new CSpecCPAM();
$spec_cpam = $spec_cpam->loadList();
  
// Récupération des profils
$where = array (
  "template" => "= '1'"
);
$profiles = new CUser();
$profiles = $profiles->loadList($where);

// Creation du tableau de profil en fonction du type
foreach($profiles as $key => $profil){
  $tabProfil[$profil->user_type][] = $profil->_id;
}

// Récupération du user à ajouter/editer 
// (mis en dernier car interferences avec le chargement 
// des autres users car utilisation d'une spec commune)
$user_id = CValue::getOrSession("user_id");
$object = new CMediusers;
if (CValue::get("no_association")) {
  $object->user_id = $user_id;
  $object->updateFormFields();
  $object->_user_id = $user_id;
  $object->_id = null;
  $actif = CValue::get("ldap_user_actif", 1);
  $object->actif = $actif;
} else {
  $object->load($user_id);
}
if (isset($object->_ref_user)) {
  $object->_ref_user->isLDAPLinked();
}

// Création du template
$smarty = new CSmartyDP();

$smarty->assign("total_mediuser", $total_mediuser);
$smarty->assign("page"          , $page         );
$smarty->assign("pro_sante"     , $pro_sante    );
$smarty->assign("inactif"       , $inactif      );
$smarty->assign("ldap_bound"    , $ldap_bound   );
$smarty->assign("filter"        , $filter       );
$smarty->assign("mediusers"     , $mediusers    );
$smarty->assign("tabProfil"     , $tabProfil    );
$smarty->assign("utypes"        , CUser::$types );
$smarty->assign("banques"       , $banques      );
$smarty->assign("object"        , $object       );
$smarty->assign("profiles"      , $profiles     );
$smarty->assign("group"         , $group        );
$smarty->assign("disciplines"   , $disciplines  );
$smarty->assign("spec_cpam"     , $spec_cpam    );
$smarty->assign("order_way"     , $order_way);
$smarty->assign("order_col"     , $order_col);
$smarty->assign("step"          , $step);

$smarty->display("vw_idx_mediusers.tpl");

?>