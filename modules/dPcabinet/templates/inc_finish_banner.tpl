<script type="text/javascript">
{{if $ajax}}
new PairEffect("listConsult", { sEffect : "appear", bStartVisible : true });
{{/if}}

function submitConsultWithChrono(chrono) {
  var oForm = document.editFrmFinish;
  oForm.chrono.value = chrono;
  submitFormAjax(oForm, 'systemMsg', { onComplete : reloadFinishBanner });
}

function reloadFinishBanner() {
  var mainUrl = new Url;
  mainUrl.setModuleAction("dPcabinet", "httpreq_vw_finish_banner");
  mainUrl.addParam("selConsult", document.editFrmFinish.consultation_id.value);
  mainUrl.addParam("_is_anesth", "{{$_is_anesth}}");
  mainUrl.requestUpdate('finishBanner', { waitingText : null });
}
</script>

<form class="watch" name="editFrmFinish" action="?m={{$m}}" method="post" onsubmit="return checkForm(this);">

<input type="hidden" name="m" value="{{$m}}" />
<input type="hidden" name="del" value="0" />
<input type="hidden" name="dosql" value="do_consultation_aed" />
{{mb_field object=$consult field="consultation_id" type="hidden" spec=""}}
{{mb_field object=$consult field="chrono" type="hidden" spec=""}}

<table class="form">
  <tr>
    <th class="category" colspan="4">
      {{if $_is_anesth}}
      <button class="print" type="button" style="float: left;" onclick="printFiche()">
        Imprimer la fiche
      </button>
      <button class="print" type="button" style="float: left;" onclick="printAllDocs()">
        Imprimer les documents
      </button>      
      {{else}}
      <button id="listConsult-trigger" type="button" style="float:left">+/-</button>
      <button class="print" type="button" style="float: right;" onclick="printAllDocs()">
        Imprimer les documents
      </button> 
      {{/if}}
        Consultation
        (Etat : {{$consult->_etat}}
      {{if $consult->chrono <= $consult|const:'EN_COURS'}}
      / 
      <button class="submit" type="button" onclick="submitAll(); submitConsultWithChrono({{$consult|const:'TERMINE'}})">
        Terminer
      </button>
      {{/if}})
    </th>
  </tr>
</table>
</form>