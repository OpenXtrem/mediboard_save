<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPccam
* @version $Revision$
* @author Romain Ollivier
*/

global $AppUI, $can;

$can->needsAdmin();

set_time_limit(360);
ini_set("memory_limit", "64M");

$sourcePath = "modules/dPcim10/base/cim10.tar.gz";
$targetDir = "tmp/cim10";
$targetPath = "tmp/cim10/cim10.sql";

// Extract the SQL dump
if (null == $nbFiles = CMbPath::extract($sourcePath, $targetDir)) {
  $AppUI->stepAjax("Erreur, impossible d'extraire l'archive", UI_MSG_ERROR);
} 

$AppUI->stepAjax("Extraction de $nbFiles fichier(s)", UI_MSG_OK);

$ds = CSQLDataSource::get("cim10");
if (null == $lineCount = $ds->queryDump($targetPath)) {
  $msg = $ds->error();
  $AppUI->stepAjax("Erreur de requ�te SQL: $msg", UI_MSG_ERROR);
}

$AppUI->stepAjax("import effectu� avec succ�s de $lineCount lignes", UI_MSG_OK);

?>