
<script type="text/javascript">
Main.add(function(){
  Control.Tabs.create("field_groups_layout");
  //ExClass.putCellSpans($$(".drop-grid")[0]);
});

toggleList = function(select) {
  $$(".hostfield-list").invoke("hide");
  $$(".hostfield-"+$V(select))[0].setStyle({display: "inline-block"});
}
</script>

<form name="form-layout-field" method="post" action="" onsubmit="return onSubmitFormAjax(this)">
  <input type="hidden" name="m" value="system" />
  <input type="hidden" name="dosql" value="do_ex_class_field_aed" />
  <input type="hidden" name="ex_class_field_id" value="" />
  
  <input type="hidden" name="coord_label_x" class="coord" value="" />
  <input type="hidden" name="coord_label_y" class="coord" value="" />
  <input type="hidden" name="coord_field_x" class="coord" value="" />
  <input type="hidden" name="coord_field_y" class="coord" value="" />
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

<form name="form-layout-hostfield" method="post" action="" onsubmit="return false">
  <input type="hidden" name="m" value="system" />
  <input type="hidden" name="dosql" value="do_ex_class_host_field_aed" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="ex_class_host_field_id" value="" />
  <input type="hidden" name="ex_class_id" value="{{$ex_class->_id}}" />
  <input type="hidden" name="ex_group_id" value="" />
  <input type="hidden" name="host_class" value="" />
  <input type="hidden" name="field" value="" />
  <input type="hidden" name="callback" value="" />
  
  <input type="hidden" name="coord_label_x" class="coord" value="" />
  <input type="hidden" name="coord_label_y" class="coord" value="" />
  <input type="hidden" name="coord_value_x" class="coord" value="" />
  <input type="hidden" name="coord_value_y" class="coord" value="" />
</form>

<ul class="control_tabs" id="field_groups_layout" style="font-size: 0.9em;">
  {{foreach from=$ex_class->_ref_groups item=_group}}
    <li>
      <a href="#group-layout-{{$_group->_guid}}" style="padding: 2px 4px;">
        {{$_group->name}} <small>({{$_group->_ref_fields|@count}})</small>
      </a>
    </li>
  {{/foreach}}
  <li style="font-size: 1.2em; font-weight: bold;">
    <label title="Plut�t que glisser-d�poser">
      <input type="checkbox" onclick="ExClass.setPickMode(this.checked)" checked="checked" />
      Disposer par clic
    </label>
  </li>
</ul>
<hr class="control_tabs" />

{{assign var=groups value=$ex_class->_ref_groups}}

<form name="form-grid-layout" method="post" onsubmit="return false" class="prepared pickmode">
  
{{foreach from=$grid key=_group_id item=_grid}}

<div id="group-layout-{{$groups.$_group_id->_guid}}" style="display: none;" class="group-layout">
  
{{mb_include module=forms template=inc_out_of_grid_elements}}

<table class="main drop-grid" style="border-collapse: collapse;">
  <tr>
    <th colspan="5" class="title">Disposition</th>
  </tr>
  <tr>
    <th style="background: #ddd;"></th>
    {{foreach from=$_grid|@reset key=_x item=_field}}
      <th style="background: #ddd;">{{$_x}}</th>
    {{/foreach}}  
  </tr>
  
  {{foreach from=$_grid key=_y item=_line}}
  <tr>
    <th style="padding: 4px; width: 2em; text-align: right; background: #ddd;">{{$_y}}</th>
    {{foreach from=$_line key=_x item=_group}}
      <td style="border: 1px dotted #aaa; min-width: 2em; padding: 0; vertical-align: middle;" class="cell">
      
        {{*
        <div style="position: relative;" class="cell-layout-wrapper">
          <table class="layout cell-layout">
            <tr>
              <td></td>
              <td><a href="#">&#x25B2;</a><br /><a href="#">&#x25BC;</a></td>
              <td></td>
            </tr>
            <tr class="middle">
              <td><a href="#">&#x25C4;</a>&#x2005;<a href="#">&#x25BA;</a></td>
              <td></td>
              <td><a href="#">&#x25C4;</a>&#x2005;<a href="#">&#x25BA;</a></td>
            </tr>
            <tr>
              <td></td>
              <td><a href="#">&#x25B2;<br /><a href="#">&#x25BC;</a></td>
              <td></td>
            </tr>
          </table>
        </div>
        *}}
      
        <div class="droppable grid" data-x="{{$_x}}" data-y="{{$_y}}">
          {{if $_group.object}}
            {{if $_group.object instanceof CExClassField}}
              {{if !$_group.object->disabled}}
                {{mb_include module=forms template=inc_ex_field_draggable
                             _field=$_group.object
                             _type=$_group.type}}
              {{/if}}
            {{elseif $_group.object instanceof CExClassHostField}}
              {{assign var=_host_field value=$_group.object}}
              {{assign var=_host_class value=$_host_field->host_class}}
              {{assign var=_host_object value=$ex_class->_host_objects.$_host_class}}
            
              {{mb_include module=forms template=inc_ex_host_field_draggable 
                           _host_field=$_group.object 
                           ex_group_id=$_group_id 
                           _field=$_group.object->field 
                           _type=$_group.type
                           host_object=$_host_object}}
            {{else}}
              {{mb_include module=forms template=inc_ex_message_draggable 
                           _field=$_group.object 
                           ex_group_id=$_group_id 
                           _type=$_group.type}}
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

{{/foreach}}

</form>
