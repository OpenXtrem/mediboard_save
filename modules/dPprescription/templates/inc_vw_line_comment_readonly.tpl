{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

{{assign var=line value=$_line_comment}}  

{{if $line->category_prescription_id}}
	<!-- Commentaire d'elements -->
	{{assign var=category value=$line->_ref_category_prescription}}
	{{assign var=div_refresh value=$element}}
{{else}}
  <!-- Commentaires de medicaments -->
  {{assign var=div_refresh value="medicament"}}  
{{/if}}	  

<tbody class="hoverable">
   <tr>
     <td style="width: 25px"></td>
     <td style="width: 80%;" class="text">
       {{$line->commentaire|nl2br}}
     </td>
     
     <td style="text-align: right;">
	     {{if $line->category_prescription_id || $prescription_reelle->type != "sejour"}}
		     {{if $line->category_prescription_id}}
		       <b>Ex�cutant</b>: {{if $line->executant_prescription_line_id || $line->user_executant_id}}{{$line->_ref_executant->_view}}{{else}}aucun{{/if}}
		     {{/if}}
		       {{if $prescription_reelle->type != "sejour"}}
		         <b>{{mb_label object=$line field="ald"}}</b>: {{if $line->ald}}Oui{{else}}Non{{/if}}
		       {{/if}}
	     {{/if}}
     </td>
     <td />
     <td style="text-align: right"> 
       <div class="mediuser" style="border-color: #{{$line->_ref_praticien->_ref_function->color}};">
	       <!-- Affichage de la signature du praticien -->
	       {{if $line->_can_view_signature_praticien}}
	         {{include file="../../dPprescription/templates/line/inc_vw_signature_praticien.tpl"}}
	       {{elseif !$line->_protocole}}
	         {{$line->_ref_praticien->_view}}    
	       {{/if}}
	       <button class="edit notext" onclick="Prescription.reload('{{$prescription_reelle->_id}}', '', '{{$div_refresh}}', '', '{{$mode_pharma}}', null, true, {{$lite}},'{{$line->_guid}}');"></button>
       </div>
     </td>
  </tr>
</tbody>