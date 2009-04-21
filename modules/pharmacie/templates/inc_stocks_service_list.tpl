{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage pharmacie
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<table class="tbl">
  <tr>
    <th>{{tr}}CProductStockService-product_id{{/tr}}</th>
    <th>{{tr}}CProductStockService{{/tr}}</th>
    <th>{{tr}}CProductStockService-quantity{{/tr}}</th>
    <th>{{tr}}CProduct-_unit_title{{/tr}}</th>
    <th>{{tr}}CProductDelivery{{/tr}}</th>
    <th>Retour des services</th>
  </tr>
  {{foreach from=$list_stocks_service item=stock}}
    <tr>
      <td>
        <a class="tooltip-trigger" 
           onmouseover="ObjectTooltip.createEx(this, '{{$stock->_ref_product->_guid}}')"
           href="?m=dPstock&amp;tab=vw_idx_stock_service&amp;stock_service_id={{$stock->_id}}" title="{{tr}}CProductStockService-title-modify{{/tr}}">
        {{$stock->_ref_product}}
        </a>
      </td>
      <td>{{include file="../../dPstock/templates/inc_bargraph.tpl" stock=$stock}}</td>
      <td style="text-align: center;">{{mb_value object=$stock field=quantity}}</td>
      <td>{{mb_value object=$stock->_ref_product field=_unit_title}}</td>
      <td>
        {{assign var=id value=$stock->_id}}
        <form name="dispensation-{{$id}}" action="?" method="post" onsubmit="return (checkForm(this) && onSubmitFormAjax(this, {onComplete: refreshLists}))">
          <input type="hidden" name="m" value="dPstock" />
          <input type="hidden" name="dosql" value="do_delivery_aed" />
          {{mb_field object=$list_dispensations.$id field=service_id hidden=true}}
          {{mb_field object=$list_dispensations.$id field=patient_id hidden=true}}
          {{mb_field object=$list_dispensations.$id field=stock_id hidden=true}}
          <input type="hidden" name="date_dispensation" value="now" />
          {{mb_field object=$list_dispensations.$id field=quantity increment=1 form="dispensation-$id" size=3}}
          <button type="submit" class="tick">Dispenser</button>
        </form>
      </td>
      <td>
      {{if array_key_exists($id, $list_returns)}}
        {{foreach from=$list_returns.$id item=return}}
          {{assign var=id value=$return->_id}}
          <form name="return-{{$id}}" action="?" method="post" onsubmit="return (checkForm(this) && onSubmitFormAjax(this, {onComplete: refreshLists}))">
            <input type="hidden" name="m" value="dPstock" />
            <input type="hidden" name="dosql" value="do_delivery_trace_aed" />
            <input type="hidden" name="delivery_trace_id" value="{{$id}}" />
            {{mb_field object=$return field=code}}
            <input type="hidden" name="date_delivery" value="now" />
            {{mb_field object=$return field=quantity increment=1 form="return-$id" size=3}}
            <button type="submit" class="tick">Recevoir</button>
          </form><br />
        {{foreachelse}}
          Aucun retour de service
        {{/foreach}}
      {{else}}
        Aucun retour de service
      {{/if}}
      </td>
    </tr>
  {{foreachelse}}
    <tr>
      <td colspan="10">{{tr}}CProductStockService.none{{/tr}}</td>
    </tr>
  {{/foreach}}
</table>