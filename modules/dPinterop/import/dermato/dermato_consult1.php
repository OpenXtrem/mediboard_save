<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPinterop
* @version $Revision$
* @author Romain OLLIVIER
*/

global $AppUI, $can, $m;

$can->needsRead();

set_time_limit( 1800 );

mbInsertCSV("modules/dPinterop/PLAGE CS.TXT", "dermato_import_consultations1");

?>