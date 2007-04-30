{{* $Id: list_examens.tpl 1792 2007-04-10 16:16:47Z MyttO $
  -- Parameters
  $examens : List of exams to display
  $examen_id : Selected exam
*}}
<table class="tbl">  <tr>
    <th colspan="4" class="title">Liste des examens</th>
 </tr>
 
  <tr>    <th>ID</th>    <th>Libell�</th>    <th>Unit�</th>
    <th>R�f�rences</th>  </tr>
    {{foreach from=$examens item="curr_examen"}}  <tr {{if $curr_examen->_id == $examen_id}} class="selected" {{/if}}>    <td>      <a href="?m={{$m}}&amp;tab={{$tab}}&amp;examen_labo_id={{$curr_examen->_id}}">        {{$curr_examen->identifiant}}      </a>    </td>    <td>      <a href="?m={{$m}}&amp;tab={{$tab}}&amp;examen_labo_id={{$curr_examen->_id}}">        {{$curr_examen->libelle}}      </a>    </td>    {{if $curr_examen->type == "num"}}    <td>{{$curr_examen->unite}}</td>
    <td>{{$curr_examen->min}} &ndash; {{$curr_examen->max}}</td>    {{else}}    <td colspan="2">{{mb_value object=$curr_examen field="type"}}</td>    {{/if}}  </tr>  {{/foreach}}</table>
