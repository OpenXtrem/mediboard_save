{{* $Id: view_messages.tpl 7622 2009-12-16 09:08:41Z phenxdesign $ *}}

{{*
 * @package Mediboard
 * @subpackage system
 * @version $Revision: 7622 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<table class="tbl">
	<tr>
    <th>{{mb_title class=CViewSender field=name}}</th>
		<th>{{mb_title class=CViewSender field=description}}</th>
		</th>
    <th>{{mb_title class=CViewSender field=params}}</th>
    <th class="narrow">
      {{mb_title class=CViewSender field=period}}
    </th>
    <th class="narrow">
      {{mb_title class=CViewSender field=offset}}
    </th>
	</tr>

  {{foreach from=$senders item=_sender}}
  <tr>
    <td>
      <button class="edit notext" style="float: right;" onclick="ViewSender.edit('{{$_sender->_id}}');">
        {{tr}}Edit{{/tr}}
      </button> 
      {{mb_value object=$_sender field=name}}
		</td>
		<td class="text compact">
      {{mb_value object=$_sender field=description}}
    </td>
    <td class="text compact">
    	{{mb_value object=$_sender field=params}}
		</td>
    <td>{{mb_value object=$_sender field=period}}</td>
    <td>{{mb_value object=$_sender field=offset}}</td>
  </tr>
  {{foreachelse}}
	<tr>
		<td class="empty" colspan="3">{{tr}}CViewSender.none{{/tr}}</td>
	</tr>
  {{/foreach}}
  
</table>

