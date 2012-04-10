{{if @$modules.tarmed->_can->read && $conf.tarmed.CCodeTarmed.use_cotation_tarmed == "1"}}
  {{mb_script module="tarmed" script="actes"}}
{{/if}}

<script>
function printFacture(factureconsult_id, edit_justificatif, edit_bvr) {
  var url = new Url('dPcabinet', 'edit_bvr');
  url.addParam('factureconsult_id', factureconsult_id);
  url.addParam('edit_justificatif', edit_justificatif);
  url.addParam('edit_bvr', edit_bvr);
  url.addParam('suppressHeaders', '1');
  url.popup(1000, 600, 'systemMsg');
}

{{if @$modules.tarmed->_can->read && $conf.tarmed.CCodeTarmed.use_cotation_tarmed == "1"}}
  ajoutActe = function(oForm){
    {{if $facture}}      
      var url = new Url('dPcabinet', 'ajax_creation_facture');
      url.addParam('consult_id', oForm.object_id.value);
      url.addParam('ajout_consult', "ok");
      url.addParam('patient_id', '{{$facture->patient_id}}');
      url.addParam('du_patient', oForm.montant_base.value);
      url.addParam('executant_id', oForm.executant_id.value);
      url.addParam('_libelle', oForm._libelle.value);
      url.addParam('date', oForm.date.value);
      url.addParam('code', oForm.code.value);
      url.addParam('montant_base', oForm.montant_base.value);
      url.addParam('quantite', oForm.quantite.value);
      url.requestUpdate('load_facture');
    {{/if}}
  }
    
  refreshLibelle = function(){
    var oForm = document.editTarmed;
    var url = new Url("tarmed", "httpreq_vw_tarif_code_tarmed");
    url.addParam("type", "libelle");
    url.addParam("quantite", oForm.quantite.value);
    url.addParam("code", oForm.code.value);
    url.requestUpdate('libelleActeTarmed'); 
  }
    
  refreshTarif = function(){
    var oForm = document.editTarmed;
    var url = new Url("tarmed", "httpreq_vw_tarif_code_tarmed");
    url.addParam("type", "tarif");
    url.addParam("quantite", oForm.quantite.value);
    url.addParam("code", oForm.code.value);
    url.requestUpdate('tarifActeTarmed'); 
  }
  
  Main.add(function () {
    {{if $facture && $facture->_id && !$facture->cloture && @$modules.tarmed->_can->read && $conf.tarmed.CCodeTarmed.use_cotation_tarmed == "1" && isset($factures|smarty:nodefaults)}}
        var oForm = getForm("editTarmed");
        Calendar.regField(oForm.date, null);
        
        var url = new Url("tarmed", "httpreq_do_tarmed_autocomplete");
        url.autoComplete(oForm.code, "codeacte_auto_complete", {
          minChars: 0,
          dropdown: true,
          select: "newcode",
          updateElement: function(selected) {
            var form = getForm('editTarmed');
            $V(form.code, selected.down(".newcode").getText(), false);
            form.quantite.value = 1;
            refreshTarif();
            refreshLibelle();
          }
        });
    {{/if}}
  });
{{/if}}
</script>
<!-- Facture -->
    <fieldset>
      {{if $facture && $facture->_id}}
      <legend>{{$facture->_view}}</legend>
        <table class="main tbl">
          {{if $facture->cloture}}
            <tr>
              <td colspan="10">
                <div class="small-info">
                La facture est termin�e.<br />
                Pour pouvoir ajouter des �l�ments, veuillez r�ouvrir la facture.
                </div>
              </td>
            </tr>
          {{/if}}
          {{if $facture->cloture && $conf.tarmed.CCodeTarmed.use_cotation_tarmed == "1"}}
            <tr>
              <td colspan="10">
                {{if $facture->type_facture == "maladie"}}
                  <button class="printPDF" onclick="printFacture('{{$facture->_id}}', 0, 1);">Edition des BVR</button>
                {{/if}}
                <button class="cut" onclick="Facture.cutFacture('{{$facture->_id}}');">Eclatement</button>
                <button class="print" onclick="printFacture('{{$facture->_id}}', 1, 0);">Justificatif de remboursement</button>
              </td>
            </tr>
          {{/if}}
          <tr>
            <td colspan="10" > Type de la facture:
              <form name="type_facture" method="get"> 
                <input type="radio" name="type" value="maladie" {{if $facture->type_facture == 'maladie'}}checked{{/if}} disabled />
                <label for="maladie">Maladie</label>
                <input type="radio" name="type" value="accident" {{if $facture->type_facture == 'accident'}}checked{{/if}} disabled />
                <label for="accident">Accident</label>
              </form>
            </td>
          </tr>
          <tr>
            <th class="category">Date</th>
            <th class="category">Code</th>
            <th class="category">Libelle</th>
            <th class="category">{{if $conf.dPccam.CCodeCCAM.use_cotation_ccam == "1"}}Du patient{{else}}Co�t{{/if}}</th>
            <th class="category" style="min-width:50px;">{{if $conf.dPccam.CCodeCCAM.use_cotation_ccam == "1"}}Du tiers{{else}}Qte{{/if}}</th>
            <th class="category">Montant</th>
          </tr>
          {{foreach from=$facture->_ref_consults item=_consultation}}
            {{if $conf.dPccam.CCodeCCAM.use_cotation_ccam == "1"}}
              {{foreach from=$_consultation->_ref_actes_ccam item=_acte_ccam key="_key" name="tab"}}
                {{assign var=key value=$smarty.foreach.tab.index}}
                <tr>
                  <td>{{$_consultation->_date|date_format:"%d/%m/%Y"}}</td>
                  <td style="background-color:#FF69B4;">{{$_acte_ccam->code_acte}}</td>
                  
                  <td>{{$_consultation->_ext_codes_ccam.$key->libelleLong|truncate:70:"...":true}}</td>
                  <td>{{mb_value object=$_acte_ccam field="montant_base"}}</td>
                  <td>{{mb_value object=$_acte_ccam field="montant_depassement"}}</td>
                  <td>{{$_acte_ccam->montant_base+$_acte_ccam->montant_depassement}}</td>
                </tr>
              {{/foreach}}
              {{foreach from=$_consultation->_ref_actes_ngap item=_acte_ngap}}
                <tr>
                  <td>{{$_consultation->_date|date_format:"%d/%m/%Y"}}</td>
                  <td  style="background-color:#32CD32;">{{$_acte_ngap->code}}</td>
                  <td>{{$_acte_ngap->_libelle}}</td>
                  <td>{{mb_value object=$_acte_ngap field="montant_base"}}</td>
                  <td>{{mb_value object=$_acte_ngap field="montant_depassement"}}</td>
                  <td>{{$_acte_ngap->montant_base+$_acte_ngap->montant_depassement}}</td>
                </tr>
              {{/foreach}}
            {{elseif  @$modules.tarmed->_can->read && $conf.tarmed.CCodeTarmed.use_cotation_tarmed == "1"}}
              {{foreach from=$_consultation->_ref_actes_tarmed item=_acte_tarmed}}
                <tr>
                  <td style="text-align:center;width:100px;">{{if $_acte_tarmed->date}}{{mb_value object=$_acte_tarmed field="date"}} {{else}}{{$_consultation->_date|date_format:"%d/%m/%Y"}}{{/if}}</td>
                  <td  {{if $_acte_tarmed->code}} style="background-color:#BA55D3;width:140px;">{{mb_value object=$_acte_tarmed field="code"}}{{else}}>{{/if}}</td>
                  <td style="white-space: pre-wrap;">{{if !isset($_acte_tarmed->libelle|smarty:nodefaults)}}{{$_acte_tarmed->_ref_tarmed->libelle}}{{else}}{{$_acte_tarmed->libelle}}{{/if}}</td>
                  <td style="text-align:right;">{{$_acte_tarmed->montant_base/$_acte_tarmed->quantite}}</td>
                  <td style="text-align:right;">{{mb_value object=$_acte_tarmed field="quantite"}}</td>
                  <td style="text-align:right;">{{mb_value object=$_acte_tarmed field="montant_base"}}</td>
                </tr>
              {{/foreach}}
            {{/if}}
          {{/foreach}}
          {{if !$facture->cloture && @$modules.tarmed->_can->read && $conf.tarmed.CCodeTarmed.use_cotation_tarmed == "1" && isset($factures|smarty:nodefaults) && count($factures) != 0 }}
          <tr>
            <td colspan="7">
              <form name="editTarmed"  method="post" action="">
                <input type="hidden" name="del" value="0" />
                <input type="hidden" name="m" value="tarmed" />
                <input type="hidden" name="dosql" value="do_acte_tarmed_aed" />
                <input type="hidden" name="object_id" value="{{$derconsult_id}}" />
                <input type="hidden" name="object_class" value="CConsultation" />
                <input type="hidden" name="executant_id" value="{{$chirSel}}"/>                
                <input type="hidden" name="libelle" value=""/>
                <table class="form" >
                  <tr>
                  <td style="width:100px;">{{mb_field object=$acte_tarmed field="date"}}
                  </td>
                  <td style="width:135px;">
                    {{mb_field object=$acte_tarmed field="code" style="width:100px;" }}
                    <div style="display: none;" class="autocomplete" id="codeacte_auto_complete"></div>
                  </td>
                  <td style="width:500px;float:left;" id="libelleActeTarmed">
                    <input type="text" name="_libelle" value="Saisir un libelle" style="width:400px;" />
                  </td>
                  <td id="tarifActeTarmed" style="float:left;" >
                    <input type="text" name="montant_base" value="{{$acte_tarmed->montant_base}}"  style="width:70px;"/>
                  </td >
                  <td id="qteActeTarmed" style="float:left;">
                    {{mb_field object=$acte_tarmed field="quantite" size="2" form="editTarmed" increment=1 min=1}}
                  </td>
                  <td>
                    <button type="button" class="new" onclick="ajoutActe(this.form);">
                      {{tr}}Create{{/tr}}
                    </button>
                  </td>
                  </tr>
                </table>
              </form>
            </td>
          </tr>
          {{/if}}
          {{if count($facture->_montant_factures)>1}}
            {{foreach from=$facture->_montant_factures item=_montant key=key }}
              <tr>
                <td colspan="3"></td>
                <td colspan="2">Montant n�{{$key+1}}</td>
                <td style="text-align:right;">{{$_montant}}</td>
                 
              <tr>
            {{/foreach}}
          {{else}}
            <tr>
              <td colspan="3" rowspan="4"></td>
              <td colspan="2">Montant</td>
              <td style="text-align:right;">{{mb_value object=$facture field="montant_sans_remise"}}</td>
               
            <tr>
          {{/if}}
          <tr>
            <td colspan="2"><b>{{mb_label object=$facture field="rabais"}}</b></td>
            <td> 
              <form name="modif_rabais" method="post" action="?m={{$m}}">
                <input type="hidden" name="dosql" value="do_factureconsult_aed" />
                <input type="hidden" name="m" value="dPcabinet" />
                <input type="hidden" name="del" value="0" />
                <input type="hidden" name="factureconsult_id" value="{{$facture->factureconsult_id}}" />
                <input type="hidden" name="patient_id" value="{{$facture->patient_id}}" />
                <input type="hidden" name="not_load_banque" value="{{if isset($factures|smarty:nodefaults) && count($factures) != 0}}0{{else}}1{{/if}}" />
                
                {{if $facture->cloture}}
                  {{mb_value object=$facture field="rabais"}} 
                {{else}}
                  <input name="rabais" type="text" value="{{$facture->rabais}}" onchange="Facture.modifCloture(this.form);" size="4" />
                {{/if}}
                <br/>soit <b>{{if $facture->montant_sans_remise != 0}}{{math equation="(y/x)*100" x=$facture->montant_sans_remise y=$facture->rabais format="%.2f"}}{{else}}0{{/if}}%</b>
              </form>
            </td>
          </tr>
          <tr>
            <td colspan="2"><b>Montant Total</b></td>
            <td style="text-align:right;"><b>{{mb_value object=$facture field="montant_avec_remise"}}</b></td>
          <tr>
          <tr>
            <td colspan="6">
              {{if count($facture->_montant_factures)==1 || !$facture->_montant_factures}}
                <form name="change_type_facture" method="post">
                  <input type="hidden" name="dosql" value="do_factureconsult_aed" />
                  <input type="hidden" name="m" value="dPcabinet" />
                  <input type="hidden" name="del" value="0" />
                  <input type="hidden" name="factureconsult_id" value="{{$facture->factureconsult_id}}" />
                  <input type="hidden" name="cloture" value="{{if !$facture->cloture}}{{$date}}{{/if}}" />
                  <input type="hidden" name="not_load_banque" value="{{if isset($factures|smarty:nodefaults) && count($factures) != 0}}0{{else}}1{{/if}}" />
                  {{if !$facture->cloture}}
                    <button class="submit" type="button" onclick="Facture.modifCloture(this.form);" >Cloturer la facture</button>
                  {{elseif !isset($reglement|smarty:nodefaults) || ($facture->_ref_reglements|@count == 0)}}
                    <button class="submit" type="button" onclick="Facture.modifCloture(this.form);" >R�ouvrir la facture</button>
                  {{/if}}
                </form>
              {{else}}
                <form name="fusionner_eclatements" method="post">
                  <input type="hidden" name="dosql" value="do_fusion_facture_aed" />
                  <input type="hidden" name="m" value="dPcabinet" />
                  <input type="hidden" name="del" value="0" />
                  <input type="hidden" name="factureconsult_id" value="{{$facture->factureconsult_id}}" />
                  <input type="hidden" name="not_load_banque" value="{{if isset($factures|smarty:nodefaults) && count($factures) != 0}}0{{else}}1{{/if}}" />
                  <button class="submit" type="button" onclick="Facture.modifCloture(this.form);" > Fusionner les �clats de facture </button>
                </form>
              {{/if}}
            </td>
          </tr>
        </table>        
      {{else}}
        <legend>Facture</legend>
        <table class="form">
          <b style="margin-left:300px;color:red;">Aucune facture</b>
        </table>
      {{/if}}
    </fildset>

<!-- Reglement -->
{{if isset($factures|smarty:nodefaults) && count($factures) != 0 && $facture->cloture}}
  <div id="reglements_facture">
    {{mb_include module=dPcabinet template="inc_vw_reglements"}}
  </div>
{{/if}}