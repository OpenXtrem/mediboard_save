<table class="main">
  <tr>
    <td>
      <table class="tbl">
        <tr>
          <th class="title" colspan="5">Urgences de la journ�e</th>
        </tr>
        <tr>
          <th>Patient</th>
          <th>Praticien</th>
          <th>Salle</th>
          <th>Cot�</th>
          <th>Intervention</th>
        </tr>
        {{foreach from=$urgences item=curr_op}}
        <tr>
          <td>{{$curr_op->_ref_sejour->_ref_patient->_view}}</td>
          <td>Dr. {{$curr_op->_ref_chir->_view}}</td>
          <td>
            <form name="editOpFrm{{$curr_op->opertion_id}}" action="?m={{$m}}" method="post">
            <input type="hidden" name="m" value="dPplanningOp" />
            <input type="hidden" name="del" value="0" />
            <input type="hidden" name="dosql" value="do_planning_aed" />
            <input type="hidden" name="operation_id" value="{{$curr_op->operation_id}}"
            <select name="salle_id" onchange="submitFormAjax(this.form, 'systemMsg')">
              <option value="">&mdash; Choix de la salle</option>
              {{foreach from=$listSalles item=curr_salle}}
              <option value="{{$curr_salle->id}}" {{if $curr_salle->id == $curr_op->_ref_salle->id}}selected="selected"{{/if}}>
                {{$curr_salle->nom}}
              </option>
              {{/foreach}}
            </select>
          </td>
          <td>{{$curr_op->cote}}</td>
          <td class="text">
            {{foreach from=$curr_op->_ext_codes_ccam item=curr_code}}
              <strong>{{$curr_code->code}}</strong> : {{$curr_code->libelleLong}}<br />
            {{/foreach}}
          </td>
        </tr>
        {{/foreach}}
      </table>
    </td>
  </tr>
</table>