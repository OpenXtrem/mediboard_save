<form name="editConfig" action="?m={{$m}}&amp;{{$actionType}}=configure" method="post" onsubmit="return checkForm(this)">

<input type="hidden" name="dosql" value="do_configure" />
<input type="hidden" name="m" value="system" />

<table class="form">
  <tr>
    <th class="title" colspan="2">Affichage</th>
  </tr>
  
  {{mb_include module=system template=inc_config_enum var=fiche_admission values="a4|a5"}}
  {{mb_include module=system template=inc_config_bool var=show_dh}}
  {{mb_include module=system template=inc_config_bool var=show_prestations_sorties}}
  {{mb_include module=system template=inc_config_bool var=use_recuse}}
  <tr>
    {{assign var="var" value="hour_matin_soir"}}
    <th>
      <label for="{{$m}}[{{$var}}]" title="{{tr}}config-{{$m}}-{{$var}}{{/tr}}">
        {{tr}}config-{{$m}}-{{$var}}{{/tr}}
      </label>  
    </th>
    <td class="greedyPane">
      <select class="num" name="{{$m}}[{{$var}}]">
      {{foreach from=0|range:24 item=_hour}}
        <option value="{{$_hour}}" {{if $_hour == $conf.$m.$var}} selected="selected" {{/if}}>
          {{$_hour|string_format:"%02d"}}
        </option>
      {{/foreach}}
      </select>
    </td>
  </tr>
  
  {{mb_include module=system template=inc_config_bool var=show_deficience}}

  <tr>
    <th style="width: 50%"></th>
    <td class="text">
      {{assign var=antecedents value=$conf.dPpatients.CAntecedent.types}}
      {{if preg_match("/deficience/", $antecedents)}}
        <div class="small-success">
          Le type d'ant�c�dent <strong>D�ficience</strong> est bien coch� dans le volet Ant�c�dents de
          <a href="?m=patients&tab=configure">l'onglet Configurer du module Dossier Patient</a>
        </div>
      {{else}}
        <div class="small-warning">
          Pour afficher cette ic�ne, le type d'ant�c�dent <strong>D�ficience</strong> 
          doit �tre coch� dans le volet Ant�c�dents de
          <a href="?m=patients&tab=configure">l'onglet Configurer du module Dossier Patient</a>
        </div>
      {{/if}}
    </td>
  </tr>
  <tr>
    <td class="button" colspan="100">
      <button class="modify" type="submit">{{tr}}Save{{/tr}}</button>
    </td>
  </tr>
</table>
</form>