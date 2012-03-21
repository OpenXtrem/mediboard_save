<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPhospi
* @version $Revision$
* @author Romain Ollivier
*/

$module = CModule::getInstalled(basename(dirname(__FILE__)));

$module->registerTab("vw_placements"              , TAB_READ);

$module->registerTab("edit_sorties"               , TAB_READ);
$module->registerTab("vw_recherche"               , TAB_READ);
$module->registerTab("vw_suivi_bloc"              , TAB_READ);
$module->registerTab("form_print_planning"        , TAB_READ);
if(CAppUI::conf("dPhospi pathologies") || CAppUI::$user->isAdmin()) {
  $module->registerTab("vw_idx_pathologies"         , TAB_READ);
}
/*
$module->registerTab("vw_idx_sejour"              , TAB_READ);
if(CModule::getActive("dPprescription")){
$module->registerTab("vw_bilan_prescription"      , TAB_READ);
}
*/
$module->registerTab("vw_idx_infrastructure"      , TAB_ADMIN);
$module->registerTab("vw_stats"                   , TAB_ADMIN);
$module->registerTab("vw_prestations"             , TAB_ADMIN);
$module->registerTab("vw_etiquettes"              , TAB_ADMIN);
if (CModule::getInstalled("printing")) {
  $module->registerTab("vw_printers"              , TAB_READ);
}
if (CModule::getInstalled("brancardage")) {
  $module->registerTab("vw_plan_etage"				    , TAB_READ);
  $module->registerTab("vw_placement_patients"    , TAB_READ);
}
?>