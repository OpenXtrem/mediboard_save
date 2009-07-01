<?php /* $Id $ */

/**
 * @package Mediboard
 * @subpackage webservices
 * @version $Revision: 6287 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */

global $can;

$can->needsRead();

$echange_soap_id = mbGetValueFromGet("echange_soap_id");
$page            = mbGetValueFromGet('page', 1);
$now             = mbDate();
$_date_min       = mbGetValueFromGetOrSession('_date_min');
$_date_max       = mbGetValueFromGetOrSession('_date_max');

$web_service    = mbGetValueFromGetOrSession("web_service"); 

$doc_errors_msg = $doc_errors_ack = "";

// Chargement de l'�change SOAP demand�
$echange_soap = new CEchangeSOAP();
$echange_soap->_date_min = $_date_min ? $_date_min : $now;
$echange_soap->_date_max = $_date_max ? $_date_max : $now;

$echange_soap->load($echange_soap_id);
if($echange_soap->_id) {
  $echange_soap->loadRefs(); 
    
  $echange_soap->input  = unserialize($echange_soap->input);
  if($echange_soap->soapfault != 1) {
  	$echange_soap->output = unserialize($echange_soap->output);
  }
}

// R�cup�ration de la liste des echanges SOAP
$itemEchangeSoap = new CEchangeSOAP;

$where = array();
$where["web_service_name"] = $web_service ? " = '".$web_service."'" : "IS NULL";

$total_echange_soap = $itemEchangeSoap->countList($where);

//Pagination
$total_pages = ceil($total_echange_soap / 20);

$limit = ($page == 1) ? 0 : $page * 10;
$order = "date_echange DESC";
$listEchangeSoap = $itemEchangeSoap->loadList($where, $order, intval($limit).',20');
  
foreach($listEchangeSoap as &$curr_echange_soap) {
  $curr_echange_soap->loadRefs();
  
  $url = parse_url($curr_echange_soap->destinataire);
  $curr_echange_soap->destinataire = $url['host'];
}

// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("echange_soap"       , $echange_soap);
$smarty->assign("listEchangeSoap"    , $listEchangeSoap);
$smarty->assign("total_echange_soap" , intval($total_echange_soap));
$smarty->assign("total_pages"        , $total_pages);

$smarty->assign("web_service"        , $web_service);

$smarty->display("vw_idx_echange_soap.tpl");
?>
