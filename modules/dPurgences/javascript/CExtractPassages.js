CExtractPassages = {
  refreshExtractPassages : function(form) {
    new Url("dPurgences", "ajax_refresh_extract_passages")
      .addFormData(form)
      .requestUpdate("extractPassages");
    return false;
  },

  doesExtractPassagesExist : function(extract_passages_id) {
    if (!extract_passages_id) {
      return false;
    }

    new Url('dPurgences', 'ajax_does_extract_passages_exist')
      .addParam('extract_passages_id', extract_passages_id)
      .requestJSON(
        function(id) {
          if (id) {
            CExtractPassages.popupEchangeViewer(extract_passages_id);
          }
          else {
            SystemMessage.notify("<div class='error'>"+$T('CExtractPassages-doesnt-exist')+"</div>");
          }
      });

    return false;
  },

  popupEchangeViewer: function(extract_passages_id) {
    new Url("dPurgences", "extract_viewer")
      .addParam("extract_passages_id", extract_passages_id)
      .modal();

    return false;
  },

  encrypt: function(extract_passages_id) {
    new Url("dPurgences", "ajax_encrypt_passages")
      .addParam("extract_passages_id", extract_passages_id)
      .addParam("view", 1)
      .requestUpdate('file_passage_'+extract_passages_id);
  },

  sendPassage: function(passage_id, type) {
    new Url("dPurgences", "ajax_transmit_passages")
      .addParam("extract_passages_id", passage_id)
      .requestUpdate("systemMsg");
  },

  changePage: function(page) {
    $V(getForm('listFilter').page, page);
  }
};