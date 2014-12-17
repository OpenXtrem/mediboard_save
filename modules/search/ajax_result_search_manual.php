<?php 

/**
 * $Id$
 *  
 * @category Search
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @link     http://www.mediboard.org */

CCanDo::checkRead();
// R�cup�ration des valeurs n�cessaires
$words         = CValue::get("words");
$start         = (int)CValue::get("start", 0);
$sejour_id     = CValue::get("sejour_id", null);
$contexte      = CValue::get("contexte");
$user          = CMediusers::get();

// Donn�es n�cessaires pour la recherche
$client_index = new CSearch();
$client_log = new CSearchLog();
$client_index->createClient();
$client_log->createClient();

// Journalisation de la recherche
$group = CGroups::loadCurrent();
if ($words && CAppUI::conf("search indexing active_indexing_log", $group)) {
  try {
    $client_log->log(null, $contexte, $user->_id, $words, false);
  }
  catch (Exception $e) {
    CAppUI::displayAjaxMsg("La requ�te ne peut pas �tre journalis�e", UI_MSG_WARNING);
    mbLog($e->getMessage());
  }
}

// Recherche fulltext
$time              = 0;
$nbresult          = 0;
$array_results     = array();
$array_highlights  = array();
$authors           = array();
$author_ids        = array();
$patients          = array();

try {
  $results_query = $client_index->searchQueryStringManual($words, $start, 30, $sejour_id);
  $results       = $results_query->getResults();
  $time          = $results_query->getTotalTime();
  $nbresult      = $results_query->getTotalHits();

  // traitement des r�sultats
  $patient_ids       = array();
  foreach ($results as $result) {
    $var             = $result->getHit();
    $author_ids[]    = $var["_source"]["author_id"];
    $patient_ids[]   = $var["_source"]["patient_id"];
    $var["_source"]["body"] = CMbString::normalizeUtf8($var["_source"]["body"]);
    $array_results[] = $var;

    // Traitement des highlights
    $highlights =$result->getHighlights();
    if (count($highlights) != 0) {
      $array_highlights[] = mb_convert_encoding(implode(" [...] ", $highlights['body']), "WINDOWS-1252",  "UTF-8");
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
  foreach ($patient_ids as $_patient) {
    $patients[$_patient] = CMbObject::loadFromGuid("CPatient-$_patient");
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
$smarty->assign("time", $time);
$smarty->assign("nbresult", $nbresult);
$smarty->assign("words", $words);
$smarty->assign("contexte", $contexte);
$smarty->assign("sejour_id", $sejour_id);

$smarty->display("inc_results_search_manual.tpl");