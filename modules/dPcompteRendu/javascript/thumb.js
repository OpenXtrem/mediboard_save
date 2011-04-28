var Thumb = {
  compte_rendu_id: 0,
  modele_id: 0,
  file_id: 0,
  thumb_up2date: true,
  thumb_refreshing: false,
	nb_thumbs: 0,
	first_time: 1,
	changed: false,
	contentChanged: false,
  choixAffiche: function(isNotModele) {
    $("thumbs").toggle();
    if (isNotModele == 1) {
      $("thumbs_button").toggle();
      var editeur = $("editeur");
    }
    else {
      var editeur = $("htmlarea");
    }
    var colspan_editeur = editeur.readAttribute("colspan");
    colspan_editeur == '1' ? editeur.writeAttribute("colspan",'2') : editeur.writeAttribute("colspan",'1');
  },

  refreshThumbs: function(first_time, print) {
    
    $("thumbs").stopObserving("scroll", Thumb.refreshThumb);
    this.changed = false;
    var mess = null;
    if (mess = $('mess')) {
      mess.stopObserving("click");
      mess.hide();
    }
    $("thumbs").setOpacity(1);
    var form = getForm("editFrm");
    var url = new Url();
    url.addParam("compte_rendu_id", this.compte_rendu_id || this.modele_id);
    
    var content = '';
    
    if (window.CKEDITOR && CKEDITOR.instances.htmlarea.getData) {
      if (window.pdf_thumbnails) {
        restoreStyle();
      }
      content = CKEDITOR.instances.htmlarea.getData();
      if (window.pdf_thumbnails) {
        deleteStyle();
      }
    } else {
      content = $V(form._source);
    }
    
    url.addParam("content", encodeURIComponent(content));
    url.addParam("mode", this.mode);
    
    if (print) {
      url.addParam("print", print);
      Thumb.print = 0;
    }
    
    if (this.modele_id) {
      url.addParam("type",      $V(form.elements.type));
      url.addParam("header_id", $V(form.elements.header_id));
      url.addParam("footer_id", $V(form.elements.footer_id));
      url.addParam("height",    $V(form.elements.height));
    }
    
    url.addParam("stream", 0);
    url.addParam("write_page", 1);
    url.addParam("first_time", first_time);
    url.addParam("user_id", this.user_id);
    url.addParam("margins[]",[form.elements.margin_top.value,
                              form.elements.margin_right.value,
                              form.elements.margin_bottom.value,
                              form.elements.margin_left.value]);
                              
    url.addParam("orientation", $V(PageFormat.form._orientation));
    url.addParam("page_format", form.elements._page_format.value);
    url.addParam("page_width",  form.elements.page_width.value);
    url.addParam("page_height", form.elements.page_height.value);
    
    url.requestUpdate("thumbs", {
      method: "post",
      getParameters: {
        m: "dPcompteRendu", 
        a: "ajax_pdf"
      },
      onComplete: function() {
        Thumb.thumb_refreshing = false;
        if(!Thumb.thumb_up2date) {
          Thumb.thumb_up2date = true;
          Thumb.old();
        }
        else {
          // Requ�te pour la premi�re vignette
          (function() { Thumb.refreshThumb()}).defer();
          $("thumbs").observe("scroll", Thumb.refreshThumb);
        }
      }
    });
  },
  refreshThumb: function() {
    var document_height = document.viewport.getHeight();
    var thumbs = $("thumbs");
    var thumbs_empty = $$(".thumb_empty");

    if (!thumbs_empty || thumbs_empty.length == 0 || Thumb.changed) {
      $("thumbs").stopObserving("scroll", Thumb.refreshThumb);
      return;
    }
    
    for(var thumb in thumbs_empty) {
     
      thumb = thumbs_empty[thumb];
      if (typeof thumb == "function") continue;
      
      var index = parseInt(thumb.id.substr(6)) -1 ;
      
      var thumbs_lower = thumbs.cumulativeOffset()[1];
      var thumbs_higher = thumbs_lower + thumbs.getHeight();
      var scroll_lower = thumb.cumulativeOffset()[1] - thumb.cumulativeScrollOffset()[1];
      var scroll_higher = scroll_lower + thumb.getHeight();
      
      if ((scroll_lower >= thumbs_lower && scroll_lower <= thumbs_higher) ||
          (scroll_higher >= thumbs_lower && scroll_higher <= thumbs_higher)) {
        var url = new Url("dPcompteRendu", "ajax_thumbs");
        url.addParam("index", index);
        url.addParam("file_id", Thumb.file_id);
        thumb.removeClassName("thumb_empty").addClassName("thumb_full");
        url.requestJSON(function(thumbnail) {
          thumb.observe("click", function(){
            (new Url).ViewFilePopup('CCompteRendu', Thumb.compte_rendu_id || Thumb.modele_id, 'CFile', Thumb.file_id, index)});
          thumb.src = "data:image/png;base64,"+thumbnail; Thumb.refreshThumb();
        });
        break;
      }
    }
  },
  old: function() {
    if (window.pdf_thumbnails && window.Preferences.pdf_and_thumbs == 1) {
      if (this.thumb_refreshing) {
        
        this.thumb_up2date = false;
        return;
      }
      var on_click = function(){
    	  CKEDITOR.instances.htmlarea.on("key", loadOld);
    	  Thumb.changed = true;
        Thumb.first_time = 0;
        Thumb.thumb_refreshing = true;
        window.thumbs_timeout = setTimeout(function() {
          Thumb.refreshThumbs(0);
        }, 0);
      }

      var mess = $('mess');
      if (this.thumb_up2date && mess) {
        mess.show();
        mess.stopObserving("click");
        mess.observe("click", on_click);
      }
    }
  }
}


function loadOld() {
  var instance = CKEDITOR.instances.htmlarea;
  if (!instance.checkDirty()) return;
  var html = instance.getData();
  if (html != Thumb.content) {
    Thumb.contentChanged = true;
    Thumb.changed = true;
    instance.removeListener("key", loadOld);
    Thumb.content = html;
    if (window.pdf_thumbnails && window.Preferences.pdf_and_thumbs == 1) {
      clearTimeout(window.thumbs_timeout);
      Thumb.old();
    }
  }
}

function pdfAndPrintServer(compte_rendu_id) {
  Thumb.print = 0;
  var url = new Url();
  url.addParam("compte_rendu_id", compte_rendu_id);
  url.addParam("write_page", 1);
  url.addParam("print", 1);
  url.requestUpdate("pdf_area", {method: "post", getParameters: {m: "dPcompteRendu", a: "ajax_pdf"}});
}

function restoreStyle() {
  /*var instance = CKEDITOR.instances.htmlarea;
  
  if (!window.save_style) return;
  var tag = instance.document.getBody().getFirst();
  if (tag.$.tagName == "STYLE") return;
  window.save_style.insertBefore(tag);*/
}

function deleteStyle() {
  /*var instance = CKEDITOR.instances.htmlarea;
  
  if (!instance.document) return;
  var styleTag = instance.document.getBody().getFirst();
  if (styleTag.$.tagName == "STYLE") {
    return styleTag.remove();
  }*/
}