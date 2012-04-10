<?php /* $Id ajax_refresh_reglement.php $ */

/**
 * @package Mediboard
 * @subpackage dPcabinet
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

CCanDo::checkEdit();

$factureconsult_id  = CValue::getOrSession("factureconsult_id");

$facture = new CFactureConsult();
$facture->load($factureconsult_id); 
$facture->loadRefs();

$reglement = new CReglement();

// Chargement des banques
$orderBanque = "nom ASC";
$banque = new CBanque();
$banques = $banque->loadList(null,$orderBanque);

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("facture"       , $facture);
$smarty->assign("banques"       , $banques);
$smarty->assign("reglement"       , $reglement);
$smarty->assign("date"          , mbDate());

$smarty->display("inc_vw_reglements.tpl");
?>