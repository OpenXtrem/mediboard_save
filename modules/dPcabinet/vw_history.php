<?php
/**
 * $Id$
 *
 * @package    Mediboard
 * @subpackage Cabinet
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision$
 */

CCanDo::checkRead();

// D�finition des variables
$consultation_id = CValue::get("consultation_id", 0);

$consult = new CConsultation();
$consult->load($consultation_id);
$consult->loadRefConsultAnesth();

$consult->loadLogs();

foreach ($consult->_refs_dossiers_anesth as $_dossier_anesth) {
  $_dossier_anesth->loadLogs();
}

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("consult", $consult);

$smarty->display("vw_history.tpl");
