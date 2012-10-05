<script type="text/javascript">
updateBanque = function(mode) {
  var form = mode.form;
  var banque_id = form.banque_id;
  var reference = form.reference;
  var BVR       = form.num_bvr;
  var mode = $V(mode);
  
  banque_id.hide();
  reference.hide();
  BVR.hide();
  
  switch(mode) {
    case "cheque":
      banque_id.show();
      reference.show();
      break;
      
    case "virement":
      reference.show();
      $V(banque_id, "");
      break;
      
    case "BVR":
      BVR.show();
      $V(banque_id, "");
      
    default:
      $V(banque_id, "");
  }
}

delReglement = function(reglement_id){
  var oForm = getForm('reglement-delete');
  $V(oForm.reglement_id, reglement_id);
  
  return confirmDeletion(oForm, { ajax: true, typeName:'le r�glement' }, {
     onComplete : function() {
      var url = new Url('dPcabinet', 'ajax_view_facture');
      {{if isset($facture|smarty:nodefaults)}}
        url.addParam('factureconsult_id', '{{$facture->_id}}');
      {{elseif isset($consult|smarty:nodefaults)}}
        url.addParam('consult_id',        '{{$consult->_id}}');
      {{/if}}
      url.requestUpdate("load_facture");
      Reglement.reload(true);
    }
  });
}

editReglementDate = function(reglement_id, date){
  var oForm = getForm('reglement-edit-date');
  $V(oForm.reglement_id, reglement_id);
  $V(oForm.date,         date);
  
  return onSubmitFormAjax(oForm, function() {
    var url = new Url('dPcabinet', 'ajax_view_facture');
    {{if isset($facture|smarty:nodefaults)}}
      url.addParam('factureconsult_id', '{{$facture->_id}}');
    {{elseif isset($consult|smarty:nodefaults)}}
      url.addParam('consult_id',        '{{$consult->_id}}');
    {{/if}}
    url.requestUpdate('load_facture');
    Reglement.reload(true);
  });
}

addReglement = function (oForm){
  return onSubmitFormAjax(oForm, function() {
    {{if isset($facture|smarty:nodefaults)}}
      var name = "factureconsult_id";
    {{elseif isset($consult|smarty:nodefaults)}}
      var name = "consult_id";
    {{/if}}
    
    var url = new Url('dPcabinet', 'ajax_view_facture');
    url.addParam(name, oForm.object_id.value);
    url.requestUpdate('load_facture');
    Reglement.reload(true);
  });
}

modifMontantBVR = function (num_bvr){
  var eclat = num_bvr.split('>')[0];
  var form = getForm("reglement-add");
  form.montant.value = eclat.substring(2, 12)/100;
}
</script>

{{if $facture->_id}}
  {{assign var=object value=$facture}}
{{else}}
  {{assign var=object value=$consult}}
{{/if}}

<fieldset>
  <legend>R�glements ({{tr}}{{$object->_class}}{{/tr}})</legend>
    {{if $object->du_patient}}
      <!-- Formulaire de suppression d'un reglement (car pas possible de les imbriquer) -->
      <form name="reglement-delete" action="#" method="post">
        <input type="hidden" name="m" value="dPcabinet" />
        <input type="hidden" name="del" value="1" />
        <input type="hidden" name="dosql" value="do_reglement_aed" />
        <input type="hidden" name="reglement_id" value="" />
      </form>
      
      <form name="reglement-edit-date" action="#" method="post">
        <input type="hidden" name="m" value="dPcabinet" />
        <input type="hidden" name="del" value="0" />
        <input type="hidden" name="dosql" value="do_reglement_aed" />
        <input type="hidden" name="reglement_id" value="" />
        <input type="hidden" name="date" value="" />
      </form>
      
      <form name="reglement-add" action="" method="post" onsubmit="return addReglement(this);">
        <input type="hidden" name="m" value="{{$m}}" />
        <input type="hidden" name="del" value="0" />
        <input type="hidden" name="dosql" value="do_reglement_aed" />
        <input type="hidden" name="emetteur" value="patient" />
        <input type="hidden" name="object_id" value="{{$object->_id}}" />
        <input type="hidden" name="object_class" value="{{$object->_class}}" />
        <table class="main tbl">
          <tr>
            <th class="category" style="width: 50%;">
              {{if isset($facture|smarty:nodefaults)}}
                {{mb_include module=system template=inc_object_notes      object=$facture}}
              {{/if}}
              {{mb_label object=$reglement field=mode}}
              ({{mb_label object=$reglement field=banque_id}})
            </th>
            <th class="category">{{mb_label object=$reglement field=reference}}</th>
            <th class="category narrow">{{mb_label object=$reglement field=montant}}</th>
            <th class="category narrow">{{mb_label object=$reglement field=date}}</th>
            <th class="category narrow"></th>
          </tr>
          
          <!--  Liste des reglements deja effectu�s -->
          {{foreach from=$object->_ref_reglements item=_reglement}}
          <tr>
            <td>
              {{mb_value object=$_reglement field=mode}}
              {{if $_reglement->_ref_banque->_id}}
                ({{$_reglement->_ref_banque}})
              {{/if}}
              {{if $_reglement->num_bvr}}( {{$_reglement->num_bvr}} ){{/if}}
            </td>
            <td>
              {{mb_value object=$_reglement field=reference}}
            </td>
            <td style="text-align: right;">
              {{mb_value object=$_reglement field=montant}}
            </td>
            <td>
              <input type="hidden" name="date_{{$_reglement->_id}}" class="{{$_reglement->_props.date}}" value="{{$_reglement->date}}" />
              <button type="button" class="submit notext" onclick="editReglementDate('{{$_reglement->_id}}', this.up('td').down('input[name=date_{{$_reglement->_id}}]').value);"></button>
              <script type="text/javascript">
                Main.add(function(){
                  Calendar.regField(getForm("reglement-add").date_{{$_reglement->_id}});
                });
              </script>
            </td>
            <td>
              <button type="button" class="remove notext" onclick="delReglement('{{$_reglement->_id}}');"></button>
            </td>
          </tr>
          {{/foreach}}
          {{if ($object->_du_restant_patient) > 0}}
            <tr>
              <td>
                {{mb_field object=$reglement field=mode emptyLabel="Choose" onchange="updateBanque(this)"}}
                {{mb_field object=$reglement field=banque_id options=$banques style="display: none"}}
                {{if isset($object->_num_bvr|smarty:nodefaults)}}
                  <select name="num_bvr" style="display:none;" onchange="modifMontantBVR(this.value);" >
                    <option value="0">&mdash; Choisir un num�ro</option>
                    {{foreach from=$object->_num_bvr item=num}}
                      <option value="{{$num}}">{{$num}}</option>
                    {{/foreach}}
                  </select>
                {{/if}}
              </td>
              <td>
                {{mb_field object=$reglement field=reference style="display: none"}}
              </td>
              <td><input type="text" class="currency notNull" size="4" maxlength="8" name="montant" value="{{$object->_du_restant_patient}}" /></td>
              <td>{{mb_field object=$_reglement field=date register=true form="reglement-add" value="now"}}</td>
              <td>
                <button class="add notext" type="submit">{{tr}}Add{{/tr}}</button>
              </td>
            </tr>
          {{/if}}
          <tr>
            <td colspan="5" style="text-align: center;">
              {{mb_value object=$object field=_reglements_total_patient}} r�gl�s, 
              <strong>{{mb_value object=$object field=_du_restant_patient}} restant</strong>
            </td>
          </tr>

          {{if $object->patient_date_reglement}}
          <tr>
            <td colspan="5" style="text-align: center;">
              <strong>
                {{mb_label object=$object field=patient_date_reglement}}
                le 
                {{mb_value object=$object field=patient_date_reglement}}
              </strong>
            </td>
          </tr>
          {{/if}}

        </table>
      </form>
    {{/if}}
</fieldset>