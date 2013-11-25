<?php
/**
 * $Id$
 *
 * @package    Mediboard
 * @subpackage Cabinet
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision$
 */

$ds = CSQLDataSource::get("std");

// Initialisation des variables
global $period, $periods, $chir_id, $function_id, $date, $ndate, $pdate, $plageconsult_id, $consultation_id;

$hour             = CValue::get("hour");
$hide_finished    = CValue::get("hide_finished", true);
$_line_element_id = CValue::get("_line_element_id");
$multipleMode     = CValue::get("multipleMode", 0);
$multiple_edit    = CValue::get("multipleEdit", 0);

if ($multiple_edit || $consultation_id) {
  $hide_finished = false;
}

//if multiple, no weekly planner
if ($multipleMode) {
  $periods         = array("day", "week", "month");
  if ($period == "weekly") {
    $period = "month";
  }
}

$consultation_ids = array();
// next consultations in editMultiple
if ($consultation_id) {
  $consultation_ids = array();
  $consultation_temp = new CConsultation();
  $consultation_temp->load($consultation_id);
  $consultation_temp->loadRefPlageConsult()->loadRefChir();

  // we add the first consult to the future json list
  $consultation_ids[] = array(
    $consultation_temp->plageconsult_id,
    $consultation_temp->_id,
    $consultation_temp->_ref_plageconsult->date,
    $consultation_temp->heure,
    $consultation_temp->_ref_plageconsult->chir_id,
    $consultation_temp->_ref_plageconsult->_ref_chir->_view,
    $consultation_temp->annule
  );

  //edit mod
  if ($multiple_edit) {
    $plage_temp = $consultation_temp->_ref_plageconsult;
    if (!$function_id) {
      $function_id = $plage_temp->_ref_chir->function_id;
    }
    $function_id = $plage_temp->_ref_chir->function_id;
    $where_next = array();
    $ljoin_next = array();
    $limit = CAppUI::pref("NbConsultMultiple");
    $ljoin_next["plageconsult"] = "plageconsult.plageconsult_id = consultation.plageconsult_id";
    $ljoin_next["users_mediboard"] = "plageconsult.chir_id = users_mediboard.user_id";
    $where_next["patient_id"] = "= '$consultation_temp->patient_id'";
    $where_next["users_mediboard.function_id"] = "= '$function_id'";
    $where_next["date"] = ">= '$plage_temp->date'";
    $where_next[$consultation_temp->_spec->key] = "!= '$consultation_id'";
    /** @var $_consult CConsultation */
    foreach ($consultation_temp->loadList($where_next, "date", null, null, $ljoin_next) as $_consult) {
      $consultation_temp->loadRefPlageConsult()->loadRefChir();
      $consultation_ids[]= array(
        $_consult->plageconsult_id,
        $_consult->_id,
        $_consult->_ref_plageconsult->date,
        $_consult->heure,
        $_consult->_ref_chir->_id,
        $_consult->_ref_chir->_view,
        $_consult->annule
      );
    }
  }
}

//functions
$function       = new CFunctions();
$listFunctions  = $function->loadSpecialites(PERM_EDIT);

// R�cup�ration des plages de consultation disponibles
$plage = new CPlageconsult();
$where = array();

// Praticiens s�lectionn�s
$listPrat = CConsultation::loadPraticiens(PERM_EDIT, $function_id, null, true);

if ($_line_element_id) {
  $where["pour_tiers"] = "= '1'";
}

$chir_sel = CSQLDataSource::prepareIn(array_keys($listPrat), $chir_id);
$where[] = "chir_id $chir_sel OR remplacant_id $chir_sel";

// Filtres
if ($hour) {
  $where["debut"] = "<= '$hour:00'";
  $where["fin"] = "> '$hour:00'";
}

if ($hide_finished) {
  $where[] = $ds->prepare("`date` >= %", CMbDT::date());
}

$minDate = $maxDate = $refDate = CMbDT::date(null, $date);
// Filtre de la p�riode
switch ($period) {
  case "day":
    $minDate = $maxDate = $refDate = CMbDT::date(null, $date);
    break;

  case "week":
    $minDate = CMbDT::date("last sunday", $date);
    $maxDate = CMbDT::date("next saturday", $date);
    $refDate = CMbDT::date("+1 day", $minDate);
    break;

  case "4weeks":
    $minDate = CMbDT::date("last sunday", $date);
    $maxDate = CMbDT::date("+ 3 weeks", CMbDT::date("next saturday", $date));
    $refDate = CMbDT::date("+1 day", $minDate);
    break;

  case "month":
    $minDate = CMbDT::format($date, "%Y-%m-01");
    $maxDate = CMbDT::transform("+1 month", $minDate, "%Y-%m-01");
    $maxDate = CMbDT::date("-1 day", $maxDate);
    $refDate = $minDate;
    break;

  default:
    trigger_error("P�riode '$period' inconnue");
    break;
}

$bank_holidays = array_merge(CMbDate::getHolidays($minDate), CMbDate::getHolidays($maxDate));

$where["date"] = $ds->prepare("BETWEEN %1 AND %2", $minDate, $maxDate);
$where[] = "libelle != 'automatique' OR libelle IS NULL";

$ljoin["users"] = "users.user_id = plageconsult.chir_id OR users.user_id = plageconsult.remplacant_id ";

$order = "date, user_last_name, user_first_name, debut";

// Chargement des plages disponibles
/** @var CPlageconsult[] $listPlage */
$listPlage = $plage->loadList($where, $order, null, "plageconsult_id", $ljoin);

if (!array_key_exists($plageconsult_id, $listPlage)) {
  $plage->_id = $plageconsult_id = null;
}

foreach ($listPlage as $currPlage) {
  if (!$plageconsult_id && $date == $currPlage->date) {
    $plageconsult_id = $currPlage->_id;
  }

  $currPlage->_ref_chir = $listPrat[$currPlage->chir_id];
  $currPlage->loadFillRate();
  $currPlage->loadCategorieFill();
  $currPlage->loadRefsNotes();
}

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("period"         , $period);
$smarty->assign("periods"        , $periods);
$smarty->assign("hour"           , $hour);
$smarty->assign("hours"          , CPlageconsult::$hours);
$smarty->assign("hide_finished"  , $hide_finished);
$smarty->assign("date"           , $date);
$smarty->assign("refDate"        , $refDate);
$smarty->assign("ndate"          , $ndate);
$smarty->assign("pdate"          , $pdate);
$smarty->assign("bank_holidays"  , $bank_holidays);
$smarty->assign("chir_id"        , $chir_id);
$smarty->assign("function_id"    , $function_id);
$smarty->assign("plageconsult_id", $plageconsult_id);
$smarty->assign("plage"          , $plage);
$smarty->assign("listPlage"      , $listPlage);
$smarty->assign("listFunctions"  , $listFunctions);
$smarty->assign("consultation_id", $consultation_id);
$smarty->assign("consultation_ids", $consultation_ids);
$smarty->assign("online"         , true);
$smarty->assign("_line_element_id", $_line_element_id);
$smarty->assign("multipleMode"   , $multipleMode);
$smarty->assign("multiple_edit"  , $multiple_edit);

$smarty->display("plage_selector.tpl");
