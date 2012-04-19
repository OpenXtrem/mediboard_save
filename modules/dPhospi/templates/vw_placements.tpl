{{mb_script module=hospi script=affectation_uf}}

<script type='text/javascript'>
  Position.includeScrollOffsets = true;
  Placement = {
    tabs: null,
    updater: null,
    frequency: null,
    scrollAffectations: 0,
    scrollNonPlaces: 0,
    loadTableau: function(services_ids) {
      var url = new Url('dPhospi', 'vw_affectations');
      url.requestUpdate('tableau');
    },
    loadTemporel: function() {
      var url = new Url('dPhospi', 'vw_mouvements');
      url.requestUpdate('temporel');
    },
    showLegend: function() {
      modal("legend_" + this.tabs.activeLink.key);
    },
    selectServices: function() {
      var url = new Url("dPhospi", "ajax_select_services");
      url.addParam("view", this.tabs.activeLink.key);
      url.requestModal(null, null, {maxHeight: '600'});
    },
    loadActiveView: function() {
      switch (this.tabs.activeLink.key) {
        case 'tableau':
          this.loadTableau();
          break;
        case 'temporel':
          this.loadTemporel();
      }
    },
    init: function(frequency){
      this.frequency = frequency || this.frequency;
      
      var url = new Url("dPhospi", "vw_mouvements");
      Placement.updater = url.periodicalUpdate('temporel', {
        frequency: this.frequency,
        onCreate: function() {
          var view_affectations = $("view_affectations");
          var list_affectations = $("list_affectations");
          if (!view_affectations || !list_affectations) {
            return;
          }
          Placement.scrollAffectations = view_affectations.scrollTop;
          Placement.scrollNonPlaces    = list_affectations.scrollTop;
        }
      });
    },
    
    start: function(delay, frequency){
      this.stop();
      this.init.delay(delay, frequency);
    },
    
    stop: function(){
      if (this.updater) {
        this.updater.stop();
      }
    },
    
    resume: function(){
      if (this.updater) {
        this.updater.resume();
      }
    }
  }
  
  Main.add(function(){
    Placement.tabs = Control.Tabs.create('placements_tabs', true);
    if (Placement.tabs.activeLink.key == "temporel") {
      Placement.start(0, 120);
    }
    else {
      Placement.loadActiveView();
    }
  });
</script>

<!-- L�gendes -->
<div class="modal" id="legend_temporel" style="display: none;">
  {{mb_include module=hospi template=inc_legend_mouvement}}
</div>

<div class="modal" id="legend_tableau" style="display: none;">
  {{mb_include module=hospi template=legende}}
</div>

<ul class="control_tabs" id="placements_tabs">
  <li onmousedown="Placement.loadTableau();">
    <a href="#tableau">Tableau</a>
  </li>
  <li onmousedown="Placement.start(0, 120);">
    <a href="#temporel">Temporel</a>
  </li>
  <li>
    <button type="button" onclick="Placement.selectServices();" class="search">Services</button>
  </li>
  <li style="float: right">
    <button type="button" onclick="Placement.showLegend();" class="search">L�gende</button>
  </li>
</ul>

<hr class="control_tabs" />

<div id="tableau" style="display: none;"></div>
<div id="temporel" style="display: none;"></div>
