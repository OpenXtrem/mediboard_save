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

function graphOpAnnulees($debut = null, $fin = null, $prat_id = 0, $salle_id = 0, $bloc_id = 0, $codeCCAM = "", $type_hospi = "", $hors_plage) {
  if (!$debut) $debut = CMbDT::date("-1 YEAR");
  if (!$fin) $fin = CMbDT::date();
  
  $prat = new CMediusers;
  $prat->load($prat_id);
  
  $salle = new CSalle;
  $salle->load($salle_id);

  $ticks = array();
  $serie_total = array(
    'label' => 'Total',
    'data' => array(),
    'markers' => array('show' => true),
    'bars' => array('show' => false)
  );
  for ($i = $debut; $i <= $fin; $i = CMbDT::date("+1 MONTH", $i)) {
    $ticks[] = array(count($ticks), CMbDT::transform("+0 DAY", $i, "%m/%Y"));
    $serie_total['data'][] = array(count($serie_total['data']), 0);
  }

  $salles = CSalle::getSallesStats($salle_id, $bloc_id);
  $series = array();
  $total = 0;

  // Gestion du hors plage
  if ($hors_plage) {
    $where_hors_plage = "AND (plagesop.date BETWEEN '$debut' AND '$fin'
                              OR operations.date BETWEEN '$debut' AND '$fin')";
  }
  else {
    $where_hors_plage = "AND plagesop.date BETWEEN '$debut' AND '$fin'
                         AND operations.date IS NULL
                         AND operations.plageop_id IS NOT NULL";
  }

  foreach ($salles as $salle) {
    $serie = array(
      'label' => utf8_encode($bloc_id ? $salle->nom : $salle->_view),
      'data' => array()
    );
    $query = "SELECT COUNT(DISTINCT(operations.operation_id)) AS total,
                DATE_FORMAT(COALESCE(operations.date, plagesop.date), '%m/%Y') AS mois,
                DATE_FORMAT(COALESCE(operations.date, plagesop.date), '%Y-%m-01') AS orderitem
              FROM operations
              LEFT JOIN sejour ON operations.sejour_id = sejour.sejour_id
              LEFT JOIN sallesbloc ON operations.salle_id = sallesbloc.salle_id
              LEFT JOIN plagesop ON plagesop.plageop_id = operations.plageop_id
              LEFT JOIN user_log ON user_log.object_id = operations.operation_id
                AND user_log.object_class = 'COperation'
              WHERE operations.annulee = '1'
                $where_hors_plage
                AND sejour.group_id = '".CGroups::loadCurrent()->_id."'
                AND user_log.type = 'store'
                AND DATE(user_log.date) = plagesop.date
                AND user_log.fields LIKE '%annulee%'";
  
    if ($type_hospi) $query .= "\nAND sejour.type = '$type_hospi'";
    if ($prat_id)    $query .= "\nAND operations.chir_id = '$prat_id'";
    if ($codeCCAM)   $query .= "\nAND operations.codes_ccam LIKE '%$codeCCAM%'";

    $query .= "\nAND sallesbloc.salle_id = '$salle->_id'";
  
    $query .= "GROUP BY mois
               ORDER BY orderitem";

    $result = $prat->_spec->ds->loadlist($query);
    
    foreach ($ticks as $i => $tick) {
      $f = true;
      foreach ($result as $r) {
        if ($tick[1] == $r["mois"]) {
          $serie["data"][] = array($i, $r["total"]);
          $serie_total["data"][$i][1] += $r["total"];
          $total += $r["total"];
          $f = false;
          break;
        }
      }
      if ($f) {
        $serie["data"][] = array(count($serie["data"]), 0);
      }
    }

    $series[] = $serie;
  }
  
  $series[] = $serie_total;
  
  // Set up the title for the graph
  $title = "Interventions annul�es le jour m�me";
  $subtitle = "$total interventions";
  if ($prat_id)  $subtitle   .= " - Dr $prat->_view";
  if ($salle_id) $subtitle   .= " - $salle->nom";
  if ($codeCCAM) $subtitle   .= " - CCAM : $codeCCAM";
  if ($type_hospi) $subtitle .= " - ".CAppUI::tr("CSejour.type.$type_hospi");

  $options = array(
    'title' => utf8_encode($title),
    'subtitle' => utf8_encode($subtitle),
    'xaxis' => array('labelsAngle' => 45, 'ticks' => $ticks),
    'yaxis' => array('autoscaleMargin' => 1),
    'bars' => array('show' => true, 'stacked' => true, 'barWidth' => 0.8),
    'HtmlText' => false,
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
  
  return array('series' => $series, 'options' => $options);
}