<tr>
  <th colspan="3">
    {{mb_include module=system template=inc_object_notes     }}
    {{mb_include module=system template=inc_object_idsante400}}
    {{mb_include module=system template=inc_object_history   }}
    {{$object}}
    {{if $object instanceof CAffectation}}
      {{mb_include module=system template=inc_interval_datetime from=$object->entree to=$object->sortie}}
    {{/if}}
  </th>
</tr>
  <td rowspan="3">
    {{mb_include module=patients template=inc_vw_photo_identite mode=read patient=$patient size=50}}
  </td>
  <td>
    <span onmouseover="ObjectTooltip.createEx(this, '{{$patient->_guid}}')">
      {{$patient->nom}} {{$patient->prenom}}
    </span>
  </td>
  <td>
    {{mb_value object=$sejour field=entree}}
  </td>
</tr>
<tr>
  <td>{{mb_include module=mediusers template=inc_vw_mediuser mediuser=$sejour->_ref_praticien}}</td>
  <td>{{mb_value object=$sejour field=sortie}}</td>
</tr>
<tr>
  <td colspan="2" class="text">
    {{mb_label object=$sejour field=libelle}} : {{mb_value object=$sejour field=_motif_complet}}
  </td>
</tr>

{{if $sejour->_couvert_cmu || $sejour->_couvert_ald}}
  <tr>
    <td colspan="3">
      {{if $sejour->_couvert_cmu}}CMU /{{/if}} {{if $sejour->_couvert_ald}}ALD{{/if}} 
    </td>
  </tr>
{{/if}}

{{if $object instanceof CSejour}}
  <tr>
    <td class="text" colspan="2">
      Etablissement : {{$object->_ref_group}}
    </td>
    <td class="text">
      {{mb_label object=$object field=type}} : {{mb_value object=$object field=type}}
    </td>
  </tr>
{{/if}}

<tr>
  <td colspan="3">
    {{if $affectations|@count}}
      Affectations :
      <ul>
        {{foreach from=$affectations item=_affectation}}
          <li>
            {{if $_affectation->_id == $object->_id}}
              <strong>
            {{else}}
              <span onmouseover="ObjectTooltip.createEx(this, '{{$_affectation->_guid}}')">
            {{/if}}
            {{$_affectation}} {{mb_include module=system template=inc_interval_datetime from=$_affectation->entree to=$_affectation->sortie}}
            {{if $_affectation->_id == $object->_id}}
              </strong>
            {{else}}
              </span>
            {{/if}}
          </li>
        {{/foreach}}
      </ul>
    {{/if}}
    {{if $operations|@count}}
      Interventions :
      <ul>
        {{foreach from=$operations item=_operation}}
          <li>
            <span onmouseover="ObjectTooltip.createEx(this, '{{$_operation->_guid}}')">
              Intervention du {{mb_value object=$_operation field=_datetime}}
            </span>
          </li>
        {{/foreach}}
      </ul>
    {{/if}}
  </td>
</tr>