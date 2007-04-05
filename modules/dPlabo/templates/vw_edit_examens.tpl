<table class="main">
  <tr>
    <td class="halfPane">
      <form name="selectCatalogue" action="index.php" method="get">
      <input type="hidden" name="m" value="{{$m}}" />
      <input type="hidden" name="tab" value="{{$tab}}" />
      <label for="catalogue_labo_id" title="Selectionner le catalogue que vous d�sirez afficher">
        Choisissez un catalogue
      </label>
      <select name="catalogue_labo_id" onchange="this.form.submit()">
        <option value="0">&mdash; aucun</option>
        {{foreach from=$listCatalogues item="curr_catalogue"}}
        <option value="{{$curr_catalogue->_id}}" {{if $curr_catalogue->_id == $catalogue->_id}}selected="selected"{{/if}}>
          {{$curr_catalogue->_view}}
        </option>
        {{foreach from=$curr_catalogue->_ref_catalogues_labo item="curr_sub_catalogue"}}
        <option value="{{$curr_sub_catalogue->_id}}" {{if $curr_sub_catalogue->_id == $catalogue->_id}}selected="selected"{{/if}}>
          &mdash; {{$curr_sub_catalogue->_view}}
        </option>
        {{/foreach}}
        {{/foreach}}
      </select>
      </form>
      <table class="tbl">
        <tr>
          <th>Identifiant</th>
          <th>Libell�</th>
          <th>Type</th>
          <th>Unit�</th>
          <th>Min</th>
          <th>Max</th>
        </tr>
        {{foreach from=$catalogue->_ref_examens_labo item="curr_examen"}}
        <tr>
          <td>
            <a href="?m={{$m}}&amp;tab={{$tab}}&amp;examen_labo_id={{$curr_examen->_id}}">
              {{$curr_examen->identifiant}}
            </a>
          </td>
          <td>
            <a href="?m={{$m}}&amp;tab={{$tab}}&amp;examen_labo_id={{$curr_examen->_id}}">
              {{$curr_examen->libelle}}
            </a>
          </td>
          <td>
            <a href="?m={{$m}}&amp;tab={{$tab}}&amp;examen_labo_id={{$curr_examen->_id}}">
              {{$curr_examen->type}}
            </a>
          </td>
          <td>
            <a href="?m={{$m}}&amp;tab={{$tab}}&amp;examen_labo_id={{$curr_examen->_id}}">
              {{$curr_examen->unite}}
            </a>
          </td>
          <td>
            <a href="?m={{$m}}&amp;tab={{$tab}}&amp;examen_labo_id={{$curr_examen->_id}}">
              {{$curr_examen->min}} {{$curr_examen->unite}}
            </a>
          </td>
          <td>
            <a href="?m={{$m}}&amp;tab={{$tab}}&amp;examen_labo_id={{$curr_examen->_id}}">
              {{$curr_examen->max}} {{$curr_examen->unite}}
            </a>
          </td>
        </tr>
        {{/foreach}}
      </table>
    </td>
    <td class="halfPane">
      {{if $can->edit}}
      <a class="buttonnew" href="index.php?m={{$m}}&amp;tab={{$tab}}&amp;examen_labo_id=0">
        Ajouter un nouvel examen
      </a>
      <form name="editExamen" action="./index.php?m={{$m}}" method="post" onsubmit="return checkForm(this)">
      <input type="hidden" name="dosql" value="do_examen_aed" />
      <input type="hidden" name="examen_labo_id" value="{{$examen->_id}}" />
      <input type="hidden" name="del" value="0" />
      <table class="form">
        <tr>
          {{if $examen->_id}}
          <th class="title modify" colspan="2">Modification de l'examen {{$examen->_view}}</th>
          {{else}}
          <th class="title" colspan="2">Cr�ation d'un examen</th>
          {{/if}}
        </tr>
        <tr>
          <th>{{mb_label object=$examen field="catalogue_labo_id"}}</th>
          <td>
			      <select name="catalogue_labo_id">
			        {{foreach from=$listCatalogues item="curr_catalogue"}}
			        <option value="{{$curr_catalogue->_id}}" {{if $curr_catalogue->_id == $examen->catalogue_labo_id}}selected="selected"{{/if}}>
			          {{$curr_catalogue->_view}}
			        </option>
			        {{foreach from=$curr_catalogue->_ref_catalogues_labo item="curr_sub_catalogue"}}
			        <option value="{{$curr_sub_catalogue->_id}}" {{if $curr_sub_catalogue->_id == $examen->catalogue_labo_id}}selected="selected"{{/if}}>
			          &mdash; {{$curr_sub_catalogue->_view}}
			        </option>
			        {{/foreach}}
			        {{/foreach}}
			      </select>
        </td>
        </tr>
        <tr>
          <th>{{mb_label object=$examen field="identifiant"}}</th>
          <td>{{mb_field object=$examen field="identifiant"}}</td>
        </tr>
        <tr>
          <th>{{mb_label object=$examen field="libelle"}}</th>
          <td>{{mb_field object=$examen field="libelle"}}</td>
        </tr>
        <tr>
          <th>{{mb_label object=$examen field="type"}}</th>
          <td>{{mb_field object=$examen field="type"}}</td>
        </tr>
        <tr>
          <th>{{mb_label object=$examen field="unite"}}</th>
          <td>{{mb_field object=$examen field="unite"}}</td>
        </tr>
        <tr>
          <th>{{mb_label object=$examen field="min"}}</th>
          <td>{{mb_field object=$examen field="min"}}</td>
        </tr>
        <tr>
          <th>{{mb_label object=$examen field="max"}}</th>
          <td>{{mb_field object=$examen field="max"}}</td>
        </tr>
        <tr>
          <td class="button" colspan="2">
            <button class="submit" type="submit">Valider</button>
            {{if $examen->_id}}
              <button class="trash" type="button" onclick="confirmDeletion(this.form,{typeName:'l'examen',objName:'{{$examen->_view|smarty:nodefaults|JSAttribute}}'})">Supprimer</button>
            {{/if}}
          </td>
        </tr>
      </table>
      </form>
      {{/if}}
    </td>
  </tr>
</table>