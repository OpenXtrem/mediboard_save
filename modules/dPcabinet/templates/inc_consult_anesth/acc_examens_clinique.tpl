<script type="text/javascript">
function calculImcVst(){
   var oForm = document.editAnesthPatFrm;
   var sImcValeur = "";
   var fImc       = "";
   var fVst       = "";
   if(oForm.poid.value && !isNaN(parseFloat(oForm.poid.value)) && parseFloat(oForm.poid.value)>0){
     fVst = {{if $patient->sexe=="m"}}70{{else}}65{{/if}}*parseFloat(oForm.poid.value);
     if(oForm.taille.value && !isNaN(parseInt(oForm.taille.value)) && parseInt(oForm.taille.value)>0){
       fImc = round(parseFloat(oForm.poid.value) / (parseInt(oForm.taille.value) * parseInt(oForm.taille.value) * 0.0001),2);
       if(fImc < {{if $patient->sexe=="m"}}20{{else}}19{{/if}}){
         sImcValeur = "Maigreur";
       }else if(fImc > {{if $patient->sexe=="m"}}25{{else}}24{{/if}} && fImc <=30){
         sImcValeur = "Surpoids";
       }else if(fImc > 30 && fImc <=40){
         sImcValeur = "Ob�sit�";
       }else if(fImc > 40){
         sImcValeur = "Ob�sit� morbide";
       }
     }
   }
   oForm._vst.value = fVst;
   oForm._imc.value = fImc;
   $('imcValeur').innerHTML = sImcValeur;
   calculPSA(); 
   calculClairance();  
}
</script>

<table class="form">
  <tr>
    <td class="HalfPane">
      <form name="editAnesthPatFrm" action="?m={{$m}}" method="post" onsubmit="return checkForm(this);">
      <input type="hidden" name="m" value="{{$m}}" />
      <input type="hidden" name="del" value="0" />
      <input type="hidden" name="dosql" value="do_consult_anesth_aed" />
      {{mb_field object=$consult_anesth field="consultation_anesth_id" type="hidden" spec=""}}
      <table class="form">
        <tr>
          <th>{{mb_label object=$consult_anesth field="poid"}}</th>
          <td>
            {{mb_field object=$consult_anesth field="poid" tabindex="1" size="4" onchange="javascript:calculImcVst();submitForm(this.form);"}}
            kg
          </td>
          <th>{{mb_label object=$consult_anesth field="tasys"}}</th>
          <td>
            {{mb_field object=$consult_anesth field="tasys" tabindex="3" size="2" onchange="submitForm(this.form);"}}
            /
            {{mb_field object=$consult_anesth field="tadias" tabindex="4" size="2" onchange="submitForm(this.form);"}}
            cm Hg
          </td>
        </tr>
        <tr>
          <th>{{mb_label object=$consult_anesth field="taille"}}</th>
          <td>
            {{mb_field object=$consult_anesth field="taille" tabindex="2" size="4" onchange="javascript:calculImcVst();submitForm(this.form);"}}
            cm
          </td>
          <th>{{mb_label object=$consult_anesth field="pouls"}}</th>
          <td>
            {{mb_field object=$consult_anesth field="pouls" size="4" tabindex="5" onchange="submitForm(this.form);"}}
            / min
          </td>
        </tr>
        <tr>
          <th>{{mb_label object=$consult_anesth field="_vst"}}</th>
          <td class="readonly">
            {{mb_field object=$consult_anesth field="_vst" size="4" type="text" readonly="readonly"}}
            ml
          </td>
          <th>{{mb_label object=$consult_anesth field="spo2"}}</th>
          <td>
            {{mb_field object=$consult_anesth field="spo2" tabindex="6" size="4" onchange="submitForm(this.form);"}}
            %
          </td>
        </tr>
        <tr>
          <th>{{mb_label object=$consult_anesth field="_imc"}}</th>
          <td class="readonly">
            {{mb_field object=$consult_anesth field="_imc" size="4" type="text" readonly="readonly"}}
          </td>
          <td id="imcValeur" colspan="2" style="color:#F00;">{{$consult_anesth->_imc_valeur}}</td>
        </tr>
        </table>
      </form>
    </td>
    <td class="HalfPane">
      <form class="watch" name="editFrmExams" action="?m={{$m}}" method="post" onsubmit="return checkForm(this);">
      <input type="hidden" name="m" value="{{$m}}" />
      <input type="hidden" name="del" value="0" />
      <input type="hidden" name="dosql" value="do_consultation_aed" />
      {{mb_field object=$consult field="consultation_id" type="hidden" spec=""}}
      {{mb_field object=$consult field="_check_premiere" type="hidden" spec=""}}
      {{mb_label object=$consult field="examen"}}
      <select name="_helpers_examen" size="1" onchange="pasteHelperContent(this);this.form.examen.onchange();">
        <option value="">&mdash; Choisir une aide</option>
        {{html_options options=$consult->_aides.examen}}
      </select>
      <button class="new notext" title="Ajouter une aide � la saisie" type="button" onclick="addHelp('CConsultation', this.form.examen)"></button><br />
      {{mb_field object=$consult field="examen" onchange="submitFormAjax(this.form, 'systemMsg')"}}<br />
      </form>
    </td>
  </tr>
</table>      
      
{{include file="inc_consult_anesth/intubation.tpl"}}