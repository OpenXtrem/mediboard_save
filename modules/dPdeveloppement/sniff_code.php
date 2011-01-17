<?php /* $Id: form_tester.php 6402 2009-06-08 07:53:07Z phenxdesign $ */

/**
* @package Mediboard
* @subpackage dPdeveloppement
* @version $Revision: 6402 $
* @author Fabien M�nager
*/

CCanDo::checkRead();

$file = "classes/mbobject.class.php";

$sniffer = new CMbCodeSniffer;
//$sniffer->process($file);
//echo "<pre>";
//$sniffer->report($file, "full");
//echo "</pre>";

$files = $sniffer->getFilesTree();


// Cuz sniffer changes work dir but restores it at destruction
// Be aware that unset() won't call __destruct() anyhow
$sniffer->__destruct();

// Cr�ation du template
$smarty = new CSmartyDP();
$smarty->assign("files", $files);
$smarty->display("sniff_code.tpl");

?>