<select name="_helpers_{{$field}}" style="width: 7em;" onchange="pasteHelperContent(this)">
  <option value="">&mdash; {{tr}}Choose{{/tr}}</option>
  {{if $no_enum && $field}}
    {{html_options options=$object->_aides.$field.no_enum}}
  {{else}}
    {{foreach from=$object->_aides item=_list key=sTitleOpt}}
      {{foreach from=$_list item=list_aides_by_type key=_type_aide}}
        {{if $_type_aide != "no_enum"}}
          {{* FIXME: Les optgroups n'ont pas le droit d'etre imbriqu�s (un seul niveau autoris�) *}}
          <optgroup label="{{$_type_aide}}">
            {{foreach from=$list_aides_by_type item=_list_aides key=cat}}
              <optgroup label="{{$cat}}" style="padding-left: 10px;">
                {{html_options options=$_list_aides}}
              </optgroup>
            {{/foreach}}
          </optgroup>
        {{/if}}
      {{/foreach}}
    {{/foreach}}
  {{/if}}
</select>