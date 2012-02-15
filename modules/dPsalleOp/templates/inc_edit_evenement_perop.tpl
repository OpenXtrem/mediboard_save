<form name="edit-evenement-{{$evenement->_guid}}" method="post" action="?" onsubmit="return onSubmitFormAjax(this, {onComplete: function(){ Control.Modal.close(); reloadSurveillancePerop(); }})">
  <input type="hidden" name="m" value="dPsalleOp" />
  <input type="hidden" name="@class" value="{{$evenement->_class}}" />
  <input type="hidden" name="operation_id" value="{{$operation_id}}" />
  
  <table class="main form">
    {{mb_include module=system template=inc_form_table_header object=$evenement}}
    
    {{if $evenement instanceof CAnesthPerop}}
      <tr>
        <th>{{mb_label object=$evenement field=datetime}}</th>
        <td>{{mb_field object=$evenement field=datetime form="edit-evenement-`$evenement->_guid`" register=true}}</td>
      </tr>
      <tr>
        <th>{{mb_label object=$evenement field=libelle}}</th>
        <td>{{mb_field object=$evenement field=libelle}}</td>
      </tr>
      <tr>
        <th>{{mb_label object=$evenement field=incident}}</th>
        <td>{{mb_field object=$evenement field=incident typeEnum=checkbox}}</td>
      </tr>
      <tr>
        <td></td>
        <td>
          <button type="submit" class="submit">{{tr}}Save{{/tr}}</button>
        </td>
      </tr>
    {{/if}}
  </table>
</form>