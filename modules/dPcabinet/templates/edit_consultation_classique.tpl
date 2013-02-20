{{if "dPprescription"|module_active}}
  {{mb_script module="dPprescription" script="prescription"}}
  {{mb_script module="dPprescription" script="prescription_editor"}}
{{/if}}

{{mb_script module="dPcompteRendu" script="document"}}
{{mb_script module="dPcompteRendu" script="modele_selector"}}
{{mb_script module="dPcabinet" script="edit_consultation"}}

<script type="text/javascript">
{{if !$consult->_canEdit}}
  App.readonly = true;
{{/if}}

function printAllDocs() {
  var url = new Url("dPcabinet", "print_select_docs"); 
  url.addElement(document.editFrmFinish.consultation_id);
  url.popup(700, 500, "printDocuments");
}

function submitAll() {
  onSubmitFormAjax(getForm("editFrmExams"));
}

Main.add(function () {
  ListConsults.init("{{$consult->_id}}", "{{$userSel->_id}}", "{{$date}}", "{{$vue}}", "{{$current_m}}");
} );

</script>


<table class="main">
  <tr>
    <td id="listConsult" style="width: 240px;"></td>
    <td>
      {{if $consult->_id}}
        {{assign var="patient" value=$consult->_ref_patient}}

        <div id="finishBanner">
          {{mb_include module=cabinet template=inc_finish_banner}}
        </div>

        <div id="Infos">
          {{mb_include module=cabinet template=inc_patient_infos_accord_consult}}
        </div>

        <div id="mainConsult">
          {{mb_include module=cabinet template=inc_main_consultform}}
        </div>

        <div id="fdrConsult">
          {{mb_include module=cabinet template=inc_fdr_consult}}
        </div>

        <!-- Reglement -->
        {{mb_script module="dPcabinet" script="reglement"}}
        <script type="text/javascript">
          Reglement.consultation_id = '{{$consult->_id}}';
          Reglement.user_id = '{{$userSel->_id}}';
          Reglement.register('{{$consult->_id}}');
        </script>
      
      {{/if}}
    </td>
  </tr>
</table>
