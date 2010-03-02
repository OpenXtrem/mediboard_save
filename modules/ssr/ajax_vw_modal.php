<?php /* $Id: httpreq_do_element_autocomplete.php 7211 2009-11-03 12:27:08Z rhum1 $ */

/**
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision: 7211 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

$category_id = CValue::get("category_id");
$element_prescription_id = CValue::get("element_prescription_id");
$prescription_id = CValue::get("prescription_id");

// Chargement de la ligne selectionnée
$element = new CElementPrescription();
$element->load($element_prescription_id);

// Chargement de toutes les lignes de la categorie
$line = new CPrescriptionLineElement();
$ljoin["element_prescription"] = "prescription_line_element.element_prescription_id = element_prescription.element_prescription_id";
$where["prescription_id"] = " = '$prescription_id'";
$where["element_prescription.category_prescription_id"] = " = '$category_id'";
$lines = $line->loadList($where, null, null, null, $ljoin);

$last_line = end($lines);

// Création du template
$smarty = new CSmartyDP();
$smarty->assign("element", $element);
$smarty->assign("lines", $lines);
$smarty->assign("last_line", $last_line);
$smarty->assign("nodebug", true);
$smarty->assign("current_date", mbDate());
$smarty->display("inc_vw_modal.tpl");

?>