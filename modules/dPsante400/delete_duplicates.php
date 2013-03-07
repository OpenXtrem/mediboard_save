<?php /* $Id: view_identifiants.php 12345 2011-06-03 12:55:42Z flaviencrochard $ */

/**
 * @package Mediboard
 * @subpackage sante400
 * @version $Revision: 12345 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

CCanDo::checkRead();

$canSante400 = CModule::getCanDo("dPsante400");
$dialog = CValue::get("dialog");

// Chargement du filtre
$filter = new CIdSante400;
$filter->object_id    = CValue::getOrSession("object_id");
$filter->object_class = CValue::getOrSession("object_class", "CPatient");
$filter->_start_date  = CValue::getOrSession("_start_date", CMbDT::dateTime());
$filter->_end_date    = CValue::getOrSession("_end_date", CMbDT::dateTime());
$limit_duplicates     = CValue::getOrSession("limit_duplicates", 30);
$do_delete            = CValue::get("do_delete", false);

$filter->nullifyEmptyFields();

// Récupéraration des doublon
$query = "SELECT COUNT(*) AS total, object_id, object_class, tag, id400,
    CAST(GROUP_CONCAT(id_sante400_id SEPARATOR ', ') AS CHAR) AS ids, '' AS msg
  FROM id_sante400
  WHERE 1";
if($filter->object_id) {
  $query .= " AND object_id = '".$filter->object_id."'";
}
if($filter->object_class) {
  $query .= " AND object_class = '".$filter->object_class."'";
}
$query .= " AND last_update BETWEEN '".$filter->_start_date."' AND '".$filter->_end_date."'";
$query .= " GROUP BY object_id, tag, id400
  HAVING total > 1
  ORDER BY total DESC, last_update DESC";
$list = $filter->_spec->ds->loadList($query, $limit_duplicates);

if($do_delete) {
  $idSante400 = new CIdSante400();
  foreach($list as &$duplicate) {
    $delete_items = implode(", ", array_slice(explode(", ", $duplicate["ids"]), 1));
    $query = "DELETE FROM id_sante400 WHERE id_sante400_id IN ($delete_items)";
    if($idSante400->_spec->ds->query($query)) {
      $duplicate["msg"] = "Identifiants supprimés : $delete_items"; 
    } else {
      $duplicate["msg"] = "Erreur : $query"; 
    }
  }
}

// Récupération de la liste des classes disponibles
$listClasses = CApp::getInstalledClasses();

// Création du template
$smarty = new CSmartyDP();
$smarty->assign("filter"           , $filter);
$smarty->assign("limit_duplicates" , $limit_duplicates);
$smarty->assign("do_delete"        , $do_delete);
$smarty->assign("listClasses"      , $listClasses);
$smarty->assign("list"             , $list);
$smarty->display("delete_duplicates.tpl");

?>