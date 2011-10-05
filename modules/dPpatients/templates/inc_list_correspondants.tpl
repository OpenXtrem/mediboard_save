<script type="text/javascript">
  Main.add(function() {
    Control.Tabs.setTabCount("correspondance", "{{$nb_correspondants}}");
  });
</script>
{{if $nb_correspondants > 0}}
  {{foreach from=$correspondants_by_relation item=_correspondants key=relation}}
    <tr>
      <th colspan="10">{{tr}}CCorrespondantPatient.relation.{{$relation}}{{/tr}}</th>
    </tr>
    {{foreach from=$_correspondants item=_correspondant}}
      <tr>
        <td>{{mb_value object=$_correspondant field=nom}}</td>
        <td>
          {{if $_correspondant->relation != "employeur"}}
            {{mb_value object=$_correspondant field=prenom}}
          {{/if}}
        </td>
        <td>{{mb_value object=$_correspondant field=adresse}}</td>
        <td>
          {{mb_value object=$_correspondant field=cp}}
          {{mb_value object=$_correspondant field=ville}}
        </td>
        <td>{{mb_value object=$_correspondant field=tel}}</td>
        <td>
          {{if $_correspondant->relation != "employeur"}}
            {{mb_value object=$_correspondant field=parente}}
          {{/if}}
        </td>
        <td>
          {{if $_correspondant->relation == "employeur"}}
            {{mb_value object=$_correspondant field=urssaf}}
          {{/if}}
        </td>
        <td>{{mb_value object=$_correspondant field=email}}</td>
        <td>{{mb_value object=$_correspondant field=remarques}}</td>
        <td>
          <button type="button" class="edit notext" onclick="Correspondant.edit('{{$_correspondant->_id}}')"></button>
        </td>
      </tr>
    {{foreachelse}}
      <tr>
        <td colspan="10" class="empty">{{tr}}CCorrespondantPatient.none{{/tr}}</td>
      </tr>
    {{/foreach}}
  {{/foreach}}
{{else}}
  <tr>
    <td colspan="10" class="empty">{{$nb_correspondants}}{{tr}}CCorrespondantPatient.none{{/tr}}</td>
  </tr>
{{/if}}