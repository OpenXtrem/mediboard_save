{{math assign=colspan equation="x+1" x=$columns|@count}}

{{if $root}}

	{{if $columns|is_array}}
	  {{assign var=_columns value=","|implode:$columns}}
	{{else}}
	  {{assign var=_columns value=""}}
	{{/if}}
	
	<table class="main tbl treegrid" data-columns="{{$_columns}}">
		<tr>
			<th colspan="{{$colspan}}">
				{{tr}}{{$object_class}}{{/tr}}
			</th>
		</tr>
{{/if}}

{{mb_default var=children value=$tree.children}}
{{mb_default var=parent value=null}}
{{mb_default var=level value=0}}
{{mb_default var=ancestors value=""}}

{{foreach from=$children item=_tag name=tree}}
  <tbody data-tag_id="{{$_tag.parent->_id}}"
         class="{{foreach from=","|explode:$ancestors item=_ancestor}}{{if $_ancestor}}tag-{{$_ancestor}} {{/if}}{{/foreach}}"
         {{if $parent}}data-parent_tag_id="{{$parent->_id}}"{{/if}}
				 style="{{if !$root}}display: none;{{/if}}"
				 >
	  <tr>
	  	<td colspan="{{$colspan}}">
				
				<a href="#1" style="margin-left: {{$level*18}}px;" class="tree-folding" onclick="$(this).up('tbody').toggleClassName('opened'); Tag.setNodeVisibility(this); Tag.loadElements(this); return false;">
				  {{$_tag.parent}}
				</a>
			</td>
		</tr>
	</tbody>
	
	{{mb_include module=system template=inc_object_tag_tree root=false parent=$_tag.parent children=$_tag.children level=$level+1 ancestors="$ancestors,`$_tag.parent->_id`"}}
{{/foreach}}

{{if $root}}
	  <tbody data-tag_id="none-{{$object_class}}" class="tag-none">
	    <tr>
	      <td colspan="{{$colspan}}">
	        
	        <a href="#1" class="tree-folding" onclick="$(this).up('tbody').toggleClassName('opened'); Tag.setNodeVisibility(this); Tag.loadElements(this); return false;">
	          Non class�
	        </a>
	      </td>
	    </tr>
	  </tbody>
  </table>
{{/if}}
