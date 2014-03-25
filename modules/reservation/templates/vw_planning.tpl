{{*
 * $Id:$
 * 
 * @package    Mediboard
 * @subpackage reservation
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision:$
 *}}

{{mb_script module=dPplanningOp script=operation}}
{{if "dPfacturation"|module_active}}
  {{mb_script module=facturation script=facture}}
{{/if}}

<script>

  function strpad(val) {
    return (!isNaN(val) && val.toString().length==1) ? "0" + val : val;
  }

  togglePlayPause = function(button) {
    button.toggleClassName("play");
    button.toggleClassName("pause");
    if (!(window.autoRefreshPlanningResa)) {
      window.autoRefreshPlanningResa = setInterval(function(){
        refreshPlanning();
      }, ({{math equation="a*1000" a=$conf.dPbloc.CPlageOp.time_autorefresh}}));
    }
    else {
      clearTimeout(window.autoRefreshPlanningResa);
    }
  };

  refreshPlanning = function() {
    var form = getForm("filterPlanning");
    var url = new Url("reservation", "ajax_vw_planning");
    url.addParam("current_m"    , "{{$current_m}}");
    var week_container = $$(".week-container")[0];
    if (week_container) {
      url.addParam("scroll_top", week_container.scrollTop);
    }
    url.requestUpdate("planning");
  };

  modifPlage = function(plageop_id) {
    var oform = getForm("filterPlanning");
    console.log(oform.bloc_id);
    var url = new Url('dPbloc', 'inc_edit_planning');
    url.addParam('plageop_id', plageop_id);
    url.addParam('date', $(oform.date_planning).getValue());
    url.addParam('bloc_id', $(oform.bloc_id).getValue());
    url.requestModal(800);
    url.modalObject.observe("afterClose", function() {
      refreshPlanning();
    });
  };

  modifIntervention = function(date, hour, salle_id, operation_id, enplage, chir_id, minutes) {
    if (enplage) {
      var url = new Url("dPplanningOp", "vw_edit_planning");
    }
    else {
      var url = new Url("dPplanningOp", "vw_edit_urgence");
      url.addParam("date_urgence", date);
      url.addParam("hour_urgence", hour);
      url.addParam("salle_id"    , salle_id);
      url.addParam("min_urgence" , minutes);
    }

    if (chir_id) {
      url.addParam("chir_id", chir_id);
    }

    url.addParam("operation_id", operation_id);
    url.addParam("dialog", 1);
    url.modal({
      width: "95%",
      height: "95%",
      onClose: function(){ refreshPlanning(); } // Laisser dans une fonction anonyme a cause de l'argument "period"
    });
  };

  deleteCommentaire = function(commentaire_id) {
    var form = getForm("editCommentairePlanning");
    $V(form.commentaire_planning_id, commentaire_id);
    confirmDeletion(form, {typeName:'Commentaire '+commentaire_id, ajax: true}, {onComplete: refreshPlanning});
    $V(form.del, 0);
  };

  pasteCommentaire = function(date_planning, salle_id, hour_debut, hour_fin, color, commentaire_id) {
    //if commentaire_id => cut
    var form = getForm("editCommentairePlanning");
    $V(form.commentaire_planning_id, commentaire_id);
    $V(form.debut, date_planning+" "+hour_debut);
    $V(form.fin, date_planning+" "+hour_fin);
    $V(form.salle_id, salle_id);
    $V(form.commentaire, window.copy_commentaire_commentaire);
    $V(form.libelle, window.copy_commentaire_libelle);
    $V(form.color, color);

    onSubmitFormAjax(form, {onComplete: function() {
      updateStatusCut();
      refreshPlanning();
    } });
  };

  pasteIntervention = function(operation_id, salle_id, time, sejour_id, duree) {
    var date = window.calendar_planning.altElement.defaultValue;
    var datetime_interv = date + " " + time;

    // Mode copier
    // Ouverture de modale pour modifier �ventuellement les dates du s�jour
    if (sejour_id) {
      window.save_copy_operation =
      { "operation_id": operation_id,
        "date": date,
        "duree": duree,
        "time_operation": time,
        "salle_id": salle_id
      };

      // Cr�ation d'un nouveau s�jour si la date d'intervention ne colle pas
      if (datetime_interv < window.save_entree_prevue || datetime_interv > window.save_sortie_prevue) {
        modifSejour(null, datetime_interv, sejour_id, null, null, true, "afterCopy");
      }
      // Sinon, on passe le sejour_id pour une modification
      else {
        modifSejour(null, datetime_interv, sejour_id, window.save_entree_prevue, window.save_sortie_prevue, false, "afterCopy");
      }
      return;
    }

    // Mode couper
    if (datetime_interv < window.save_entree_prevue || datetime_interv > window.save_sortie_prevue) {
      window.save_cut_operation =
      { "operation_id": operation_id,
        "date": date,
        "time_operation": time,
        "salle_id": salle_id
      };

      modifSejour(operation_id, datetime_interv, null, null, null, null, "afterModifSejour");
      return;
    }

    var form = getForm("cutOperation");

    $V(form.operation_id  , operation_id);
    $V(form.date          , date);
    $V(form.salle_id      , salle_id);
    $V(form.time_operation, time);

    onSubmitFormAjax(form, {onComplete: function() {
      window.cut_operation_id = null;
      updateStatusCut();
      refreshPlanning();
    } });
  };

  updateStatusCut = function() {
    var div = $("status_cut");
    if (window.cut_operation_id) {
      div.update("Intervention coup�e");
      div.setStyle({borderColor: "#080"});
    }
    else if (window.copy_operation_id) {
      div.update("Intervention copi�e");
      div.setStyle({borderColor: "#080"});
    }
    else if (window.copy_commentaire_id) {
      div.update("Commentaire copi�");
      div.setStyle({borderColor: "#080"});
    }
    else {
      div.update();
      div.setStyle({borderColor: "#ddd"});
      if (window.save_elem) {
        window.save_elem.removeClassName("opacity-50");
      }
    }
  };

  modifSejour = function(operation_id, date_move, sejour_id, entree_prevue, sortie_prevue, new_sejour, callback) {
    var url = new Url("dPplanningOp", "ajax_edit_dates_sejour");
    if (sejour_id) {
      url.addParam("sejour_id", sejour_id);
      url.addParam("new_sejour", new_sejour ? 1 : 0);
      if (new_sejour) {
        url.addParam("hour_intervention", window.save_copy_operation.time_operation);
        url.addParam("duree", window.save_copy_operation.duree);
      }
    }
    else {
      url.addParam("operation_id", operation_id);
    }

    url.addParam("date_move", date_move);
    if (callback) {
      url.addParam("callback", callback);
    }
    if (entree_prevue && sortie_prevue) {
      url.addParam("entree_prevue", entree_prevue);
      url.addParam("sortie_prevue", sortie_prevue);
    }
    url.requestModal(300);
    url.modalObject.observe("afterClose", refreshPlanning);
  };

  afterModifSejour = function() {
    // Apr�s un drag and drop
    if (window.save_operation) {
      var form = getForm("editOperation");
      $V(form.operation_id  , window.save_operation.operation_id);
      $V(form.time_operation, window.save_operation.time_operation);
      $V(form.temp_operation, window.save_operation.temp_operation);
      $V(form.salle_id      , window.save_operation.salle_id);

      onSubmitFormAjax(form, {onComplete: function() {
        getForm("editSejour").onsubmit = "";
        window.cut_operation_id = null;
        updateStatusCut();
        onSubmitFormAjax(getForm("editSejour"), {onComplete: Control.Modal.close});
      }
      });
      window.save_cut_operation = null;
      return;
    }


    // Apr�s un couper
    if (window.save_cut_operation) {
      var form = getForm("cutOperation");
      $V(form.operation_id, window.save_cut_operation.operation_id);
      $V(form.date, window.save_cut_operation.date);
      $V(form.time_operation, window.save_cut_operation.time_operation);
      $V(form.salle_id, window.save_cut_operation.salle_id);
      onSubmitFormAjax(form, {onComplete: function() {
        getForm("editSejour").onsubmit = "";
        window.cut_operation_id = null;
        updateStatusCut();
        onSubmitFormAjax(getForm("editSejour"), {onComplete: Control.Modal.close});
      }
      });
      window.save_cut_operation = null;
    }
  };

  modifCommentaire = function(date, hour, salle_id, commentaire_id, clone) {
    var url = new Url("reservation", "ajax_edit_commentaire");

    if (commentaire_id) {
      url.addParam("commentaire_id", commentaire_id);
    }

    if (clone) {
      url.addParam("clone", true);
    }

    url.addParam("date", date);
    url.addParam("hour", hour);
    url.addParam("salle_id", salle_id);

    url.requestModal(500, 300);
    url.modalObject.observe("afterClose", refreshPlanning);
  };

  afterCopy = function(sejour_id, sejour) {
    // Apr�s la copie de s�jour et intervention,
    // on ne vide pas l'op�ration sauvegard�e
    // pour continuer � la coller
    var form = getForm("copyOperation");
    $V(form.copy_operation_id, window.save_copy_operation.operation_id);
    $V(form.salle_id, window.save_copy_operation.salle_id);
    $V(form.sejour_id, sejour_id);
    $V(form.date, window.save_copy_operation.date);
    $V(form.time_operation, window.save_copy_operation.time_operation);
    onSubmitFormAjax(form, {onComplete: Control.Modal.close});
  };

  planningInter = function(plageop_id) {
    var url = new Url("dPbloc", "vw_edit_interventions");
    url.addParam("plageop_id", plageop_id);
    url.requestModal(1000,700);
    url.modalObject.observe("afterClose", refreshPlanning);
  };

  openLegend = function() {
    var url = new Url("reservation", "ajax_legend_planning");
    url.requestModal();
  };


  updateSession = function(variable, value) {
    var url = new Url("{{$current_m}}", "ajax_assign_session");
    url.addParam("var", variable);
    url.addParam("value", value);
    url.requestUpdate("systemMsg", function() {
      refreshPlanning();
    });
  };

  modalDossierBloc = function(operation_id) {
    var url = new Url("dPsalleOp", "ajax_vw_operation");
    url.addParam("op", operation_id);
    url.addParam("hide_finished", 1);
    url.requestModal(1000,500);
  };

  resetCopy = function() {
    window.cut_operation_id = null;
    window.copy_operation_id = null;
    window.copy_commentaire_id = null;
    updateStatusCut();
  };

  Main.add(function() {
    var form = getForm("filterPlanning");
    window.calendar_planning = Calendar.regField(form.date_planning);
    refreshPlanning();
    if (Preferences.startAutoRefreshAtStartup == 1) {
      togglePlayPause($('autorefreshPlanningButton'));
    }
  });
</script>

<form name="editOperation" method="post">
  <input type="hidden" name="m" value="dPplanningOp" />
  <input type="hidden" name="dosql" value="do_planning_aed" />
  <input type="hidden" name="operation_id" />
  <input type="hidden" name="time_operation" />
  <input type="hidden" name="temp_operation" />
  <input type="hidden" name="salle_id" />
</form>

<form name="cutOperation" method="post">
  <input type="hidden" name="m" value="dPplanningOp" />
  <input type="hidden" name="dosql" value="do_cut_operation" />
  <input type="hidden" name="operation_id" />
  <input type="hidden" name="date" />
  <input type="hidden" name="time_operation" />
  <input type="hidden" name="salle_id" />
</form>

<form name="copyOperation" method="post">
  <input type="hidden" name="m" value="dPplanningOp" />
  <input type="hidden" name="dosql" value="do_copy_operation" />
  <input type="hidden" name="copy_operation_id" />
  <input type="hidden" name="salle_id" />
  <input type="hidden" name="sejour_id" />
  <input type="hidden" name="date" />
  <input type="hidden" name="time_operation" />
</form>

<form name="editCommentairePlanning" method="post">
  <input type="hidden" name="m" value="reservation" />
  <input type="hidden" name="dosql" value="do_commentaire_planning_aed" />
  <input type="hidden" name="commentaire_planning_id" />
  <input type="hidden" name="del" value="0"/>
  <input type="hidden" name="debut" />
  <input type="hidden" name="fin" />
  <input type="hidden" name="salle_id" />
  <input type="hidden" name="commentaire" />
  <input type="hidden" name="libelle" />
  <input type="hidden" name="color"/>
</form>

<form name="filterPlanning" method="get"> 
  <table class="form">
    <tr>
      <th class="category" colspan="5">
        <span style="float:left;"><button id="autorefreshPlanningButton" class="play" title="Arr�ter / Relancer le rafra�chissement automatique" onclick="togglePlayPause(this);" type="button">Rech. auto</button></span>
        <span style="float:left;"><button id="autorefreshPlanningButton" class="new" onclick="modifPlage();" type="button">Ajouter une plage</button></span>
        Filtre
      </th>
      <th class="category">
        Interface
      </th>
      <th class="category">
        <a href="#" class="button search" onclick="openLegend();">{{tr}}Legend{{/tr}}</a>
      </th>
    </tr>
    <tr>
      <td>
        <a href="#1" onclick="window.calendar_planning.datePicked(new Date(new Date(window.calendar_planning.altElement.defaultValue).setHours('-24')))">&lt;&lt;&lt;</a>
        <label>
        Date <input name="date_planning" type="hidden" value="{{$date_planning}}" class="date" onchange="updateSession('date_planning', this.value);"/>
        </label>
        <a href="#1" onclick="window.calendar_planning.datePicked(new Date(new Date(window.calendar_planning.altElement.defaultValue).setHours('+24')))">&gt;&gt;&gt;</a>
      </td>
      <td>
          <label>
            Praticien
            <select name="planning_chir_id" onchange="updateSession('planning_chir_id', this.value);">
              <option value="">&mdash; Tous les praticiens</option>
              {{mb_include module=mediusers template=inc_options_mediuser list=$praticiens selected=$praticien_id}}
            </select>
          </label>
      </td>
      <td>
        <label>
          {{tr}}CBlocOperatoire{{/tr}}
          <select name="bloc_id" onchange="updateSession('bloc_id', this.value);">
            <option value="">&mdash; {{tr}}CBlocOperatoire.all{{/tr}}</option>
            {{foreach from=$blocs item=_bloc}}
              <option value="{{$_bloc->_id}}" {{if $bloc_id == $_bloc->_id}}selected{{/if}}>{{$_bloc->nom}}</option>
            {{/foreach}}
          </select>
        </label>
      </td>
      <td>
        <label>
          <input type="checkbox" name="show_cancelled" {{if $show_cancelled}}checked{{/if}} onclick="updateSession('show_cancelled', (this.checked) ? 1 : 0);"/>
            {{tr}}checkbox-COperation-show_cancelled{{/tr}}
        </label>
      </td>
      <td>
          <label>
            <input type="checkbox" name="show_operations" {{if $show_operations}}checked{{/if}} onclick="updateSession('show_operations', (this.checked) ? 1 : 0);"/>
            {{tr}}checkbox-COperation-show_operations{{/tr}}
          </label>
      </td>
      <td>
        <label>
          <input type="checkbox" name="_comment_mode" /> Mode commentaire
        </label>
      </td>
      <td class="narrow">
        <div id="status_cut" style="width: 100px; height: 14px; border: 2px dashed #ddd; font-weight: bold; text-align: center; cursor: pointer;"
          onclick="resetCopy();">
        </div>
      </td>
    </tr>
  </table>
</form>

<div id="planning"></div>
