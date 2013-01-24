<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage dPadmissions
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

CCanDo::checkRead();

$date       = CValue::get("date", mbDate());
$type       = CValue::get("type");
$service_id = CValue::get("service_id");

$date_next = mbDate("+ 1 DAY", $date);
$service = new CService();
$service->load($service_id);
$group = CGroups::loadCurrent();

$sejour = new CSejour();
$where = array();
$where["sejour.sortie"]   = "BETWEEN '$date' AND '$date_next'";
$where["sejour.annule"]   = "= '0'";
$where["sejour.group_id"] = "= '$group->_id'";

if($type == "ambucomp") {
  $where[] = "`sejour`.`type` = 'ambu' OR `sejour`.`type` = 'comp'";
} elseif($type) {
  $where["sejour.type"] = " = '$type'";
} else {
  $where[] = "`sejour`.`type` != 'urg' AND `sejour`.`type` != 'seances'";
}

$ljoin = array();
$ljoin["users"] = "users.user_id = sejour.praticien_id";
if($service->_id) {
  $ljoin["affectation"]        = "affectation.sejour_id = sejour.sejour_id AND affectation.sortie = sejour.sortie";
  $ljoin["lit"]                = "affectation.lit_id = lit.lit_id";
  $ljoin["chambre"]            = "lit.chambre_id = chambre.chambre_id";
  $ljoin["service"]            = "chambre.service_id = service.service_id";
  $where["service.service_id"] = "= '$service->_id'";
}
$order = "users.user_last_name, users.user_first_name, sejour.sortie";

$sejours = $sejour->loadList($where, $order, null, null, $ljoin);

$listByPrat = array();
foreach ($sejours as $key => &$sejour) {
  $sejour->loadRefPraticien();
  $sejour->loadRefsAffectations();
  $sejour->loadRefPatient();
  $sejour->loadRefPrestation();
  $sejour->_ref_last_affectation->loadRefLit();
  $sejour->_ref_last_affectation->_ref_lit->loadCompleteView();
  
  $curr_prat = $sejour->praticien_id;
  $listByPrat[$curr_prat]["praticien"] =& $sejour->_ref_praticien;
  $listByPrat[$curr_prat]["sejours"][] =& $sejour;
}

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("date"      , $date);
$smarty->assign("type"      , $type);
$smarty->assign("service"   , $service);
$smarty->assign("listByPrat", $listByPrat);
$smarty->assign("total"     , count($sejours));

$smarty->display("print_sorties.tpl");

?>