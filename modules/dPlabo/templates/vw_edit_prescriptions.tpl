<script type="text/javascript">

function popPat() {
  var url = new Url();
  url.setModuleAction("dPpatients", "pat_selector");
  url.popup(500, 500, "Patient");
}

function setPat( key, val ) {
  var oForm = document.patFrm;
  if (val != '') {
    oForm.patient_id.value = key;
    oForm.patNom.value = val;
  }
  oForm.submit();
}

var Catalogue = {
  select : function(iCatalogue) {
    if(isNaN(iCatalogue)) {
      iCatalogue = 0;
      oForm = $('currCatalogue');
      if(oForm) {
        iCatalogue = oForm.catalogue_labo_id.value;
      }
    }
    var url = new Url;
    url.setModuleAction("dPlabo", "httpreq_vw_catalogues");
    if(iCatalogue) {
      url.addParam("catalogue_labo_id", iCatalogue);
    }
    url.addParam("typeListe", getCheckedValue(document.typeListeFrm.typeListe));
    url.requestUpdate('listExamens', { waitingText : null });
  }
}

var Pack = {
  select : function(pack_id) {
    if(isNaN(pack_id)) {
      pack_id = 0;
      oForm = $('newPackItem');
      if(oForm) {
        pack_id = oForm.pack_examens_labo_id.value;
      }
    }
    var url = new Url;
    url.setModuleAction("dPlabo", "httpreq_vw_packs");
    if(pack_id) {
      url.addParam("pack_examens_labo_id", pack_id);
    }
    url.addParam("dragPacks", 1);
    url.addParam("typeListe", getCheckedValue(document.typeListeFrm.typeListe));
    url.requestUpdate("listExamens", { waitingText: null });
  },
  delExamen: function(oForm) {
    oFormBase = $('newPackItem');
    oFormBase.pack_examens_labo_id.value = oForm.pack_examens_labo_id.value;
    submitFormAjax(oForm, 'systemMsg', { onComplete: Pack.select });
    return true;
  }
}

var Prescription = {
  select : function(prescription_id) {
    if(isNaN(prescription_id)) {
      prescription_id = 0;
      oForm = document.editPrescriptionItem;
      if(oForm) {
        prescription_id = oForm.prescription_labo_id.value;
      }
    }
    var iPatient_id = document.patFrm.patient_id.value;
    var url = new Url;
    url.setModuleAction("dPlabo", "httpreq_vw_prescriptions");
    if(prescription_id) {
      url.addParam("prescription_labo_id", prescription_id);
    }
    url.addParam("patient_id"          , iPatient_id    );
    url.requestUpdate('listPrescriptions', { waitingText: null });
  },
  
  create : function() {
    var oPatientForm = document.patFrm;
    if(!oPatientForm.patient_id.value) {
      return false;
    }
    var oForm = document.editPrescription
    oForm.praticien_id.value = {{$app->user_id}};
    oForm.patient_id.value = oPatientForm.patient_id.value
    oForm.date.value = new Date().toDATETIME();
    submitFormAjax(oForm, 'systemMsg', { onComplete: Prescription.select });
    return true;
  },
  
  delExamen: function(oForm) {
    oFormBase = document.editPrescriptionItem;
    oFormBase.prescription_labo_id.value = oForm.prescription_labo_id.value;
    submitFormAjax(oForm, 'systemMsg', { onComplete: Prescription.select });
    return true;
  },
  
  editExamen: function() {
    oFormBase = document.editPrescriptionItem;
  },
  
  dropExamen: function(sExamen_id, prescription_id) {
    oFormBase = document.editPrescriptionItem;
    aExamen_id = sExamen_id.split("-");
    if(aExamen_id[0] == "examen") {
      oFormBase.dosql.value = "do_prescription_examen_aed";
      oFormBase.examen_labo_id.value = aExamen_id[1];
    } else if(aExamen_id[0] == "pack") {
      oFormBase.dosql.value = "do_prescription_pack_add";
      oFormBase._pack_examens_labo_id.value = aExamen_id[1];
    }
    oFormBase.prescription_labo_id.value = prescription_id;
    submitFormAjax(oFormBase, 'systemMsg', { onComplete: Prescription.select });
    return true;
  }
}

var Resultat = {
  select: function() {
    Console.trace("Mode Résultats");
  }
}

var oDragOptions = { 
  revert: true,
  ghosting: true,
  starteffect : function(element) { 
    Element.classNames(element).add("dragged");
    new Effect.Opacity(element, { duration:0.2, from:1.0, to:0.7 }); 
  },
  reverteffect: function(element, top_offset, left_offset) {
    var dur = Math.sqrt(Math.abs(top_offset^2)+Math.abs(left_offset^2))*0.02;
    element._revert = new Effect.Move(element, { 
      x: -left_offset, 
      y: -top_offset, 
      duration: dur,
      afterFinish : function (effect) { 
        Element.classNames(effect.element.id).remove("dragged");
      }
    } );
  },
  endeffect: function(element) { 
    new Effect.Opacity(element, { duration:0.2, from:0.7, to:1.0 } ); 
  }
}

function pageMain() {
  Prescription.select();
  window[getCheckedValue(document.typeListeFrm.typeListe)].select();
}

</script>

<table class="main">
  <tr>
    <th>

      <form name="patFrm" action="index.php" method="get">
      <table class="form">
        <tr>
          <th>
            <label for="patNom" title="Merci de choisir un patient pour voir son dossier">Choix du patient</label>
          </th>
          <td class="readonly">
            <button class="new" type="button" style="float: right;"onclick="Prescription.create();">
              Nouvelle prescription
            </button>
            <input type="hidden" name="m" value="dPlabo" />
            <input type="hidden" name="patient_id" value="{{$patient->_id}}" />
            <input type="text" readonly="readonly" name="patNom" value="{{$patient->_view}}" />
            <button class="search" type="button" onclick="popPat()">Chercher</button>
          </td>
        </tr>
      </table>
      </form>

      <form name="editPrescription" action="?m={{$m}}" method="post" onsubmit="return checkForm(this)">
        <input type="hidden" name="m" value="dPlabo" />
        <input type="hidden" name="dosql" value="do_prescription_aed" />
        <input type="hidden" name="prescription_labo_id" value="" />
        <input type="hidden" name="praticien_id" value="" />
        <input type="hidden" name="patient_id" value="" />
        <input type="hidden" name="date" value="" />
        <input type="hidden" name="del" value="0" />
      </form>

    </th>
    <th>
      <form name="typeListeFrm" action="?" method="get">
      <table class="form">
        <tr>
          <td>
            <input type="hidden" name="m" value="dPlabo" />
            <input type="radio" name="typeListe" value="Pack" {{if $typeListe == "Pack" || $typeListe == ""}}checked="checked"{{/if}} onchange="window[this.value].select();" />
            <label for="typeListe_Pack">affichage des packs</label>
            <input type="radio" name="typeListe" value="Catalogue" {{if $typeListe == "Catalogue"}}checked="checked"{{/if}} onchange="window[this.value].select();" />
            <label for="typeListe_Catalogue">affichage des catalogues</label>
            <input type="radio" name="typeListe" value="Resultat" {{if $typeListe == "Resultat"}}checked="checked"{{/if}} onchange="window[this.value].select();" />
            <label for="typeListe_Resultat">remplissage des résultats</label>
          </td>
        </tr>
      </table>
      </form>
    </th>
  </tr>
  <tr>
    <td class="halfPane" id="listPrescriptions">
    </td>
    <td class="halfPane" id="listExamens">
    </td>
  </tr>
</table>