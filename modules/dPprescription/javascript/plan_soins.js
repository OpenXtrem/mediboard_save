/* $Id: $ */

/**
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision:  $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 */
 
PlanSoins = {
	formClick: null,
	composition_dossier: null,
	timeOutBefore: null,
	timeOutAfter: null,
	date: null,
	manual_planif: null,
	bornes_composition_dossier: null,
	
  init: function(options){
		Object.extend(PlanSoins, options);
		PlanSoins.formClick = getForm("click");
  },
	
	selColonne: function(hour){
	  $('plan_soin').select('div.non_administre:not(.perfusion), div.a_administrer:not(.perfusion)').each(function(oDiv){
	    if(oDiv.up("tbody").visible() && oDiv.up("td").hasClassName(hour)){
	      if(Object.isFunction(oDiv.onclick)){
	        oDiv.onclick();
	      }
	    }
    });
	},
	
	oDragOptions: {
	  constraint: 'horizontal',
	  revert: true,
	  ghosting: true,
	  starteffect : function(element) { 
	    new Effect.Opacity(element, { duration:0.2, from:1.0, to:0.7 }); 
	   // element.hide();
	  },
	  reverteffect: function(element, top_offset, left_offset) {
	    var dur = Math.sqrt(Math.abs(top_offset^2)+Math.abs(left_offset^2))*0.02;
	    element._revert = new Effect.Move(element, { 
	      x: -left_offset, 
	      y: -top_offset, 
	      duration: 0
	    } );
	   // Suppression des zones droppables sur le revert
	   Droppables.drops.clear(); 
	   element.show();
	  },
	  endeffect: function(element) { 
	    new Effect.Opacity(element, { duration:0.2, from:0.7, to:1.0 } ); 
	  }       
  },
	
	addAdministration: function(line_id, quantite, key_tab, object_class, dateTime, administrations, planification_id, multiple_adm) {
	  /*
	   Dans le cas des administrations multiples, si on clique sur la case principale, 
	   on selectionne toutes les administrations et on lance la fenetre d'administrations multiples
	  */
	  if(multiple_adm == 1){
	    var date_time = dateTime.replace(' ', '_').substring(0,13);
	    $('subadm_'+line_id+'_'+object_class+'_'+key_tab+'_'+date_time).select('div').each(function(e){
	      e.onclick.bind(e)();
	    });
	    PlanSoins.applyAdministrations();
	    return;
	  }
	  
	  // On ne permet pas de faire des planifications sur des lignes de medicament
	  if(!planification_id && (object_class == "CPrescriptionLineMedicament") && ($V(document.mode_dossier_soin.mode_dossier) == "planification")){
	    return;
	  }
	  
	  var url = new Url("dPprescription", "httpreq_add_administration");
	  url.addParam("line_id",  line_id);
	  url.addParam("quantite", quantite);
	  url.addParam("key_tab", key_tab);
	  url.addParam("object_class", object_class);
	  url.addParam("dateTime", dateTime);
	  url.addParam("administrations", administrations);
	  url.addParam("planification_id", planification_id);
	  url.addParam("date_sel", PlanSoins.date);
	  url.addParam("mode_dossier", $V(document.mode_dossier_soin.mode_dossier));
	  url.addParam("multiple_adm", multiple_adm);
	  url.popup(800,600,"Administration");
	},
	
	addPlanification: function(date, time, key_tab, object_id, object_class, element_id){
	  // Split de l'element_id
	  var element = element_id.split("_");
	  var original_date = element[3]+" "+element[4]+":00:00";
	  var quantite = element[5];
	  var planification_id = element[6];
	
	  // Hack pour corriger le probleme des planifications sur aucune prise prevue
	  if(element[2] == 'aucune' && element[3] == 'prise'){
	    original_date = element[4]+" "+element[5]+":00:00";
	    quantite = element[6];
	    planification_id = element[7];
	  }
	
	  var oForm = document.addPlanif;
	  $V(oForm.administrateur_id, User.id);
	  
	  $V(oForm.object_id, object_id);
	  $V(oForm.object_class, object_class);
	  
	  var prise_id = !isNaN(key_tab) ? key_tab : '';
	  var unite_prise = isNaN(key_tab) ? key_tab : '';
	
	  $V(oForm.unite_prise, unite_prise);
	  $V(oForm.prise_id, prise_id);
	  $V(oForm.quantite, quantite);
	
	  var dateTime = date+" "+time;
	  
	  $V(oForm.dateTime, dateTime);
	  if(planification_id){
	    $V(oForm.administration_id, planification_id);
	    oForm.original_dateTime.writeAttribute("disabled", "disabled");
	  } else { 
	    oForm.original_dateTime.enable();
	    $V(oForm.original_dateTime, original_date);
	  }
	  
	  if(original_date != dateTime || PlanSoins.manual_planif){
	    submitFormAjax(oForm, 'systemMsg', { onComplete: function(){ 
	      Prescription.loadTraitement(null,date, $V(getForm("click").nb_decalage), 'planification', object_id, object_class, key_tab);
	    } } ); 
	  }
	},
	
	
	toggleSelectForAdministration: function (element, line_id, quantite, key_tab, object_class, dateTime) {  
	  element = $(element);
	
	  // si la case est une administration multiple, on selectionne tous les elements � l'interieur
	  if(element.hasClassName('multiple_adm')){
	    element.next('div').select('div').invoke('onclick');
	  }
	  
	  if (element._administration) {
	    element.removeClassName('administration-selected');
	    element._administration = null;
	  }
	  else {
	    element.addClassName('administration-selected');
	    element._administration = {
	      line_id: line_id,
	      quantite: quantite,
	      key_tab: key_tab,
	      object_class: object_class,
	      dateTime: dateTime,
	      date_sel: PlanSoins.date
	    };
	  }
	},
	
	viewDossierSoin: function(element){  
	  // recuperation du mode d'affichage du dossier (administration ou planification)
	  mode_dossier = $V(document.mode_dossier_soin.mode_dossier);
	  
	  // Dossier en mode Administration
	  if(mode_dossier == "administration" || mode_dossier == ""){
	    if (PlanSoins.manual_planif) {
	      $$(".manual_planif").invoke("hide");
	    }
	    
	    $('button_administration').update("Appliquer les administrations s�lectionn�es");
	    element.select('.colorPlanif').each(function(elt){
	       elt.setStyle( { backgroundColor: '#FFD' } );
	    });
	    element.select('.draggablePlanif').each(function(elt){
	       elt.removeClassName("draggable");
	       elt.onmousedown = null;
	    });
	    element.select('.canDropPlanif').each(function(elt){
	       elt.removeClassName("canDrop");
	    });
	  }
	  
	  // Dossier en mode planification
	  if(mode_dossier == "planification"){
	    if (PlanSoins.manual_planif) {
	      var periode_visible = PlanSoins.composition_dossier[PlanSoins.formClick.nb_decalage.value];
	      PlanSoins.toggleManualPlanif(periode_visible);
	    }
	    
	    $('button_administration').update("Appliquer les planifications s�lectionn�es");
	    element.select('.colorPlanif').each(function(elt){
	       elt.setStyle( { backgroundColor: '#CAFFBA' } );
	    });
	    element.select('.draggablePlanif').each(function(elt){
	       elt.addClassName("draggable");
	       elt.onmousedown = function(){
	         PlanSoins.addDroppablesDiv(element);
	       }
	    });
	    element.select('.canDropPlanif').each(function(elt){
	       elt.addClassName("canDrop");
	    });
	  }
	},
	
	toggleManualPlanif: function(periode_visible){
	  var bornes_dossier = PlanSoins.bornes_composition_dossier;
	  var bornes_visibles = bornes_dossier[periode_visible];
	  
	  $$(".manual_planif").each(function(planif){
	    var date = planif.getAttribute("data-datetime");
	    if(date >= bornes_visibles["min"] && date <= bornes_visibles["max"]){
	      planif.show();
	    } else {
	      planif.hide();
	    }
	  });
	},

	// Deplacement du dossier de soin
	moveDossierSoin: function(element){
	  var periode_visible = PlanSoins.composition_dossier[PlanSoins.formClick.nb_decalage.value];
	  
	  PlanSoins.composition_dossier.each(function(moment){
	    listToHide = element.select('.'+moment);
	    listToHide.each(function(elt) { 
	      elt.show();
	    });  
	  });
	  PlanSoins.composition_dossier.each(function(moment){
	    if(moment != periode_visible){
	      listToHide = element.select('.'+moment);
	      listToHide.each(function(elt) { 
	        elt.hide();
	      });  
	    }
	  });
	  PlanSoins.viewDossierSoin(element);
	},
	
	addDroppablesDiv: function(draggable){
	  $('plan_soin').select('.before').each(function(td_before) {
	    td_before.onmouseover = function(){
	      PlanSoins.timeOutBefore = setTimeout(PlanSoins.showBefore, 1000);
	    }
	  });
	  $('plan_soin').select('.after').each(function(td_after) {
	    td_after.onmouseover = function(){
	      PlanSoins.timeOutAfter = setTimeout(PlanSoins.showAfter, 1000);
	    }
	  });
	  
	  $(draggable).up(1).select('td').each(function(td) {
	    if(td.hasClassName("canDrop")){
	      Droppables.add(td.id, {
	        onDrop: function(element) {
	          var _td = td.id.split("_");
	          line_id = _td[1];
	          line_class = _td[2];
	          unite_prise = td.getAttribute("data-uniteprise");
	          date = _td[4];
	          hour = _td[5];
	          
	          // Hack pour corriger le probleme des planifications sur aucune prise prevue
	          if(_td[3] == 'aucune' && _td[4] == 'prise'){
	            unite_prise = "aucune_prise";
	            date = _td[5];
	            hour = _td[6];
	          }
	          // Ajout de la planification
	          PlanSoins.addPlanification(date, hour+":00:00", unite_prise, line_id, line_class, element.id);
	          // Suppression des zones droppables
	          Droppables.drops.clear(); 
	          $('plan_soin').select('.before').each(function(td_before) {
	            td_before.onmouseover = null;
	          });
	          $('plan_soin').select('.after').each(function(td_after) {
	            td_after.onmouseover = null;
	          });
	        },
	        hoverclass:'soin-selected'
	      } );
	    } 
	  });
	},
	// Deplacement du dossier vers la gauche
	showBefore: function(){
	  if(PlanSoins.formClick.nb_decalage.value >= 1){
	    PlanSoins.formClick.nb_decalage.value = parseInt(PlanSoins.formClick.nb_decalage.value) - 1;
	    PlanSoins.moveDossierSoin($('plan_soin'));
	  }
	},
	
	// Deplacement du dossier de soin vers la droite
	showAfter: function(){
	  if(PlanSoins.formClick.nb_decalage.value <= 3){
	    PlanSoins.formClick.nb_decalage.value = parseInt(PlanSoins.formClick.nb_decalage.value) + 1;
	    PlanSoins.moveDossierSoin($('plan_soin'));
	  }
	},
	
	applyAdministrations: function () {
	  var administrations = {};
	   
	  $$('div.administration-selected').each(function(element) { 
	    if(!element.hasClassName('multiple_adm')){
	      var adm = element._administration;
	      administrations[adm.line_id+'_'+adm.key_tab+'_'+adm.dateTime] = adm; 
	    }
	  });
	  
	  $V(getForm("adm_multiple")._administrations, Object.toJSON(administrations));
	  
	  var url = new Url;
	  url.setModuleAction("dPprescription", "httpreq_add_multiple_administrations");
	  url.addParam("mode_dossier", $V(document.mode_dossier_soin.mode_dossier));
	  url.addParam("refresh_popup", "1");
	  url.popup(700, 600, "Administrations multiples");
	}
};