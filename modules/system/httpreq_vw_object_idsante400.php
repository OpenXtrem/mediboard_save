<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage system
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

$object = mbGetObjectFromGet("object_class", "object_id", "object_guid");

// Cr�ation du template
$smarty = new CSmartyDP();
$smarty->assign("canSante400", CModule::getCanDo("dPsante400"));
$smarty->assign("object", $object);
$smarty->display("inc_object_idsante400.tpl");
