var file_preview = null;
var file_deleted = null;

 popFile = function(objectClass, objectId, elementClass, elementId, sfn){
  var url = new Url;
  url.ViewFilePopup(objectClass, objectId, elementClass, elementId, sfn);
 };

ZoomAjax = function(objectClass, objectId, elementClass, elementId, sfn){
  file_preview = elementId;
  var url = new Url('files', 'preview_files');
  url.addParam('objectClass', objectClass);
  url.addParam('objectId', objectId);
  url.addParam('elementClass', elementClass);
  url.addParam('elementId', elementId);
  if(sfn && sfn != 0){
    url.addParam('sfn', sfn);
  }
  url.requestUpdate('bigView');
};

setObject = function(oObject){
  var oForm = getForm('FrmClass');
  oForm.selKey.value = oObject.id;
  oForm.selView.value = oObject.view;
  oForm.selClass.value = oObject.objClass;
  oForm.keywords.value = oObject.keywords;
  oForm.file_id.value = '';
  if (oForm.onsubmit()) {
    oForm.submit();
  }
  
  if(window.saveObjectInfos){
    saveObjectInfos(oObject);
  }
};

reloadListFileDossier = function(sAction){
  var oForm = getForm('FrmClass');
  var sSelClass = oForm.selClass.value;
  var sSelKey   = oForm.selKey.value;
  
  if($('tab-'+sSelClass+sSelKey)){
    return;
  }
  
  var url = new Url('files', 'httpreq_vw_listfiles');
  url.addParam('selKey', sSelKey);
  url.addParam('selClass', sSelClass);  
  url.addParam('typeVue', oForm.typeVue.value);
  url.addParam('accordDossier', 1);
  url.requestUpdate('File'+sSelClass+sSelKey);
};

reloadAfterUploadFile = function(category_id){
  reloadListFile('add', category_id);
};

reloadAfterMoveFile = function(category_id){
  reloadListFile('move', category_id);
};

reloadAfterDeleteFile = function(category_id){
  reloadListFile('delete', category_id);
};

reloadListFile = function(sAction, category_id){
  if(sAction == 'delete' && file_preview == file_deleted){
    ZoomAjax('','','','', 0);
  }
  
  var oForm = getForm('FrmClass');
  var url = new Url('files', 'httpreq_vw_listfiles');
  url.addParam('selKey', oForm.selKey.value);
  url.addParam('selClass', oForm.selClass.value);  
  url.addParam('typeVue', oForm.typeVue.value);

  var category = $('Category-'+category_id);
  if (category) {
    if (category_id == '') {
      category_id = 0;
    }
    url.addParam('category_id', category_id);
    url.requestUpdate('Category-' + category_id);
  }
  else {
    url.requestUpdate('listView');
  }
};

submitFileChangt = function(oForm){
  file_deleted = null;
  onSubmitFormAjax(oForm, reloadAfterMoveFile);
};

if (window.Document) {
  Document.refreshList = reloadAfterUploadFile;
}

showCancelled = function(button) {
  $('listView').select('div.file_cancelled').invoke('toggle');
};

cancelFile = function(form, category_id) {
  if (confirm($T('CFile-comfirm_cancel'))) {
    onSubmitFormAjax(form, reloadAfterDeleteFile.curry(category_id));
  }
  return false;
};

// used for move a file
File_Attach = {
  object_class  : null,
  object_id     : null,
  object_guid   : null,
  file_id       : null,
  file_class    : null,
  file_guid     : null,
  patient_id    : null,
  is_valid      : false,
  button_Attach : null,

  listRefsForPatient : function(patient_id, prat_id, guess_date, target_dom_id) {
    this.patient_id = patient_id;
    var url = new Url("dPpatients", "ajax_list_refs_to_attach_select");
    url.addParam("patient_id", patient_id);
    url.addParam("prat_id", prat_id);
    url.addParam("date", guess_date);
    url.requestUpdate(target_dom_id);
  },


  setFile: function (file_id, file_class) {
    this.file_id = file_id;
    this.file_class = file_class;
    this.file_guid = this.file_class+"-"+this.file_id;
    this.checkLink();
  },

  setObject: function(object_class, object_id, elt) {
    if (object_class == "CPatient") {
      if (!confirm("Associer ce fichier � un dossier patient implique qu'il sera visible de tous les utilisateurs ayant acc�s au dossier patient, �tes vous sur ?")) {
        if (elt) {
          $V(elt, 0);
        }
        return;
      }
    }

    this.object_class = object_class;
    this.object_id = object_id;
    this.object_guid = this.object_class+"-"+this.object_id;
    if (elt) {
      $V(elt, 1);
    }
    this.checkLink();
  },

  doMovefile : function(file_id, file_class, destination_id, destination_class) {
    if (file_id && file_class) {
      this.setFile(file_id, file_class);
    }
    if (destination_id && destination_class) {
      this.setObject(destination_class, destination_id);
    }
    var url = new Url("files", "controllers/do_move_file");
    url.addParam("object_id", this.file_id);
    url.addParam("object_class", this.file_class);
    url.addParam("destination_guid", this.object_guid);
    url.requestUpdate("systemMsg", Control.Modal.close);
  },

  checkLink : function() {
    if (this.object_class && this.object_id && this.file_id) {
      this.is_valid = true;
      if (this.button_Attach) {
        $(this.button_Attach).show();
      }
    }
  },

  /**
   * try to find the maximum guess of the elements
   * guesses = [[], [], [], []]
   */
  guessElement : function(guesses) {
    console.log(guesses);
    var lenght = (guesses.length-1);
    for (var i = lenght; i>0; i--) {

      //one result and maximum : check it
      if (guesses[i].length == 1 ) {
        this.setObject(
          guesses[i][0].get("class"),
          guesses[i][0].get("id"),
          guesses[i][0]
        );
        return;
      }

      if (guesses[i].length > 0) {
        this.setObject(
          guesses[guesses[i].length-1][0].get("class"),
          guesses[guesses[i].length-1][0].get("id"),
          guesses[guesses[i].length-1][0]
        );
        return;
      }
    }
  }
};