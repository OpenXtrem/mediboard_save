<script type="text/javascript">


preselectType = function(contexte){
  var oForm = document.addProtocolePresc; 
  
  {{if $contexteType}}
  
  contexteType = {{$contexteType|@json}};
  _contexteType = contexteType[contexte];

  if(contexte == "CConsultation"){
    oForm.type.value = "externe";
  } else {
    oForm.type.value = "traitement";
  }
  
  $A(oForm.type).each( function(input) {
    input.disabled = !_contexteType.include(input.value);
  });
  
  {{/if}}
}

</script>

<!-- Formulaire de creation du protocole -->
{{if !$prescription->_id && $mode_protocole}}
<form action="?m=dPprescription" method="post" name="addProtocolePresc" onsubmit="return Protocole.add();">	
   <input type="hidden" name="m" value="dPprescription" />
   <input type="hidden" name="dosql" value="do_prescription_aed" />
   <input type="hidden" name="prescription_id" value="" />
   <input type="hidden" name="del" value="0" />
   <input type="hidden" name="object_class" value=""/>
   <input type="hidden" name="object_id" value=""/>
   <input type="hidden" name="praticien_id" value="" />
   {{if $prescription->object_class == "CConsultation"}}
     <input type="hidden" name="type" value="externe" />
   {{/if}}
   {{if $prescription->object_class == "CSejour"}}
     <input type="hidden" name="type" value="pre_admission" />
   {{/if}}
   <input type="hidden" name="callback" value="Prescription.reloadAddProt" />
   <table class="form">
     <tr>
       <th class="category" colspan="2">
         Cr�ation d'un protocole
       </th>
    </tr>
    <tr>
      <th>  
        {{mb_label object=$protocole field="libelle"}}
      </th>
      <td>
		    {{mb_field object=$protocole field="libelle" class="notNull"}}  
      </td>
    </tr>
    <tr>
      <th>
			  {{mb_label object=$protocole field="object_class"}}
			</th>
			<td>
			  {{mb_field object=$protocole field="object_class" onchange="preselectType(this.value)"}}  
			</td>
	  </tr>
	  <tr>
	    <th>
	      {{mb_label object=$protocole field="type"}}
	    </th>
	    <td>
	      {{mb_field object=$protocole field="type"}}
	    </td>
	  </tr>
	  <tr>
	   <td colspan="2" style="text-align: center">
			  <button type="button" onclick="this.form.onsubmit();" class="new">Cr�er une protocole</button>
	   </td>  
	  </tr>
  </table>
</form>
{{/if}}


<!-- Formulaire de cr�ation de la prescription -->
{{if !$prescription->_id && !$mode_protocole}}
<form action="?m=dPprescription" method="post" name="addPrescription" onsubmit="return checkForm(this);">
  <input type="hidden" name="m" value="dPprescription" />
  <input type="hidden" name="dosql" value="do_prescription_aed" />
  <input type="hidden" name="prescription_id" value="" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="object_class" value="{{$prescription->object_class}}"/>
  <input type="hidden" name="object_id" value="{{$prescription->object_id}}"/>
  {{if $prescription->object_class == "CConsultation"}}
  <input type="hidden" name="type" value="externe" />
  {{/if}}
  {{if $prescription->object_class == "CSejour"}}
  <input type="hidden" name="type" value="pre_admission" />
  {{/if}}
  <select name="praticien_id">
    {{foreach from=$listPrats item=curr_prat}}
    <option value="{{$curr_prat->_id}}">
      {{$curr_prat->_view}}
    </option>
    {{/foreach}}
  </select>
  <button type="submit" class="new">Cr�er une prescription</button>
</form>
{{/if}}


<!-- Affichage de la prescription -->    
{{if $prescription->_id}}
<table class="form">
  <tr>
    <th class="title">
      {{if !$mode_protocole && !$dialog}}
      <button type="button" class="cancel" onclick="Prescription.close('{{$prescription->object_id}}','{{$prescription->object_class}}')" style="float: left">
        Fermer 
      </button>
      {{/if}}
      <!-- Impression de la prescription -->
      <button type="button" class="print notext" onclick="Prescription.print('{{$prescription->_id}}')" style="float: left">
        Print
      </button>
      {{if !$mode_protocole}}
      <!-- Affichage du recapitulatif des alertes -->
      <button type="button" class="search" onclick="Prescription.viewFullAlertes('{{$prescription->_id}}')" style="float: left">
        Alertes
      </button>
      {{/if}}
      {{if $mode_protocole}}
      <!-- Formulaire de modification du libelle de la prescription -->
      <form name="addLibelle-{{$prescription->_id}}" method="post">
        <input type="hidden" name="m" value="dPprescription" />
        <input type="hidden" name="dosql" value="do_prescription_aed" />
        <input type="hidden" name="del" value="0" />
        <input type="hidden" name="prescription_id" value="{{$prescription->_id}}" />
        <input type="text" name="libelle" value="{{$prescription->libelle}}" 
               onchange="submitFormAjax(this.form, 'systemMsg', { 
                 onComplete : function() { 
                   Protocole.refreshList('{{$prescription->praticien_id}}','{{$prescription->_id}}') 
                 } })" />
      </form>
      <button class="tick notext"></button>
      {{else}}
        {{$prescription->_view}}
      {{/if}}
    </th>
  </tr>
  {{if !$mode_protocole}}
  <tr>
    <td>
      Protocoles de {{$praticien->_view}}
      <!-- Formulaire de selection protocole -->
      <form name="applyProtocole" method="post" action="?">
        <input type="hidden" name="m" value="dPprescription" />
        <input type="hidden" name="dosql" value="do_apply_protocole_aed" />
        <input type="hidden" name="del" value="0" />
        <input type="hidden" name="prescription_id" value="{{$prescription->_id}}" />
        <select name="protocole_id" onchange="submitFormAjax(this.form, 'systemMsg'); this.value='';">
          <option value="">&mdash; S�lection d'un protocole</option>
          {{foreach from=$protocoles item=protocole}}
          <option value="{{$protocole->_id}}">{{$protocole->_view}}</option>
          {{/foreach}}  
        </select>
      </form>
    </td>
  </tr>
  {{/if}}
</table>

<!-- Affichage des elements de la prescription -->
<div id="produits_elements">
  {{include file="inc_vw_produits_elements.tpl"}}  
</div>

{{/if}}

<script type="text/javascript">


// Preparation du formulaire de creation de protocole
if(document.addProtocolePresc){
  prepareForm(document.addProtocolePresc);
  
  preselectType("CConsultation");
}
</script>