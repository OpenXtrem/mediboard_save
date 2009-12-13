{{mb_include_script module="dPImeds" script="Imeds_results_watcher"}}
{{mb_include_script module="dPcompteRendu" script="modele_selector"}}

<script type="text/javascript">

var ViewFullPatient = {
  select: function(eLink) {
    // Unselect previous row
    if (this.idCurrent) {
      $(this.idCurrent).removeClassName("selected");
    }
		
    // Select current row
    this.idCurrent = $(eLink).up(1).identify();
		$(this.idCurrent).addClassName("selected");
  },
  
  main: function() {
    PairEffect.initGroup("patientEffect", {
      bStartAllVisible: true,
      bStoreInCookie: true
    } );
  }
}

function popEtatSejour(sejour_id) {
  var url = new Url("dPhospi", "vw_parcours");
  url.addParam("sejour_id",sejour_id);
  url.pop(1000, 550, 'Etat du S�jour');
}

{{if $isImedsInstalled}}
//Main.add(ImedsResultsWatcher.loadResults);
{{/if}}
 
</script>

<table class="form">

<tr>
  <th class="title" colspan="2">
    <a href="#" onclick="viewCompleteItem('{{$patient->_guid}}'); ViewFullPatient.select(this)">
      {{$patient->_view}} ({{$patient->_age}} ans)
    </a>
  </th>
  <th class="title">
    {{if $patient->_canRead}}
    <div style="float:right;">
      {{if $isImedsInstalled}}
      <a href="#" onclick="view_labo_patient()">
        <img align="top" src="images/icons/labo.png" title="R�sultats de laboratoire" alt="R�sultats de laboratoire"  />
      </a>
      {{/if}}
      <a href="#" 
        onclick="setObject( {
          objClass: 'CPatient', 
          keywords: '', 
          id: {{$patient->patient_id}}, 
          view: '{{$patient->_view|smarty:nodefaults|JSAttribute}}' })"
        title="{{$patient->_nb_files_docs}} doc(s)">
        {{$patient->_nb_files_docs}}
        <img align="top" src="images/icons/{{if !$patient->_nb_files_docs}}next_gray.png{{else}}next.png{{/if}}" title="{{$patient->_nb_files_docs}} doc(s)" alt="Afficher les documents"  />                
      </a>
    </div>
    {{/if}} 
  </th>
</tr>

{{if !$app->user_prefs.simpleCabinet}}
<!-- S�jours -->

<tr id="sejours-trigger">
  <th colspan="3" class="title">{{$patient->_ref_sejours|@count}} s�jour(s)</th>
</tr>

<tbody class="patientEffect" style="display: none" id="sejours">

{{foreach from=$patient->_ref_sejours item=_sejour}}
<tr id="CSejour-{{$_sejour->_id}}">
  <td>
  	<button class="lookup notext" onclick="popEtatSejour({{$_sejour->_id}});">{{tr}}Lookup{{/tr}}</button>

    <span onmouseover="ObjectTooltip.createEx(this, '{{$_sejour->_guid}}');"
          onclick="{{if @$can_view_dossier_medical}}viewDossierSejour('{{$_sejour->_id}}');{{else}}viewCompleteItem('{{$_sejour->_guid}}');{{/if}} ViewFullPatient.select(this)">
      {{$_sejour->_shortview}} 
    </span>
    <script type="text/javascript">
      ImedsResultsWatcher.addSejour('{{$_sejour->_id}}', '{{$_sejour->_num_dossier}}');
    </script>
  </td>

	{{assign var=praticien value=$_sejour->_ref_praticien}}
	{{if $_sejour->group_id == $g}}
  <td {{if $_sejour->annule}}class="cancelled"{{/if}}>
    {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$praticien}}
  </td>
  {{else}}
  <td style="background-color:#afa">
    {{$_sejour->_ref_group->text|upper}}
  </td>
  {{/if}}
  
  <td style="text-align:right;">
  {{if $_sejour->_canRead}}
    {{if $isImedsInstalled}}
    <div id="labo_for_{{$_sejour->_id}}" style="display: none; float: left;">
    <a href="#" onclick="view_labo_sejour({{$_sejour->_id}})">
      <img align="top" src="images/icons/labo.png" title="R�sultats de laboratoire" alt="R�sultats de laboratoire"  />
    </a>
    </div>
    <div id="labo_hot_for_{{$_sejour->_id}}" style="display: none; float: left;">
    <a href="#" onclick="view_labo_sejour({{$_sejour->_id}})">
      <img align="top" src="images/icons/labo_hot.png" title="R�sultats de laboratoire" alt="R�sultats de laboratoire"  />
    </a>
    </div>
    {{/if}}
    <a href="#" onclick="setObject( {
      objClass: 'CSejour', 
      keywords: '', 
      id: {{$_sejour->_id}}, 
      view:'{{$_sejour->_view|smarty:nodefaults|JSAttribute}}'} )"
      title="{{$_sejour->_nb_files_docs}} doc(s)">
      {{$_sejour->_nb_files_docs}}
      <img align="top" src="images/icons/next{{if !$_sejour->_nb_files_docs}}_gray{{/if}}.png" title="{{$_sejour->_nb_files_docs}} doc(s)" alt="Afficher les documents"  />
    </a>
    {{/if}}         
  </td>
</tr>

{{if $_sejour->_ref_rpu && $_sejour->_ref_rpu->_id}}
{{assign var=rpu value=$_sejour->_ref_rpu}}
<tr>
  <td style="padding-left: 20px;" colspan="2">
    Passage aux urgences
  </td>
  <td style="text-align:right;">
  {{if $rpu->_canRead}}
    <a href="#" onclick="setObject( {
      objClass: 'CRPU', 
      keywords: '', 
      id: {{$rpu->_id}}, 
      view:'{{$rpu->_view|smarty:nodefaults|JSAttribute}}'} )"
      title="{{$rpu->_nb_files_docs}} doc(s)">
      {{$rpu->_nb_files_docs}}
      <img align="top" src="images/icons/next{{if !$rpu->_nb_files_docs}}_gray{{/if}}.png" title="{{$rpu->_nb_files_docs}} doc(s)" alt="Afficher les documents"  />
    </a>
    {{/if}} 
  </td>
</tr>
{{/if}}

<!-- Si le sejour a un RPU et une consultation associ�e-->
{{if $_sejour->_ref_rpu && $_sejour->_ref_rpu->_id && $_sejour->_ref_rpu->_ref_consult->_id}}
{{assign var="_consult" value=$_sejour->_ref_rpu->_ref_consult}}
<tr>
  <td style="padding-left: 20px;">
    <a href="#"
      onmouseover="ObjectTooltip.createEx(this, '{{$_consult->_guid}}');"
      onclick="viewCompleteItem('{{$_consult->_guid}}'); ViewFullPatient.select(this)">
      Le {{$_consult->_datetime|date_format:$dPconfig.date}}
    </a>
  </td>
  
  {{assign var=praticien value=$_consult->_ref_chir}}
  
  {{if $_consult->annule}}
  <td class="cancelled">
  {{else}}
  <td>
  {{/if}}
    {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$praticien}}
	</td>

  <td style="text-align: right;">
 
  {{if $_sejour->_canRead}}
    <a href="#" title="{{$_consult->_nb_files_docs}} doc(s)"
      onclick="setObject( {
        objClass: 'CConsultation', 
        keywords: '', 
        id: {{$_consult->consultation_id}}, 
        view: '{{$_consult->_view|smarty:nodefaults|JSAttribute}}'} )">
      {{$_consult->_nb_files_docs}}
      <img align="top" src="images/icons/next{{if !$_consult->_nb_files_docs}}_gray{{/if}}.png" title="{{$_consult->_nb_files_docs}} doc(s)" alt="Afficher les documents"  />
    </a>
   {{/if}}
  </td>
</tr>

{{/if}}

{{foreach from=$_sejour->_ref_operations item=_op}}
<tr>
  <td style="padding-left: 20px;">
    <span onmouseover="ObjectTooltip.createEx(this, '{{$_op->_guid}}')"
          onclick="viewCompleteItem('{{$_op->_guid}}'); ViewFullPatient.select(this)">
      Interv. le {{$_op->_datetime|date_format:$dPconfig.date}}
    </span>
  </td>

  {{assign var=praticien value=$_op->_ref_chir}}
	{{if $_sejour->group_id == $g}}
  <td {{if $_op->annulee}}class="cancelled"{{/if}}>
    {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$praticien}}
  </td>
  {{else}}
  <td style="background-color:#afa">
    {{$_sejour->_ref_group->text|upper}}
  </td>
  {{/if}}

  <td style="text-align:right;">
  {{if $_op->_canRead}}
    <a href="#" onclick="setObject( {
      objClass: 'COperation', 
      keywords: '', 
      id: {{$_op->operation_id}}, 
      view:'{{$_op->_view|smarty:nodefaults|JSAttribute}}'} )"
      title="{{$_op->_nb_files_docs}} doc(s)">
      {{$_op->_nb_files_docs}}
      <img align="top" src="images/icons/next{{if !$_op->_nb_files_docs}}_gray{{/if}}.png" title="{{$_op->_nb_files_docs}} doc(s)" alt="Afficher les documents"  />
    </a>
    {{/if}} 
  </td>
</tr>

{{assign var="consult_anesth" value=$_op->_ref_consult_anesth}}
{{if $consult_anesth->_id}}
{{assign var="_consult" value=$consult_anesth->_ref_consultation}}
<tr>
  <td style="padding-left: 20px;">
    <span
      {{if $consult_anesth->_id}}style="padding-left: 20px; background: url(images/icons/anesth.png) no-repeat center left;"{{/if}} 
		  onmouseover="ObjectTooltip.createEx(this, '{{$consult_anesth->_guid}}')"
      onclick="viewCompleteItem('{{$consult_anesth->_guid}}'); ViewFullPatient.select(this)">
      Le {{$_consult->_datetime|date_format:$dPconfig.date}}
    </span>
  </td>

  {{assign var=praticien value=$_consult->_ref_chir}}
  {{assign var=praticien value=$_consult->_ref_chir}}
  {{if $_consult->annule}}
  <td class="cancelled">[Consult annul�e]</td>
  {{else}}
  <td>
    {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$praticien}}
	</td>
  {{/if}}
  
  <td style="text-align:right;">
  {{if $_consult->_canRead}}
    <a href="#" title="{{$_consult->_nb_files_docs}} doc(s)"
      onclick="setObject( {
        objClass: 'CConsultation', 
        keywords: '', 
        id: {{$_consult->consultation_id}}, 
        view: '{{$_consult->_view|smarty:nodefaults|JSAttribute}}'} )">
      {{$_consult->_nb_files_docs}}
      <img align="top" src="images/icons/next{{if !$_consult->_nb_files_docs}}_gray{{/if}}.png" title="{{$_consult->_nb_files_docs}} doc(s)" alt="Afficher les documents"  />
    </a>
    {{/if}}
  </td>
</tr>
{{/if}}
{{/foreach}}

{{foreachelse}}
<tr><td colspan="3"><em>Pas de s�jours</em></td></tr>
{{/foreach}}
</tbody>

{{/if}}  

<!-- Consultations -->

<tr id="consultations-trigger">
  <th colspan="3" class="title">{{$patient->_ref_consultations|@count}} consultation(s)</th>
</tr>

<tbody class="patientEffect" style="display: none" id="consultations">

{{foreach from=$patient->_ref_consultations item=_consult}}
<tr>
  <td>
    {{assign var=consult_anesth value=$_consult->_ref_consult_anesth}}
    {{if $consult_anesth->_id}}
      {{assign var=object value=$consult_anesth}}
    {{else}}
      {{assign var=object value=$_consult}}
    {{/if}}
    <span
		  {{if $consult_anesth->_id}}style="padding-left: 20px; background: url(images/icons/anesth.png) no-repeat center left;"{{/if}} 
		  onmouseover="ObjectTooltip.createEx(this, '{{$object->_guid}}');"
      onclick="viewCompleteItem('{{$object->_guid}}'); ViewFullPatient.select(this)">
      Le {{$_consult->_datetime|date_format:$dPconfig.date}}
    </span>
  </td>
  
  {{assign var=praticien value=$_consult->_ref_chir}}
  {{if $_consult->annule}}
  <td class="cancelled">
  {{else}}
  <td>
  {{/if}}
    {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$praticien}}
	</td>

  <td style="text-align:right;">
  {{if $_consult->_canRead}}
    <a href="#" title="{{$_consult->_nb_files_docs}} doc(s)"
      onclick="setObject( {
        objClass: 'CConsultation', 
        keywords: '', 
        id: {{$_consult->consultation_id}}, 
        view: '{{$_consult->_view|smarty:nodefaults|JSAttribute}}'} )">
      {{$_consult->_nb_files_docs}}
      <img align="top" src="images/icons/next{{if !$_consult->_nb_files_docs}}_gray{{/if}}.png" title="{{$_consult->_nb_files_docs}} doc(s)" alt="Afficher les documents"  />
    </a>
    {{/if}}
  </td>
</tr>
{{foreachelse}}
<tr><td colspan="3"><em>Pas de consultations</em></td></tr>
{{/foreach}}

</tbody>

</table>
  
<hr/>
  
<!-- Planifier -->

<table class="form">

<tr id="planifier-trigger">
  <th colspan="2" class="title">Planifier</th>
</tr>

<tbody class="patientEffect" style="display: none" id="planifier">
  <tr><th class="category" colspan="2">Ev�nements</th></tr>
  {{if $app->user_prefs.simpleCabinet}}
  <tr>
    <td class="button" colspan="2">
      <a class="button new" href="?m=dPcabinet&amp;tab=edit_planning&amp;pat_id={{$patient->patient_id}}&amp;consultation_id=0">
        Consultation
      </a>
    </td>
  </tr>
  {{else}}
  <tr>
    <td class="button">
      <a class="button new" href="?m=dPcabinet&amp;tab=edit_planning&amp;pat_id={{$patient->patient_id}}&amp;consultation_id=0">
        Consultation
      </a>
    </td>
    <td class="button">
      {{if !@$modules.ecap->mod_active}}
      <a class="button new" href="?m=dPplanningOp&amp;tab=vw_edit_planning&amp;pat_id={{$patient->patient_id}}&amp;operation_id=0&amp;sejour_id=0">
        Intervention
      </a>
      {{/if}}
    </td>
  </tr>
  <tr>
    <td class="button">
    {{if @$modules.ecap->mod_active}}
	    {{mb_include_script module=ecap script=dhe}}
	    <div id="dhe"></div>
	    <script type="text/javascript">DHE.register({{$patient->patient_id}}, null, "dhe");</script>
	  {{else}}
      <a class="button new" href="?m=dPplanningOp&amp;tab=vw_edit_sejour&amp;patient_id={{$patient->patient_id}}&amp;sejour_id=0">
        S�jour
      </a>
    </td>
    <td class="button">
      <a class="button new" href="?m=dPplanningOp&amp;tab=vw_edit_urgence&amp;pat_id={{$patient->patient_id}}&amp;operation_id=0&amp;sejour_id=0">
        Interv. hors plage
      </a>
    {{/if}}
    </td>
  </tr>
  {{/if}}

  {{if $listPrat|@count && $canCabinet->edit}}
  <tr><th class="category" colspan="2">Consultation imm�diate</th></tr>
  <tr>
    <td class="button" colspan="2">
      <form name="addConsFrm" action="?m=dPcabinet" method="post" onsubmit="return checkForm(this)">
      <input type="hidden" name="m" value="dPcabinet" />
      <input type="hidden" name="dosql" value="do_consult_now" />
      <input type="hidden" name="del" value="0" />
      <input type="hidden" name="patient_id" class="notNull ref" value="{{$patient->patient_id}}" />
      <label for="prat_id" title="Praticien pour la consultation imm�diate. Obligatoire">Praticien</label>
      <select name="prat_id" class="notNull ref"  style="width: 140px;">
        <option value="">&mdash; {{tr}}Choose{{/tr}}</option>
        {{foreach from=$listPrat item=_prat}}
          <option value="{{$_prat->user_id}}" {{if $_prat->user_id == $app->user_id}} selected="selected" {{/if}}>
            {{$_prat->_view}}
          </option>
        {{/foreach}}
      </select>
      <button class="new" type="submit">Consulter</button>
      </form>
    </td>
  </tr>
  {{/if}}
</tbody>        

</table>