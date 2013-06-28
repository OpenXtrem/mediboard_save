{{assign var=pdf_thumbnails value=$conf.dPcompteRendu.CCompteRendu.pdf_thumbnails}}
{{assign var=choice_factory value=$app->user_prefs.choice_factory}}
{{assign var=header_footer_fly value=$conf.dPcompteRendu.CCompteRendu.header_footer_fly}}

{{mb_script module=compteRendu script=thumb}}

<script type="text/javascript">
window.same_print = {{$conf.dPcompteRendu.CCompteRendu.same_print}};
window.pdf_thumbnails = {{$pdf_thumbnails|@json}} == 1;
window.nb_printers = {{$nb_printers|@json}};
window.modal_mode_play = null;
window.documentGraphs = {{$templateManager->graphs|@json}};
window.choice_factory = {{$choice_factory|@json}};

document.title = "{{$compte_rendu->_ref_object}} - {{$compte_rendu->nom}}";

function openCorrespondants(compte_rendu_id, object_guid, show_modal) {
  var url = new Url("dPcompteRendu", "ajax_edit_correspondants_courrier");
  url.addParam("compte_rendu_id", compte_rendu_id);
  url.addParam("object_guid", object_guid);
  url.requestUpdate("correspondants_courrier", {onComplete: function() {
    // Dans le cas o� on est d�connect� lors de l'ouverture de la modale,
    // afficher un bouton afin de fermer la modale
    if (!$('correspondants_area')) {
      var closeButton  = DOM.button({type: "button", className: "close", onClick: "Control.Modal.close()"}, $T('Close'));
      closeButton.innerHTML = $T('Close');
      $("correspondants_courrier").insert({bottom: closeButton })
    }
    
    if (show_modal) {
      Modal.open($("correspondants_courrier"));
    }
  } });
}

function playField(element, class_name, editor_element, name) {
  var modal = $("play_modal");
  var field_area = modal.select("td.field_aera")[0];
  field_area.update();
  
  if (class_name == "name") {
    field_area.insert(new DOM.p({}, name));
  }

  field_area.insert(element);
  modal.select(".tick")[0].onclick = function() { replaceField(element, class_name); };

  // Ajout du double clic sur les options
  if (class_name == "name") {
    element.ondblclick = function() { replaceField(element, class_name); };
  }
  modal.select(".trash")[0].onclick = function() { replaceField(element, class_name, 1); };
  modal.select(".cancel")[0].onclick = function() {
    Control.Modal.close();
    Element.setStyle(editor_element, {backgroundColor: ""});
  }
  
  // R�ouverture si la modale est ferm�e 
  if (!window.modal_mode_play || !window.modal_mode_play.isOpen) {
    window.modal_mode_play = Modal.open(modal, {draggable: modal.select(".title")[0], overlayOpacity: 0.3});
    
    var left = document.viewport.getDimensions().width - window.modal_mode_play.container.getDimensions().width;
    modal.setStyle({top: 0, left: left+"px"});
  }
}

function submitCompteRendu(callback){
  CKEDITOR.instances.htmlarea.document.getBody().setStyle("background", "#ddd");

  var mess = null;
  if (mess=$('mess')) {
    mess.stopObserving("click");
  }
  (function(){
    if (window.pdf_thumbnails && Prototype.Browser.IE) {
      restoreStyle();
    }
    var html = CKEDITOR.instances.htmlarea.getData();
    if (window.pdf_thumbnails && Prototype.Browser.IE) {
      window.save_style = deleteStyle();
    }
    $V($("htmlarea"), html, false);
    
    var form = getForm("editFrm");
    
    if(checkForm(form) && User.id) {
      CKEDITOR.instances.htmlarea.on("key", loadOld);
      form.onsubmit=function(){ return true; };
      if (Thumb.modele_id && Thumb.contentChanged) {
        emptyPDF();
      }
      clearTimeout(window.thumbs_timeout);
      
      var destinataires = $("destinataires");
      
      if (destinataires && destinataires.select("input[checked]").length) {
        $V(form.do_merge, 1);
      }
      
      onSubmitFormAjax(form,{ useDollarV: true, onComplete: function() {
        Thumb.contentChanged = false;
        if ((!window.pdf_thumbnails || window.Preferences.pdf_and_thumbs == 0) && window.opener) {
          if (window.opener.Document.refreshList) {
            window.opener.Document.refreshList($V(form.file_category_id), $V(form.object_class), $V(form.object_id));
          }
          if (window.opener.reloadListFileEditPatient) {
            window.opener.reloadListFileEditPatient("load");
          }
        }
        window.callback = callback ? callback : null;
      }},  $("systemMsg"));
    }
  }).defer();
  
}

function refreshZones(id, obj) {
  var form = getForm("editFrm");
  $V(form.date_print, obj.date_print);
  
  if (Preferences.multiple_docs == "1" && id) {
    window.name = "cr_"+id;
  }
  
  var afterSetData = function() {
    // Dans le cas de la g�n�ration d'un document par correspondant,
    // mise � jour du nom du document dans la popup
    $V(getForm("editFrm").nom, obj.nom);
    $V(getForm("download-pdf-form")._ids_corres, obj._ids_corres);
    $V(getForm("download-pdf-form").compte_rendu_id, id);
    
    var refresh = function(){};
    if (window.pdf_thumbnails && window.Preferences.pdf_and_thumbs == 1) {
      Thumb.compte_rendu_id = id;
      Thumb.modele_id = 0;
      refresh = function() { window.thumbs_timeout = setTimeout(function() {
        Thumb.refreshThumbs(0, Thumb.print);
      }, 0)};
    }
    
    var url = new Url("dPcompteRendu", "edit_compte_rendu");
    url.addParam("compte_rendu_id", id);
    url.addParam("reloadzones", 1);
    url.requestUpdate("reloadzones",
        {onComplete: function(){
           refresh();
           window.resizeEditor();
           var form = getForm("editFrm");
           $V(form.compte_rendu_id, id);
           if (Thumb.print) {
             pdfAndPrintServer(id);
           }
           else if (window.callback){
             window.callback();
           }
           form.onsubmit = function() { Url.ping({onComplete: submitCompteRendu}); return false;};
    }});
  }
    
  // Remise du content sauvegard�, avec le refresh des vignettes si dispo, et/ou l'impression en callback
  CKEDITOR.instances.htmlarea.setData(obj._source, afterSetData);
}

function openWindowMail() {
  {{if $exchange_source->_id}}
    var form = getForm("editFrm");
    var url = new Url("dPcompteRendu", "ajax_view_mail");
    url.addParam("object_guid", "CCompteRendu-"+$V(form.compte_rendu_id));
    url.requestModal(700, 320);
  {{else}}
    alert("Veuillez param�trer votre compte mail (source smtp dans les pr�f�rences utilisateur).");
  {{/if}}
}

function openWindowApicrypt() {
  {{if $exchange_source->_id}}
    var form = getForm("editFrm");
    var url = new Url("apicrypt", "ajax_view_apicrypt_mail");
    url.addParam("object_id", '{{$compte_rendu->object_id}}');
    url.addParam("object_class", '{{$compte_rendu->object_class}}');
    url.addParam("doc_id", $V(form.compte_rendu_id));
    url.requestModal(700, 320);
  {{else}}
    alert("Veuillez param�trer votre compte mail (source smtp dans les pr�f�rences utilisateur).");
  {{/if}}
}

function openModalPrinters() {
  // Mise � jour de la date d'impression
  $V(getForm("editFrm").date_print, "now");
  window.modalPrinters = new Url("dPcompteRendu", "ajax_choose_printer");
  modalPrinters.requestModal(700, 400);
}

{{if $pdf_thumbnails && $app->user_prefs.pdf_and_thumbs}}

  togglePageLayout = function() {
    $("page_layout").toggle();
  }
  
  completeLayout = function() {
    var tab_margin = ["top", "right", "bottom", "left"];
    var form = getForm("editFrm");
    var dform = getForm('download-pdf-form');
    for(var i=0; i < 4; i++) {
      if ($("input_margin_"+tab_margin[i])) {
        $("input_margin_"+tab_margin[i]).remove();
      }
      dform.insert({bottom: new Element("input",{id: "input_margin_"+tab_margin[i],type: 'hidden', name: 'margins[]', value: $("editFrm_margin_"+tab_margin[i]).value})});
    }
    $V(dform.orientation, $V(form._orientation));
    $V(dform.page_format, form._page_format.value);
  }
  
  save_page_layout = function() {
    page_layout_save = { 
      margin_top:    PageFormat.form.margin_top.value,
      margin_left:   PageFormat.form.margin_left.value,
      margin_right:  PageFormat.form.margin_right.value,
      margin_bottom: PageFormat.form.margin_bottom.value,
      page_format:   PageFormat.form._page_format.value,
      page_width:    PageFormat.form.page_width.value,
      page_height:   PageFormat.form.page_height.value,
      orientation:   $V(PageFormat.form._orientation)
    };
  }
  
  cancel_page_layout = function() {
    $V(PageFormat.form.margin_top,    page_layout_save.margin_top);
    $V(PageFormat.form.margin_left,   page_layout_save.margin_left);
    $V(PageFormat.form.margin_right,  page_layout_save.margin_right);
    $V(PageFormat.form.margin_bottom, page_layout_save.margin_bottom);
    $V(PageFormat.form._page_format,  page_layout_save.page_format);
    $V(PageFormat.form.page_height,   page_layout_save.page_height);
    $V(PageFormat.form.page_width,    page_layout_save.page_width);
    $V(PageFormat.form._orientation,  page_layout_save.orientation);

    if(Thumb.thumb_up2date && !Thumb.changed) {
      Thumb.thumb_up2date = true;
      $('mess').hide();
      $('thumbs').setOpacity(1);
    }
    Control.Modal.close();
  }

  emptyPDF = function() {
    Thumb.old();
    
    // La requ�te de vidage de pdf doit �tre faite dans le scope
    // de la fen�tre principale, car on est en train de fermer la popup
    var f = getForm("download-pdf-form");

    if (Prototype.Browser.IE) {
      var url = new Url();
    }
    else {
      var url = new window.opener.Url();
    }
    url.addParam("m", "dPcompteRendu");
    url.addParam("dosql", "do_modele_aed");
    url.addParam("_do_empty_pdf", 1);
    url.addParam("compte_rendu_id", $V(f.compte_rendu_id));
    
    url.requestJSON(function(){}, {method: "post"});
  }
{{/if}}

function saveAndMerge() {
  Control.Modal.close();
  var form = getForm('editFrm');
  $V(form.do_merge, 1);
  form.onsubmit();
}

function toggleLock(button) {
  var form = button.form;
  $V(form.valide, $V(form.valide) == 1 ? 0 : 1);
  var classes = Element.classNames(button);
  classes.flip('lock', 'unlock');
  form.onsubmit();
}

function modalHeaderFooter(state) {
  var form = getForm("editFrm");
  if (state) {
    window.save_header_id = $V(form.header_id);
    window.save_footer_id = $V(form.footer_id);
    Modal.open("header_footer_fly");
  }
  else {
    Control.Modal.close();
    $V(form.header_id, window.save_header_id);
    $V(form.footer_id, window.save_footer_id);
  }
}

function duplicateDoc(form) {
  $V(form.modele_id, $V(form.compte_rendu_id));
  $V(form.compte_rendu_id, '');
  CKEDITOR.instances.htmlarea.element.$.disabled=false;
  CKEDITOR.instances.htmlarea.element.$.contentEditable=true;
  CKEDITOR.instances.htmlarea.element.$.designMode="On";
  $V(form.callback, "afterDuplicate");
  form.onsubmit();
}

function afterDuplicate(cr_id) {
  window.opener.Document.edit(cr_id);
  window.close();
}

Main.add(function(){
  if (window.pdf_thumbnails && window.Preferences.pdf_and_thumbs == 1) {
    PageFormat.init(getForm("editFrm"));
    Thumb.compte_rendu_id = '{{$compte_rendu->_id}}';
    Thumb.modele_id = '{{$modele_id}}';
    Thumb.user_id = '{{$user_id}}';
    Thumb.mode = "doc";
    Thumb.object_class = '{{$compte_rendu->object_class}}';
    Thumb.object_id = '{{$compte_rendu->object_id}}';
  }
  
  // Les correspondants doivent �tre pr�sent pour le store du compte-rendu
  // Chargement en arri�re-plan de la modale
  {{if $isCourrier}}
    openCorrespondants('{{$compte_rendu->_id}}', '{{$compte_rendu->_ref_object->_guid}}', 0);
  {{/if}}
  
  window.onbeforeunload = function(e) {
    e = e || window.event;
    
    if (Thumb.contentChanged == false) return;

    if (window.pdf_thumbnails && window.Preferences.pdf_and_thumbs == 1 && Thumb.contentChanged == true) {
      emptyPDF();
    }
    
    if (e) {
      e.returnValue = ' ';
    }
    
    return ' ';
  };
  
  var htmlarea = $('htmlarea');
  
  // documentGraphs est un tableau si vide ($H donnera les mauvaises cl�s), un objet sinon
  if (documentGraphs.length !== 0) {
    $H(documentGraphs).each(function(pair){
      var g = pair.value;
      $('graph-container').update();
      g.options.fontSize = 14;
      g.options.resolution = 2;
      g.options.legend = {
        labelBoxWidth: 28,
        labelBoxHeight: 20
      };
      g.options.pie.explode = 0;
      var f = new Flotr.Graph($('graph-container'), g.data, g.options);
      g.dataURL = f.canvas.toDataURL();
      oFCKeditor.value = htmlarea.value = htmlarea.value.replace('<'+'span class="field">'+g.name+'</'+'span>', '<'+'img src="'+g.dataURL+'" width="450" height="300" /'+'>');
    });
  }
  
  {{if !$compte_rendu->_id && $switch_mode == 1}}
    if (window.opener.saveFields) {
      from = window.opener.saveFields;
      var to = getForm("editFrm");
      if (from[0].any(function(elt){ return elt.size > 1; })) {
        toggleOptions();
      }
      from.each(function(elt) {
        elt.each(function(select) {
          if (select) {
            $V(to[select.name], $V(select));
          }
        })
      });
    }
  {{/if}}
});

</script>

<iframe name="download_pdf" style="width: 0; height: 0; position: absolute; top: -1000px;">
</iframe>

<div style="position: absolute; top: -1500px;">
  <div style="position: relative; width: 900px; height: 600px;" id="graph-container"></div>
</div>

<!-- Modale pour le mode play -->
<div style="display: none; width: 500px; height: 450px;" id="play_modal">
  <table class="form">
  <tr>
    <th class="title">
      {{tr}}CCompteRendu-mode_play{{/tr}}
    </th>
  </tr>
    <tr>
      <td class="field_aera" style="padding-top: 10px;">
      </td>
    </tr>
    <tr>
      <td style="text-align: center;">
        <button class="tick">{{tr}}CCompteRendu-apply_field{{/tr}}</button>
        <button class="trash">{{tr}}CCompteRendu-empty_field{{/tr}}</button>
        <button class="cancel">{{tr}}CCompteRendu-close{{/tr}}</button>
      </td>
    </tr>
  </table>
</div>

<!-- Formulaire d'ajout de correspondant courrier par autocomplete -->
<form name="addCorrespondant" method="post">
  <input type="hidden" name="m" value="dPcompteRendu" />
  <input type="hidden" name="dosql" value="do_correspondant_courrier_aed" />
  <input type="hidden" name="correspondant_courrier_id" />
  <input type="hidden" name="compte_rendu_id" value="" />
  <input type="hidden" name="object_class" value="CMedecin" />
  <input type="hidden" name="tag" value="correspondant" />
  <input type="hidden" name="object_id" />
</form>


<form name="addCorrespondantToDossier" method="post">
  <input type="hidden" name="m" value="dPpatients"/>
  <input type="hidden" name="dosql" value="do_correspondant_aed" />
  <input type="hidden" name="patient_id" value="" />
  <input type="hidden" name="medecin_id" value="" />
</form>


<!-- Formulaire pour l'impression server side -->
<form name="print-server" method="post" action="?m=dPcompteRendu&amp;ajax_print_server">
  <input type="hidden" name="content" value=""/>
  <input type="hidden" name=""/>
</form>

<!-- Zone cach�e pour la g�n�ration PDF et l'impression server side -->
<div id="pdf_area" style="display: none;"></div>


<!-- Formulaire pour streamer le pdf -->
<form style="display: none;" name="download-pdf-form" target="{{if $choice_factory == "CDomPDFConverter"}}download_pdf{{else}}_blank{{/if}}" method="post" action="?m=dPcompteRendu&amp;a=ajax_pdf"
      onsubmit="{{if $pdf_thumbnails && $app->user_prefs.pdf_and_thumbs}}completeLayout();{{/if}} this.submit();">
  <input type="hidden" name="content" value=""/>
  <input type="hidden" name="compte_rendu_id" value='{{if $compte_rendu->_id != ''}}{{$compte_rendu->_id}}{{else}}{{$modele_id}}{{/if}}' />
  <input type="hidden" name="object_id" value="{{$compte_rendu->object_id}}"/>
  <input type="hidden" name="suppressHeaders" value="1"/>
  <input type="hidden" name="stream" value="1"/>
  <input type="hidden" name="page_format" value=""/>
  <input type="hidden" name="orientation" value=""/>
  <input type="hidden" name="_ids_corres" value="" />
</form>

<form name="editFrm" action="?m={{$m}}" method="post"
      onsubmit="Url.ping({onComplete: submitCompteRendu}); return false;" 
      class="{{$compte_rendu->_spec}}">
  <input type="hidden" name="m" value="dPcompteRendu" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="dosql" value="do_modele_aed" />
  <input type="hidden" name="function_id" value="" />
  <input type="hidden" name="user_id" value="" />
  <input type="hidden" name="group_id" value="" />
  <input type="hidden" name="switch_mode" value='{{$switch_mode}}'/>
  <input type="hidden" name="date_print" value="{{$compte_rendu->date_print}}" />
  <input type="hidden" name="do_merge" value="0" />
  <input type="hidden" name="purge_field" value="{{$compte_rendu->purge_field}}" />
  <input type="hidden" name="callback" value="refreshZones" />
  
  {{mb_key object=$compte_rendu}}
  {{mb_field object=$compte_rendu field="object_id" hidden=1}}
  {{mb_field object=$compte_rendu field="object_class" hidden=1}}
  {{mb_field object=$compte_rendu field="modele_id" hidden=1}}
  {{mb_field object=$compte_rendu field="font" hidden=1}}
  {{mb_field object=$compte_rendu field="size" hidden=1}}
  {{mb_field object=$compte_rendu field="valide" hidden=1}}

  {{if $header_footer_fly}}
    <div id="header_footer_fly" class="modal" style="display: none">
      <table class="tbl">
        <tr>
          <th>
            {{mb_label object=$compte_rendu field=header_id}} :
          </th>
          {{if $headers|@count && ($headers.prat|@count > 0 || $headers.func|@count > 0 || $headers.etab|@count > 0)}}
            <td>
              <select name="header_id" onchange="Thumb.old();" class="{{$compte_rendu->_props.header_id}}" style="width: 15em;">
                <option value="" {{if !$compte_rendu->header_id}}selected{{/if}}>&mdash; {{tr}}CCompteRendu-set-header{{/tr}}</option>
                {{foreach from=$headers item=headersByOwner key=owner}}
                  {{if $headersByOwner|@count}}
                    <optgroup label="{{tr}}CCompteRendu._owner.{{$owner}}{{/tr}}">
                      {{foreach from=$headersByOwner item=_header}}
                        <option value="{{$_header->_id}}" {{if $compte_rendu->header_id == $_header->_id}}selected="selected"{{/if}}>{{$_header->nom}}</option>
                        {{foreachelse}}
                        <option value="" disabled="disabled">{{tr}}None{{/tr}}</option>
                      {{/foreach}}
                    </optgroup>
                  {{/if}}
                {{/foreach}}
              </select>
            </td>
          {{else}}
            <td class="empty">
              {{mb_field object=$compte_rendu field=header_id hidden=1}}
              Pas d'ent�te
            </td>
          {{/if}}
        </tr>
        <tr>
          <th>
            {{mb_label object=$compte_rendu field=footer_id}} :
          </th>
          {{if $footers|@count && ($footers.prat|@count > 0 || $footers.func|@count > 0 || $footers.etab|@count > 0)}}
            <td>
              <select name="footer_id" onchange="Thumb.old();" class="{{$compte_rendu->_props.footer_id}}" style="width: 15em;">
                <option value="" {{if !$compte_rendu->footer_id}}selected{{/if}}>&mdash; {{tr}}CCompteRendu-set-footer{{/tr}}</option>
                {{foreach from=$footers item=footersByOwner key=owner}}
                  {{if $footersByOwner|@count}}
                    <optgroup label="{{tr}}CCompteRendu._owner.{{$owner}}{{/tr}}">
                      {{foreach from=$footersByOwner item=_footer}}
                        <option value="{{$_footer->_id}}" {{if $compte_rendu->footer_id == $_footer->_id}}selected="selected"{{/if}}>{{$_footer->nom}}</option>
                        {{foreachelse}}
                        <option value="" disabled="disabled">{{tr}}None{{/tr}}</option>
                      {{/foreach}}
                    </optgroup>
                  {{/if}}
                {{/foreach}}
              </select>
            </td>
          {{else}}
            <td class="empty">
              {{mb_field object=$compte_rendu field=footer_id hidden=1}}
              Pas de pied de page
            </td>
          {{/if}}
        </tr>
        <tr>
          <td class="button" colspan="2">
            <button type="button" class="tick" onclick="Control.Modal.close()">{{tr}}Validate{{/tr}}</button>
            <button type="button" class="cancel" onclick="modalHeaderFooter(0);">{{tr}}Close{{/tr}}</button>
          </td>
        </tr>
      </table>
    {{/if}}
  </div>

  <table class="form">
    <tr>
    <th class="category" colspan="2">
      {{if $compte_rendu->_id}}
        <a style="float: left;" class="button left {{if !$prevnext.prev}}disabled{{/if}}"
          {{if $prevnext.prev}}
            href="?m=compteRendu&a=edit_compte_rendu&compte_rendu_id={{$prevnext.prev}}&dialog=1"
          {{/if}}>
          {{tr}}Previous{{/tr}}
        </a>
        <a style="float: right;" class="button right {{if !$prevnext.next}}disabled{{/if}}"
          {{if $prevnext.next}}
            href="?m=compteRendu&a=edit_compte_rendu&compte_rendu_id={{$prevnext.next}}&dialog=1"
          {{/if}}>
          {{tr}}Next{{/tr}}
        </a>
        {{mb_include module=system template=inc_object_idsante400 object=$compte_rendu}}
        {{mb_include module=system template=inc_object_history object=$compte_rendu}}
      {{/if}}
      {{mb_label object=$compte_rendu field=nom}}
      {{mb_field object=$compte_rendu field=nom}}
      
      &mdash;
      {{mb_label object=$compte_rendu field=file_category_id}}
      <select name="file_category_id" style="width: 8em;">
        <option value=""{{if !$compte_rendu->file_category_id}} selected="selected"{{/if}}>&mdash; Aucune</option>
        {{foreach from=$listCategory item=currCat}}
          <option value="{{$currCat->file_category_id}}"{{if $currCat->file_category_id==$compte_rendu->file_category_id}} selected="selected"{{/if}}>{{$currCat->nom}}</option>
        {{/foreach}}
      </select>
      
      &mdash;
      <label>
        {{tr}}CCompteRendu-private{{/tr}}
        {{mb_field object=$compte_rendu field=private typeEnum="checkbox"}}
      </label>
      {{if $pdf_thumbnails && $app->user_prefs.pdf_and_thumbs}}
        &mdash;
        <button type="button" class="pagelayout notext" title="{{tr}}CCompteRendu-Pagelayout{{/tr}}"
                onclick="save_page_layout(); Modal.open($('page_layout'), {
                closeOnClick: $('page_layout').down('button.tick')
                });">
        </button>
        {{if $compte_rendu->_id != null}}
          &mdash;
          <button class="hslip" type="button" title="Afficher / Masquer les vignettes"
                  onclick = "Thumb.choixAffiche(1);">Vignettes</button>
        {{/if}}
        <div id="page_layout" style="display: none;">
          {{mb_include module=compteRendu template=inc_page_layout droit=1}}
          <button class="tick" type="button">{{tr}}Validate{{/tr}}</button>
          <button class="cancel" type="button" onclick="cancel_page_layout();">{{tr}}Cancel{{/tr}}</button>
        </div>
      {{/if}}
      {{if $header_footer_fly}}
        &mdash;
        <button type="button" class="header_footer notext" onclick="modalHeaderFooter(1)"
          title="Ent�te / pied de page � la vol�e"></button>
      {{/if}}
      {{if $can_lock}}
        &mdash;
        <button type="button" class="{{if $compte_rendu->valide}}unlock{{else}}lock{{/if}} notext"
                onclick="toggleLock(this)">Verrouiller / D�verouiller le document</button>
      {{/if}}
      {{if $compte_rendu->_id}}
        <button type="button" class="add" onclick="duplicateDoc(this.form)">Dupliquer le document</button>
      {{/if}}
    </th>
  </tr>

  <tr>
    <td colspan="2">
      <div id="reloadzones">
        {{mb_include module=compteRendu template=inc_zones_fields}}
      </div>
    </td>
  </tr>

  {{if $compte_rendu->_id && $conf.dPfiles.system_sender}}
  <tr>
    <th style="width: 50%">
      <script type="text/javascript">
        refreshSendButton = function() {
          var url = new Url("dPfiles", "ajax_send_button");
          url.addParam("item_guid", "{{$compte_rendu->_guid}}");
          url.addParam("onComplete", "refreshSendButton()");
          url.requestUpdate("sendbutton");
          refreshList();
        }
      </script>
      <label title="{{tr}}config-dPfiles-system_sender{{/tr}}">
        {{tr}}config-dPfiles-system_sender{{/tr}}
        <em>({{tr}}{{$conf.dPfiles.system_sender}}{{/tr}})</em>
      </label>
    </th>
    <td id="sendbutton">
      {{mb_include module=files template=inc_file_send_button 
                   _doc_item=$compte_rendu
                   onComplete="refreshSendButton()"
                   notext=""}}
    </td>
  </tr>
  {{/if}}
  <tr>
    <td class = "greedyPane" style="width: 1200px;"
      {{if $pdf_thumbnails && $app->user_prefs.pdf_and_thumbs}}
        colspan="1"
      {{else}}
        colspan="2"
      {{/if}} id="editeur">
      <textarea id="htmlarea" name="_source">
        {{$templateManager->document}}
      </textarea>
    </td>
    {{if $pdf_thumbnails && $app->user_prefs.pdf_and_thumbs}}
      <td id="thumbs_button" class="narrow">
        <div id="mess" class="oldThumbs opacity-60" style="display: none;">
        </div>
        <div id="thumbs" style="overflow: auto; overflow-x: hidden; width: 160px; text-align: center; white-space: normal;">
        </div>
      </td>
    {{/if}}
  </tr>  
</table>
</form>