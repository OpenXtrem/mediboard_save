<table class="main tbl">
  <tr>
    <th class="category" style="width: 50%;">
      {{mb_label object=$reglement field=mode}}
      ({{mb_label object=$reglement field=banque_id}})
    </th>
    <th class="category">{{mb_label object=$reglement field=reference}}</th>
    <th class="category narrow">{{mb_label object=$reglement field=montant}}</th>
    <th class="category narrow">{{mb_label object=$reglement field=date}}</th>
  </tr>
  
  <!--  Liste des reglements deja effectu�s -->
  {{foreach from=$object->_ref_reglements item=_reglement}}
  <tr>
    <td>
      {{mb_value object=$_reglement field=mode}}
      {{if $_reglement->_ref_banque->_id}}
        ({{$_reglement->_ref_banque}})
      {{/if}}
    </td>
    <td> {{mb_value object=$_reglement field=reference}} </td>
    <td> {{mb_value object=$_reglement field=montant}} </td>
    <td> {{mb_value object=$_reglement field=date format="%d/%m/%Y"}} </td>
  </tr>
  {{/foreach}}
  <tr>
    <td colspan="4" style="text-align: center;">
      <strong> Aucun r�glement � percevoir du patient </strong>
    </td>
  </tr>
</table>