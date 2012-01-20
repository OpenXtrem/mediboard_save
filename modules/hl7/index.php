<?php /* $Id $ */

/**
 * @package Mediboard
 * @subpackage hl7
 * @version $Revision:$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */

$module = CModule::getInstalled(basename(dirname(__FILE__)));

$module->registerTab("vw_servers_mllp"        , TAB_ADMIN);
$module->registerTab("vw_read_hl7v2_files"    , TAB_READ);
$module->registerTab("vw_test_hl7v2_data_type", TAB_READ);
$module->registerTab("vw_hl7v2_tables"        , TAB_READ);
$module->registerTab("vw_hl7v2_schemas"       , TAB_READ);

?>