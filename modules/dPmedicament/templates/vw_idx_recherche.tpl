<script type="text/javascript">

function viewProduit(cip){
  var url = new Url;
  url.setModuleAction("dPmedicament", "vw_produit");
  url.addParam("CIP", cip);
  url.popup(700, 620, "Descriptif produit");
}

function changeFormSearch(){
  var oForm = document.formSearch;
  var type_recherche = oForm.type_recherche.value;
  if(type_recherche != "nom"){
    oForm.position_text.checked = false;
    oForm.position_text.disabled = true;
  }
  if(type_recherche == "nom"){
    oForm.position_text.disabled = false;
  }
}

function pageMain(){
  changeFormSearch();
}

</script>

<table class="main">
  <tr>
    <td>Recherche par
      <form name="formSearch" action="?m=dPmedicament&tab=vw_idx_recherche" method="post">
        <select name="type_recherche" onchange="changeFormSearch(this.value);">
          <option value="nom" {{if $type_recherche == 'nom'}}selected = "selected"{{/if}}>Nom</option>
          <option value="cip" {{if $type_recherche == 'cip'}}selected = "selected"{{/if}}>CIP</option>
          <option value="ucd" {{if $type_recherche == 'ucd'}}selected = "selected"{{/if}}>UCD</option>
        </select>
        <br />
        <input type="text" name="produit" value="{{$produit}}"/>
        <button type="button" class="search" onclick="submit();">Rechercher</button>
        <br />
        <input type="checkbox" name="supprime" value="1" {{if $supprime == 1}}checked = "checked"{{/if}} />
        Afficher les produits supprim�s
        <br />
        <input type="checkbox" name="position_text" value="partout" {{if $type_recherche == 'partout'}}checked = "checked"{{/if}} />
        Rechercher n'importe o� dans le nom du produit
      </form>
    </td>
  </tr>
  <tr>
    <td>
      <table class="tbl">
        <tr>
          <th colspan="2">{{$produits|@count}} R�sultat(s)</th>
        </tr>
        <tr>
          <th>CIP</th>
          <th>Produit</th>
        </tr>
        {{foreach from=$produits item="produit"}}
        <tr>
          <td>
            {{$produit->code_cip}}
            {{if $produit->hospitalier}}
            <img src="./images/icons/hopital.gif" alt="Produit Hospitalier" title="Produit Hospitalier" />
            {{/if}}
            {{if $produit->_generique}}
            <img src="./images/icons/generiques.gif" alt="Produit G�n�rique" title="Produit G�n�rique" />
            {{/if}}
            {{if $produit->_referent}}
            <img src="./images/icons/referents.gif" alt="Produit R�f�rent" title="Produit R�f�rent" />
            {{/if}}
          </td>
          <td>
            <a href="#produit{{$produit->code_cip}}" onclick="viewProduit({{$produit->code_cip}})" {{if $produit->_suppression}}style="color: red"{{/if}}>{{$produit->libelle}}</a>
          </td>
        </tr>
        {{/foreach}}
      </table>
    </td>
  </tr>
</table>
  
  
  
  
  
  