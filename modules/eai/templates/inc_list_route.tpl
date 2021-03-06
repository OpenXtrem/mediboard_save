{{*
 * $Id$
 *  
 * @category EAI
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
*}}

<table class="main tbl">
  <tr>
    <th colspan="7" class="title">
      {{tr}}CEAIRoute.list{{/tr}}
    </th>
  </tr>
  <tr>
    <th class="section" colspan="2">{{tr}}CInteropSender{{/tr}}</th>
    <th class="section" colspan="2">{{tr}}CInteropReceiver{{/tr}}</th>
    <th class="section" colspan="2"></th>
  </tr>
  <tr>
    <th> {{mb_title class=CEAIRoute field=sender_class}} </th>
    <th> {{mb_title class=CEAIRoute field=sender_id}} </th>
    <th> {{mb_title class=CEAIRoute field=receiver_class}} </th>
    <th> {{mb_title class=CEAIRoute field=receiver_id}} </th>
    <th> {{mb_title class=CEAIRoute field=active}} </th>
    <th> {{mb_title class=CEAIRoute field=description}} </th>
  </tr>

  {{foreach from=$routes key=_sender_guid item=_routes}}
    {{assign var=sender value=$senders.$_sender_guid}}
    <tbody class="hoverable">
    {{foreach from=$_routes item=_route name="foreach_routes"}}
      {{assign var=receiver value=$_route->_ref_receiver}}

        <tr {{if !$_route->active}}class="opacity-30"{{/if}}>
          {{if $smarty.foreach.foreach_routes.first}}
          <td rowspan="{{$_routes|@count}}" class="button">
            <button type="button" class="add notext"
                    onclick="Route.add('{{$sender->_guid}}', Route.refreshList.curry())">
              {{tr}}CInteropSender-add-route{{/tr}}</button>

           {{tr}} {{$sender->_class}} {{/tr}}
          </td>
          {{/if}}

          {{if $smarty.foreach.foreach_routes.first}}
          <td rowspan="{{$_routes|@count}}">
            <span onmouseover="ObjectTooltip.createEx(this, '{{$sender->_guid}}');">
               {{$sender->_view}}
             </span>
          </td>
          {{/if}}

          <td class="button">
            <button type="button" class="edit notext"
                    onclick="Route.edit('{{$_route->_id}}', Route.refreshList.curry())">
              {{tr}}Edit{{/tr}}
            </button>

            {{tr}} {{$receiver->_class}} {{/tr}}
          </td>

          <td>
           <span onmouseover="ObjectTooltip.createEx(this, '{{$receiver->_guid}}');">
             {{$receiver->_view}}
           </span>
          </td>

          <td>
            <form name="editActiveRoute{{$_route->_id}}" method="post" onsubmit="return onSubmitFormAjax(this)">
              {{mb_key object=$_route}}
              {{mb_class object=$_route}}
              {{mb_field object=$_route field="active" onchange=this.form.onsubmit()}}
            </form>
          </td>
          <td class="text compact">
            {{mb_value object=$_route field="description"}}
          </td>
        </tr>
    {{/foreach}}
    </tbody>
  {{/foreach}}
</table>