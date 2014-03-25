{{mb_script module=mediusers script=color_selector ajax=true}}

<script>
  editTag = function(id, oclass) {
    var url = new Url("system", "ajax_edit_tag");
    if (id) {
      url.addParam("object_guid", "CTag-"+id);
    }
    else {
      if (oclass) {
        url.addParam("object_class", oclass);
      }
    }
    url.requestModal("500");
    url.modalObject.observe('afterClose', function() {
      refreshTagList();
    });
  };

  doMerge = function(oForm) {
    var url = new Url("system", "object_merger");
    url.addParam("objects_class", "CTag");
    if ($V(oForm["objects_id[]"])) {
      url.addParam("objects_id", $V(oForm["objects_id[]"]).join("-"));
    }
    url.popup(800, 600, "merge_patients");
  };

  removeParent = function() {
    var oform = getForm('filterTag');
    $V(oform.parent_id, '', true);
    refreshTagList();
  };

  refreshTagList = function(page_number, parent_id) {
    var oform = getForm('filterTag');
    $V(oform.page, page_number? page_number : 0);
    if (parent_id) {
      $V(oform.parent_id, parent_id, true);
    }
    oform.onsubmit();
  };

  Main.add(function() {
    refreshTagList();
  });
</script>

<button class="new" onclick="editTag(null, '{{$object_class}}')" style="float:right">{{tr}}CTag.add{{/tr}} ({{tr}}{{$object_class}}{{/tr}})</button>
<form name="filterTag" method="get" onsubmit="return onSubmitFormAjax(this, null, 'result_tags')" style="margin:0 auto;">
  <input type="hidden" name="m" value="system"/>
  <input type="hidden" name="a" value="ajax_search_tag"/>
  <input type="hidden" name="object_class" value="{{$object_class}}"/>
  <input type="hidden" name="parent_id" value=""/>
  <input type="text" name="name" value="" placeholder="{{tr}}Search{{/tr}}" onkeyup="$V(this.form.page, 0)"/>
  <!--<label>Utilis�s au moins 1 fois<input type="checkbox" name="no_item" onchange="$V(this.form.page, 0)"/></label>-->
  <label><input type="checkbox" name="is_child" onchange="$V(this.form.page, 0)"/>Sont des fils</label>
  <input type="hidden" name="page" value="0"/>
  <button class="search notext">{{tr}}Search{{/tr}}</button>
</form>
<hr/>

{{if $tag->_can->edit}}
  <form name="fusion-tag" method="get">
    <input type="hidden" name="" value=""/>
{{/if}}
  <div id="result_tags">

  </div>

{{if $tag->_can->edit}}
  </form>
{{/if}}