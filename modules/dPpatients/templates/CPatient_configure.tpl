{{assign var=class value=CPatient}}
<form name="EditConfig-{{$class}}" action="?m={{$m}}&amp;{{$actionType}}=configure" method="post" onsubmit="return onSubmitFormAjax(this)">

<input type="hidden" name="m" value="system" />
<input type="hidden" name="dosql" value="do_configure" />

<table class="form">  
  {{mb_include module=system template=inc_config_str var=tag_ipp      }}
  {{mb_include module=system template=inc_config_str var=tag_ipp_group_idex}}
  {{mb_include module=system template=inc_config_str var=tag_ipp_trash}}
  {{mb_include module=system template=inc_config_str var=tag_conflict_ipp}}
  
  {{mb_include module=system template=inc_config_bool var=merge_only_admin}}
  {{mb_include module=system template=inc_config_bool var=extended_print  }}
  {{mb_include module=system template=inc_config_str  var=adult_age       }}

  {{mb_include module=system template=inc_config_enum var=identitovigilence values="nodate|date|doublons"}}
  {{mb_include module=system template=inc_config_enum var=multi_group       values="full|limited|hidden"}}
  {{mb_include module=system template=inc_config_bool var=function_distinct}}
  {{mb_include module=system template=inc_config_enum var=limit_char_search values="0|3|4|5|6|8|10"}}
  
	{{mb_include module=system template=inc_config_bool var=check_code_insee}}
  {{mb_include module=system template=inc_config_bool var=show_patient_link}}
	
  <tr>
    <td class="button" colspan="6">
      <button class="modify" type="submit">{{tr}}Save{{/tr}}</button>
    </td>
  </tr>

</table>

</form>