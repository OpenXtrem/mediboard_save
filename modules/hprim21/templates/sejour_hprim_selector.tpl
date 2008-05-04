<script type="text/javascript">

var Sejour = {
  
  select: function(Numdos) {
		window.opener.SejourHprimSelector.set(Numdos);
    window.close();
  }
}

</script>

<!-- Formulaire de recherche -->
<form action="?" name="patientSearch" method="get">

<input type="hidden" name="m" value="hprim21" />
<input type="hidden" name="a" value="pat_hprim_selector" />
<input type="hidden" name="dialog" value="1" />

<table class="form">

<tr>
  <th class="category" colspan="6">Crit�res de s�lection</th>
</tr>

<tr>
  <th><label for="name" title="Nom du patient � rechercher, au moins les premi�res lettres">Nom</label></th>
  <td><input name="name" value="{{$name|stripslashes}}" size="30" tabindex="1" /></td>
  
  <th><label for="nomjf" title="Nom de naissance">Nom de naissance</label></th>
  <td><input name="nomjf" value="{{$nomjf|stripslashes}}" size="30" tabindex="3" /></td>
  
  <td>
  </td>
</tr>

<tr>
  <th><label for="firstName" title="Pr�nom du patient � rechercher, au moins les premi�res lettres">Pr�nom</label></th>
  <td><input name="firstName" value="{{$firstName|stripslashes}}" size="30" tabindex="2" /></td>
  
  <th><label for="naissance" title="Date de naissance">Date de naissance</label></th>
  <td>
    {{html_select_date
      time=$datePat
      start_year=1900
      field_order=DMY
      day_empty="Jour"
      month_empty="Mois"
      year_empty="Ann�e"
      day_extra="tabindex='4'"
      month_extra="tabindex='5'"
      year_extra="tabindex='6'"
      all_extra="style='display:inline;'"}}         
    </td>
  <td><button class="search" type="submit">Rechercher</button></td>
</tr>
</table>

</form>

<!-- Liste de patients -->
<table class="tbl">
  <tr>
    <th class="category" colspan="5">Choisissez un patient dans la liste</th>
  </tr>
  <tr>
    <th align="center">Patient</th>
    <th align="center">Date de naissance</th>
    <th align="center">T�l�phone</th>
    <th align="center">Mobile</th>
    <th align="center">Actions</th>
  </tr>

  <!-- Recherche exacte -->
  {{foreach from=$patients item=_patient}}
    {{include file="inc_line_sejour_hprim_selector.tpl"}}
  {{foreachelse}}
  {{if $name || $firstName}}
  <tr>
    <td class="button" colspan="5">
      Aucun r�sultat exact
    </td>
  </tr>
  {{/if}}
  {{/foreach}}
  <tr>
    <td class="button" colspan="5">
      <button class="cancel" type="button" onclick="window.close()">Annuler</button>
    </td>
  </tr>

  <!-- Recherche phon�tique -->
  {{if $patientsSoundex|@count}}
  <tr>
    <th colspan="5">
      <em>R�sultats proches</em>
    </th>
  </tr>
  {{/if}}

  {{foreach from=$patientsSoundex item=_patient}}
    {{include file="inc_line_pat_hprim_selector.tpl"}}
  {{/foreach}}
</table>
