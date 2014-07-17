{{*
 * $Id$
 *  
 * @category Drawing
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
*}}

<fieldset class="active" id="draw_tools_1">
  <legend>Dessin au crayon</legend>
  <p><label>Largeur du trait<input type="range" min="1" max="10" value="3" onchange="DrawObject.changeDrawWidth($V(this));"/></label></p>
  <p><label>Couleur
      <div class="basic_color" style="background-color: black;" onclick="colorSelect('black');"></div>
      <div class="basic_color" style="background-color: gray;" onclick="colorSelect('gray');"></div>
      <div class="basic_color" style="background-color: white;" onclick="colorSelect('white');"></div>
      <div class="basic_color" style="background-color: blue;" onclick="colorSelect('blue');"></div>
      <div class="basic_color" style="background-color: green;" onclick="colorSelect('green');"></div>
      <div class="basic_color" style="background-color: yellow;" onclick="colorSelect('yellow');"></div>
      <div class="basic_color" style="background-color: red;" onclick="colorSelect('red');"></div>
      <div class="basic_color" style="background-color: fuchsia;" onclick="colorSelect('fuchsia');"></div>
      {{if $app->user_prefs.drawing_advanced_mode}}
        <form name="osef" method="get" onsubmit="return false;">
          <input type="hidden" name="color_inout" value="#fff" onchange="colorSelect(this.value);"/>
          <script>
            ColorSelector.init = function(form_name) {
              this.sForm  = form_name;
              this.sColor = "color_inout";
              this.sColorView = 'current_color';
              this.pop();
            };
          </script>
          <button style="border:none; display: inline-block; width:1.35em; height: 2em; text-align: center;" onclick="ColorSelector.init(this.form);">P</button>
        </form>
      {{/if}}
      <span style="display:block; width: 100%; height:1.5em; background-color: black;" id="current_color"></span>

    </label>
  </p>
</fieldset>

<button class="switch" onclick="toggleMode();"></button>

<fieldset id="draw_tools_0">
  <legend>Controles</legend>
  <button onclick="DrawObject.removeActiveObject();" class="cancel notext">{{tr}}drawobject.delete{{/tr}}</button>
  <button onclick="DrawObject.zoomInObject()" class="zoom-in notext">{{tr}}drawobject.flipy-desc{{/tr}}</button>
  <button onclick="DrawObject.zoomOutObject()" class="zoom-out notext">{{tr}}drawobject.flipy-desc{{/tr}}</button>

  {{if $app->user_prefs.drawing_advanced_mode}}
    <button onclick="DrawObject.flipXObject()" class="hslip notext">{{tr}}drawobject.flipx-desc{{/tr}}</button>
    <button onclick="DrawObject.flipYObject()" class="vslip notext">{{tr}}drawobject.flipy-desc{{/tr}}</button>

    {{*<button onclick="DrawObject.sendToBack()"     class="down notext">{{tr}}drawobject.flipy-desc{{/tr}}</button>*}}
    <button onclick="DrawObject.sendBackwards()"  class="down notext">{{tr}}drawobject.flipy-desc{{/tr}}</button>
    <button onclick="DrawObject.bringForward()"   class="up notext">{{tr}}drawobject.flipy-desc{{/tr}}</button>
    {{*<button onclick="DrawObject.bringToFront()"   class="up notext">{{tr}}drawobject.flipy-desc{{/tr}}</button>*}}

    <p><label>Opacit�<input type="range" min="1" max="100" value="100" onchange="DrawObject.changeOpacty($V(this));"/></label></p>
  {{/if}}

</fieldset>

<hr/>

<fieldset>
  <legend>Historique</legend>
  <button onclick="DrawObject.undo()" class="undo">Annuler le dernier ajout</button>
  <button onclick="DrawObject.clearCanvas();" class="cleanup">Tout effacer</button>
</fieldset>

<hr/>

<form method="get" name="titi" >
  <table class="form">
    <tr>
      <th>Texte</th>
      <td>
        <textarea id="content_text_cv" name="content_text_cv"></textarea>
      </td>
    </tr>
    <tr>
      <th>Couleur</th>
      <td>
        <input type="color" value="#000000" name="color_text_cv" id="color_text_cv"/>
      </td>
    </tr>
    <tr>
      <th>{{if $app->user_prefs.drawing_advanced_mode}}
          Ombre<br/>du texte {{/if}}

      </th>
      <td>
        <input type="text" value="#ffffff 0 0 10px" name="bgcolor_text_cv" id="bgcolor_text_cv"   {{if !$app->user_prefs.drawing_advanced_mode}}
style="display: none;" {{/if}}            />
      </td>
    </tr>
    <tr>
      <td colspan="2" class="button">
        <button type="button" onclick="DrawObject.addEditText( $V('content_text_cv'), $V('color_text_cv'), $V('bgcolor_text_cv') );">Valider</button>
        <button type="button" onclick="Control.Modal.close();">Annuler</button>
      </td>
    </tr>
  </table>
</form>