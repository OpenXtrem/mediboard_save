<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage eai
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

$client_addr = CValue::post("client_addr");
$client_port = CValue::post("client_port");
$port        = CValue::post("port");
$message     = CValue::post("message");

mbLog($message, "FROM $client_addr:$client_port TO localhost:$port");
