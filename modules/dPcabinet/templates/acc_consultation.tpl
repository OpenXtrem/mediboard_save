{{assign var="chir_id" value=$consult->_ref_plageconsult->chir_id}}
{{assign var="object" value=$consult}}
{{assign var="module" value="dPcabinet"}}
{{assign var="do_subject_aed" value="do_consultation_aed"}}
{{mb_include module=dPsalleOp template=js_codage_ccam}}
{{assign var=sejour_id value=""}}

<script type="text/javascript">
function setField(oField, sValue) {
  oField.value = sValue;
}

var constantesMedicalesDrawn = false;
function refreshConstantesMedicales (force) {
	if (!constantesMedicalesDrawn || force) {
	  var url = new Url();
	  url.setModuleAction("dPhospi", "httpreq_vw_constantes_medicales");
	  url.addParam("patient_id", {{$consult->_ref_patient->_id}});
	  url.addParam("context_guid", "{{$consult->_guid}}");
	  url.requestUpdate("Constantes");
		constantesMedicalesDrawn = true;
	}
};

Main.add(function () {
  var tabsConsult = Control.Tabs.create('tab-consult', false);
  {{if $app->user_prefs.ccam_consultation == 1}}
  var tabsActes = Control.Tabs.create('tab-actes', false);
  {{/if}}
});
</script>

<ul id="tab-consult" class="control_tabs">
  {{if $consult->sejour_id}}
  <li><a href="#rpuConsult">
     RPU 
    {{if $consult->_ref_sejour->_num_dossier}}
      [{{$consult->_ref_sejour->_num_dossier}}]
    {{/if}}</a>
  </li>
  {{/if}}
  
  <li><a href="#AntTrait">Antécédents</a></li>
  <li onmousedown="refreshConstantesMedicales();"><a href="#Constantes">Constantes</a></li>
  <li><a href="#Examens">Examens</a></li>
  
  {{if $app->user_prefs.ccam_consultation == 1}}
  <li><a href="#Actes">Actes</a></li>
  {{/if}}
  
  <li><a href="#fdrConsult">Docs et Règlements</a></li>
</ul>
<hr class="control_tabs" />

{{if $consult->sejour_id}}
{{assign var="rpu" value=$consult->_ref_sejour->_ref_rpu}}
<div id="rpuConsult" style="display: none;">{{include file="../../dPurgences/templates/inc_vw_rpu.tpl"}}</div>
{{/if}}

<div id="AntTrait" style="display: none;">{{include file="../../dPcabinet/templates/inc_ant_consult.tpl"}}</div>
<div id="Constantes" style="display: none"></div>
<div id="Examens" style="display: none;">{{include file="../../dPcabinet/templates/inc_main_consultform.tpl"}}</div>

{{if $app->user_prefs.ccam_consultation == 1}}
<div id="Actes" style="display: none;">
  <ul id="tab-actes" class="control_tabs">
    <li><a href="#ccam">Actes CCAM</a></li>
    <li><a href="#ngap">Actes NGAP</a></li>
    {{if $consult->sejour_id}}
    <li><a href="#cim">Diagnostics</a></li>
    {{/if}}
  </ul>
  <hr class="control_tabs"/>
  
  <div id="ccam" style="display: none;">
    {{assign var="module" value="dPcabinet"}}
    {{assign var="subject" value=$consult}}
    {{mb_include module=dPsalleOp template=inc_codage_ccam}}
  </div>
  
  <div id="ngap" style="display: none;">
    <div id="listActesNGAP">
      {{assign var="_object_class" value="CConsultation"}}
	    {{mb_include module=dPcabinet template=inc_codage_ngap}}
    </div>
  </div>
  
  {{if $consult->sejour_id}}
  <div id="cim" style="display: none;">
      {{assign var="sejour" value=$consult->_ref_sejour}}
      {{include file="../../dPsalleOp/templates/inc_diagnostic_principal.tpl" modeDAS="1"}}
  </div>
  {{/if}}
</div>
{{/if}}

<div id="fdrConsult" style="display: none;">{{include file="../../dPcabinet/templates/inc_fdr_consult.tpl"}}</div>