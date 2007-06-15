<script type="text/javascript">

Object.extend(Droppables, {
  addPrescription: function(prescription_id) {
    var oDragOptions = {
      onDrop: function(element) {
        Prescription.Examen.drop(element.id, prescription_id)
      }, 
      hoverclass:'selected'
    }
    
    this.add('drop-listprescriptions-' + prescription_id,  oDragOptions);
  }
} );
  
</script>

{{if $prescription->_id}}
<table class="tbl" id="drop-listprescriptions-{{$prescription->_id}}">
  <tr>
    <th class="title" colspan="100">
      <a style="float:right;" href="#nothing" onclick="view_log('{{$prescription->_class_name}}', {{$prescription->_id}})">
        <img src="images/icons/history.gif" alt="historique" title="Voir l'historique" />
      </a>
      {{$prescription->_view}}
      <script type="text/javascript">
        Droppables.addPrescription({{$prescription->_id}});
      </script>
    </th>
  </tr>
  <tr>
    <th>Analyse</th>
    <th>Unit�</th>
    <th>R�f�rences</th>
    <th>Resultat</th>
    <th>Interne</th>
    <th>Externe</th>
  </tr>
  {{foreach from=$prescription->_ref_prescription_items item="_item"}}
  {{assign var="curr_examen" value=$_item->_ref_examen_labo}}
  <tbody class="hoverable">
  <tr id="PrescriptionItem-{{$_item->_id}}">
    <td rowspan="2">
      <a href="#{{$_item->_class_name}}-{{$_item->_id}}" onclick="Prescription.Examen.edit({{$_item->_id}})">
        {{$curr_examen->_view}}
      </a>
      <form name="delPrescriptionExamen-{{$_item->_id}}" action="?m={{$m}}" method="post" onsubmit="return checkForm(this)">
        <input type="hidden" name="m" value="dPlabo" />
        <input type="hidden" name="dosql" value="do_prescription_examen_aed" />
        <input type="hidden" name="prescription_labo_id" value="{{$prescription->_id}}" />
        <input type="hidden" name="prescription_labo_examen_id" value="{{$_item->_id}}" />
        <input type="hidden" name="del" value="1" />
        {{if $prescription->_status < $prescription|const:"VEROUILLEE"}}
        <button type="button" class="trash notext" onclick="Prescription.Examen.del(this.form)" >{{tr}}Delete{{/tr}}</button>
        {{/if}}
        <button type="button" class="search notext" onclick="ObjectTooltip.create(this, 'CExamenLabo', {{$curr_examen->_id}}, { mode: 'complete', popup: true })">
          view
        </button>
      </form>
    </td>
    {{if $curr_examen->type == "num"}}
    <td rowspan="2">{{$curr_examen->unite}}</td>
    <td rowspan="2">{{$curr_examen->min}} &ndash; {{$curr_examen->max}}</td>
    {{else}}
    <td rowspan="2" colspan="2">{{mb_value object=$curr_examen field="type"}}</td>
    {{/if}}
    <td>
      {{if !$curr_examen->_external}}
      {{if $_item->date}}
        {{assign var=msgClass value=""}}
        {{if $curr_examen->type == "num"}}
          {{mb_ternary var=msgClass test=$_item->_hors_limite value=warning other=message}}
        {{/if}}
        
        <div class="{{$msgClass}}">
          {{mb_value object=$_item field=resultat}}
        </div>
      {{else}}
        <em>En attente</em>
      {{/if}}
      {{else}}
        <em>Analyse externe</em>
      {{/if}}
    </td>
    {{if $curr_examen->_external}}
    <td rowspan="2">
      <input type="radio" name="radio-{{$_item->_id}}" disabled="disabled" />
    </td>
    <td rowspan="2">
      <input type="radio" name="radio-{{$_item->_id}}" disabled="disabled" checked="checked" />
    </td>
    {{elseif $curr_examen->_ref_siblings|@count}}
    <td>
      <input type="radio" name="radio-{{$_item->_id}}" checked="checked" />
    </td>
    <td>
      <input type="radio" name="radio-{{$_item->_id}}" />
    </td>
    </tr>
    <tr>
      <td colspan="3">
      <select name="sibling">
        <option value="">&mdash; Analyse externe</option>
      {{foreach from=$curr_examen->_ref_siblings item="curr_sibling"}}
        <option value="{{$cur_sibling_id}}">{{$curr_sibling->_view}}</option>
      {{/foreach}}
      </select>
    </td>
    {{else}}
    <td rowspan="2">
      <input type="radio" name="radio-{{$_item->_id}}" disabled="disabled" checked="checked" />
    </td>
    <td rowspan="2">
      <input type="radio" name="radio-{{$_item->_id}}" name="" disabled="disabled" />
    </td>
    {{/if}}
  </tr>
  </tbody>
  {{/foreach}}
</table>
{{/if}}