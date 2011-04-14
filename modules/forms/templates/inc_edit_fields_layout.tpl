
<script type="text/javascript">
Main.add(function(){
  Control.Tabs.create("field_groups_layout");
});
</script>

<div class="small-info">Glissez-d�posez les champs et leur libell� dans la grille "Disposition"</div>

<form name="form-layout-field" method="post" action="" onsubmit="return onSubmitFormAjax(this)">
  <input type="hidden" name="m" value="system" />
  <input type="hidden" name="dosql" value="do_ex_class_field_aed" />
  <input type="hidden" name="ex_class_field_id" value="" />
  
  <input type="hidden" name="coord_label_x" class="coord" value="" />
  <input type="hidden" name="coord_label_y" class="coord" value="" />
  <input type="hidden" name="coord_field_x" class="coord" value="" />
  <input type="hidden" name="coord_field_y" class="coord" value="" />
</form>

<form name="form-layout-hostfield" method="post" action="" onsubmit="return false">
  <input type="hidden" name="m" value="system" />
  <input type="hidden" name="dosql" value="do_ex_class_host_field_aed" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="ex_class_host_field_id" value="" />
  <input type="hidden" name="ex_class_id" value="{{$ex_class->_id}}" />
  <input type="hidden" name="ex_group_id" value="" />
  <input type="hidden" name="field" value="" />
  <input type="hidden" name="callback" value="" />
  
  <input type="hidden" name="coord_label_x" class="coord" value="" />
  <input type="hidden" name="coord_label_y" class="coord" value="" />
  <input type="hidden" name="coord_value_x" class="coord" value="" />
  <input type="hidden" name="coord_value_y" class="coord" value="" />
</form>

<form name="form-layout-message" method="post" action="" onsubmit="return onSubmitFormAjax(this)">
  <input type="hidden" name="m" value="system" />
  <input type="hidden" name="dosql" value="do_ex_class_message_aed" />
  <input type="hidden" name="ex_class_message_id" value="" />
  
  <input type="hidden" name="coord_title_x" class="coord" value="" />
  <input type="hidden" name="coord_title_y" class="coord" value="" />
  <input type="hidden" name="coord_text_x" class="coord" value="" />
  <input type="hidden" name="coord_text_y" class="coord" value="" />
</form>

<style type="text/css">
  .out-of-grid div {
    /*display: inline-block;*/
  }
  
  .label-list .draggable,
  .field-list .draggable {
    border: 1px dotted #aaa;
    margin: 2px;
    padding: 2px;
  }
  
  .droppable.grid .draggable {
    display: block;
  }
  
  .droppable.grid .draggable.label {
    /*text-align: right;*/
    font-weight: bold;
    white-space: nowrap;
  }
  
  .field-list .field {
    white-space: normal;
  }
  
  .field:hover .field-info,
  .field-list .field .field-info {
    display: block !important;
    position: absolute;
    top: -1.4em;
    color: #333;
    background: #ddd;
    padding: 0px 1em;
    -moz-border-radius-topleft: 4px;
    -moz-border-radius-topright: 4px;
    -webkit-border-top-left-radius: 4px;
    -webkit-border-top-right-radius: 4px;
    border-radius-topleft: 4px;
    border-radius-topright: 4px;
  }
  
  .field-list .field {
    margin-top: 1.2em;
  }
  
  .field .field-content {
    overflow-y: hidden;
  }
  
  .field-list .field .field-content {
    max-height: 2.5em;
  }
  
  .grid .field .field-content {
    max-height: 3.5em;
  }
  
  .draggable .overlay {
    position:absolute;
    top:0;
    left:0;
    bottom:0;
    right:0;
  }
  
  .grid .hostfield .field-name, 
  .hostfield.dragging .field-name {
    display: inline !important;
  }
  
  .hostfield {
    background-color: rgb(205,252,204);
    background-color: rgba(205,252,204,0.4);
  }
  
  .draggable.hr {
    padding: 6px;
  }

	div.ex-message-title {
	  font-weight: bold;
	  border-bottom: 1px solid #666;
	  font-size: 1.2em;
	  /*left: 0.5em; 
	  right: 0.5em; 
	  position: absolute;*/
	}
</style>

<ul class="control_tabs" id="field_groups_layout" style="font-size: 0.9em;">
  {{foreach from=$ex_class->_ref_groups item=_group}}
  {{if $_group->_ref_fields|@count > 0}}
    <li>
      <a href="#group-layout-{{$_group->_guid}}" style="padding: 2px 4px;">
        {{$_group->name}} <small>({{$_group->_ref_fields|@count}})</small>
      </a>
    </li>
  {{/if}}
  {{/foreach}}
</ul>
<hr class="control_tabs" />

{{assign var=groups value=$ex_class->_ref_groups}}

<form name="form-grid-layout" method="post" onsubmit="return false" class="prepared">
  
{{foreach from=$grid key=_group_id item=_grid}}

{{if $groups.$_group_id->_ref_fields|@count > 0}}
<div id="group-layout-{{$groups.$_group_id->_guid}}" style="display: none;" class="group-layout">
  
<div class="out-of-grid droppable">
	<script type="text/javascript">
	Main.add(function(){
	  Control.Tabs.create("class-message-layout-tabs-{{$_group_id}}");
	});
	</script>
	
	<ul class="control_tabs" id="class-message-layout-tabs-{{$_group_id}}">
    <li>
      <a href="#outofgrid-class-fields-{{$_group_id}}">Champs</a>
    </li>
		<li>
			<a href="#outofgrid-hostfields-and-messages-{{$_group_id}}">Champs de {{tr}}{{$ex_class->host_class}}{{/tr}} / Messages</a>
		</li>
	</ul>
	<hr class="control_tabs" />
	
  <table class="main tbl" style="table-layout: fixed;">
	  <!-- Fields -->
    <tbody id="outofgrid-class-fields-{{$_group_id}}" style="display: none;">
	    <tr>
	      <th>Libell�s</th>
	      <th>Champs</th>
	    </tr>
	    <tr>
	      <td class="label-list" data-x="" data-y="" style="padding: 4px; height: 2em; vertical-align: top;">
	        {{foreach from=$out_of_grid.$_group_id.label item=_field}}
	          {{mb_include module=forms template=inc_ex_field_draggable _type="label" }}
	        {{/foreach}}
	      </td>
	  
	      <td class="field-list" data-x="" data-y="" style="padding: 4px; vertical-align: top;">
	        {{foreach from=$out_of_grid.$_group_id.field item=_field}}
	          {{mb_include module=forms template=inc_ex_field_draggable _type="field"}}
	        {{/foreach}}
	      </td>
	    </tr>
    </tbody>
		
		<!-- Messages -->
    <tbody id="outofgrid-hostfields-and-messages-{{$_group_id}}" style="display: none;">
      <tr>
        <th>
          {{if $ex_class->host_class != "CMbObject"}}
            Champs de <strong>{{tr}}{{$ex_class->host_class}}{{/tr}}</strong>
          {{/if}}
        </th>
        <th>Titres</th>
        <th>Textes</th>
      </tr>
      <tr>
        <td class="hostfield-list" data-x="" data-y="" style="padding: 4px; height: 2em; vertical-align: top;">
          {{if $ex_class->host_class != "CMbObject"}}
            <div style="height: 100%; overflow-y: scroll; min-height: 100px;">
              <ul>
              {{foreach from=$host_object->_specs item=_spec key=_field}}
                {{if $_spec->show == 1 || $_field == "_view" || ($_spec->show == "" && $_field.0 !== "_")}}
                  <li>
                    {{mb_include module=forms template=inc_ex_host_field_draggable ex_group_id=$_group_id}}
                  </li>
                {{/if}}
              {{/foreach}}
              </ul>
            </div>
          {{else}}
            <em>Veuillez lier le formulaire � un �v�nement</em>
          {{/if}}
        </td>
    
        <td class="message_title-list" data-x="" data-y="" style="padding: 4px; vertical-align: top;">
          {{foreach from=$out_of_grid.$_group_id.message_title item=_field}}
            {{mb_include module=forms template=inc_ex_message_draggable _type="message_title"}}
          {{/foreach}}
        </td>
    
        <td class="message_text-list" data-x="" data-y="" style="padding: 4px; vertical-align: top;">
          {{foreach from=$out_of_grid.$_group_id.message_text item=_field}}
            {{mb_include module=forms template=inc_ex_message_draggable _type="message_text"}}
          {{/foreach}}
        </td>
      </tr>
    </tbody>
  </table>
</div>

<table class="main tbl drop-grid" style="border-collapse: collapse;">
  <tr>
    <th colspan="10" class="title">Disposition</th>
  </tr>
  <tr>
    <th></th>
    {{foreach from=$_grid|@reset key=_x item=_field}}
      <th>{{$_x}}</th>
    {{/foreach}}  
  </tr>
  
  {{foreach from=$_grid key=_y item=_line}}
  <tr>
    <th style="padding: 4px; width: 2em; text-align: right;">{{$_y}}</th>
    {{foreach from=$_line key=_x item=_group}}
      <td style="border: 1px dotted #aaa; min-width: 2em; padding: 0;">
			  <div class="droppable grid" data-x="{{$_x}}" data-y="{{$_y}}">
	        {{if $_group.object}}
	          {{if $_group.object instanceof CExClassField}}
	            {{mb_include module=forms template=inc_ex_field_draggable _field=$_group.object _type=$_group.type}}
	          {{elseif $_group.object instanceof CExClassHostField}}
	            {{mb_include module=forms template=inc_ex_host_field_draggable _host_field=$_group.object ex_group_id=$_group_id _field=$_group.object->field _type=$_group.type}}
	          {{else}}
              {{mb_include module=forms template=inc_ex_message_draggable _field=$_group.object ex_group_id=$_group_id _type=$_group.type}}
            {{/if}}
					{{else}}
					  &nbsp;
	        {{/if}}
				</div>
      </td>
    {{/foreach}}
  </tr>
  {{/foreach}}
</table>

</div>
{{/if}}

{{/foreach}}

</form>
