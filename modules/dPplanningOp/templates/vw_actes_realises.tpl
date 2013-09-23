<script>

function submitActeCCAM(oForm, acte_ccam_id, sField){
  if(oForm[sField].value == 1) {
    $V(oForm[sField], 0);
  } else {
    $V(oForm[sField], 1);
  }
  $(sField + '-' + acte_ccam_id).toggleClassName('cancel').toggleClassName('tick');
  return onSubmitFormAjax(oForm, {onComplete: function() { reloadActeCCAM(acte_ccam_id) } });
}

function reloadActeCCAM(acte_ccam_id) {
  var url = new Url;
  url.setModuleAction("dPplanningOp", "httpreq_vw_reglement_ccam");
  url.addParam("acte_ccam_id", acte_ccam_id);
  url.requestUpdate('divreglement-'+acte_ccam_id);
}

function viewCCAM(codeacte) {
  var url = new Url;
  url.setModuleAction("dPccam", "vw_full_code");
  url.addParam("_codes_ccam", codeacte);
  url.popup(800, 600, "Code CCAM");
}
function viewTarmed(codeacte) {
  var url = new Url;
  url.setModuleAction("tarmed", "vw_tarmed");
  url.addParam("code_tarmed", codeacte);
  url.addParam("dialog", 1);
  url.popup(800, 600, "Code Tarmed");
}

</script>

<table class="main">
  <tr>
    <th colspan="2">
      <a href="#" onclick="window.print()">
        Rapport des actes cod�s
      </a>
    </th>
  </tr>
  <tr>
    <td>
      <table class="main">
        <tr>
          <td>
            Dr {{$praticien->_view}}
          </td>
        </tr>
        <tr>
          <td>
            du {{$_date_min|date_format:$conf.longdate}}
          </td>
        </tr>
        <tr>
          <td>
            au {{$_date_max|date_format:$conf.longdate}}
          </td>
        </tr>
      </table>
    </td>
    <td>
      <table class="tbl">
        <tr>
          <th>Nombre de s�jours</th>
          <td>
            {{$nbActes|@count}}
          </td>
        </tr>
        <tr>
          <th>Nombre d'actes</th>
          <td>
            {{$totalActes}}
          </td>
        </tr>
        <tr>
          <th>Total</th>
          <td>
            {{$montantTotalActes|currency}}
          </td>
        </tr>
      </table>
    </td>
  </tr>

  {{if $typeVue == 1}}
    {{foreach from=$sejours key="key" item="jour"}}
      <tr>
        <td colspan="2">
          <table>
            <tr>
              <td>
                <strong>Sortie r�elle le {{$key|date_format:$conf.longdate}}</strong>
              </td>
            </tr>
          </table>
          <table class="tbl">
            <tr>
              <th style="width: 20%">Patient</th>
              <th style="width: 05%">Total S�jour</th>
              <th style="width: 20%">Type</th>
              <th style="width: 05%">Code</th>
              <th style="width: 05%">Act.</th>
              <th style="width: 05%">Phase</th>
              <th style="width: 05%">Mod</th>
              <th style="width: 05%">ANP</th>
              <th style="width: 05%">{{mb_title class=CActeCCAM field=montant_base}}</th>
              <th style="width: 05%">{{mb_title class=CActeCCAM field=montant_depassement}}</th>
              <th style="width: 05%">{{mb_title class=CActeCCAM field=_montant_facture}}</th>
            </tr>

            <!-- Parcours des sejours -->
            {{foreach from=$jour item="sejour"}}
            {{assign var="sejour_id" value=$sejour->_id}}
            <tbody class="hoverable">
            <tr>
              <td rowspan="{{$nbActes.$sejour_id}}">{{$sejour->_ref_patient->_view}} {{if $sejour->_ref_patient->_age}}({{$sejour->_ref_patient->_age}}){{/if}}</td>
              <td rowspan="{{$nbActes.$sejour_id}}">
                {{$montantSejour.$sejour_id|currency}}
              </td>
              <td class="text" rowspan="{{$nbActes.$sejour_id}}">
                {{if $sejour->_ref_actes|@count}}
                  Sejour du {{mb_value object=$sejour field=_entree}}
                  au {{mb_value object=$sejour field=_sortie}}
                {{/if}}
                {{foreach from=$sejour->_ref_operations item=operation}}
                  {{if $operation->_ref_actes|@count}}
                    <br/>Intervention du {{mb_value object=$operation field=_datetime_best}}
                    {{if $operation->libelle}}<br /> {{$operation->libelle}}{{/if}}
                  {{/if}}
                {{/foreach}}
                {{foreach from=$sejour->_ref_consultations item=consult}}
                  {{if $consult->_ref_actes|@count}}
                    <br/>Consultation du {{$consult->_datetime|date_format:"%d %B %Y"}}
                    {{if $consult->motif}}: {{$consult->motif}}{{/if}}
                  {{/if}}
                {{/foreach}}
              </td>

              {{mb_include module=dPplanningOp template=inc_acte_realise codable=$sejour}}
              {{if $sejour->_ref_operations}}
                {{foreach from=$sejour->_ref_operations item=operation}}
                  {{mb_include module=dPplanningOp template=inc_acte_realise codable=$operation}}
                {{/foreach}}
              {{/if}}

              {{if $sejour->_ref_consultations}}
                {{foreach from=$sejour->_ref_consultations item=consult}}
                  {{mb_include module=dPplanningOp template=inc_acte_realise codable=$consult}}
                {{/foreach}}
              {{/if}}

            </tr>
            </tbody>
            {{/foreach}}
          </table>
        </td>
      </tr>
    {{/foreach}}
  {{/if}}
</table>