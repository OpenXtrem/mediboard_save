{{assign var=pdf_thumbnails value=$conf.dPcompteRendu.CCompteRendu.pdf_thumbnails}}

// Preloading extra plugins
CKEDITOR.plugins.addExternal("mbheader"   , "../../modules/dPcompteRendu/fcke_plugins/mbheader/plugin.js");
CKEDITOR.plugins.addExternal("mbfooter"   , "../../modules/dPcompteRendu/fcke_plugins/mbfooter/plugin.js");
CKEDITOR.plugins.addExternal("mbfields"   , "../../modules/dPcompteRendu/fcke_plugins/mbfields/plugin.js");
CKEDITOR.plugins.addExternal("mbfreetext" , "../../modules/dPcompteRendu/fcke_plugins/mbfreetext/plugin.js");
CKEDITOR.plugins.addExternal("mbhelpers"  , "../../modules/dPcompteRendu/fcke_plugins/mbhelpers/plugin.js");
CKEDITOR.plugins.addExternal("mblists"    , "../../modules/dPcompteRendu/fcke_plugins/mblists/plugin.js");
/*CKEDITOR.plugins.addExternal("mbplay"     , "../../modules/dPcompteRendu/fcke_plugins/mbplay/plugin.js");*/
CKEDITOR.plugins.addExternal("mbprint"    , "../../modules/dPcompteRendu/fcke_plugins/mbprint/plugin.js");
CKEDITOR.plugins.addExternal("mbprinting" , "../../modules/dPcompteRendu/fcke_plugins/mbprinting/plugin.js");
CKEDITOR.plugins.addExternal("mbprintPDF" , "../../modules/dPcompteRendu/fcke_plugins/mbprintPDF/plugin.js");
CKEDITOR.plugins.addExternal("mbpagebreak", "../../modules/dPcompteRendu/fcke_plugins/mbpagebreak/plugin.js");
CKEDITOR.plugins.addExternal("mblineheight", "../../modules/dPcompteRendu/fcke_plugins/mblineheight/plugin.js");



// CK editor general configuration
CKEDITOR.editorConfig = function(config) {
  config.skin = "v2";
  config.language = 'fr';
  config.defaultLanguage = 'fr';
  config.contentsLanguage = 'fr';
  config.enterMode = CKEDITOR.ENTER_BR;
  config.pasteFromWordPromptCleanup = true;
  config.pasteFromWordRemoveFontStyles = true; 
  config.fontSize_sizes = 'xx-small/xx-small;x-small/x-small;small/small;medium/medium;large/large;x-large/x-large;xx-large/xx-large';
  config.contentsCss = "style/mediboard/htmlarea.css?build={{$version.build}}";
  config.docType = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">';
  config.filebrowserImageBrowseUrl = "lib/kcfinder/browse.php?type=image";
  config.resize_maxWidth = "100%";
  config.resize_minWidth = "100%";
  // Suppression du redimensionnement manuel
  config.resize_enabled = false;
  // Suppression du bouton de masquage des barres d'outils
  config.toolbarCanCollapse = false;
  // Suppression de la barre d'�tat avec la dom
  config.removePlugins = 'elementspath';
  {{if $templateManager->printMode}}
    config.toolbar_Full = [['Preview', 'Print', '-','Find']];

  {{elseif $templateManager->simplifyMode}}
    config.toolbar_Full = [
        ['Save', 'Preview'],
        ['Font', 'FontSize'],
        ['Bold', 'Italic', 'Underline', '-', 'Subscript', 'Superscript'],
        ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'],
        ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent'],
        ['TextColor', 'BGColor']
      ];
  {{else}}
    {{if $app->user_prefs.saveOnPrint}}
      var textForPrint = 'mbprint';
    {{else}}
      var textForPrint = 'Print';
    {{/if}}
    
    config.extraPlugins = 'mbfields,mbfreetext,mbhelpers,mblists,mbprint,mbprintPDF,mbheader,mbfooter,mbpagebreak,mblineheight{{if "printing"|module_active && !$templateManager->isModele}},mbprinting{{/if}}';
    config.toolbar_Full = [
      ['Save','Preview'], [{{if $pdf_thumbnails == 1}}'mbprintPDF',{{/if}} textForPrint, 'mbprinting', 'SelectAll', 'Cut', 'Copy', 'PasteText', 'PasteFromWord', 'Undo','Redo', 'Find'],
      [{{if !$templateManager->isModele}}'mbheader', 'mbfooter',{{/if}} 'mbpagebreak'],
      ['Table','HorizontalRule','Image','SpecialChar'],
      ['Maximize', 'Source'], '/',
      ['Font', 'FontSize'],
      ['RemoveFormat', 'Bold', 'Italic', 'Underline', 'Strike'],
      ['Subscript', 'Superscript', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', 'NumberedList', 'BulletedList'],
      ['Outdent', 'Indent', 'mblineheight', 'TextColor', 'BGColor'],'/',
      ['mbfields', {{if $templateManager->isModele}}'mblists', 'mbfreetext', {{/if}}'mbhelpers']];

    window.parent.fields = [];
    window.parent.listeChoix = [];
    window.parent.helpers = [];

    // Champs
    var aOptionsFields = [];

    window.parent.fields.push({
      commandName: "MbField",
      spanClass: {{if $templateManager->valueMode}} "value" {{else}} "field" {{/if}},
      commandLabel: "Champs",
      options: aOptionsFields
    });

    {{assign var=i value=0}}
    {{foreach from=$templateManager->sections key=title item=section}}
    
      aOptionsFields[{{$i}}] = [];
  {{assign var=j value=0}}
  {{foreach from=$section item=property key=_index}}
    {{if strpos($_index, ' - ') === false}}
      aOptionsFields[{{$i}}][{{$j}}] = [
      {{foreach from=$property item=_property name=subproperty}}
        {
        section: "{{$title|smarty:nodefaults|escape:"htmlall"|escape:"javascript"}}",
        itemname: "{{$_index|smarty:nodefaults|escape:"htmlall"|escape:"javascript"}}",
        view: "{{$_property.view|smarty:nodefaults|escape:"javascript"}}" ,
        item: 
          {{if $templateManager->valueMode}}
            "{{$_property.value|smarty:nodefaults|nl2br|escape:"javascript"}}",
          {{else}} 
            "[{{$_property.field|smarty:nodefaults|escape:"htmlall"|escape:"javascript"}}]", 
          {{/if}}
         shortview: "{{$_property.shortview|smarty:nodefaults|escape:"javascript"}}"
        }
      {{if $smarty.foreach.subproperty.index != $smarty.foreach.subproperty.last}}
        ,
      {{/if}}
      {{/foreach}}
      ];
    {{else}}
    aOptionsFields[{{$i}}][{{$j}}] =
    {   section: "{{$title|smarty:nodefaults|escape:"htmlall"|escape:"javascript"}}",
        view: '{{$property.view|smarty:nodefaults|escape:"javascript"}}' ,
        item: 
          {{if $templateManager->valueMode}}
            {{if @$property.options.barcode}}
              "{{$property.field|smarty:nodefaults|escape:"javascript"}}" ,
            {{else}}
              "{{$property.value|smarty:nodefaults|nl2br|escape:"javascript"}}",
            {{/if}}
          {{else}} 
            {{if @$property.options.barcode}}
              "{{$property.field|smarty:nodefaults|escape:"javascript"}}",
            {{else}}
              "[{{$property.field|smarty:nodefaults|escape:"htmlall"|escape:"javascript"}}]", 
            {{/if}}
          {{/if}}
         shortview: "{{$property.shortview|smarty:nodefaults|escape:"javascript"}}"
      };
    {{/if}}
    {{math equation="$j+1" assign=j}}
  {{/foreach}}
    {{math equation="$i+1" assign=i}}
{{/foreach}}

  // Liste de choix
  {{if !$templateManager->valueMode}}
    // Add name lists Combo
    var aOptionsList = [];
    window.parent.listeChoix.push({
      commandName: "MbNames",
      spanClass: "name",
      commandLabel: "Liste de choix",
      options: aOptionsList
    });

    
    {{foreach from=$templateManager->lists item=list}}
      aOptionsList.push( {
        view: "{{$list.name|smarty:nodefaults|escape:"htmlall"|escape:"javascript"}}" ,
        item: "[Liste - {{$list.name|smarty:nodefaults|escape:"htmlall"|escape:"javascript"}}]"
        });
    {{/foreach}}
  {{/if}}

  // Aides � la saisie
  aOptionsHelpers = {{$templateManager->helpers|@json|smarty:nodefaults}};
  window.parent.helpers.push({
    commandName: "MbHelpers",
    spanClass: "helper",
    commandLabel: "Aides &agrave; la saisie",
    options: aOptionsHelpers
  });
  
  // Aides � la saisie
  aOptionsHelpers = {{$templateManager->helpers|@json|smarty:nodefaults}};
  window.parent.helpers.push({
    commandName: "MbHelpers",
    spanClass: "helper",
    commandLabel: "Aides &agrave; la saisie",
    options: aOptionsHelpers
  });
  
  window.parent.destinataires = {{$templateManager->destinataires|@json|smarty:nodefaults}};
{{/if}}


  // Definition of custom keystrokes
  config.keystrokes.push( [CKEDITOR.CTRL + 72 /*H*/, "mbheader"] );
  config.keystrokes.push( [CKEDITOR.CTRL + 79 /*O*/, "mbfooter"] );
  config.keystrokes.push( [CKEDITOR.CTRL + 75 /*K*/, "mbpagebreak"] );
  config.keystrokes.push( [CKEDITOR.CTRL + CKEDITOR.ALT + 85 /*U*/, "Source"] );
  config.keystrokes.push( [CKEDITOR.CTRL + 83 /*S*/, "save"] );  
  if (window.parent.pdf_thumbnails == 1)
    config.keystrokes.push( [CKEDITOR.CTRL + 80 /*P*/, "mbprintPDF"] );
}