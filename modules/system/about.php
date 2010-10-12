<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage system
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

?>

<script type="text/javascript">
var Slideshow = {
  container: null,
  
  next: function(){
    var i, slides = this.container.childElements();
    for (i = 0; i < slides.length; i++) {
      if (slides[i].visible()) {
        slides[i].fade({duration:0.5, afterFinishInternal:function(){
          slides[i].hide();
          slides[i+1].appear({duration:0.5, afterFinishInternal:function(){}});
        }});
        return false;
      }
    }
  },
  
  previous: function(){
    var i, slides = this.container.childElements();
    for (i = slides.length-1; i > 0; --i) {
      if (slides[i].visible()) {
        slides[i].fade({duration:0.5, afterFinishInternal:function(){
          slides[i].hide();
          slides[i-1].appear({duration:0.5, afterFinishInternal:function(){}});
        }});
        return false;
      }
    }
  }
};

Main.add(function(){
  Slideshow.container = $('slideshow');
});
</script>

<div id="slideshow">
  <div class="about">
    <div class="text">
      <h2>Pr�sentation</h2>
      <a href="http://www.mediboard.org/" title="Site du projet Mediboard" target="_blank">Mediboard</a>
      est un <strong>syst�me web open source de gestion d'�tablissements de sant�</strong>.
      Il se d�finit plus pr�cis�ment comme un <strong>SIH</strong> (Syst�me d'Information Hospitalier)
      c'est-�-dire un PGI (Progiciel de Gestion Integr�) adapt� aux <strong>�tablissements de sant� de toute taille</strong>,
      du simple cabinet de praticien au centre m�dical multi-sites.
    </div>
    <div class="nav">
      -
      <a href="#1" onclick="return Slideshow.next()">L'equipe &gt;&gt;</a>
    </div>
  </div>
  
  <div class="about" style="display: none;">
    <div class="text">
      <h2>L'equipe</h2>
      Romain Ollivier<br />
      Thomas Despoix<br />
      Alexis Granger<br />
      Fabien M�nager<br />
      Yohann Poiron<br />
      Flavien Crochard<br />
      <h2>Soci�t�s actives</h2>
      <a href="http://www.openxtrem.com" target="_blank">OpenXtrem</a><br />
      <a href="http://www.kheops.ch/" target="_blank">Kheops Technologies</a><br />
    </div>
    <div class="nav">
      <a href="#1" onclick="return Slideshow.previous()">&lt;&lt; Pr�sentation</a>
      -
      <a href="#1" onclick="return Slideshow.next()">Remerciements &gt;&gt;</a>
    </div>
  </div>
  
  <div class="about" style="display: none;">
    <div class="text">
      <h2>Remerciements</h2>
      Merci � tous les praticiens qui ont pris du temps sur leur emploi du temps d�j� charg�
      pour nous aider � mener ce projet � maturation.
    </div>
    <div class="nav">
      <a href="#" onclick="return Slideshow.previous()">&lt;&lt; L'�quipe</a>
      -
    </div>
  </div>
</div>