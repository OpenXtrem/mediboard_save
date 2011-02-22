var Tag = {
	attach: function(object_guid, tag_id) {
		var parts = object_guid.split("-");
		
		var url = new Url().mergeParams({
			m:            "system",
			dosql:        "do_tag_item_aed",
			object_class: parts[0],
			object_id:    parts[1],
			tag_id:       tag_id
		});
					
		url.requestUpdate("systemMsg", {method: "post"});
	},
	create: function(object_class, name, parent_tag_id) {
    var url = new Url().mergeParams({
      m:            "system",
      dosql:        "do_tag_aed",
      object_class: object_class,
      name:         name
    });
		
		if (parent_tag_id) {
			url.addParam("parent_tag_id", parent_id);
		}
    
    url.requestUpdate("systemMsg", {method: "post"});
	},
	manage: function(object_class) {
      new Url('system', 'vw_object_tag_manager')
         .addParam('object_class', object_class)
         .popup(800, 600, "Tags");
	},
	setNodeVisibility: function(node) {
    node = $(node);
    
    var row = node.up('tbody');
    var table = row.up('table');
    var opened = row.hasClassName("opened");
    var tagId = row.getAttribute("data-tag_id");
    
    if (opened) {
      node.show();
      
      var childRows = table.select('tbody[data-parent_tag_id='+tagId+']');
      childRows.invoke("setVisible", opened);
      
      var children = table.select('tbody[data-parent_tag_id='+tagId+'] .tree-folding');
      children.each(function(child) {
        Tag.setNodeVisibility(child);
      });
    }
    else {
      table.select('tbody.tag-'+tagId).invoke("hide");
    }
  },
	loadElements: function(node) {
    node = $(node);
		
		var row = node.up('tbody');
    var table = row.up('table');
		var columns = table.getAttribute("data-columns");
		
		if (columns) {
			columns = columns.split(",");
		}
		
		// Don't load if the row is closed
		if (!row.hasClassName("opened")) return;
		
		var nextRow = row.next('tbody');
		var insertAfter = ((nextRow && nextRow.getAttribute("data-tag_id")) || !nextRow);
		var insertion, target;
		var offset = parseInt(node.style.marginLeft)+18;
		var tagId = row.getAttribute("data-tag_id");
		
		if (insertAfter) {
			insertion = "after";
			target = row;
			//target = row.insert({after: "<tbody><tr><td colspan='10'></td></tr></tbody>"}).next('tbody');
		}
		else {
			return; // don't load if already loaded
      target = nextRow;
		}
		
		var url = new Url('system', 'ajax_list_objects_by_tag');
		url.addParam("tag_id", tagId);
		
		if (columns && columns.length) {
			url.addParam("col[]", columns, true);
		}
		
		url.requestUpdate(target, {
			insertion: insertion, 
			onComplete: function(){
				var tbody = row.next('tbody');
				
				tbody.className = row.className;
				tbody.addClassName('tag-'+tagId);
				tbody.setAttribute("data-parent_tag_id", tagId);
				
				var firstCells = tbody.select("td:first-of-type");
				firstCells.invoke("setStyle", {paddingLeft: offset+"px"});
			}
		});
	},
  removeItem: function(tag_item_id, onComplete) {
    var url = new Url().mergeParams({
      "@class": "CTagItem",
      tag_item_id: tag_item_id,
      del: 1
    })
    .requestUpdate("systemMsg", {method: "post", onComplete: onComplete || function(){} });
  },
  bindTag: function(object_guid, tag_id, onComplete) {
		var parts = object_guid.split("-");
    var url = new Url().mergeParams({
      "@class": "CTagItem",
      tag_id: tag_id,
      object_class: parts[0],
      object_id: parts[1]
    })
    .requestUpdate("systemMsg", {method: "post", onComplete: onComplete || function(){} });
  }
};
