<?php
/**
 * $Id$
 *
 * @package    Mediboard
 * @subpackage dPstats
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision$
 */

/**
 * R�cuparation du graphique du nombre d'interventions annul�es le jour m�me
 *
 * @param string $date_min    Date de d�but
 * @param string $date_max    Date de fin
 * @param int    $prat_id     Identifiant du praticien
 * @param int    $salle_id    Identifiant de la salle
 * @param int    $bloc_id     Identifiant du bloc
 * @param string $code_ccam   Code CCAM
 * @param string $type_sejour Type de s�jour
 * @param bool   $hors_plage  Prise en charge des hors plage
 *
 * @return array
 */
function graphWorkflowOperation(
    $date_min = null, $date_max = null, $prat_id = null, $salle_id = null, $bloc_id = null,
    $code_ccam = null, $type_sejour = null, $hors_plage = false
) {
  $miner = new COperationWorkflow();
  $miner->warnUsage();

  if (!$date_min) {
    $date_min = CMbDT::date("-1 YEAR");
  }

  if (!$date_max) {
    $date_max = CMbDT::date();
  }

  $date_min = CMbDT::format($date_min, "%Y-%m-01");
  $date_max = CMbDT::transform("+1 MONTH", $date_max, "%Y-%m-01");

  $prat = new CMediusers;
  $prat->load($prat_id);

  // Series declarations
  $labels = array(
    "op_count"           => utf8_encode("Nombre d'interventions"),
    "creation"           => utf8_encode("Planification intervention"),
    "consult_chir"       => utf8_encode("Consultation chirurgicale"),
    "consult_anesth"     => utf8_encode("Consultation anesth�siste"),
    "visite_anesth"      => utf8_encode("Visite anesth�siste"),
    "creation_consult_chir"   => utf8_encode("RDV de consultation chirurgicale"),
    "creation_consult_anesth" => utf8_encode("RDV de consultation anesth�siste"),
  );

  $salles = CSalle::getSallesStats($salle_id, $bloc_id);

  $query = new CRequest();
  $query->addColumn("DATE_FORMAT(date_operation, '%Y-%m')", "mois");
  $query->addColumn("COUNT(operations.operation_id)", "op_count");
  $query->addColumn("AVG(DATEDIFF(ow.date_operation, ow.date_creation      ))", "creation"               );
  $query->addColumn("AVG(DATEDIFF(ow.date_operation, ow.date_consult_chir  ))", "consult_chir"           );
  $query->addColumn("AVG(DATEDIFF(ow.date_operation, ow.date_consult_anesth))", "consult_anesth"         );
  $query->addColumn("AVG(DATEDIFF(ow.date_operation, ow.date_visite_anesth ))", "visite_anesth"          );
  $query->addColumn("AVG(DATEDIFF(ow.date_operation, ow.date_creation_consult_chir  ))", "creation_consult_chir"  );
  $query->addColumn("AVG(DATEDIFF(ow.date_operation, ow.date_creation_consult_anesth))", "creation_consult_anesth");
  $query->addTable("operations");
  $query->addLJoin("operation_workflow AS ow ON ow.operation_id = operations.operation_id");

  // Pr�vention des donn�es n�gatives aberrantes
  $tolerance_in_days = 4;
  $query->addWhere("ow.date_creation                IS NULL OR DATEDIFF(ow.date_operation, ow.date_creation               ) > -$tolerance_in_days");
  $query->addWhere("ow.date_consult_chir            IS NULL OR DATEDIFF(ow.date_operation, ow.date_consult_chir           ) > -$tolerance_in_days");
  $query->addWhere("ow.date_consult_anesth          IS NULL OR DATEDIFF(ow.date_operation, ow.date_consult_anesth         ) > -$tolerance_in_days");
  $query->addWhere("ow.date_visite_anesth           IS NULL OR DATEDIFF(ow.date_operation, ow.date_visite_anesth          ) > -$tolerance_in_days");
  $query->addWhere("ow.date_creation_consult_chir   IS NULL OR DATEDIFF(ow.date_operation, ow.date_creation_consult_chir  ) > -$tolerance_in_days");
  $query->addWhere("ow.date_creation_consult_anesth IS NULL OR DATEDIFF(ow.date_operation, ow.date_creation_consult_anesth) > -$tolerance_in_days");

  $query->addWhereClause("date_operation", "BETWEEN '$date_min' AND '$date_max'");
  $query->addWhereClause("salle_id", CSQLDataSource::prepareIn(array_keys($salles)));
  $query->addGroup("mois");
  $query->addOrder("mois");

  // Filtre sur hors plage
  if (!$hors_plage) {
    $query->addWhereClause("plageop_id", "IS NOT NULL");
  }

  // Filtre sur le praticien
  if ($prat_id) {
    $query->addWhereClause("operations.chir_id", "= '$prat_id'");
  }

  // Filtre sur les codes CCAM
  if ($code_ccam) {
    $query->addWhereClause("operations.codes_ccam", "LIKE '%$code_ccam%'");
  }

  // Filtre sur le type d'hospitalisation
  if ($type_sejour) {
    $query->addLJoinClause("sejour", "sejour.sejour_id = operations.sejour_id");
    $query->addWhereClause("sejour.type", "= '$type_sejour'");
  }

  // Query result
  $ds = CSQLDataSource::get("std");
  $all_values = $ds->loadHashAssoc($query->makeSelect());

  // Build horizontal ticks
  $months = array();
  $ticks = array();
  for ($_date = $date_min; $_date < $date_max; $_date = CMbDT::date("+1 MONTH", $_date)) {
    $count_ticks = count($ticks);
    $ticks[] = array($count_ticks, CMbDT::format($_date, "%m/%Y"));
    $months[CMbDT::format($_date, "%Y-%m")] = $count_ticks;
  }

  // Series building
  $series = array();
  foreach ($labels as $_label_name => $_label_title) {
    $series[$_label_name] = array(
      "label" => $_label_title,
      "data" => array(),
      "yaxis" => 2
    );
  }

  $series["op_count"]["markers"]["show"] = true;
  $series["op_count"]["yaxis"] = 1;
  $series["op_count"]["lines"]["show"] = false;
  $series["op_count"]["points"]["show"] = false;
  $series["op_count"]["bars"]["show"] = true;;
  $series["op_count"]["bars"]["fillColor"] = "#ccc";
  $series["op_count"]["color"] = "#888";

  $total = 0;

  foreach ($months as $_month => $_tick) {
    $values =  isset($all_values[$_month]) ? $all_values[$_month] : array_fill_keys(array_keys($labels), null);
    unset($values["mois"]);
    foreach ($values as $_name => $_value) {
      $series[$_name]["data"][] = array($_tick, $_value);
    }
    $total += $values["op_count"];
  }

  // Set up the title for the graph
  $title = "Anticipation de la programmation des interventions";
  $subtitle = "$total interventions";
  if ($prat_id) {
    $subtitle   .= " - Dr $prat->_view";
  }
  if ($salle_id) {
    $salle = reset($salles);
    $subtitle   .= " - $salle->_view";
  }
  if ($code_ccam) {
    $subtitle   .= " - CCAM : $code_ccam";
  }
  if ($type_sejour) {
    $subtitle .= " - ".CAppUI::tr("CSejour.type.$type_sejour");
  }

  $options = array(
    'title' => utf8_encode($title),
    'subtitle' => utf8_encode($subtitle),
    'xaxis' => array('labelsAngle' => 45, 'ticks' => $ticks),
    'yaxis'  => array('autoscaleMargin' => 1, "title" => utf8_encode("Quantit� d'interventions"), "titleAngle" => 90),
    'y2axis' => array('autoscaleMargin' => 1, "title" => utf8_encode("Anticipation moyenne en jours vs la date d'intervention"), "titleAngle" => 90),
    "points" => array("show" => true, "radius" => 2, "lineWidth" => 1),
    "lines" => array("show" => true, "lineWidth" => 1),
    'bars' => array('show' => false, 'stacked' => false, 'barWidth' => 0.8),
    'HtmlText' => false,
    'legend' => array('show' => true, 'position' => 'nw'),
    'grid' => array('verticalLines' => false),
    'spreadsheet' => array(
      'show' => true,
      'csvFileSeparator' => ';',
      'decimalSeparator' => ',',
      'tabGraphLabel' => utf8_encode('Graphique'),
      'tabDataLabel' => utf8_encode('Donn�es'),
      'toolbarDownload' => utf8_encode('Fichier CSV'),
      'toolbarSelectAll' => utf8_encode('S�lectionner tout le tableau')
    )
  );

  return array('series' => array_values($series), 'options' => $options);
}

