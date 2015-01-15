{{*
 * $Id$
 *  
 * @category Mediusers
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
*}}

{{mb_include module=system template=inc_pagination total=$total_mediuser current=$page change_page='changePage'}}

{{mb_include template=vw_list_mediusers}}

{{mb_include module=system template=inc_pagination total=$total_mediuser current=$page change_page='changePage'}}