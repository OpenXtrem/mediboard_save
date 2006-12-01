<table class="main">
  <tr>
    <th>
      <form action="index.php" name="mntTable" method="get">
      <input type="hidden" name="m" value="{{$m}}" />
      <input type="hidden" name="tab" value="{{$tab}}" />

      <label for="selClass" title="Veuillez S�lectionner une Class">Choix du type d'objet</label>
      <select title="str|notNull" name="selClass" onchange="submit();">
        <option value=""{{if !$selClass}} selected="selected"{{/if}}>&mdash; Liste des erreurs</option>
        {{foreach from=$listClass item=curr_listClass}}
        <option value="{{$curr_listClass}}"{{if $selClass==$curr_listClass}} selected="selected"{{/if}}>{{tr}}{{$curr_listClass}}{{/tr}}</option>
        {{/foreach}}
      </select>
      </form>
    </th>
  </tr>
  <tr>
    <td>
      <table class="tbl">
        <tr>
          <th rowspan="2">Objet</th>
          <th rowspan="2">Propri�t� de l'objet</th>
          <th colspan="5">Base de Donn�es</th>
        </tr>
        <tr>
          <th>Nom</th>
          <th>Type</th>
          <th>Null</th>
          <th>Default</th>
          <th>Index</th>
        </tr>
        {{assign var="styleColorKey"     value="style=\"background-color:#afa;\""}}
        {{assign var="styleColorError"   value="style=\"background-color:#f00;\""}}
        {{assign var="styleColorConflit" value="style=\"background-color:#fc0;\""}}
        
        {{foreach from=$aChamps key=keyClass item=currClass}}
        
        {{if $currClass|@count}}
        <tr>
          <th colspan="7" class="title">
            {{$keyClass}}
          </th>
        </tr>
        {{foreach from=$currClass key=keyChamp item=currChamp}}
        <tr>
          <td {{if !$currChamp.class_field}}
                {{$styleColorError|smarty:nodefaults}}
              {{elseif $currChamp.keytable && $currChamp.keytable==$currChamp.class_field}}
                {{$styleColorKey|smarty:nodefaults}}
              {{/if}}>
            {{$currChamp.class_field}}
          </td>
          <td {{if $currChamp.keytable && $currChamp.keytable==$currChamp.class_field && $currChamp.class_props}}
                {{$styleColorError|smarty:nodefaults}}
              {{elseif $currChamp.keytable && $currChamp.keytable==$currChamp.class_field}}
                {{$styleColorKey|smarty:nodefaults}}
              {{elseif $currChamp.error_class_props}}
                {{$styleColorConflit|smarty:nodefaults}}
              {{elseif !$currChamp.class_props}}
                {{$styleColorError|smarty:nodefaults}}
              {{/if}}>
            {{$currChamp.class_props}}
            {{if !$currChamp.class_field && $currChamp.class_props}}
            &mdash; <strong>{{$keyChamp}}</strong>
            {{/if}}
          </td>
          {{if !$currChamp.BDD_name}}
          <td colspan="5" {{$styleColorError|smarty:nodefaults}}>
          </td>
          {{else}}
          <td {{if $currChamp.keytable==$currChamp.BDD_name}}
                {{$styleColorKey|smarty:nodefaults}}
              {{/if}}>
            {{$currChamp.BDD_name}}
          </td>
          <td {{if $currChamp.error_BDD_type}}
                {{$styleColorConflit|smarty:nodefaults}}
              {{elseif $currChamp.keytable==$currChamp.BDD_name}}
                {{$styleColorKey|smarty:nodefaults}}
              {{/if}}>
            {{$currChamp.BDD_type}}
            {{if $currChamp.error_BDD_type}}
              &mdash; <strong>{{$currChamp.error_BDD_type}}</strong>
            {{/if}}
          </td>
          <td {{if $currChamp.error_BDD_null}}
                {{$styleColorConflit|smarty:nodefaults}}
              {{elseif $currChamp.keytable==$currChamp.BDD_name}}
                {{$styleColorKey|smarty:nodefaults}}
              {{/if}}>
            {{if $currChamp.BDD_null!="NO"}}
            {{$currChamp.BDD_null}}
            {{/if}}
          </td>
          <td {{if $currChamp.keytable==$currChamp.BDD_name}}
                {{$styleColorKey|smarty:nodefaults}}
              {{/if}}>
            {{$currChamp.BDD_default}}
          </td>
          <td {{if $currChamp.keytable==$currChamp.BDD_name}}
                {{$styleColorKey|smarty:nodefaults}}
              {{/if}}>
            {{$currChamp.BDD_index}}
          </td>
          {{/if}}
        </tr>
        {{/foreach}}
        {{/if}}
        {{/foreach}}
      </table>
    </td>
  </tr>
</table>