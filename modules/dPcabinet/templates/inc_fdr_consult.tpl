<script type="text/javascript">
function cancelTarif() {
  var oForm = document.tarifFrm;
  oForm.secteur1.value = 0;
  oForm.secteur2.value = 0;
  oForm.tarif.value = "";
  oForm.paye.value = "0";
  oForm.date_paiement.value = "";
  submitFdr(oForm);
}

function popFile(objectClass, objectId, elementClass, elementId){
  var url = new Url;
  url.ViewFilePopup(objectClass, objectId, elementClass, elementId, 0);
}

function modifTarif() {
  var oForm = document.tarifFrm;
  var secteurs = oForm.choix.value;
  if(secteurs != '') {
    var pos = secteurs.indexOf("/");
    var size = secteurs.length;
    var secteur1 = eval(secteurs.substring(0, pos));
    var secteur2 = eval(secteurs.substring(pos+1, size));
    oForm.secteur1.value = secteur1;
    oForm.secteur2.value = secteur2;
    oForm._somme.value = secteur1 + secteur2;
    for (i = 0;i < oForm.choix.length;++i)
    if(oForm.choix.options[i].selected == true)
     oForm.tarif.value = oForm.choix.options[i].text;
   } else {
     oForm.secteur1.value = 0;
     oForm.secteur2.value = 0;
     oForm._somme.value = '';
     oForm.tarif.value = '';
   }  
}

function effectuerReglement() {
  var oForm = document.tarifFrm;
  oForm.paye.value = "1";
  oForm.date_paiement.value = makeDATEFromDate(new Date());
  submitFdr(oForm);
}

function putTiers() {
  var form = document.tarifFrm;
  form.type_tarif.value = form._tiers.checked ? "tiers" : "";
}

function editDocument(compte_rendu_id) {
  var url = new Url;
  url.setModuleAction("dPcompteRendu", "edit_compte_rendu");
  url.addParam("compte_rendu_id", compte_rendu_id);
  url.popup(700, 700, "Document");
}

function createDocument(oSelect, consultation_id) {
  if (modele_id = oSelect.value) {
    var url = new Url;
    url.setModuleAction("dPcompteRendu", "edit_compte_rendu");
    url.addParam("modele_id", modele_id);
    url.addParam("object_id", consultation_id);
    url.popup(700, 700, "Document");
  }
  
  oSelect.value = "";
}

function newExam(oSelect, consultation_id) {
  if (sAction = oSelect.value) {
    var url = new Url;
    url.setModuleAction("dPcabinet", sAction);
    url.addParam("consultation_id", consultation_id);
    url.popup(900, 600, "Examen"); 
  }

  oSelect.value = ""; 
}

function reloadFdr() {
  var url = new Url;
  url.setModuleAction("dPcabinet", "httpreq_vw_fdr_consult");
  {{if $noReglement}}
  url.addParam("noReglement", "1"); 
  {{/if}}
  url.addParam("selConsult", document.editFrmFinish.consultation_id.value);
  url.requestUpdate('fdrConsultContent', { waitingText : null });
}

function reloadAfterSaveDoc(){
  reloadFdr();
}

function reloadAfterUploadFile(){
  reloadFdr();
}

function confirmFileDeletion(oButton) {
  oOptions = {
    typeName: 'le fichier',
    objName: oButton.form._view.value,
    ajax: 1,
    target: 'systemMsg'
  };
  
  oAjaxOptions = {
    onComplete: reloadFdr
  }
  
  confirmDeletion(oButton.form, oOptions, oAjaxOptions);
}

function submitFdr(oForm) {
  submitFormAjax(oForm, 'systemMsg', { onComplete : reloadFdr });
}
</script>


<table class="form">
  <tr>
    <th class="category">Fichiers li�s</th>
    <th class="category">Documents</th>
    {{if !$noReglement}}
    <th colspan="2" class="category">R�glement</th>
    {{/if}}
  </tr>
  <tr>

    <!-- Files -->

    <td class="text">
      <form name="newExamen" action="?m=dPcabinet">
        <label for="type_examen" title="Type d'examen compl�mentaire � effectuer"><strong>Examens compl�mentaires</strong></label>
        <select name="type_examen" onchange="newExam(this, {{$consult->consultation_id}})">
          <option value="">&mdash; Choisir un type d'examen</option>
          <option value="exam_audio">Audiogramme</option>
          <option value="exam_possum">Score Possum</option>
          <option value="exam_nyha">Classification NYHA</option>
        </select>
      </form>
      <strong>Fichiers</strong>
      <ul>
        {{foreach from=$consult->_ref_files item=curr_file}}
        <li>
          <form name="delFrm{{$curr_file->file_id}}" action="?m=dPcabinet" enctype="multipart/form-data" method="post" onsubmit="return checkForm(this)">
            <a href="#" onclick="popFile('{{$consult->_class_name}}','{{$consult->_id}}','{{$curr_file->_class_name}}','{{$curr_file->_id}}');">{{$curr_file->file_name}}</a>
            ({{$curr_file->_file_size}})
            <input type="hidden" name="m" value="dPfiles" />
            <input type="hidden" name="dosql" value="do_file_aed" />
            <input type="hidden" name="del" value="1" />
            <input type="hidden" name="file_id" value="{{$curr_file->file_id}}" />
            <input type="hidden" name="_view" value="{{$curr_file->_view}}" />
            <button class="trash notext" type="button" onclick="confirmFileDeletion(this)"></button>
          </form>
        </li>
        {{foreachelse}}
          <li>Aucun fichier disponible</li>
        {{/foreach}}
      </ul>     
      <button class="new" type="button" onclick="uploadFile('CConsultation', {{$consult->consultation_id}}, '')">
        Ajouter un fichier
      </button>
    </td>

	<!-- Documents -->

    <td>
    
    <table class="form">
      {{foreach from=$consult->_ref_documents item=document}}
      <tr>
        <th>{{$document->nom}}</th>
        <td class="button">
          <form name="editDocumentFrm{{$document->compte_rendu_id}}" action="?m={{$m}}" method="post">
          <input type="hidden" name="m" value="dPcompteRendu" />
          <input type="hidden" name="del" value="0" />
          <input type="hidden" name="dosql" value="do_modele_aed" />
          {{if $consult->_ref_consult_anesth->consultation_anesth_id}}
          <input type="hidden" name="object_id" value="{{$consult->_ref_consult_anesth->consultation_anesth_id}}" />
          {{else}}
          <input type="hidden" name="object_id" value="{{$consult->consultation_id}}" />
          {{/if}}          
          <input type="hidden" name="compte_rendu_id" value="{{$document->compte_rendu_id}}" />
          <button class="edit notext" type="button" onclick="editDocument({{$document->compte_rendu_id}})"></button>
          <button class="trash notext" type="button" onclick="confirmDeletion(this.form, {typeName:'le document',objName:'{{$document->nom|smarty:nodefaults|JSAttribute}}',ajax:1,target:'systemMsg'},{onComplete:reloadFdr})" />
          </form>
        </td>
      </tr>
      {{/foreach}}
    </table>
    
    <form name="newDocumentFrm" action="?m={{$m}}" method="post">
    <table class="form">
      <tr>
        <td>
          {{if $consult->_ref_consult_anesth->consultation_anesth_id}}
          <select name="_choix_modele" onchange="createDocument(this, {{$consult->_ref_consult_anesth->consultation_anesth_id}})">
          {{else}}
          <select name="_choix_modele" onchange="createDocument(this, {{$consult->consultation_id}})">
          {{/if}}           
            <option value="">&mdash; Choisir un mod�le</option>
            {{if $listModelePrat|@count}}
            <optgroup label="Mod�les du praticien">
              {{foreach from=$listModelePrat item=curr_modele}}
              <option value="{{$curr_modele->compte_rendu_id}}">{{$curr_modele->nom}}</option>
              {{/foreach}}
            </optgroup>
            {{/if}}
            {{if $listModeleFunc|@count}}
            <optgroup label="Mod�les du cabinet">
              {{foreach from=$listModeleFunc item=curr_modele}}
              <option value="{{$curr_modele->compte_rendu_id}}">{{$curr_modele->nom}}</option>
              {{/foreach}}
            </optgroup>
            {{/if}}
          </select>
        </td>
      </tr>
    </table>
    </form>
    
    </td>
    {{if !$noReglement}}
    <!-- R�glements -->	
    
    <td>
      <form name="tarifFrm" action="?m={{$m}}" method="post" onsubmit="return checkForm(this)">

      <input type="hidden" name="m" value="{{$m}}" />
      <input type="hidden" name="del" value="0" />
      <input type="hidden" name="dosql" value="do_consultation_aed" />
      <input type="hidden" name="consultation_id" value="{{$consult->consultation_id}}" />
      <input type="hidden" name="_check_premiere" value="{{$consult->_check_premiere}}" />
 
      <table class="form">
        {{if !$consult->tarif}}
        <tr>
          <th><label for="choix" title="Type de tarif pour la consultation. Obligatoire.">Choix du tarif</label></th>
          <td>
            <select name="choix"  title="notNull str" onchange="modifTarif()">
              <option value="" selected="selected">&mdash; Choix du tarif</option>
              {{if $tarifsChir|@count}}
              <optgroup label="Tarifs praticien">
              {{foreach from=$tarifsChir item=curr_tarif}}
                <option value="{{$curr_tarif->secteur1}}/{{$curr_tarif->secteur2}}">{{$curr_tarif->description}}</option>
              {{/foreach}}
              </optgroup>
              {{/if}}
              {{if $tarifsCab|@count}}
              <optgroup label="Tarifs cabinet">
              {{foreach from=$tarifsCab item=curr_tarif}}
                <option value="{{$curr_tarif->secteur1}}/{{$curr_tarif->secteur2}}">{{$curr_tarif->description}}</option>
              {{/foreach}}
              </optgroup>
              {{/if}}
            </select>
          </td>
        </tr>
        {{/if}}
        
        {{if $consult->paye == "0"}}
        <tr>
          <th><label for="_somme" title="Somme � r�gler. Obligatoire.">Somme � r�gler</label></th>
          <td>
            <input type="text" size="4" name="_somme" title="notNull currency" value="{{$consult->secteur1+$consult->secteur2}}" /> �
            <input type="hidden" name="secteur1" value="{{$consult->secteur1}}" />
            <input type="hidden" name="secteur2" value="{{$consult->secteur2}}" />
            <input type="hidden" name="tarif" value="{{if $consult->tarif != null}}{{$consult->tarif}}{{/if}}" />
            <input type="hidden" name="paye" value="0" />
            <input type="hidden" name="date_paiement" value="" />
          </td>
        </tr>
        {{else}}
        <tr>
          <td colspan="2" class="button">
            <input type="hidden" name="secteur1" value="{{$consult->secteur1}}" />
            <input type="hidden" name="secteur2" value="{{$consult->secteur2}}" />
            <input type="hidden" name="tarif" value="{{$consult->tarif}}" />
            <input type="hidden" name="paye" value="{{$consult->paye}}" />
            <input type="hidden" name="date_paiement" value="{{$consult->date_paiement}}" />
            <strong>{{$consult->secteur1+$consult->secteur2}} � ont �t� r�gl�s : {{$consult->type_tarif}}</strong>
          </td>
        </tr>
        <tr>
          <td colspan="2" class="button">
            <button class="cancel" type="button" onclick="cancelTarif()">Annuler</button>
          </td>
        </tr>
        {{/if}}
        
        {{if $consult->tarif && $consult->paye == "0"}}
        <tr>
          <th>
            <label for="type_tarif" title="Moyen de paiement">Moyen de paiement</label>
          </th>
          <td>
            <select name="type_tarif">
              <option value="cheque"  {{if $consult->type_tarif == "cheque" }}selected="selected"{{/if}}>Ch�ques     </option>
              <option value="CB"      {{if $consult->type_tarif == "CB"     }}selected="selected"{{/if}}>CB          </option>
              <option value="especes" {{if $consult->type_tarif == "especes"}}selected="selected"{{/if}}>Esp�ces     </option>
              <option value="tiers"   {{if $consult->type_tarif == "tiers"  }}selected="selected"{{/if}}>Tiers-payant</option>
              <option value="autre"   {{if $consult->type_tarif == "autre"  }}selected="selected"{{/if}}>Autre       </option>
            </select>
          </td>
        </tr>
        <tr>
          <td colspan="2" class="button">
            <button class="submit" type="button" onclick="effectuerReglement()">R�glement effectu�</button>
            <button class="cancel" type="button" onclick="cancelTarif()">Annuler</button>
          </td>
        </tr>
        {{elseif $consult->paye == "0"}}
        <tr>
          <th><label for="_tiers" title="Le r�glement s'effectue par tiers-payant">Tiers-payant ?</label></th>
          <td>
            <input type="checkbox" name="_tiers" onchange="putTiers()" />
            <input type="hidden" name="type_tarif" value="" />
          </td>
        </tr>
        <tr>
          <td colspan="2" class="button">
            <button class="submit" type="button" onclick="submitFdr(this.form)">Valider ce tarif</button>
            <button class="cancel" type="button" onclick="cancelTarif()">Annuler</button>
          </td>
        </tr>
        {{/if}}
      </table>
      
      </form>
    </td>
    {{/if}}
        

  </tr>
</table>
          
