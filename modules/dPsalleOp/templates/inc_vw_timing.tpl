<form name="timing{{$selOp->operation_id}}" action="?m={{$m}}" method="post">

<input type="hidden" name="m" value="dPplanningOp" />
<input type="hidden" name="dosql" value="do_planning_aed" />
<input type="hidden" name="operation_id" value="{{$selOp->operation_id}}" />
<input type="hidden" name="del" value="0" />

<table class="form" style="table-layout: fixed;">
  <tr>
    <th class="title" colspan="4">Horodatage</th>
		
  </tr>

	{{assign var=submit value=submitTiming}}
  {{assign var=opid value=$selOp->operation_id}}
  {{assign var=form value=timing$opid}}
  <tr>
    {{if @$modules.brancardage->_can->read}}
      {{mb_script module=brancardage script=creation_brancardage ajax=true}}
      <td id="demandebrancard-{{$selOp->sejour_id}}" rowspan="2"> </td>
      <script>
        Main.add(function () {
          var url = new Url("brancardage", "ajax_exist_brancard");
          url.addParam("sejour_id"    , "{{$selOp->sejour_id}}");
          url.addParam("salle_id"     , "{{$selOp->salle_id}}");
          url.addParam("operation_id" , '{{$selOp->_id}}');
          url.addParam("id"           , "demandebrancard");
          url.addParam("opid"         , "{{$opid}}");
          url.requestUpdate('demandebrancard-{{$selOp->sejour_id}}');
        });
      </script>
    {{/if}}
    
    {{include file=inc_field_timing.tpl object=$selOp field=entree_salle}}
    {{include file=inc_field_timing.tpl object=$selOp field=pose_garrot }}
    {{include file=inc_field_timing.tpl object=$selOp field=debut_op    }}
  </tr>
  <tr>
    {{include file=inc_field_timing.tpl object=$selOp field=sortie_salle  }}
    {{include file=inc_field_timing.tpl object=$selOp field=retrait_garrot}}
    {{include file=inc_field_timing.tpl object=$selOp field=fin_op        }}
  </tr>
</table>

</form>
