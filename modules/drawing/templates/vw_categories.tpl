{{*
 * $Id$
 *  
 * @category Drawing
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
*}}

{{mb_script module=drawing script=DrawingCategory}}
{{mb_script module=files script=file}}

<style>
  .drawing_file_list img{
    max-width: 120px;
    max-height: 120px;
  }
</style>

<script>
  reloadPage = function() {
    document.location.reload();
  };

  Main.add(function() {
    $$("#cat_drawing td.droppable").each(function(td) {
      console.log(td);
      Droppables.add(td, {
        onDrop: function(from, to, event) {
          Event.stop(event);
          console.log(to);
          console.log(from);
          var file_id = from.get("file_id");
          var target_guid = to.get("cat_guid");
          if (target_guid && file_id) {
            var url = new Url("files","controllers/do_move_file");
            url.addParam("object_id", file_id);
            url.addParam("object_class", "CFile");
            url.addParam("destination_guid", target_guid );
            url.requestUpdate("systemMsg", function() {
              document.location.reload();
            });
          }
        },
        accept: 'draggable',
        hoverclass:'dropover'
      });
    });

    $$("#cat_drawing div.draggable").each(function(a) {
      new Draggable(a, {
        onEnd: function(element, event) {
          Event.stop(event);
        },
        ghosting: true});
    });
  });
</script>

<button class="new" type="button" onclick="DrawingCategory.editModal('', reloadPage);">{{tr}}CDrawingCategory.new{{/tr}}</button>

<table class="tbl" id="cat_drawing">
  {{foreach from=$categories item=_cat}}
    <tr>
      <th class="title" style="text-align: left;">
        <button class="edit notext" type="button" style="float:left;" onclick="DrawingCategory.editModal('{{$_cat->_id}}', reloadPage);">{{tr}}CDrawingCategory.edit{{/tr}}</button>
        <button class="add notext" type="button" style="float:left;" onclick="File.upload('{{$_cat->_class}}', '{{$_cat->_id}}');">{{tr}}CFile.add{{/tr}}</button>
        <span onmouseover="ObjectTooltip.createEx(this,'{{$_cat->_guid}}');">{{$_cat}} <small>({{$_cat->_ref_files|@count}})</small></span>
      </th>
    </tr>
    <tr>
      <td class="droppable drawing_file_list {{if !$_cat->_ref_files|@count}}empty{{/if}}" data-cat_guid="{{$_cat->_guid}}" style="text-align: center;">
        {{foreach from=$_cat->_ref_files item=_file}}
          <div style="position: relative; display: inline-block" class="draggable" data-file_id="{{$_file->_id}}">
            <form method="post" name="delete-{{$_file->_guid}}">
              <input type="hidden" name="m" value="files" />
              <input type="hidden" name="dosql" value="do_file_aed" />
              <input type="hidden" name="del" value="1"/>
              {{mb_class object=$_file}}
              {{mb_key object=$_file}}
              <button style="position: absolute; top:0; left:0;" class="trash" type="button" onclick="confirmDeletion(this.form, {ajax:true}, {onComplete: reloadPage})"></button>
            </form>
            <span onmouseover="ObjectTooltip.createEx(this, '{{$_file->_guid}}');">
              <img src="?m=files&amp;a=fileviewer&amp;file_id={{$_file->_id}}&amp;phpThumb=1" alt=""/>
            </span>
          </div>
        {{foreachelse}}
          {{tr}}CFile.none{{/tr}}
        {{/foreach}}
        {{*mb_include module=dPfiles template=inc_widget_list_files object=$_cat*}}
      </td>
    </tr>
  {{foreachelse}}
    <tr>
      <td colspan="2" class="empty">{{tr}}CDrawingCategory.none{{/tr}}</td>
    </tr>
  {{/foreach}}
</table>

