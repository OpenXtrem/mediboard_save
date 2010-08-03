<button class="new" onclick="editStockLocation(0)">
  {{tr}}CProductStockLocation-title-create{{/tr}}
</button>


<form name="edit_stock_location" action="?m={{$m}}" method="post" onsubmit="return checkForm(this)">
  <input type="hidden" name="dosql" value="do_stock_location_aed" />
  <input type="hidden" name="stock_location_id" value="{{$stock_location->_id}}" />
  <input type="hidden" name="group_id" value="{{$g}}" />
  <input type="hidden" name="del" value="0" />
  <table class="form">
    <tr>
      {{if $stock_location->_id}}
      <th class="title modify" colspan="2">{{tr}}CProductStockLocation-title-modify{{/tr}} {{$stock_location->name}}</th>
      {{else}}
      <th class="title" colspan="2">{{tr}}CProductStockLocation-title-create{{/tr}}</th>
      {{/if}}
    </tr> 
    <tr>
      <th>{{mb_label object=$stock_location field="name"}}</th>
      <td>{{mb_field object=$stock_location field="name"}}</td>
    </tr>
    <tr>
      <th>{{mb_label object=$stock_location field="desc"}}</th>
      <td>{{mb_field object=$stock_location field="desc"}}</td>
    </tr>
    <tr>
      <th>{{mb_label object=$stock_location field="position"}}</th>
      <td>{{mb_value object=$stock_location field="position"}}</td>
    </tr>
    <tr>
      <th>{{mb_label object=$stock_location field="_before"}}</th>
      <td>{{mb_field object=$stock_location field="_before" form="edit_stock_location" autocomplete="true,2,30,false,true"}}</td>
    </tr>
    <tr>
      <td class="button" colspan="4">
        {{if $stock_location->_id}}
        <button class="modify" type="submit">{{tr}}Save{{/tr}}</button>
        <button type="button" class="trash" onclick="confirmDeletion(this.form,{typeName:'',objName:'{{$stock_location->_view|smarty:nodefaults|JSAttribute}}'})">
          {{tr}}Delete{{/tr}}
        </button>
        {{else}}
        <button class="submit" type="submit">{{tr}}Create{{/tr}}</button>
        {{/if}}
      </td>
    </tr>  
  </table>
</form>
  
{{if $stock_location->_id}}
<table class="main tbl">
  <tr>
    <th class="category" colspan="10">
      <button style="float: right;" class="print notext" onclick="new Url('dPstock','print_stock_location').addParam('stock_location_id','{{$stock_location->_id}}').popup()">
        {{tr}}Print{{/tr}}
      </button>
      Stocks � cet emplacement
    </th>
  </tr>
  {{foreach from=$stock_location->_back.group_stocks item=_stock}}
    <tr>
      <td>
        <strong onmouseover="ObjectTooltip.createEx(this, '{{$_stock->_guid}}')">
          {{$_stock}}
        </strong>
      </td>
      <td>{{$_stock->quantity}}</td>
      <td>{{mb_include module=dPstock template=inc_bargraph stock=$_stock}}</td>
    </tr>
  {{foreachelse}}
    <tr>
      <td colspan="10">{{tr}}CProductStockGroup.none{{/tr}}</td>
    </tr>
  {{/foreach}}
</table>
{{/if}}