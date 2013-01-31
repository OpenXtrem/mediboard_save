<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPpmsi
* @version $Revision$
* @author Romain Ollivier
*/

CCanDo::checkRead();
$ds = CSQLDataSource::get("std");

$now       = mbDate();
$filter = new COperation;
$filter->salle_id      = CValue::get("salle_id");
$filter->_date_min     = CValue::get("_date_min", $now);
$filter->_date_max     = CValue::get("_date_max", $now);
$filter->_prat_id      = CValue::get("_prat_id");
$filter->_plage        = CValue::get("_plage");
$filter->_ranking      = CValue::get("_ranking");
$filter->_cotation     = CValue::get("_cotation");
$filter->_specialite   = CValue::get("_specialite");
$filter->_codes_ccam   = CValue::get("_codes_ccam");
$filter->_ccam_libelle = CValue::get("_ccam_libelle", 1);

$filterSejour = new CSejour;
$filterSejour->type = CValue::get("type");


$group = CGroups::loadCurrent();

//On sort les plages opératoires
//  Chir - Salle - Horaires

$plagesop = new CPlageOp;

$where = array();
$where["date"] =  $ds->prepare("BETWEEN %1 AND %2", $filter->_date_min, $filter->_date_max);

$order = "date, salle_id, debut";

$chir_id = CValue::get("chir");
$user = CMediusers::get();

// En fonction du praticien
if ($filter->_prat_id) {
  $where["chir_id"] = $ds->prepare("= %", $filter->_prat_id);
}

// En fonction de la salle
$listBlocs = $group->loadBlocs(PERM_READ);

$salle = new CSalle();
$whereSalle = array('bloc_id' => CSQLDataSource::prepareIn(array_keys($listBlocs)));
$listSalles = $salle->loadListWithPerms(PERM_READ, $whereSalle);

$where["salle_id"] = CSQLDataSource::prepareIn(array_keys($listSalles), $filter->salle_id);

$plagesop = $plagesop->loadList($where, $order);
$plagesop["urgences"] = new CPlageOp();

$prats = CMbObject::massLoadFwdRef($plagesop, "chir_id");
CMbObject::massLoadFwdRef($prats, "function_id");

// Operations de chaque plage
$listUrgencesTraitees = array();
foreach ($plagesop as $_plage) {
  $where = array();
  $ljoin = array();
  $tempOp = new COperation();

  // Cas des plages normales
  if ($_plage->_id) {

    $_plage->loadRefsFwd();

    // Opérations normale
    $joins = array();
    $where["plageop_id"] = "= '$_plage->_id'";
    $where["annulee"] = "= '0'";

    // Intervention ordonnancé
    switch ($filter->_ranking) {
      case "ok" :
        $where["rank"] = "!= '0'";
        break;
      case "ko" :
        $where["rank"] = "= '0'";
    }

    // Interventions avec ou sans actes
    if ($filter->_cotation) {
      $ljoin["acte_ccam"] = "operations.operation_id = acte_ccam.object_id AND acte_ccam.object_class = 'COperation'";
      switch ($filter->_cotation) {
        case "ok":
          $where["acte_id"] = "IS NOT NULL";
          break;
        case "ko":
          $where["acte_id"] = "IS NULL";
      }
    }

    if ($filter->_codes_ccam) {
      $where["codes_ccam"] = "LIKE '%$filter->_codes_ccam%'";
    }

    $order = "operations.rank";
    $listOperations = $tempOp->loadList($where, $order, null, null, $ljoin);

    // Urgences
    $where["plageop_id"]   = "IS NULL";
    $where["salle_id"]     = "= '$_plage->salle_id'";
    $where["chir_id"]      = "= '$_plage->chir_id'";
    $where["date"]         = "= '$_plage->date'";
    $where["operation_id"] = $_plage->_spec->ds->prepareNotIn($listUrgencesTraitees);
    $listUrgences = $tempOp->loadList($where, $order, null, null, $ljoin);
    $listUrgencesTraitees = array_merge($listUrgencesTraitees, array_keys($listUrgences));

    // On compile les interventions
    $_plage->_ref_operations = array_merge($listOperations, $listUrgences);
  }
  else {
    // Interventions avec ou sans actes
    if ($filter->_cotation) {
      $ljoin["acte_ccam"] = "operations.operation_id = acte_ccam.object_id AND acte_ccam.object_class = 'COperation'";
      switch ($filter->_cotation) {
        case "ok":
          $where["acte_id"] = "IS NOT NULL";
          break;
        case "ko":
          $where["acte_id"] = "IS NULL";
      }
    }

    // Cas des urgences restantes
    $ljoin["sejour"] = "sejour.sejour_id = operations.sejour_id";
    $where["sejour.group_id"] = "= '$group->_id'";
    $where["plageop_id"]   = "IS NULL";
    $where["date"]         = $ds->prepare("BETWEEN %1 AND %2", $filter->_date_min, $filter->_date_max);
    $where["operation_id"] = $ds->prepareNotIn($listUrgencesTraitees);
    $order = "date, chir_id";
    $_plage->_ref_operations = $tempOp->loadList($where, $order, null, null, $ljoin);
    if (!count($_plage->_ref_operations)) {
      unset($plagesop["urgences"]);
      continue;
    }
  }

  foreach ($_plage->_ref_operations as $_operation) {
    $sejour = $_operation->loadRefSejour();
    if ($filterSejour->type && $filterSejour->type != $sejour->type) {
      unset($_plage->_ref_operations[$_operation->_id]);
      continue;
    }

    $_operation->loadRefPraticien()->loadRefFunction();
    $_operation->loadExtCodesCCAM();
    foreach ($_operation->loadRefsActesCCAM() as $_acte) {
      $_acte->loadRefExecutant();
    }

    $sejour->loadRefPatient();
    $sejour->loadRefCurrAffectation($_operation->_datetime);
  }

  if (!count($_plage->_ref_operations) && !$filter->_plage) {
    unset($plagesop[$_plage->_id]);
  }
}

// Création du template
$smarty = new CSmartyDP();

$smarty->assign("filter"  , $filter);
$smarty->assign("plagesop", $plagesop);

$smarty->display("print_planning.tpl");
