{{if $sejour->_id}}
<form name="frmCopyAntecedent" action="?m=dPcabinet" method="post">
  <input type="hidden" name="m" value="dPpatients" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="dosql" value="do_copy_antecedent" />
  <input type="hidden" name="antecedent_id" value="" />
  <input type="hidden" name="_sejour_id" value="{{$sejour->_id}}" />
</form>

<form name="frmCopyAddiction" action="?m=dPcabinet" method="post">
  <input type="hidden" name="m" value="dPpatients" /> 
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="dosql" value="do_copy_addiction" />
  <input type="hidden" name="addiction_id" value="" />
  <input type="hidden" name="_sejour_id" value="{{$sejour->_id}}" />
</form>

<form name="frmCopyTraitement" action="?m=dPcabinet" method="post">
  <input type="hidden" name="m" value="dPpatients" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="dosql" value="do_copy_traitement" />
  <input type="hidden" name="traitement_id" value="" />
  <input type="hidden" name="_sejour_id" value="{{$sejour->_id}}" />
</form>

<script type="text/javascript">

onSubmitDossierMedical = function(oForm) {
	return onSubmitFormAjax(oForm, { 
		onComplete : reloadDossierMedicalSejour 
	} );
}

copyAntecedent = function(antecedent_id){
  var oForm = document.frmCopyAntecedent;
  oForm.antecedent_id.value = antecedent_id;
 	onSubmitDossierMedical(oForm);
}

copyTraitement = function(traitement_id){
  var oForm = document.frmCopyTraitement;
  oForm.traitement_id.value = traitement_id;
  onSubmitDossierMedical(oForm);
}

copyAddiction = function(addiction_id) {
	var oForm = document.frmCopyAddiction;
	oForm.addiction_id.value = addiction_id;
	onSubmitDossierMedical(oForm);
}

</script>


{{include file="inc_consult_anesth/inc_list_addiction_anesth.tpl}}    

<strong>Ant�c�dents significatifs</strong>
<ul>
  {{foreach from=$sejour->_ref_dossier_medical->_ref_antecedents key=curr_type item=list_antecedent}}
  {{if $list_antecedent|@count}}
  {{foreach from=$list_antecedent item=curr_antecedent}}
  <li>
    <form name="delAntFrm-{{$curr_antecedent->_id}}" action="?m=dPcabinet" method="post">

    <input type="hidden" name="m" value="dPpatients" />
    <input type="hidden" name="del" value="0" />
    <input type="hidden" name="dosql" value="do_antecedent_aed" />
    <input type="hidden" name="antecedent_id" value="{{$curr_antecedent->_id}}" />
    
    <button class="trash notext" type="button" onclick="Antecedent.remove(this.form, reloadDossierMedicalSejour)">
     {{tr}}delete{{/tr}}
    </button>          
    {{if $curr_antecedent->date}}
      {{$curr_antecedent->date|date_format:"%d/%m/%Y"}} :
    {{/if}}
    
	  </form>

	  <strong>{{tr}}CAntecedent.type.{{$curr_type}}{{/tr}}</strong> :
	  <span class="tooltip-trigger" onmouseover="ObjectTooltip.create(this, { mode: 'objectViewHistory', params: { object_class: 'CAntecedent', object_id: {{$curr_antecedent->_id}} } })">
	   {{$curr_antecedent->rques}}
	  </span>
  </li>
  {{/foreach}}
  {{/if}}
  {{foreachelse}}
  <li><em>Pas d'ant�c�dents</em></li>
  {{/foreach}}
</ul>
      
<strong>Traitements significatifs</strong>
<ul>
  {{foreach from=$sejour->_ref_dossier_medical->_ref_traitements item=curr_trmt}}
  <li>
    <form name="delTrmtFrm-{{$curr_trmt->_id}}" action="?m=dPcabinet" method="post">
    <input type="hidden" name="m" value="dPpatients" />
    <input type="hidden" name="del" value="0" />
    <input type="hidden" name="dosql" value="do_traitement_aed" />
    <input type="hidden" name="traitement_id" value="{{$curr_trmt->_id}}" />
    <button class="trash notext" type="button" onclick="Traitement.remove(this.form, reloadDossierMedicalSejour)">
        {{tr}}delete{{/tr}}
    </button>
    {{if $curr_trmt->fin}}
      Du {{$curr_trmt->debut|date_format:"%d/%m/%Y"}} au {{$curr_trmt->fin|date_format:"%d/%m/%Y"}} :
    {{elseif $curr_trmt->debut}}
      Depuis le {{$curr_trmt->debut|date_format:"%d/%m/%Y"}} :
    {{/if}}
     <span class="tooltip-trigger" onmouseover="ObjectTooltip.create(this, { mode: 'objectViewHistory', params: { object_class: 'CTraitement', object_id: {{$curr_trmt->_id}} } })">
       {{$curr_trmt->traitement}}
     </span>
    </form>
  </li>
  {{foreachelse}}
  <li><em>Pas de traitements</em></li>
  {{/foreach}}
</ul>

<strong>Diagnostics significatifs de l'op�ration</strong>
<ul>
  {{foreach from=$sejour->_ref_dossier_medical->_ext_codes_cim item=curr_code}}
  <li>
    <button class="trash notext" type="button" onclick="oCimAnesthField.remove('{{$curr_code->code}}')">
      {{tr}}delete{{/tr}}
    </button>
    {{$curr_code->code}}: {{$curr_code->libelle}}
  </li>
  {{foreachelse}}
  <li><em>Pas de diagnostic</em></li>
  {{/foreach}}
</ul>

<form name="editDiagAnesthFrm" action="?m=dPcabinet" method="post" onsubmit="return checkForm(this);">
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="m" value="dPpatients" />
  <input type="hidden" name="tab" value="edit_consultation" />
  <input type="hidden" name="dosql" value="do_dossierMedical_aed" />
  <input type="hidden" name="object_id" value="{{$sejour->_id}}" />
  <input type="hidden" name="object_class" value="CSejour" />
  <input type="hidden" name="codes_cim" value="{{$sejour->_ref_dossier_medical->codes_cim}}" />
</form>

<script type="text/javascript">
oCimAnesthField = new TokenField(document.editDiagAnesthFrm.codes_cim, { 
  confirm  : 'Voulez-vous r�ellement supprimer ce diagnostic ?',
  onChange : updateTokenCim10Anesth
} );
</script>
{{else}}
Aucun s�jour s�lectionn�
{{/if}}