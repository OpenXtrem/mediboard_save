<!-- $Id$ -->

<script type="text/javascript">
function view_history_patient(id){
  url = new Url();
  url.setModuleAction("dPpatients", "vw_history");
  url.addParam("patient_id", id);
  url.popup(600, 500, "history");
}

function viewPatient() {
  var oForm = document.actionPat;
  var oTabField = oForm.tab;
  oTabField.value = "vw_full_patients";
  oForm.submit();
}

function editPatient() {
  var oForm = document.actionPat;
  var oTabField = oForm.tab;
  oTabField.value = "vw_edit_patients";
  oForm.submit();
}

function printPatient(id) {
  var url = new Url;
  url.setModuleAction("dPpatients", "print_patient");
  url.addParam("patient_id", id);
  url.popup(700, 550, "Patient");
}

function popFile(file_id){
  var url = new Url;
  url.ViewFilePopup(file_id,0);
}

function editDocument(compte_rendu_id) {
  var url = new Url;
  url.setModuleAction("dPcompteRendu", "edit_compte_rendu");
  url.addParam("compte_rendu_id", compte_rendu_id);
  url.popup(700, 700, "Document");
}

function createDocument(oSelect, patient_id) {
  if (modele_id = oSelect.value) {
    var url = new Url;
    url.setModuleAction("dPcompteRendu", "edit_compte_rendu");
    url.addParam("modele_id", modele_id);
    url.addParam("object_id", patient_id);
    url.popup(700, 700, "Document");
  }
  oSelect.value = "";
}

function printIntervention(id) {
  var url = new Url;
  url.setModuleAction("dPplanningOp", "view_planning");
  url.addParam("operation_id", id);
  url.popup(700, 550, "Admission");
}

function reloadVwPatient(){
  var mainUrl = new Url;
  mainUrl.setModuleAction("dPpatients", "httpreq_vw_patient");
  mainUrl.addParam("patient_id", document.actionPat.patient_id.value);
  mainUrl.requestUpdate('vwPatient', { waitingText : null });
}

function reloadAfterSaveDoc(){
  reloadVwPatient();
}
</script>

<table class="form">
  <tr>
    <th class="category" colspan="2">
      <a style="float:right;" href="javascript:view_history_patient({{$patient->patient_id}})">
        <img src="images/history.gif" alt="historique" />
      </a>
      Identit�
    </th>
    <th class="category" colspan="2">Coordonn�es</th>
  </tr>

  <tr>
    <th>Nom</th>
    <td>{{$patient->nom}}</td>
    <th>Adresse</th>
    <td class="text">{{$patient->adresse|nl2br}}</td>
  </tr>
  
  <tr>
    <th>Pr�nom</th>
    <td>{{$patient->prenom}}</td>
    <th>Code Postal</th>
    <td>{{$patient->cp}}</td>
  </tr>
  
  <tr>
    <th>Nom de naissance</th>
    <td>{{$patient->nom_jeune_fille}}</td>
    <th>Ville</th>
    <td>{{$patient->ville}}</td>
  </tr>
  
  <tr>
    <th>Date de naissance</th>
    <td>{{$patient->_naissance}}</td>
    <th>T�l�phone</th>
    <td>{{$patient->_tel1}} {{$patient->_tel2}} {{$patient->_tel3}} {{$patient->_tel4}} {{$patient->_tel5}}</td>
  </tr>
  
  <tr>
    <th>Sexe</th>
    <td>
      {{tr}}CPatient.sexe.{{$patient->sexe}}{{/tr}}
    </td>
    <th>Portable</th>
    <td>{{$patient->_tel21}} {{$patient->_tel22}} {{$patient->_tel23}} {{$patient->_tel24}} {{$patient->_tel25}}</td>
  </tr>
  
  {{if $patient->rques}}
  <tr>
    <th class="category" colspan="4">Remarques</th>
  </tr>
  
  <tr>
    <td colspan="4" class="text">{{$patient->rques|nl2br}}</td>
  </tr>
  {{/if}}
  
  <tr>
    <td class="button" colspan="4">
      <form name="actionPat" action="./index.php" method="get">
      <input type="hidden" name="m" value="dPpatients" />
      <input type="hidden" name="tab" value="vw_idx_patients" />
      <input type="hidden" name="patient_id" value="{{$patient->patient_id}}" />
      <button type="button" class="search" onclick="viewPatient()">
        Afficher
      </button>
      <button type="button" class="print" onclick="printPatient({{$patient->patient_id}})">
        Imprimer
      </button>
      {{if $canEdit}}
      <button type="button" class="modify" onclick="editPatient()">
        Modifier
      </button>
      {{/if}}
      </form>
    </td>
  </tr>
</table>

<table class="form">
  <tr>
    <th class="category" colspan="3">Planifier</th>
  </tr>
  <tr>
    <td class="button">
      <a class="buttonnew" href="index.php?m=dPplanningOp&amp;tab=vw_edit_planning&amp;pat_id={{$patient->patient_id}}&amp;operation_id=0&amp;sejour_id=0">
        Une intervention
      </a>
    </td>
    <td class="button">
      <a class="buttonnew" href="index.php?m=dPplanningOp&amp;tab=vw_edit_sejour&amp;patient_id={{$patient->patient_id}}&amp;sejour_id=0">
        Un s�jour
      </a>
    </td>
    <td class="button">
      <a class="buttonnew" href="index.php?m=dPcabinet&amp;tab=edit_planning&amp;pat_id={{$patient->patient_id}}&amp;consultation_id=0">
        Une consultation
      </a>
    </td>
  </tr>
  {{if $listPrat|@count && $canEditCabinet}}
  <tr><th class="category" colspan="3">Consultation imm�diate</th></tr>
  <tr>
    <td class="button" colspan="3">
      <form name="addConsFrm" action="index.php?m=dPcabinet" method="post" onsubmit="return checkForm(this)">
      <input type="hidden" name="m" value="dPcabinet" />
      <input type="hidden" name="dosql" value="do_consult_now" />
      <input type="hidden" name="del" value="0" />
      <input type="hidden" name="patient_id" title="notNull|ref" value="{{$patient->patient_id}}" />
      <label for="prat_id" title="Praticien pour la consultation imm�diate. Obligatoire">Praticien</label>
      <select name="prat_id" title="notNull|ref">
        <option value="">&mdash; Choisir un praticien</option>
        {{foreach from=$listPrat item=curr_prat}}
          <option value="{{$curr_prat->user_id}}" {{if $curr_prat->user_id == $app->user_id}} selected="selected" {{/if}}>
            {{$curr_prat->_view}}
          </option>
        {{/foreach}}
      </select>
      <button class="new" type="submit">Consulter</button>
      </form>
    </td>
  </tr>
  {{/if}}
</table>

<table class="form">
  {{assign var="affectation" value=$patient->_ref_curr_affectation}}
  {{if $affectation->affectation_id}}
  <tr>
  	<th colspan="3" class="category">Chambre actuelle</th>
  </tr>
  <tr>
    <td colspan="3">
      {{$affectation->_ref_lit->_view}}
      depuis {{$affectation->entree|date_format:"%d %b %Y � %H:%M"}}
    </td>
  </tr>
  {{assign var="affectation" value=$patient->_ref_next_affectation}}
  {{elseif $affectation->affectation_id}}
  <tr>
    <th colspan="3" class="category">Prochaine chambre</th>
  </tr>
  <tr>
    <td colspan="3">
      {{$affectation->_ref_lit->_view}}
      depuis {{$affectation->entree|date_format:"%d %b %Y � %H:%M"}}
    </td>
  </tr>
  {{/if}}

  {{if $patient->_ref_sejours}}
  <tr>
    <th colspan="2" class="category">S�jours</th>
  </tr>
  {{foreach from=$patient->_ref_sejours item=curr_sejour}}
  <tr>
    <td>
      <a class="actionPat" title="Modifier le s�jour" href="index.php?m=dPplanningOp&amp;tab=vw_edit_sejour&amp;sejour_id={{$curr_sejour->sejour_id}}">
        <img src="modules/dPpatients/images/planning.png" alt="Planifier"/>
      </a>
      <a class="actionPat" href="index.php?m=dPadmissions&amp;tab=vw_idx_admission&amp;date={{$curr_sejour->entree_prevue|date_format:"%Y-%m-%d"}}#adm{{$curr_sejour->sejour_id}}">
        S�jour du {{$curr_sejour->entree_prevue|date_format:"%d %b %Y"}} 
        au {{$curr_sejour->sortie_prevue|date_format:"%d %b %Y"}}
      </a>
	</td>
    {{if $curr_sejour->annule}}
 	<td style="background: #f00">
      <strong>[SEJOUR ANNULE]</strong>
	</td>
    {{else}}
 	<td>
      <a href="index.php?m=dPadmissions&amp;tab=vw_idx_admission&amp;date={{$curr_sejour->entree_prevue|date_format:"%Y-%m-%d"}}#adm{{$curr_sejour->sejour_id}}">
        Dr. {{$curr_sejour->_ref_praticien->_view}}
      </a>
	</td>
    {{/if}}
  </tr>
  {{foreach from=$curr_sejour->_ref_operations item=curr_op}}
  <tr>
    <td>
      <a class="actionPat" href="javascript:printIntervention({{$curr_op->operation_id}})">
        <img src="modules/dPpatients/images/print.png" alt="Imprimer" title="Imprimer l'op�ration"/>
      </a>
      <a class="actionPat" href="index.php?m=dPplanningOp&amp;tab=vw_edit_planning&amp;operation_id={{$curr_op->operation_id}}">
        <img src="modules/dPpatients/images/planning.png" alt="modifier" title="modifier" />
      </a>
      <a class="actionPat" href="index.php?m=dPplanningOp&amp;tab=vw_edit_planning&amp;operation_id={{$curr_op->operation_id}}">
        Intervention le {{$curr_op->_datetime|date_format:"%d %b %Y"}}
      </a>
    </td>
    {{if $curr_op->annulee}}
 	<td style="background: #f00">
      <strong>[OPERATION ANNULEE]</strong>
	</td>
    {{else}}
    <td>
      <a href="index.php?m=dPplanningOp&amp;tab=vw_edit_planning&amp;operation_id={{$curr_op->operation_id}}">
        Dr. {{$curr_op->_ref_chir->_view}}
      </a>
    </td>
    {{/if}}
  </tr>
  {{/foreach}}
  {{/foreach}}
  {{/if}}
  
  {{if $patient->_ref_consultations}}
  <tr><th class="category" colspan="2">Consultations</th></tr>
  {{foreach from=$patient->_ref_consultations item=curr_consult}}
  <tr>
    <td>
      {{if $curr_consult->annule}}
      [ANNULE]
      {{else}}
      <a class="actionPat" href="index.php?m=dPcabinet&amp;tab=edit_planning&amp;consultation_id={{$curr_consult->consultation_id}}">
        <img src="modules/dPpatients/images/planning.png" alt="modifier" title="modifier" />
      </a>
      {{/if}}
      <a class="actionPat" href="index.php?m=dPcabinet&amp;tab=edit_consultation&amp;selConsult={{$curr_consult->consultation_id}}">
        Le {{$curr_consult->_ref_plageconsult->date|date_format:"%d %b %Y"}} - {{$curr_consult->_etat}}
      </a>
    </td>
    <td>
      <a href="index.php?m=dPcabinet&amp;tab=edit_consultation&amp;selConsult={{$curr_consult->consultation_id}}">
        Dr. {{$curr_consult->_ref_plageconsult->_ref_chir->_view}}
      </a>
    </td>
  </tr>
  {{/foreach}}
  {{/if}}
  
  {{if $canReadFiles && 0}}
  <tr>
    <th class="category" colspan="2">Fichiers</th>
  </tr>
  <tr>
    <td colspan="2">
      {{if $patient->_ref_files}}
      <table class="form">
        {{foreach from=$affichageNbFile item=curr_nbfile key=keyCat}}
        <tr>
          <td>{{$curr_nbfile.name}}</td>
          <td>{{$curr_nbfile.nb}}</td>
          <td>
            {{if $curr_nbfile.nb>=1}}
            <a class="buttonsearch" href="index.php?m=dPfiles&amp;selClass=CPatient&amp;selKey={{$patient->patient_id}}&amp;cat_id={{$keyCat}}">
            Voir ces fichiers
            </a>
            {{/if}}
		  </td>            
        </tr>
        {{/foreach}}
      </table>
      {{/if}}
      {{if $canEditFiles}}
      <form name="uploadFrm" action="?m={{$m}}" enctype="multipart/form-data" method="post" onsubmit="return checkForm(this)">
        <input type="hidden" name="m" value="dPfiles" />
        <input type="hidden" name="dosql" value="do_file_aed" />
        <input type="hidden" name="del" value="0" />
        <input type="hidden" name="file_class" value="CPatient" />
        <input type="hidden" name="file_object_id" value="{{$patient->patient_id}}" />
        <input type="file" name="formfile" size="0" /><br />
        Dans  <select name="file_category_id">
        {{foreach from=$affichageNbFile item=curr_listCat key=keyCat}}
        <option value="{{$keyCat}}">{{$curr_listCat.name}}</option>
        {{/foreach}}
        </select>
        <button class="submit" type="submit">Ajouter</button>
      </form>
      {{/if}}
    </td>
  </tr>
  {{/if}}
  
  {{if $canReadCptRendus && 0}}
  <tr>
    <th class="category" colspan="2">Documents</th>
  </tr>
  <tr>
    <td colspan="2">
      <table class="form">
        {{foreach from=$patient->_ref_documents item=document}}
        <tr>
          <th>{{$document->nom}}</th>
          <td class="button">
            <form name="editDocumentFrm{{$document->compte_rendu_id}}" action="?m={{$m}}" method="post">
            <input type="hidden" name="m" value="dPcompteRendu" />
            <input type="hidden" name="del" value="0" />
            <input type="hidden" name="dosql" value="do_modele_aed" />
            <input type="hidden" name="object_id" value="{{$patient->patient_id}}" />
            <input type="hidden" name="compte_rendu_id" value="{{$document->compte_rendu_id}}" />
            <button class="edit notext" type="button" onclick="editDocument({{$document->compte_rendu_id}})"></button>
            <button class="trash notext" type="button" onclick="confirmDeletion(this.form, {typeName:'le document',objName:'{{$document->nom|smarty:nodefaults|JSAttribute}}',ajax:1,target:'systemMsg'},{onComplete:reloadVwPatient})">
            </button>
            </form>
          </td>
        </tr>
        {{/foreach}}
      </table>
      {{if $canEditCptRendus}}
      <form name="newDocumentFrm" action="?m={{$m}}" method="post">
      <table class="form">
        <tr>
          <td>
            <select name="_choix_modele" onchange="createDocument(this, {{$patient->patient_id}})">
              <option value="">&mdash; Choisir un mod�le</option>
              {{if $listModelePrat|@count}}
              <optgroup label="Mod�les des Praticiens">
                {{foreach from=$listModelePrat item=curr_modele}}
                <option value="{{$curr_modele->compte_rendu_id}}">{{$curr_modele->nom}}</option>
                {{/foreach}}
              </optgroup>
              {{/if}}
              {{if $listModeleFct|@count}}
              <optgroup label="Mod�les des Cabinets">
                {{foreach from=$listModeleFct item=curr_modele}}
                <option value="{{$curr_modele->compte_rendu_id}}">{{$curr_modele->nom}}</option>
                {{/foreach}}
              </optgroup>
              {{/if}}
            </select>
          </td>
        </tr>
      </table>
      </form>
      {{/if}}
    </td>
  </tr>
  {{/if}}
</table>