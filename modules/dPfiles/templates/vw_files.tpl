<script type="text/javascript">
function popSearch() {
  var f = document.FrmClass;
  var url = new Url;
  url.setModuleAction("system", "object_selector");
  url.addParam("keywords", f.keywords.value);
  url.addParam("selClass", f.selClass.value);  
  url.popup(600, 300, "-");
}

function popFile(file_id){
  var url = new Url;
  url.ViewFilePopup(file_id);
}

function ZoomFileAjax(file_id){
  var VwFileUrl = new Url;
  VwFileUrl.setModuleAction("dPfiles", "preview_files");
  VwFileUrl.addParam("file_id", file_id);
  VwFileUrl.requestUpdate('bigView', { waitingText : "Chargement du miniature" });
}

function setData(selClass,keywords,key,val){
  var f = document.FrmClass;
  if (val != '') {
    f.selKey.value = key;
    f.selView.value = val;
    f.selClass.value = selClass;
    f.keywords.value = keywords;
    f.file_id.value = "";
    f.submit();
  }
}

function reloadListFile(){
  var listFileUrl = new Url;
  listFileUrl.setModuleAction("dPfiles", "httpreq_vw_listfiles");
  listFileUrl.addParam("selKey", document.FrmClass.selKey.value);
  listFileUrl.addParam("selClass", document.FrmClass.selClass.value);  
  listFileUrl.addParam("typeVue", document.FrmClass.typeVue.value);    
  listFileUrl.requestUpdate('listView', { waitingText : null });
}

function submitFileChangt(oForm){
  submitFormAjax(oForm, 'systemMsg', { onComplete : reloadListFile });
}
</script>

<table class="main">
  <tr>
    <td>
      <form name="FrmClass" action="?m={{$m}}" method="get">
      <input type="hidden" name="m" value="{{$m}}" />
      <input type="hidden" name="file_id" value="{{$file->file_id}}" />
      <table class="form">
        <tr>
          <td  class="readonly">
            <label for="selClass" title="Veuillez Sélectionner une Class">Choix du type d'objet</label>
            <input type="text" readonly="readonly" ondblclick="popSearch()" name="selClass" value="{{$selClass}}" />
          </td>
          <td class="readonly">
            <input type="text" readonly="readonly" ondblclick="popSearch()" name="keywords" value="{{$keywords}}" />
            <button type="button" onclick="popSearch()" class="search">Rechercher</button>
            <input type="hidden" name="selKey" value="{{$selKey}}" />
            <input type="hidden" name="selView" value="{{$selView}}" />
          </td>
          {{if $selKey}}
          <td>
            <select name="typeVue" onchange="submit()">
              <option value="0" {{if $typeVue == 0}}selected="selected"{{/if}}>Avec Prévisualisation</option>
              <option value="1" {{if $typeVue == 1}}selected="selected"{{/if}}>Sans Prévisualisation</option>
              <option value="2" {{if $typeVue == 2}}selected="selected"{{/if}}>Grands apperçu</option>
            </select>
          </td>
          {{/if}}
        </tr>
      </table>
      </form>
    </td>
  </tr>
  {{if $selClass && $selKey}}
  <tr>
    <td>
      <table class="form">
        <tr>
          <th class="category" colspan="2">{{$object->_view}}</th>
        </tr>
        <tr>
          {{if $typeVue}}
          <td colspan="2" id="listView">
            {{if $typeVue==1}}
            {{include file="inc_list_view_colonne.tpl"}}
            {{else $typeVue==2}}
            {{include file="inc_list_view_gd_thumb.tpl"}}            
            {{/if}}
          </td>      
          {{else}}
          <td style="width: 400px;" id="listView">
            {{include file="inc_list_view.tpl"}}
          </td>
          <td id="bigView" style="text-align: center;">
            {{include file="inc_preview_file.tpl"}}
          </td>
          {{/if}}
        </tr>
      </table>
    </td>
  </tr>
  {{/if}}
</table>