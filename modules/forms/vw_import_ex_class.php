<?php 

/**
 * $Id$
 *  
 * @category Forms
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
 */

CCanDo::checkAdmin();

$file = "test.xml";

$import = new CMbXMLObjectImport($file);

$map = array(
  "CExConcept" => array(
    "behaviour" => "shared",
    "children"  => "CExCListItem-list_id",
    "fields" => array(
      "name"     => "ask",
    ),
  ),

  "CExList" => array(
    "behaviour" => "shared",
    "children"  => "CExCListItem-list_id",
    "fields" => array(
      "name"     => "ask",
    ),
  ),
  "CExClassListItem" => array(),
  
  "CExClass" => array(
    "children"  => array(
      "CExClassFieldGroup-ex_class_id",
    ),
    "fields" => array(
      "group_id" => "ask",
    ),
  ),

  "CExClassFieldGroup" => array(
    "children"  => array(
      "CExClassField-ex_group_id",
    ),
    "fields" => array(
      "group_id" => "ask",
    ),
  ),

  "CExClassField" => array(
    "children"  => array(
      "CExListItem-field_id",
      "CExClassFieldTranslation-ex_class_field_id",
    ),
    "fields" => array(
      "group_id" => "ask",
    ),
  ),
  "CExClassFieldTranslation" => array(),
);

$ex_class = $import->getElementsbyClass("CExClass")->item(0);
$ex_class_name = $import->getNamedValueFromElement($ex_class, "name");

$list_elements  = $import->getElementsbyClass("CExList");
$lists = array();
foreach ($list_elements as $_list_element) {
  $_id = $_list_element->getAttribute("id");
  $_elements = $import->getElementsByFwdRef("CExListItem", "list_id", $_id);
  $_elements_values = array();
  foreach ($_elements as $_element) {
    $_elements_values[] = $import->getValuesFromElement($_element);
  }
  
  /** @var CExList[] $_similar */
  $_similar = $import->getSimilarFromElement($_list_element);
  
  $lists[$_list_element->getAttribute("id")] = array(
    "values"   => $import->getValuesFromElement($_list_element),
    "similar"  => $_similar,
    "elements" => $_elements_values,
  );
}

uasort($lists, function($a, $b) {
  return strcasecmp($a["values"]["name"], $b["values"]["name"]);
});

$list = new CExList();

/** @var CExList[] $all_lists */
$all_lists = $list->loadGroupList(null, "name");
$concept_elements = $import->getElementsbyClass("CExConcept");
$concepts = array();
foreach ($concept_elements as $_concept_element) {
  $_values = $import->getValuesFromElement($_concept_element);
  $_spec = explode(" ", $_values["prop"]);
  
  $concepts[$_concept_element->getAttribute("id")] = array(
    "values"    => $import->getValuesFromElement($_concept_element),
    "similar"   => $import->getSimilarFromElement($_concept_element),
    "spec_type" => $_spec[0],
  );
}

uasort($concepts, function($a, $b) {
  return strcasecmp($a["values"]["name"], $b["values"]["name"]);
});

$concept = new CExConcept();
$all_concepts = $concept->loadGroupList(null, "name");

// Cr�ation du template
$smarty = new CSmartyDP();
$smarty->assign("ex_class_name", $ex_class_name);

$smarty->assign("concepts", $concepts);
$smarty->assign("all_concepts", $all_concepts);

$smarty->assign("lists", $lists);
$smarty->assign("all_lists", $all_lists);

$smarty->display("vw_import_ex_class.tpl");