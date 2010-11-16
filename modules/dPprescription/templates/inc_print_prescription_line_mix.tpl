{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<li>{{if !$praticien->_id && $perf->_ref_prescription->object_id}}({{$perf->_ref_praticien->_view}}){{/if}}
	<strong>{{$perf->_view}}
	{{if $perf->duree}}
	  pendant {{$perf->duree}} {{$perf->unite_duree}}(s)
	{{/if}}
	{{if $perf->_protocole}}
	  {{if $perf->decalage_interv != NULL}}
      � partir de I 
      {{if $perf->decalage_interv >= 0}}+{{/if}}
        {{mb_value object=$perf field=decalage_interv}}
         heures
     {{/if}}
	{{else}}
	  {{if $perf->date_debut}}
	    � partir du {{mb_value object=$perf field="date_debut"}}
	    {{if $perf->time_debut}}
	      � {{mb_value object=$perf field="time_debut"}}
	    {{/if}}
	  {{/if}}
	{{/if}}
	</strong>
	{{if $perf->commentaire}}
    ({{$perf->commentaire}})
  {{/if}}
	<ul>
	  {{foreach from=$perf->_ref_lines item=_line}}
	  <li>
	    <strong>{{$_line->_ucd_view}}</strong>: {{$_line->_posologie}}
	  </li>  
	  {{/foreach}}
	</ul>
</li>