{{*
  * $Id$
  * @param $_plage CPlageconsult
  *}}

{{mb_default var=multiple value=false}}

{{assign var="pct" value=$_plage->_fill_rate}}
{{if $pct gt 100}}
  {{assign var="pct" value=100}}
{{/if}}
{{if $pct lt 50}}
  {{assign var="backgroundClass" value="empty"}}
{{elseif $pct lt 90}}
  {{assign var="backgroundClass" value="normal"}}
{{elseif $pct lt 100}}
  {{assign var="backgroundClass" value="booked"}}
{{else}}
  {{assign var="backgroundClass" value="full"}}
{{/if}}
{{if $_plage->locked}}
  <img style="float: right; height: 12px;" src="style/mediboard/images/buttons/lock.png" />
{{/if}}
<a href="#{{$_plage->_id}}" onclick="RDVmultiples.loadPlageConsult({{$_plage->_id}}, null{{if $multiple}}, true{{/if}}); return false;">
  {{$_plage->date|date_format:"%A %d"}}
  {{mb_include module=system template=calendars/inc_week/inc_disponibilities object=$_plage}}
</a>
