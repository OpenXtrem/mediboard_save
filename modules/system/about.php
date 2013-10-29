<?php
/**
 * $Id$
 *
 * @package    Mediboard
 * @subpackage System
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision$
 */

CCanDo::checkRead();

CAppUI::conf("dPpatients CConstantesMedicales selection_cabinet pouls", "global");

$smarty = new CSmartyDP();
$smarty->display("about.tpl");

