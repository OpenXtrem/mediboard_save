<tr>
  <td>
    {{if $_operation->_ref_hprim_files|@count}}
     <img src="images/icons/tick.png" alt="ok" />
    {{else}}
    <img src="images/icons/cross.png" alt="alerte" />
    {{/if}}
  </td>
  
	<td>
  	{{assign var=sejour value=$_operation->_ref_sejour}}
    [{{$sejour->_num_dossier}}]
  </td>
  
	<td class="text">
    {{$_operation->_ref_chir}}
  </td>
	
  <td class="text">
    {{assign var=patient value=$sejour->_ref_patient}}
		[{{$patient->_IPP}}] 
    <a title="Voir le dossier PMSI" href="?m=dPpmsi&amp;tab=vw_dossier&amp;pat_id={{$sejour->patient_id}}">
			{{$patient}}
    </a>
  </td>

  <td>
    {{if $_operation->rank}}
      {{$_operation->time_operation|date_format:$dPconfig.time}}
    {{else}}
      NP
    {{/if}}
  </td>
	
  <td class="text">
  	{{mb_include module=dPplanningOp template=inc_vw_operation}}
  </td>
  
	<td style="text-align: center">
    {{mb_value object=$_operation field=labo}}
  </td>
  <td style="text-align: center">
    {{mb_value object=$_operation field=anapath}}
  </td>
</tr>