<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage Developpement
* @version $Revision$
* @author Romain Ollivier
*/

CCanDo::checkRead();

// D�verrouiller la session pour rendre possible les requ�tes concurrentes.
CSessionHandler::writeClose();

// Cr�ation du template
$smarty = new CSmartyDP();
$smarty->assign("module", "dPdeveloppement");
$smarty->assign("action", "view_logs");
$smarty->display("benchmark.tpl");