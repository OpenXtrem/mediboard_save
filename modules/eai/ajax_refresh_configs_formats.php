<?php 
/**
 * Formats available
 *  
 * @category EAI
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */
 
CCanDo::checkRead();

$actor_guid = CValue::getOrSession("actor_guid");

$formats_xml = CExchangeDataFormat::getAll("CEchangeXML");
foreach ($formats_xml as &$_format_xml) {
  $_format_xml = new $_format_xml;
  $_format_xml->getConfigs($actor_guid);
}

$formats_tabular = CExchangeDataFormat::getAll("CExchangeTabular");
foreach ($formats_tabular as &$_format_tabular) {
  $_format_tabular = new $_format_tabular;
  $_format_tabular->getConfigs($actor_guid);
}

// Cr�ation du template
$smarty = new CSmartyDP();
$smarty->assign("actor_guid"      , $actor_guid);
$smarty->assign("formats_xml"     , $formats_xml);
$smarty->assign("formats_tabular" , $formats_tabular);
$smarty->display("inc_configs_formats.tpl");