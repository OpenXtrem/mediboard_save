<div class="accordionMain" id="accordionConsult">

  <div id="Infos">
    <div id="InfosHeader" class="accordionTabTitleBar">
      Informations sur le patient
    </div>
    <div id="InfosContent"  class="accordionTabContentBox">
      {{include file="inc_patient_infos_accord_consultAnesth.tpl"}}
    </div>
  </div>
  
  <div id="AntTrait">
    <div id="AntTraitHeader" class="accordionTabTitleBar">
      Antécédents / Traitements
    </div>
    <div id="AntTraitContent"  class="accordionTabContentBox">
      {{include file="inc_ant_consult.tpl"}}
    </div>
  </div>

  <div id="Examens">
    <div id="ExamensHeader" class="accordionTabTitleBar">
      Examens
    </div>
    <div id="ExamensContent"  class="accordionTabContentBox">
      <div id="mainConsult">
      {{include file="inc_main_consultform.tpl"}}
      </div>
    </div>
  </div>

  <div id="Intubation">
    <div id="IntubationHeader" class="accordionTabTitleBar">
      Evaluation des conditions d'intubations et Intervention
    </div>
    <div id="IntubationContent"  class="accordionTabContentBox">
      {{include file="inc_intubation.tpl"}}
      <div id="choixAnesth">
      {{include file="inc_type_anesth.tpl"}}
      </div>
    </div>
  </div>
  
  <div id="fdrConsult">
    <div id="fdrConsultHeader" class="accordionTabTitleBar">
      Documents et Réglements
    </div>
    <div id="fdrConsultContent"  class="accordionTabContentBox">
    {{include file="inc_fdr_consult.tpl"}}
    </div>
  </div>

</div>

<script language="Javascript" type="text/javascript">
new Rico.Accordion( $('accordionConsult'), { panelHeight:340 } );
</script>
