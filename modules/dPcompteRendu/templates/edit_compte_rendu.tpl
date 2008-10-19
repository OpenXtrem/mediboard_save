<script type="text/javascript">

/**
 * @TODO Nettoyer ces deux fonctions qui semblent ne pas �tre appel�es
 * @TODO V�rifier �galement les http_req qui ne sont pas appel�es non plus
 */

function submitCR() {
  return true;
}

function refreshCR() {
  oForm = document.editFrm;
  var listUrl = new Url;
  listUrl.setModuleAction("dPcompteRendu", "httpreq_liste_choix_cr");
  listUrl.addParam("compte_rendu_id", oForm.compte_rendu_id.value);
  listUrl.requestUpdate('liste');

  var sourceUrl = new Url;
  sourceUrl.setModuleAction("dPcompteRendu", "httpreq_source_cr");
  sourceUrl.addParam("compte_rendu_id", oForm.compte_rendu_id.value);
  sourceUrl.requestUpdate('htmlarea');
}

{{if $compte_rendu->_id}}
window.opener.Document.refreshList(
  '{{$compte_rendu->object_class}}',
	'{{$compte_rendu->object_id}}'	
);
{{/if}}

</script>

<form name="editFrm" action="?m={{$m}}" method="post" onsubmit="return checkForm(this);">

<input type="hidden" name="m" value="dPcompteRendu" />
<input type="hidden" name="del" value="0" />
<input type="hidden" name="dosql" value="do_modele_aed" />
<input type="hidden" name="function_id" value="" />
<input type="hidden" name="chir_id" value="" />
{{mb_field object=$compte_rendu field="compte_rendu_id" hidden=1 prop=""}}
{{mb_field object=$compte_rendu field="object_id" hidden=1 prop=""}}
{{mb_field object=$compte_rendu field="object_class" hidden=1 prop=""}}

<table class="form">
  <tr>
    <th class="category">
      <strong>Nom du document :</strong>
      <input name="nom" size="50" value="{{$compte_rendu->nom}}" />
      &mdash;
      <strong>Cat�gorie :</strong>
      <select name="file_category_id">
      <option value=""{{if !$compte_rendu->file_category_id}} selected="selected"{{/if}}>&mdash; Aucune Cat�gorie</option>
      {{foreach from=$listCategory item=currCat}}
      <option value="{{$currCat->file_category_id}}"{{if $currCat->file_category_id==$compte_rendu->file_category_id}} selected="selected"{{/if}}>{{$currCat->nom}}</option>
      {{/foreach}}
      </select>
    </th>
  </tr>
  {{if $destinataires|@count}}
  <tr>
    <td class="destinataireCR text" id="destinataire">
      {{foreach from=$destinataires key=curr_class_name item=curr_class}}
        &bull; <strong>{{tr}}{{$curr_class_name}}{{/tr}}</strong> :
        {{foreach from=$curr_class key=curr_index item=curr_dest}}
          <input type="checkbox" name="_dest_{{$curr_class_name}}_{{$curr_index}}" />
          <label for="_dest_{{$curr_class_name}}_{{$curr_index}}">
            {{$curr_dest->nom}} ({{tr}}CDestinataire.tag.{{$curr_dest->tag}}{{/tr}});
          </label>
        {{/foreach}}
        <br />
      {{/foreach}}
    </td>
  </tr>
  {{/if}}
  <tr>
    <td class="listeChoixCR" id="liste">
      {{if $lists|@count}}
      <ul>
        {{foreach from=$lists item=curr_list}}
        <li>
          <select name="_liste{{$curr_list->liste_choix_id}}" style="max-width: 150px;">
            <option value="undef">&mdash; {{$curr_list->nom}}</option>
            {{foreach from=$curr_list->_valeurs item=curr_valeur}}
            <option value="{{$curr_valeur}}">{{$curr_valeur|truncate}}</option>
            {{/foreach}}
          </select>
        </li>
        {{/foreach}}
        <li>
          <button class="tick notext" type="submit">{{tr}}Save{{/tr}}</button>
        </li>
      </ul>
      {{/if}}
    </td>
  </tr>
  <tr>
    <td style="height: 600px">
      <textarea id="htmlarea" name="source">
        {{$templateManager->document}}
      </textarea>
    </td>
  </tr>

</table>

</form>