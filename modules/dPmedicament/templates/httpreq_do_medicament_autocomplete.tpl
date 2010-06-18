{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage dPmedicament
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<ul>
  {{foreach from=$produits item=produit}}
    <li style="text-align: left;">
      <small style="display: none;" class="code-cip">{{$produit->CodeCIP}}</small>
      <small style="display: none;" class="code-ucd">{{$produit->CodeUCD}}</small>
      <small style="display: none;" class="code-cis">{{$produit->code_cis}}</small>
			Produit:
			<strong> 
			{{if $search_libelle_long}}
				{{$produit->LibelleLong|emphasize:$tokens}}
			{{else}}
			  {{if $search_by_cis}}
			    {{$produit->ucd_view|emphasize:$tokens}}
			  {{else}}
			    {{$produit->Libelle|emphasize:$tokens}}
			  {{/if}}
			{{/if}}
			</strong>
			<br />
			{{* if !$search_libelle_long && $search_by_cis *}}
			<small>
				<span style="opacity: 0.5">
					{{if $produit->dci}}
					  DCI: {{$produit->dci|upper|emphasize:$tokens}} - 
					{{/if}}
					{{if $produit->CodeUCD || $produit->code_cis}}
					  {{$produit->forme_galenique}}
					{{/if}}
				</span>
			</small>
			{{* /if *}}
			{{if $produit->Commentaire}}
			<div style="padding-left: 1em">
			  ({{$produit->Commentaire|emphasize:$tokens}})
			</div>
			{{/if}}
      
      <small style="display: none;" class="libelle-long">{{$produit->LibelleLong}}</small>
      <small style="display: none;" class="libelle">{{$produit->Libelle}}</small>
    </li>
  {{foreachelse}}
    <li style="text-align: left;"><span class="informal">Aucun r�sultat</span></li>
  {{/foreach}}
</ul>