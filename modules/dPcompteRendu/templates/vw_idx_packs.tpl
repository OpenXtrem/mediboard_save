<!--  $Id$ -->
<script type="text/javascript">

function checkForm() {
  var form = document.editFrm;
  var field = null;
   
  if (field = form.elements['user_id']) {
    if (field.value == 0) {
      alert("Utilisateur ind�termin�");
      field.focus();
      return false;
    }
  }

  if (field = form.elements['nom']) {    
    if (field.value == 0) {
      alert("Intitul� ind�termin�");
      field.focus();
      return false;
    }
  }
    
  return true;
}
</script>

<table class="main">

<tr>
  <td class="greedyPane">

    <form name="filterFrm" action="?" method="get">
    
    <input type="hidden" name="m" value="{{$m}}" />

	<a href="index.php?m={{$m}}&amp;tab={{$tab}}&amp;pack_id=0" class="buttonnew"><strong>Cr�er un pack</strong></a>
        
    <table class="form">

      <tr>
        <th><label for="filter_user_id" title="Filtrer les packs pour cet utilisateur">Utilisateur</label></th>
        <td>
          <select name="filter_user_id" onchange="this.form.submit()">
            <option value="0">&mdash; Tous les utilisateurs</option>
            {{foreach from=$users item=curr_user}}
            <option value="{{$curr_user->user_id}}" {{if $curr_user->user_id == $user_id}} selected="selected" {{/if}}>
              {{$curr_user->_view}}
            </option>
            {{/foreach}}
          </select>
        </td>
      </tr>
    </table>

    </form>
    
    <table class="tbl">
    
    <tr>
      <th colspan="4"><strong>Packs cr��es</strong></th>
    </tr>
    
    <tr>
      <th>Utilisateur</th>
      <th>Nom</th>
      <th>modeles</th>
    </tr>

    {{foreach from=$packs item=curr_pack}}
    <tr>
      {{eval var=$curr_pack->pack_id assign="pack_id"}}
      {{assign var="href" value="?m=$m&amp;tab=$tab&amp;pack_id=$pack_id"}}
      <td><a href="{{$href}}">{{$curr_pack->_ref_chir->_view}}</a></td>
      <td><a href="{{$href}}">{{$curr_pack->nom}}</a></td>
      <td><a href="{{$href}}">{{$curr_pack->_modeles|@count}}</a></td>
    </tr>
    {{/foreach}}
      
    </table>

  </td>
  
  <td class="pane">

    <form name="editFrm" action="?m={{$m}}" method="post" onsubmit="return checkForm()">

    <input type="hidden" name="dosql" value="do_pack_aed" />
    <input type="hidden" name="pack_id" value="{{$pack->pack_id}}" />
    <input type="hidden" name="del" value="0" />

    <table class="form">

    <tr>
      <th class="category" colspan="2">
      {{if $pack->pack_id}}
        Modification d'un pack
      {{else}}
        Cr�ation d'un pack
      {{/if}}
      </th>
    </tr>

    <tr>
      <th>
        <label for="chir_id" title="Utilisateur concern�, obligatoire.">Utilisateur</label>
      </th>
      <td>
        <select name="chir_id" title="{{$pack->_props.chir_id}}">
          <option value="0">&mdash; Choisir un utilisateur</option>
          {{foreach from=$users item=curr_user}}
          <option value="{{$curr_user->user_id}}" {{if $curr_user->user_id == $pack->chir_id}} selected="selected" {{/if}}>
            {{$curr_user->_view}}
          </option>
          {{/foreach}}
        </select>
      </td>
    </tr>

    <tr>
      <th><label for="nom" title="intitul� du pack, obligatoire.">Intitul�</label></th>
      <td><input type="text" title="{{$pack->_props.nom}}" name="nom" value="{{$pack->nom}}" /></td>
    </tr>

    <tr>
      <td class="button" colspan="2">
        {{if $pack->pack_id}}
        <button class="submit" type="submit">
          Valider
        </button>
        <button class="trash" type="button" onclick="confirmDeletion(this.form,{typeName:'le pack',objName:'{{$pack->nom|escape:javascript}}'})">
          Supprimer
        </button>
        {{else}}
        <button class="submit" type="submit">
          Cr�er
        </button>
        {{/if}}
      </td>
    </tr>

    </table>
    
    </form>

  </td>
  
  {{if $pack->pack_id}}
  <td class="pane">
  
    <table class="form">
      {{if $pack->_modeles|@count}}
      <tr><th class="category" colspan="2">Mod�les du pack</th></tr>
      {{foreach from=$pack->_modeles item=curr_modele}}
      <tr><td>{{$curr_modele->nom}}</td>
        <td>
          <form name="delFrm{{$pack->pack_id}}" action="?m={{$m}}" method="post" onsubmit="return checkForm()">
          <input type="hidden" name="dosql" value="do_pack_aed" />
          <input type="hidden" name="pack_id" value="{{$pack->pack_id}}" />
          <input type="hidden" name="del" value="0" />
          <input type="hidden" name="modeles" value="{{$pack->modeles|escape:javascript}}" />
          <input type="hidden" name="_del" value="{{$curr_modele->compte_rendu_id}}" />
          <button class="trash notext" type="submit"></button>
          </form>
        </td>
      </tr>
      {{/foreach}}
      {{/if}}
      <tr><th class="category" colspan="2">Ajouter un mod�le</th></tr>
      <tr><td colspan="2">
        <form name="addFrm" action="?m={{$m}}" method="post" onsubmit="return checkForm()">
        <input type="hidden" name="dosql" value="do_pack_aed" />
        <input type="hidden" name="pack_id" value="{{$pack->pack_id}}" />
        <input type="hidden" name="del" value="0" />
        <input type="hidden" name="modeles" value="{{$pack->modeles|escape:javascript}}" />
        <select name="_new">
          <option value="">&mdash; Choisir un mod�le</option>
          <optgroup label="Mod�les du praticien">
            {{foreach from=$listModelePrat item=curr_modele}}
            <option value="{{$curr_modele->compte_rendu_id}}">{{$curr_modele->nom}}</option>
            {{/foreach}}
          </optgroup>
          <optgroup label="Mod�les du cabinet">
            {{foreach from=$listModeleFunc item=curr_modele}}
            <option value="{{$curr_modele->compte_rendu_id}}">{{$curr_modele->nom}}</option>
            {{/foreach}}
          </optgroup>
        </select>
        <button type="submit" class="tick notext"></button>
        </form>
      </td></tr>
    </table>
  
  </td>
  {{/if}}
  
</tr>

</table>
