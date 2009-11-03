<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage bloodSalvage
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

global $can, $m, $g;
CAppUI::requireModuleFile("bloodSalvage", "inc_personnel");


$blood_salvage      = new CBloodSalvage();
$date               = CValue::getOrSession("date", mbDate());
$op                 = CValue::getOrSession("op");
$totaltime          = "00:00:00";
$modif_operation    = $date>=mbDate();
$timing             = array();
$tabAffected        = array();
/*
 * Liste des cell saver.
 */
$cell_saver = new CCellSaver();
$list_cell_saver = $cell_saver->loadList();

/*
 * Liste du personnel pr�sent en SSPI.
 */
$list_nurse_sspi= CPersonnel::loadListPers("reveil");

/*
 * Liste d'incidents transfusionnels possibles.
 */
$incident = new CTypeEi();
$liste_incident = $incident->loadList();

/*
 * Cr�ation du tableau d'affectation et de celui des timings.
 */
$tabAffected = array();
$timingAffect = array();

if($op) {
  $where = array();
  $where["operation_id"] = "='$op'";  
  $blood_salvage->loadObject($where);
  $blood_salvage->loadRefsFwd();
  $blood_salvage->loadRefPlageOp();  
  $blood_salvage->_ref_operation->loadRefPatient();
  $timing["_recuperation_start"]       = array();
  $timing["_recuperation_end"]         = array();
  $timing["_transfusion_start"]        = array();
  $timing["_transfusion_end"]          = array();
  foreach($timing as $key => $value) {
    for($i = -CAppUI::conf("dPsalleOp max_sub_minutes"); $i < CAppUI::conf("dPsalleOp max_add_minutes") && $blood_salvage->$key !== null; $i++) {
      $timing[$key][] = mbTime("$i minutes", $blood_salvage->$key);
    }
  }
  
  loadAffected($blood_salvage->_id, $list_nurse_sspi, $tabAffected, $timingAffect);
  
}

$smarty = new CSmartyDP();

$smarty->assign("date", $date);
$smarty->assign("blood_salvage",$blood_salvage);
$smarty->assign("totaltime", $totaltime);
$smarty->assign("modif_operation", $modif_operation);
$smarty->assign("timing", $timing);
$smarty->assign("timingAffect", $timingAffect);
$smarty->assign("tabAffected",$tabAffected);
$smarty->assign("list_cell_saver", $list_cell_saver);
$smarty->assign("list_nurse_sspi", $list_nurse_sspi);
$smarty->assign("liste_incident", $liste_incident);


$smarty->display("inc_vw_sspi_bs.tpl");

?>