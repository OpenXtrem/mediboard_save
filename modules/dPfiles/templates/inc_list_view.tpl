{{if $accordDossier}}
<div class="accordionMain" id="accordion{{$selClass}}{{$selKey}}">
{{else}}
<div class="accordionMain" id="accordionConsult">
{{/if}}
{{foreach from=$affichageFile item=curr_listCat key=keyCat}}
  <div id="Acc{{$keyCat}}">
    <div id="Acc{{$keyCat}}Header" class="accordionTabTitleBar">
      {{$curr_listCat.name}} ({{$curr_listCat.DocsAndFiles|@count}})
    </div>
    <div id="Acc{{$keyCat}}Content" class="accordionTabContentBox">
      <table class="tbl">
        {{if $canEditFiles && !$accordDossier}}
        <tr>
          <td colspan="2" class="text">
            <button class="new" onclick="uploadFile('{{$selClass}}', '{{$selKey}}', '{{$keyCat}}')">
              Ajouter un fichier
            </button>
          </td>
        </tr>
        {{/if}}
        {{foreach from=$curr_listCat.DocsAndFiles item=curr_file}}
        <tr>
          <td class="{{cycle name=cellicon values="dark, light"}}">
            {{if $curr_file->_class_name=="CCompteRendu"}}
              {{assign var="elementId" value=$curr_file->compte_rendu_id}}
              {{assign var="srcImg" value="modules/dPfiles/images/medifile.png"}}
            {{else}}
              {{assign var="elementId" value=$curr_file->file_id}}
              {{assign var="srcImg" value="index.php?m=dPfiles&a=fileviewer&suppressHeaders=1&file_id=$elementId&phpThumb=1&wl=64&hp=64"}}
            {{/if}}
            
            <a href="#" onclick="ZoomAjax('{{$selClass}}', '{{$selKey}}', '{{$curr_file->_class_name}}', '{{$elementId}}', '0');" title="Afficher l'aper�u">
              <img src="{{$srcImg}}" alt="-" />
            </a>
   
          </td>
          <td class="text {{cycle name=celltxt values="dark, light"}}" style="vertical-align: middle;">
            <strong>{{$curr_file->_view}}</strong>
            {{if $curr_file->_class_name=="CFile"}}
              <br />Date : {{$curr_file->file_date|date_format:"%d/%m/%Y � %Hh%M"}}
            {{/if}}
            <hr />

            {{if $curr_file->_class_name=="CCompteRendu" && $canEditDoc && !$accordDossier}}
              <form name="editDoc{{$curr_file->compte_rendu_id}}" action="?m={{$m}}" method="post" onsubmit="return checkForm(this)">
              <input type="hidden" name="m" value="dPcompteRendu" />
              <input type="hidden" name="dosql" value="do_modele_aed" />
              <input type="hidden" name="compte_rendu_id" value="{{$curr_file->compte_rendu_id}}" />
              <input type="hidden" name="del" value="0" />
              {{assign var="confirmDeleteType" value="le document"}}
              {{assign var="confirmDeleteName" value=$curr_file->nom}}
              
            {{elseif $curr_file->_class_name=="CFile" && $canEditFiles && !$accordDossier}}
              <form name="editFile{{$curr_file->file_id}}" action="?m={{$m}}" method="post" onsubmit="return checkForm(this)">
              <input type="hidden" name="m" value="dPfiles" />
              <input type="hidden" name="dosql" value="do_file_aed" />
              <input type="hidden" name="file_id" value="{{$curr_file->file_id}}" />
              <input type="hidden" name="del" value="0" />
              {{assign var="confirmDeleteType" value="le fichier"}}
              {{assign var="confirmDeleteName" value=$curr_file->file_name}}
              
            {{/if}}
            
            {{if $canEditFileDoc && !$accordDossier}}
              <select name="file_category_id" onchange="submitFileChangt(this.form)">
                <option value="0" {{if $curr_file->file_category_id == 0}}selected="selected"{{/if}}>&mdash; Aucune</option>
                {{foreach from=$listCategory item=curr_cat}}
                <option value="{{$curr_cat->file_category_id}}" {{if $curr_cat->file_category_id == $curr_file->file_category_id}}selected="selected"{{/if}} >
                  {{$curr_cat->nom}}
                </option>
                {{/foreach}}
              </select>
              <button type="button" class="trash" onclick="file_deleted={{$elementId}};confirmDeletion(this.form, {typeName:'{{$confirmDeleteType}}',objName:'{{$confirmDeleteName|smarty:nodefaults|JSAttribute}}',ajax:1,target:'systemMsg'},{onComplete:reloadListFile})">
                Supprimer
              </button>
            </form>
            {{/if}}
          </td>
        </tr>
      {{foreachelse}}
      <tr>
        <td colspan="2" class="button">
          Pas de documents            
        </td>
      </tr>
      {{/foreach}}
      </table>
    </div>
  </div>
{{/foreach}}     
</div>
<script language="Javascript" type="text/javascript">
{{if $accordDossier}}
var oAccord{{$selClass}}{{$selKey}} = new Rico.Accordion( $('accordion{{$selClass}}{{$selKey}}'), {
  panelHeight: 200, 
  showDelay:50,
  showSteps:3
});
{{else}}
var oAccord = new Rico.Accordion( $('accordionConsult'), {
  panelHeight: fHeight, 
  onShowTab: storeKeyCat,
  showDelay:50,
  showSteps:3,
  onLoadShowTab: showTabAcc
});
{{/if}}
</script>