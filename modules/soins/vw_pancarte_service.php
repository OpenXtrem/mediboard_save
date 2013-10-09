<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage soins
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

$group = CGroups::loadCurrent();

$service_id = CValue::getOrSession("service_id");

if($service_id == "NP"){
  $service_id = "";
}

$cond = array();

// Chargement du service
$service = new CService();
$service->load($service_id);

// Si le service en session n'est pas dans l'etablissement courant
if(CGroups::loadCurrent()->_id != $service->group_id){
  $service_id = "";
  $service = new CService();
}

$date = CValue::getOrSession("debut");
$prescription_id = CValue::get("prescription_id");

// Chargement des configs de services
if (!$service_id) {
  $service_id = "none";
}

$configs = CConfigService::getAllFor($service_id);

if (!$date) {
  $date = CMbDT::date();

  // Si la date actuelle est inférieure a l'heure affichée sur le plan de soins, on affiche le plan de soins de la veille (cas de la nuit)
  $datetime_limit = CMbDT::dateTime($configs["Poste 1"].":00:00");
  $datetime = $date . " " . CMbDT::format(null, "%H:%M:%S");

  if ($datetime < $datetime_limit) {
    $date = CMbDT::date("- 1 DAY", $date);
  }
}


$filter_line = new CPrescriptionLineMedicament();
$filter_line->debut = $date;

// Récupération de la liste des services
$where = array();
$where["externe"]   = "= '0'";
$where["cancelled"] = "= '0'";
$service = new CService();
$services = $service->loadGroupList($where);

// Smarty template
$smarty = new CSmartyDP();
$smarty->assign("service", $service);
$smarty->assign("filter_line", $filter_line);
$smarty->assign("services", $services);
$smarty->assign("service_id", $service_id);
$smarty->assign("date"     , $date);
$smarty->assign("date_min", "");
$smarty->display('vw_pancarte_service.tpl');
