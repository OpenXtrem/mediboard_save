{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage Stock
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<table class="main">
  <tr>
    <td class="halfPane">
      <table class="tbl">
        <tr>
          <th>{{tr}}CProductCategory{{/tr}}</th>
          <th>{{tr}}CProductCategory-back-products{{/tr}}</th>
        </tr>
        {{foreach from=$list_categories item=curr_category}}
        <tr {{if $curr_category->_id == $category->_id}}class="selected"{{/if}}>
          <td class="text">
            <a href="?m=dPstock&amp;tab=vw_idx_category&amp;category_id={{$curr_category->_id}}" title="{{tr}}CProductCategory-title-modify{{/tr}}">
              {{mb_value object=$curr_category field=name}}
            </a>
          </td>
          <td>{{$curr_category->_count.products}}</td>
        </tr>
        {{/foreach}}        
      </table>  
    </td>
    <td class="halfPane">
      <a class="button new" href="?m=dPstock&amp;tab=vw_idx_category&amp;category_id=0">
        {{tr}}CProductCategory-title-create{{/tr}}
      </a>

      <form name="edit_category" action="?m={{$m}}" method="post" onsubmit="return checkForm(this)">
      <input type="hidden" name="dosql" value="do_category_aed" />
      <input type="hidden" name="category_id" value="{{$category->_id}}" />
      <input type="hidden" name="del" value="0" />
      <table class="form">
        {{mb_include module=system template=inc_form_table_header object=$category}}
        
        <tr>
          <th>{{mb_label object=$category field="name"}}</th>
          <td>{{mb_field object=$category field="name"}}</td>
        </tr>
        <tr>
          <td class="button" colspan="4">
            {{if $category->_id}}
            <button class="modify" type="submit">{{tr}}Save{{/tr}}</button>
            <button type="button" class="trash" onclick="confirmDeletion(this.form,{typeName:'',objName:'{{$category->_view|smarty:nodefaults|JSAttribute}}'})">
              {{tr}}Delete{{/tr}}
            </button>
            {{else}}
            <button class="submit" type="submit">{{tr}}Create{{/tr}}</button>
            {{/if}}
          </td>
        </tr>  
      </table>
      </form>
    </td>
  </tr>
</table>