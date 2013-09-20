{{if !@$modules.tarmed->_can->read || !$conf.tarmed.CCodeTarmed.use_cotation_tarmed}}
  {{mb_return}}
{{/if}}
{{mb_script module=patients     script=correspondant  ajax="true"}}
{{mb_script module=facturation  script=facture        ajax="true"}}
<script>
  refreshAssurance = function() {
    var url = new Url("facturation", "ajax_list_assurances");
    url.addParam("facture_id"   , '{{$facture->_id}}');
    url.addParam("facture_class", '{{$facture->_class}}');
    url.addParam("patient_id"   , '{{$facture->patient_id}}');
    url.requestUpdate("refresh-assurance");
  }

  printFacture = function(facture_id, type_pdf) {
    var url = new Url('facturation', 'ajax_edit_bvr');
    url.addParam('facture_class', '{{$facture->_class}}');
    url.addParam('facture_id'   , facture_id);
    url.addParam('type_pdf'     , type_pdf);
    url.addParam('suppressHeaders', '1');
    url.popup(1000, 600);
  }

  dossierBloc = function(operation_id) {
    var url = new Url("salleOp", "ajax_vw_operation");
    url.addParam("op", operation_id);
    url.requestModal('90%', '90%');
    url.modalObject.observe("afterClose", function(){
      Facture.reload('{{$facture->patient_id}}', '{{$facture->_class}}', 0, '{{$facture->_id}}');
    });
  }

  viewInterv = function(operation_id, plageop_id) {
    if (plageop_id) {
      var url = new Url("planningOp", "vw_edit_planning", "tab");
    }
    else {
      var url = new Url("planningOp", "vw_edit_urgence", "tab");
    }
    url.addParam("operation_id", operation_id);
    url.redirect();
  }

  {{if $facture->_ref_sejours|@count}}
    gestionFacture = function() {
      var url = new Url('facturation', 'vw_factures_sejour');
      url.addParam('facture_class', 'CFactureEtablissement');
      url.addParam('patient_id'   , '{{$facture->patient_id}}');
      url.addParam('object_id'    , '{{$facture->_ref_last_sejour->_id}}');
      url.addParam('object_class' , '{{$facture->_ref_last_sejour->_class}}');
      url.requestModal();
    }
  {{/if}}
</script>

{{if $facture->cloture && isset($factures|smarty:nodefaults) && count($factures) && !$facture->annule}}
  <tr>
    <td colspan="8">
      <button class="printPDF" onclick="printFacture('{{$facture->_id}}', 'bvr');">Edition des BVR</button>
      <button class="print" onclick="printFacture('{{$facture->_id}}', 'justificatif');">Justificatif de remboursement</button>
      {{if $facture->_ref_reglements|@count}}
        {{if ($facture->_ref_assurance_maladie->_id && $facture->type_facture == "maladie" && $facture->_ref_assurance_maladie->type_pec == "TS")
          || ($facture->_ref_assurance_accident->_id && $facture->type_facture == "accident" && $facture->_ref_assurance_accident->type_pec == "TS" && "tarmed coefficient pt_maladie"|conf:"CGroups-$g") }}
          <button class="printPDF" onclick="printFacture('{{$facture->_id}}', 'bvr_TS');">Facture Patient</button>
        {{/if}}
      {{/if}}
      {{if $facture->_is_relancable && $conf.dPfacturation.CRelance.use_relances}}
        <form name="facture_relance" method="post" action="" onsubmit="return Relance.create(this);">
          {{mb_class object=$facture->_ref_last_relance}}
          <input type="hidden" name="relance_id" value=""/>
          <input type="hidden" name="object_id" value="{{$facture->_id}}"/>
          <input type="hidden" name="object_class" value="{{$facture->_class}}"/>
          <button class="add" type="submit">Cr�er une relance</button>
        </form>
      {{/if}}
      {{if !$facture->_ref_patient->avs}}
        <div class="small-warning" style="display:inline">N� AVS manquant pour le patient</div>
      {{/if}}
      <form name="facture_extourne" method="post" action="" style="float:right;">
        {{mb_class object=$facture}}
        {{mb_key   object=$facture}}
        <input type="hidden" name="_duplicate" value="1"/>
        <button class="duplicate" type="submit">Extourner</button>
      </form>
      {{if $facture->_class == "CFactureEtablissement" && $facture->_ref_sejours|@count}}
        {{assign var="last_op" value=$facture->_ref_last_sejour->_ref_last_operation}}
        {{if $facture->numero == 1}}
          <button type="button" class="edit" onclick="viewInterv('{{$last_op->_id}}', '{{$last_op->plageop_id}}');" style="float:right;"> Infos interv. </button>
        {{/if}}
        <button type="button" class="new" onclick="gestionFacture();">Gestion des factures</button>
      {{/if}}
    </td>
  </tr>

  {{if ($facture->type_facture == "maladie" && $facture->assurance_maladie && !$facture->_ref_assurance_maladie->type_pec) ||
      ($facture->type_facture == "accident" && $facture->assurance_accident && !$facture->_ref_assurance_accident->type_pec)}}
    <tr style="height:30px;">
      <td colspan="8">
        <div class="small-warning" style="display:inline">
          Le type de prise en charge de cette assurance n'est pas sp�cifi�, merci de le renseigner
        </div>
      </td>
    </tr>
  {{/if}}
{{elseif !$facture->cloture && isset($factures|smarty:nodefaults) && count($factures) && $facture->_class == "CFactureEtablissement" && $facture->_ref_sejours|@count}}
  <tr>
    <td colspan="8">
      {{assign var="last_op" value=$facture->_ref_last_sejour->_ref_last_operation}}
      <button type="button" class="edit" onclick="dossierBloc('{{$last_op->_id}}');"> Dossier bloc </button>
      {{if $facture->numero == 1}}
        <button type="button" class="new" onclick="viewInterv('{{$last_op->_id}}', '{{$last_op->plageop_id}}');"> Infos interv. </button>
      {{/if}}
      <button type="button" class="new" onclick="gestionFacture();">Gestion des factures</button>
    </td>
  </tr>
{{/if}}
<tr>
  <td colspan="8">
    <form name="type_facture" method="post" action="">
      {{mb_class object=$facture}}
      {{mb_key   object=$facture}}
      <input type="hidden" name="facture_class" value="{{$facture->_class}}" />
      <input type="hidden" name="not_load_banque" value="{{if isset($factures|smarty:nodefaults) && count($factures)}}0{{else}}1{{/if}}" />
      <table class="main tbl">
        <tr>
          <td class="narrow">{{mb_label object=$facture field=type_facture}}</td>
          <td>{{mb_field object=$facture field=type_facture onchange="Facture.modifCloture(this.form);" readonly=$facture->cloture}}</td>
          <td class="narrow"> {{mb_label object=$facture field=cession_creance}}</td>
          <td>{{mb_field object=$facture field=cession_creance onchange="Facture.modifCloture(this.form);" readonly=$facture->cloture}}</td>
          <td style="width:400px;">
            {{if $facture->_class == "CFactureEtablissement"}}
              {{mb_label object=$facture field=dialyse}}
              {{mb_field object=$facture field=dialyse onchange="Facture.modifCloture(this.form);" readonly=$facture->cloture}} 
            {{/if}}
          </td>
        </tr>
        <tr>
          <td>{{mb_label object=$facture field=envoi_xml}}</td>
          <td>{{mb_field object=$facture field=envoi_xml onchange="Facture.modifCloture(this.form);" readonly=$facture->cloture}}</td>
          {{if $facture->_class == "CFactureCabinet"}}
            <td>{{mb_label object=$facture field=npq}}</td>
            <td>{{mb_field object=$facture field=npq onchange="Facture.modifCloture(this.form);" readonly=$facture->cloture}}</td>
          {{else}}
            <td colspan="2"></td>
          {{/if}}
          <td>
            {{mb_label object=$facture field=statut_pro}}
            {{mb_field object=$facture field=statut_pro emptyLabel="Choisir un status" onchange="Facture.cut(this.form);" readonly=$facture->cloture}}
          </td>
        </tr>
      </table>
    </form>
  </td>
</tr>
{{if $facture->type_facture != "esthetique"}}
  <tr>
    <td colspan="{{if $facture->_class == 'CFactureCabinet' || !$facture->dialyse}}2{{elseif $facture->dialyse}}3{{/if}}" id="refresh-assurance">
      {{mb_include module=facturation template="inc_vw_assurances"}}
    </td>
    <td colspan="{{if $facture->_class == 'CFactureCabinet' || !$facture->dialyse}}5{{elseif $facture->dialyse}}4{{/if}}">
      {{if $facture->rques_assurance_maladie}}
        <div class="info"><b>Remarque</b>{{mb_value object=$facture field=rques_assurance_maladie}}</div>
      {{/if}}
    </td>
  </tr>
{{/if}}

{{if $facture->type_facture == "accident"}}
  <tr>
    <td colspan="2">
      <form name="ref_accident" method="post" action="" onsubmit="return onSubmitFormAjax(this);" style="max-width:100px;">
        {{mb_class object=$facture}}
        {{mb_key   object=$facture}}
        <b>{{mb_label object=$facture field="ref_accident"}}:</b>
        {{if $facture->cloture}}
          {{mb_value object=$facture field="ref_accident"}} 
        {{else}}
          {{mb_field object=$facture field="ref_accident" onchange="return onSubmitFormAjax(this.form);"}}
        {{/if}}
      </form>
    </td>
    <td colspan="9"></td>
  </tr>
{{/if}}

<tr>
  <th class="category">Date</th>
  <th class="category">Code</th>
  <th class="category">Libelle</th>
  <th class="category">Co�t</th>
  <th class="category">Qte</th>
  <th class="category">Coeff</th>        
  <th class="category">Montant</th>
</tr>

{{if $facture->_ref_items|@count}}
  {{foreach from=$facture->_ref_items item=item}}
    {{if !$conf.dPfacturation.Other.use_view_quantitynull || ($conf.dPfacturation.Other.use_view_quantitynull && $item->quantite != 0)}}
      <tr>
        <td style="text-align:center;width:100px;">
          {{if $facture->_ref_last_sejour->_id}}
            <span onmouseover="ObjectTooltip.createEx(this, '{{$facture->_ref_last_sejour->_guid}}')">
          {{else}}
            <span onmouseover="ObjectTooltip.createEx(this, '{{$facture->_ref_last_consult->_guid}}')">
          {{/if}}
          {{mb_value object=$item field="date"}}
          </span>
        </td>
        <td class="acte-{{$item->type}}" style="width:140px;">{{mb_value object=$item field="code"}}</td>
        <td style="white-space: pre-line;" class="compact">{{mb_value object=$item field="libelle"}}</td>
        <td style="text-align:right;">{{mb_value object=$item field="montant_base"}}</td>
        <td style="text-align:right;">{{mb_value object=$item field="quantite"}}</td>
        <td style="text-align:right;">{{mb_value object=$item field="coeff"}} </td>
        <td style="text-align:right;">{{$item->montant_base*$item->coeff*$item->quantite|string_format:"%0.2f"|currency}}</td>
      </tr>
    {{/if}}
  {{/foreach}}
{{else}}
  {{foreach from=$facture->_ref_actes_tarmed item=_acte_tarmed}}
    {{mb_include module=dPfacturation template="inc_line_tarmed"}}
  {{/foreach}}
  {{foreach from=$facture->_ref_actes_caisse item=_acte_caisse}}
    {{mb_include module=dPfacturation template="inc_line_caisse"}}
  {{/foreach}}
{{/if}}
<tbody class="hoverable">
  {{assign var="nb_montants" value=$facture->_montant_factures|@count}}
  {{foreach from=$facture->_montant_factures item=_montant key=key name=montants}}
    <tr>
      {{if $smarty.foreach.montants.first}}
      <td colspan="4" rowspan="{{$nb_montants+2}}"></td>
      {{/if}}
      <td colspan="2">Montant{{if $nb_montants > 1}} n�{{$key+1}}{{/if}}</td>
      <td style="text-align:right;">{{$_montant|string_format:"%0.2f"|currency}}</td>
    </tr>
  {{/foreach}}
  
  <tr>
    {{if !$facture->_montant_factures|count}}
      <td colspan="4" rowspan="2"></td>
    {{/if}}
    <td colspan="2"><b>{{mb_label object=$facture field="remise"}}</b></td>
    <td style="text-align: right;"> 
      <form name="modif_remise" method="post" onsubmit="Facture.modifCloture(this.form);">
        {{mb_class object=$facture}}
        {{mb_key   object=$facture}}
        <input type="hidden" name="patient_id" value="{{$facture->patient_id}}" />
        <input type="hidden" name="not_load_banque" value="{{if isset($factures|smarty:nodefaults) && count($factures)}}0{{else}}1{{/if}}" />                
        
        {{if $facture->cloture}}
          {{mb_value object=$facture field="remise"}} 
        {{else}}
          <input name="remise" type="text" value="{{$facture->remise}}" onchange="Facture.modifCloture(this.form);" size="4" />
        {{/if}}
        
        <br/>soit 
        {{if $facture->_montant_sans_remise!=0 && $facture->remise}}
          <strong>{{math equation="(y/x)*100" x=$facture->_montant_sans_remise y=$facture->remise format="%.2f"}} %</strong>
        {{else}}
          <strong>0 %</strong>
        {{/if}}
      </form>
    </td>
  </tr>
  
  <tr>
    <td colspan="2"><b>Montant Total</b></td>
    <td style="text-align:right;"><b>{{mb_value object=$facture field="_montant_avec_remise"}}</b></td>
  </tr>
</tbody>

{{assign var="classe" value=$facture->_class}}
{{if (!$facture->_reglements_total_patient || $conf.dPfacturation.CReglement.add_pay_not_close)
  && !$conf.dPfacturation.$classe.use_auto_cloture && !$facture->annule && !$facture->definitive}}
  <tr>
    <td colspan="7">
      <form name="change_type_facture" method="post">
        {{mb_class object=$facture}}
        {{mb_key   object=$facture}}
        <input type="hidden" name="facture_class" value="{{$facture->_class}}" />
        <input type="hidden" name="cloture" value="{{if !$facture->cloture}}{{$date}}{{/if}}" />
        <input type="hidden" name="not_load_banque" value="{{if isset($factures|smarty:nodefaults) && count($factures)}}0{{else}}1{{/if}}" />
        {{if !$facture->cloture}}
          <button class="submit" type="button" onclick="Facture.modifCloture(this.form);"
          {{if $conf.dPfacturation.Other.use_strict_cloture && $facture->type_facture != "esthetique" &&
            (!$facture->statut_pro || (!$facture->assurance_maladie && !$facture->assurance_accident))}}
          disabled
          {{/if}}
          >Cloturer la facture</button>
        {{else}}
          <button class="submit" type="button" onclick="Facture.modifCloture(this.form);" >R�ouvrir la facture</button> Clotur�e le {{$facture->cloture|date_format:"%d/%m/%Y"}}
        {{/if}}
      </form>
    </td>
  </tr>
{{/if}}
{{if $facture->cloture && $conf.dPfacturation.Other.use_field_definitive}}
  <tr>
    <td colspan="7">
      <form name="facture_definitive" method="post" action="">
        {{mb_class object=$facture}}
        {{mb_key   object=$facture}}
        <input type="hidden" name="facture_class" value="{{$facture->_class}}" />
        {{mb_label object=$facture field=definitive}}
        {{mb_field object=$facture field=definitive onchange="Facture.modifCloture(this.form);"}}
      </form>
    </td>
  </tr>
{{/if}}