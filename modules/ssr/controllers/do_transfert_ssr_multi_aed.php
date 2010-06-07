<?php /* $Id: $ */

/**
 * @package Mediboard
 * @subpackage ssr
 * @version $Revision:  $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */


$sejour_id = CValue::post("sejour_id");
$conge_id = CValue::post("conge_id");
$replacer_id = CValue::post("replacer_id");

$conge = new CPlageVacances();
$conge->load($conge_id);

$evenement = new CEvenementSSR();
$where = array();
$where["therapeute_id"] = " = '$conge->user_id'";
$where["sejour_id"] = " = '$sejour_id'";
$where["debut"] = " BETWEEN '$conge->date_debut' AND '$conge->date_fin'";
$evenements = $evenement->loadList($where);

foreach($evenements as $_evenement){
	$_evenement->therapeute_id = $replacer_id;
  $msg = $_evenement->store();
	CAppUI::displayMsg($msg, "CEvenementSSR-msg-modify");
} 

echo CAppUI::getMsg();
CApp::rip();

?>