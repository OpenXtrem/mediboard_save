<script type="text/javascript">
Main.add(function(){
  selectProduct({{$product->_id}});
});
</script>

{{assign var=infinite_stock_service value=$dPconfig.dPstock.CProductStockService.infinite_quantity}}

<button class="new" onclick="editProduct(0)">{{tr}}CProduct-title-create{{/tr}}</button>
      
{{if $can->edit}}
  {{mb_include template=inc_form_product}}
{{/if}}

{{if $product->_id}}
<ul class="control_tabs" id="tabs-stocks-references">
  <li><a href="#tab-stocks" {{if $product->_ref_stocks_service|@count == 0}}class="empty"{{/if}}>{{tr}}CProductStock{{/tr}} <small>({{$product->_ref_stocks_service|@count}})</small></a></li>
  <li><a href="#tab-references" {{if $product->_ref_references|@count == 0}}class="empty"{{/if}}>{{tr}}CProduct-back-references{{/tr}} <small>({{$product->_ref_references|@count}})</small></a></li>
  <li><a href="#tab-deliveries" {{if $product->_ref_deliveries|@count == 0}}class="empty"{{/if}}>{{tr}}CProductStockGroup-back-deliveries{{/tr}} <small>({{$product->_ref_deliveries|@count}})</small></a></li>
</ul>
<hr class="control_tabs" />

<div id="tab-stocks" style="display: none;">
  <table class="tbl">
    <tr>
      <th></th>
      <th>{{tr}}CProductStockGroup-quantity{{/tr}}</th>
      <th>{{tr}}CProductStockGroup-location_id{{/tr}}</th>
      <th>{{tr}}CProductStockGroup-bargraph{{/tr}}</th>
    </tr>
    
    {{assign var=_stock_group value=$product->_ref_stock_group}}
    <tr>
      <td>
        <a href="?m={{$m}}&amp;tab=vw_idx_stock_group&amp;stock_id={{$_stock_group->_id}}">
          Etablissement
        </a>
      </td>
      
      {{if $product->_ref_stock_group->_id}}
        <td>{{$_stock_group->quantity}}</td>
        <td>{{$_stock_group->_ref_location->name}}</td>
        <td>{{include file="inc_bargraph.tpl" stock=$product->_ref_stock_group}}</td>
      {{else}}
        <td colspan="2">{{tr}}CProductStockGroup.none{{/tr}}</td>
        <td>
          <button class="new" type="button" onclick="window.location='?m=dPstock&amp;tab=vw_idx_stock_group&amp;stock_id=0&amp;product_id={{$product->_id}}'">
            {{tr}}CProductStockGroup-title-create{{/tr}}
          </button>
        </td>
      {{/if}}
    </tr>
    <tr>
      <th class="category" colspan="4">
        {{if !$infinite_stock_service}}
          {{tr}}CProduct-back-stocks_service{{/tr}}
        {{else}}
          {{tr}}CProduct-back-endowments{{/tr}}
        {{/if}}
      </th>
    </tr>
    {{foreach from=$product->_ref_stocks_service item=curr_stock}}
      {{if !$infinite_stock_service}}
      <tr>
        <td>
          <a href="?m={{$m}}&amp;tab=vw_idx_stock_service&amp;stock_service_id={{$curr_stock->_id}}">
            {{$curr_stock->_ref_service}}
          </a>
        </td>
        <td>{{$curr_stock->quantity}}</td>
        <td></td>
        <td>{{include file="inc_bargraph.tpl" stock=$product->_ref_stock_group}}</td>
      </tr>
      {{/if}}
      {{if $curr_stock->_ref_endowment_items|@count}}
        <tr>
          <td colspan="10" style="padding-left: 2em;">
            {{if !$infinite_stock_service}}Dotations:{{/if}}
            {{foreach from=$curr_stock->_ref_endowment_items item=_endowment name=endowment}}
              <strong>{{$_endowment->_ref_endowment->name}}</strong> ({{$_endowment->quantity}}){{$smarty.foreach.endowment.last|ternary:'':','}}
            {{/foreach}}
          </td>
        </tr>
      {{/if}}
    {{foreachelse}}
      <tr>
        <td colspan="4">
        {{if !$infinite_stock_service}}
          {{tr}}CProductStockService.none{{/tr}}
        {{else}}
          {{tr}}CProductEndowment.none{{/tr}}
        {{/if}}
        </td>
      </tr>
    {{/foreach}}
  </table>
</div>

{{mb_include template=inc_product_references_list}}

<!--
<button class="new" type="button" onclick="window.location='?m={{$m}}&amp;tab=vw_idx_reference&amp;reference_id=0&amp;product_id={{$product->_id}}'">
  Nouvelle r�f�rence pour ce produit
</button>-->

<table id="tab-deliveries" class="main tbl">
  <tr>
    <th>{{mb_title class=CProductDelivery field=service_id}}</th>
    <th>{{mb_title class=CProductDelivery field=quantity}}</th>
    <th>{{mb_title class=CProductDelivery field=date_dispensation}}</th>
  </tr>
  {{foreach from=$product->_ref_deliveries item=_delivery}}
    <tr>
      <td>{{mb_value object=$_delivery field=service_id}}</td>
      <td>{{mb_value object=$_delivery field=quantity}}</td>
      <td>{{mb_value object=$_delivery field=date_dispensation}}</td>
    </tr>
  {{foreachelse}}
    <tr>
      <td colspan="3">{{tr}}CProductDeliveryTrace.none{{/tr}}</td>
    </tr>
  {{/foreach}}
</table>

{{/if}}