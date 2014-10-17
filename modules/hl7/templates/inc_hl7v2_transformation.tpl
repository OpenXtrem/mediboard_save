{{foreach from=$tree item=_segment}}
  <li>
    {{if $_segment.name == $tree_fields.name}}
      <input type="checkbox" name="address" value="{{$tree_fields.fullpath}}" />
      <span class="field-name">{{$tree_fields.name}}</span>

      {{mb_include template="inc_hl7v2_transformation_group" component=$tree_fields}}
    {{else}}
      {{if $_segment.type == "segment"}}
        <a href="#" onclick="HL7_Transformation.viewFields('{{$actor_guid}}', '{{$profil}}', '{{$_segment.name}}',
          '{{$version}}', '{{$extension}}', '{{$message}}')">
          <span class="type-{{$_segment.type}}">{{$_segment.name}}</span>
        </a>
        <strong class="field-description">{{$_segment.description}}</strong>
      {{else}}
        <span class="type-{{$_segment.type}}">{{$_segment.name}}</span>

        <ul>
          {{mb_include module=hl7 template=inc_hl7v2_transformation tree=$_segment.children}}
        </ul>
      {{/if}}
    {{/if}}
  </li>
{{/foreach}}