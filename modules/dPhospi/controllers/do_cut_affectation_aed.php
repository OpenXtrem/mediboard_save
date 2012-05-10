<?php /* $Id: do_cut_affectation_aed.php $ */

/**
 * @package Mediboard
 * @subpackage dPpersonnel
 * @version $Revision: $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

$affectation_id = CValue::post("affectation_id");
$_date_cut      = CValue::post("_date_cut");
$lit_id         = CValue::post("lit_id");
$_action_maman  = CValue::post("_action_maman", 0);
$callback       = CValue::post("callback");

$uf_hebergement_id   = CValue::post("uf_hebergement_id");
$uf_medicale_id      = CValue::post("uf_medicale_id");
$uf_soins_id         = CValue::post("uf_soins_id");

$affectation = new CAffectation;
$affectation->load($affectation_id);

if ($_date_cut < $affectation->entree || $_date_cut > $affectation->sortie) {
  CAppUI::setMsg("Date de scission hors des bornes de l'affectation", UI_MSG_ERROR);
  echo CAppUI::getMsg();
  CApp::rip();
}

$affectation_cut = new CAffectation;
$affectation_cut->entree    = $_date_cut;
$affectation_cut->lit_id    = $affectation->lit_id;
$affectation_cut->sejour_id = $affectation->sejour_id;
$affectation_cut->sortie    = $affectation->sortie;
$affectation_cut->parent_affectation_id = $affectation->parent_affectation_id;

$affectation_cut->uf_hebergement_id = $uf_hebergement_id;
$affectation_cut->uf_medicale_id    = $uf_medicale_id;
$affectation_cut->uf_soins_id       = $uf_soins_id;
//$affectation_cut->effectue = 0;

if ($lit_id) {
  $affectation_cut->lit_id = $lit_id;
}

$save_parent_affectation_id = $affectation_cut->parent_affectation_id;

// D�tachement de la maman si la checkbox est coch�e
if ($save_parent_affectation_id && $_action_maman) {
  $affectation_cut->parent_affectation_id = null;
}

// Rattachement � l'affectation de la maman si la checkbox est coch�e
if ($_action_maman && !$save_parent_affectation_id) {
  $naissance = new CNaissance;
  $naissance->sejour_enfant_id = $affectation->sejour_id;
  $naissance->loadMatchingObject();
  
  if ($naissance->_id) {
    $sejour_maman = $naissance->loadRefSejourMaman();
    $affectation_maman = $sejour_maman->getCurrAffectation($_date_cut);
    if ($affectation_maman->_id) {
      $affectation_cut->lit_id = $affectation_maman->lit_id;
      $affectation_cut->parent_affectation_id = $affectation_maman->_id;
    }
  }
}

$affectation->sortie = $_date_cut;

if ($msg = $affectation->store()) {
  CAppUI::setMsg($msg, UI_MSG_ERROR);
}

if ($msg = $affectation_cut->store()) {
  CAppUI::setMsg($msg, UI_MSG_ERROR);
}

if ($callback) {
  $fields = $affectation_cut->getProperties();
  CAppUI::callbackAjax($callback, $affectation_cut->_id, $fields);
}

echo CAppUI::getMsg();
CApp::rip();

?>