<?php

/**
 * $Id$
 *
 * @category search
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @link     http://www.mediboard.org
 */
CCanDo::checkRead();
// R�cup�ration des valeurs n�cessaires
$words         = CValue::get("words");
$_min_date     = CValue::get("_min_date", "*");
$_max_date     = CValue::get("_max_date", "*");
$_date         = CValue::get("_date");
$specific_user = CValue::get("user_id");
$start         = (int)CValue::get("start", 0);
$names_types   = CValue::get("names_types", array());
$aggregate     = CValue::get("aggregate");
$sejour_id     = CValue::get("sejour_id");
$contexte      = CValue::get("contexte");
$user          = CMediusers::get();

if (in_array("CPrescriptionLineMix", $names_types)) {
  $names_types[] = "CPrescriptionLineMedicament";
}

// Donn�es n�cessaires pour la recherche
$client_index = new CSearch();
$client_log = new CSearchLog();
$client_index->createClient();
$client_log->createClient();

// Journalisation de la recherche
if ($words) {
  try {
    $client_log->log($names_types, $contexte, $user->_id, $words, $aggregate);
  }
  catch (Exception $e) {
    CAppUI::displayAjaxMsg("La requ�te ne peut pas �tre journalis�e", UI_MSG_WARNING);
    mbLog($e->getMessage());
  }
}

// Initialisation des mots pour la recherche
$words = $client_index->constructWordsWithPrat($words, $specific_user, $sejour_id);
$words = $client_index->constructWordsWithSejour($words, $sejour_id);
$words = $client_index->constructWordsWithDate($words, $_date, $_min_date, $_max_date);

// Recherche fulltext
$time              = 0;
$nbresult          = 0;
$array_results     = array();
$array_highlights  = array();
$array_aggregation = array();
$objects_refs      = array();
$authors           = array();
$author_ids        = array();

try {
  $results_query = $client_index->searchQueryString('AND', $words, $start, 30, $names_types, $aggregate);
  $results       = $results_query->getResults();
  $time          = $results_query->getTotalTime();
  $nbresult      = $results_query->getTotalHits();

  // traitement des r�sultats
  foreach ($results as $result) {
    $var             = $result->getHit();
    $author_ids[]    = $var["_source"]["author_id"];
    $patient_ids[]   = $var["_source"]["patient_id"];
    $array_results[] = $var;

    // Traitement des highlights
    $highlights = $result->getHighlights();
    if (count($highlights) != 0) {
      $array_highlights[] = utf8_decode(implode(" [...] ", $highlights['body']));
    }
    else {
      $array_highlights[] = "";
    }
  }

  // traitement des auteurs
  foreach ($author_ids as $author) {
    $authors[$author] = CMbObject::loadFromGuid("CMediusers-$author");
    $authors[$author]->loadRefFunction();
  }

  // traitement des patients
  $patient_ids       = array();
  $patients          = array();
  foreach ($patient_ids as $_patient) {
    $patients[$_patient] = CMbObject::loadFromGuid("CPatient-$_patient");
  }

  //traitement des contextes r�f�rents si aggregation est coch�e
  if ($aggregate) {
    $objects_refs = $client_index->loadAggregationObject($results_query->getAggregations("ref_class"));
  }
}
catch (Exception $e) {
  CAppUI::displayAjaxMsg("La requ�te est mal form�e", UI_MSG_ERROR);
  mbLog($e->getMessage());
}

$smarty = new CSmartyDP();
$smarty->assign("start", $start);
$smarty->assign("authors", $authors);
$smarty->assign("patients", $patients);
$smarty->assign("results", $array_results);
$smarty->assign("highlights", $array_highlights);
$smarty->assign("objects_refs", $objects_refs);
$smarty->assign("time", $time);
$smarty->assign("nbresult", $nbresult);
$smarty->assign("words", $words);

$smarty->display("inc_results_search.tpl");
