<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage mediusers
* @version $Revision$
* @author Romain Ollivier
*/

global $AppUI, $canRead, $canEdit, $m;

if (!$canRead) {
  $AppUI->redirect("m=system&a=access_denied");
}

// Droit de lecture dPsante400
$moduleSante400 = CModule::getInstalled("dPsante400");
$canReadSante400 = $moduleSante400 ? $moduleSante400->canRead() : false;

// Récupération du user à ajouter/editer
$mediuserSel = new CMediusers;
$mediuserSel->load(mbGetValueFromGetOrSession("user_id"));

// Récupération des fonctions
$groups = new CGroups;
$order = "text";
$groups = $groups->loadList(null, $order);
foreach ($groups as $key => $group) {
  $groups[$key]->loadRefsBack();
  foreach($groups[$key]->_ref_functions as $keyFct => $function){
    // Récuperation des utilisateurs
    $groups[$key]->_ref_functions[$keyFct]->loadRefs();
  }
}

// Récupération des disciplines
$disciplines = new CDiscipline;
$disciplines = $disciplines->loadList();

// Récupération des spécialités CPAM
$spec_cpam = new CSpecCPAM();
$spec_cpam = $spec_cpam->loadList();
  
// Récupération des profils
$where = array (
  "user_username" => "LIKE '>> %'"
);
$profiles = new CUser();
$profiles = $profiles->loadList($where);

// Création du template
$smarty = new CSmartyDP(1);

$smarty->assign("canReadSante400", $canReadSante400);
$smarty->assign("mediuserSel"    , $mediuserSel    );
$smarty->assign("profiles"       , $profiles       );
$smarty->assign("groups"         , $groups         );
$smarty->assign("disciplines"    , $disciplines    );
$smarty->assign("spec_cpam"      , $spec_cpam      );

$smarty->display("vw_idx_mediusers.tpl");

?>