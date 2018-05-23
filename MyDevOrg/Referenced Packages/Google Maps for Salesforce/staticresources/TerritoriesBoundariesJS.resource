///**********************************************************************************/
///
///  (c) 2009-2012 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/


/////////////////////////////////////////////////////////////////////////////////////
// Boundary
/////////////////////////////////////////////////////////////////////////////////////
function Boundary(boundaryCode)
{
	this._boundaryCode = boundaryCode;
	this.tileSize = new google.maps.Size(256, 256);
}

Boundary.prototype = {};

Boundary.prototype.getTile = function(coord, zoom, ownerDocument) 
{
	return $("<img />")
		.css("opacity", $("#select_LayerOpacity").val())
		.attr("src", "http://commondatastorage.googleapis.com/pextiles/" + this._boundaryCode + "/" + zoom + "/" + coord.y + "/" + coord.x + ".png")
		.get(0);
};

/////////////////////////////////////////////////////////////////////////////////////
// Boundaries
/////////////////////////////////////////////////////////////////////////////////////
function Boundaries()
{
	this._initialized = false;
	this._boundaryItems = [];
	//this._region = userLocale.substr(3).toLowerCase();

	this._tagOverlayCollections = [];
	this._currentTagOverlayCollection = null;


	this._clickLatLng = null;
	this._clickListenerActive = true;
	this._doubleClickFlag = false;

	this._defaultBoundary = "uszc";

	this._currentZoomLevel = 0;

	this._active = false;	
}

Boundaries.prototype = {};

Boundaries.prototype.init = function()
{
	if (!this._initialized)
	{
		this._loadBoundaryList();
		
		this._tagOverlayCollections["usct"] = new TagOverlayCollection(["usst", "usct"], 
			[null,null,null,null,"usst","usct","usct", "usct","usct","usct","usct","usct","usct"]);
		this._tagOverlayCollections["uszc"] = new TagOverlayCollection(["usst", "uszc"], 
			[null,null,null,null,"usst","usst","usst", "uszc","uszc","uszc","uszc","uszc","uszc"]);
			
		this._tagOverlayCollections["nyad"] = new TagOverlayCollection(["nyad"], 
			[null,null,null,null,"nyad","nyad","nyad","nyad","nyad","nyad","nyad","nyad","nyad","nyad"]);
		this._tagOverlayCollections["nycc"] = new TagOverlayCollection(["nycc"], 
			[null,null,null,null,"nycc","nycc","nycc","nycc","nycc","nycc","nycc","nycc","nycc","nycc"]);
		this._tagOverlayCollections["nycg"] = new TagOverlayCollection(["nycg"], 
			[null,null,null,null,"nycg","nycg","nycg","nycg","nycg","nycg","nycg","nycg","nycg","nycg"]);
		this._tagOverlayCollections["nyss"] = new TagOverlayCollection(["nyss"], 
			[null,null,null,null,"nyss","nyss","nyss","nyss","nyss","nyss","nyss","nyss","nyss","nyss"]);

		this._tagOverlayCollections["zadi"] = new TagOverlayCollection(["zadi"], 
			[null,null,null,null,"zadi","zadi","zadi","zadi","zadi","zadi"]);
		this._tagOverlayCollections["zasd"] = new TagOverlayCollection(["zasd"], 
			[null,null,null,null,"zasd","zasd","zasd","zasd","zasd","zasd"]);


		this._initialized = true;
	}
	else
	{
		this._setBoundarySelectItems();
		this.loadSelectedBoundary();
	}
	
	this._active = true;
};

Boundaries.prototype.cleanUp = function()
{
	this._clearAllBoundaries();
	this._clearTagOverlays();
	this._active = false;
};

Boundaries.prototype._loadBoundaryList = function()
{
	var _this = this;
//	util.sendPexysListRequest("BoundaryList", "&lang=" + userLanguage.substr(0, 2), _this.onBoundaryListLoaded);
	util.sendPexysListRequest("BoundaryList", "&lang=en", _this.onBoundaryListLoaded);
};

Boundaries.prototype.onBoundaryListLoaded = function(response, error)
{
	var _this = boundaries;
	_this._boundaryItems.length = 0;
	
	for (var i = 0; i < response.boundaryItems.length; i++)
	{
		var boundaryItem = response.boundaryItems[i];
		_this._boundaryItems[boundaryItem.code] = {name: boundaryItem.name, value : boundaryItem.code, 
			description : boundaryItem.description, zoomLevelInfo : boundaryItem.zoomLevelInfo, overlay : null };
	}
	
	_this._setBoundarySelectItems();
	_this.loadSelectedBoundary();
	
};

Boundaries.prototype._setBoundarySelectItems = function()
{
	var boundarySelect = $("#select_Boundaries").html("");

//	$("<option value='NONE' selected='selected'>-- None --</option>").appendTo(boundarySelect);

	for (var boundaryItemName in this._boundaryItems)
	{
		var boundaryItem = this._boundaryItems[boundaryItemName];
		$("<option " + 
			(boundaryItem.value == this._defaultBoundary ? "selected='selected' " : "") +
			"value='" + boundaryItem.value + "'>" + boundaryItem.name + "</option>").appendTo(boundarySelect);
	}
};

Boundaries.prototype.loadSelectedBoundary = function()
{

	this._clearAllBoundaries();
	this._clearTagOverlays();

	var boundaryCode = $("#select_Boundaries").val();
	this._currentTagOverlayCollection = this._tagOverlayCollections[boundaryCode];
	var opacity = new Number($("#select_LayerOpacity").val());

	var boundary = new Boundary(boundaryCode);
	map.overlayMapTypes.insertAt(0, boundary);


	var boundaryItem = this._boundaryItems[boundaryCode]; 
	boundaryItem.overlay = boundary;
	
	$("#span_BoundaryName").html(boundaryItem.name);
	$("#span_BoundaryDescription").html(boundaryItem.description);
	$("#div_BoundariesInfo").show();

	this._createBoundaryZoomInfo();
	
	this._currentZoomLevel = map.getZoom();
	this._currentTagOverlayCollection.showAll(this._currentZoomLevel);





/*
	this._clearAllBoundaries();
	this._clearTagOverlays();

	var boundaryCode = $("#select_Boundaries").val();

	this._currentTagOverlayCollection = this._tagOverlayCollections[boundaryCode];


	var opacity = new Number($("#select_LayerOpacity").val());

	var copyright = new GCopyrightCollection(" ");
	copyright.addCopyright(new GCopyright("Pexys", new GLatLngBounds(new GLatLng(-90, -180), 
		new GLatLng(90, 180)), 0," Pexys"));
	var tileLayer = new GTileLayer(copyright, 0, 0, {opacity: opacity, isPng: true, 
		tileUrlTemplate: "http://commondatastorage.googleapis.com/pextiles/" + boundaryCode + "/{Z}/{Y}/{X}.png"});
	var tileLayerOverlay = new GTileLayerOverlay(tileLayer,	{zPriority: 10});
	map.addOverlay(tileLayerOverlay);
	
	var boundaryItem = this._boundaryItems[boundaryCode]; 
	boundaryItem.overlay = tileLayerOverlay;
	
	$("#span_BoundaryName").html(boundaryItem.name);
	$("#span_BoundaryDescription").html(boundaryItem.description);
	$("#div_BoundariesInfo").show();

	this._createBoundaryZoomInfo();
	
	this._currentZoomLevel = map.getZoom();
	this._currentTagOverlayCollection.showAll(currentZoomLevel);
*/	
};

Boundaries.prototype._createBoundaryZoomInfo = function()
{
	var boundariesZoomTable = $("#div_BoundariesZoomInfo #table_InfoTable:first-child");

	$("<tr></tr>")
		.append($("<td></td>")
			.addClass("currentZoomLevelText")
			.text("Current Zoom Level:"))
		.append($("<td></td>")
			.addClass("currentZoomLevel")
			.append($("<div></div>")
				.attr("id", "div_CurrentZoomLevel")
				.text(map.getZoom())))
		.appendTo(boundariesZoomTable);
			
			
	var boundaryItem = this._boundaryItems[$("#select_Boundaries").val()];
	
	for (var i = 0; i < boundaryItem.zoomLevelInfo.length; i++)
	{
		var zoomLevelInfoItem = boundaryItem.zoomLevelInfo[i];
		
		$("<tr></tr>")
			.append($("<td></td>")
				.css("padding", "0px 10px")
				.text(zoomLevelInfoItem.tag))
			.append($("<td></td>")
				.text(zoomLevelInfoItem.levels))
			.appendTo(boundariesZoomTable);
	}
	 
	$("#div_BoundariesZoomInfo").show();
};

Boundaries.prototype._clearAllBoundaries = function()
{
	for (var boundaryItemCode in this._boundaryItems)
	{
		var boundaryItem = this._boundaryItems[boundaryItemCode];
		
		if (boundaryItem.overlay != null)
		{
			map.overlayMapTypes.removeAt(0);
//			map.removeOverlay(boundaryItem.overlay)
		}
		
		boundaryItem.overlay = null;
	}
	
	$("#span_BoundaryName").html("");
	$("#span_BoundaryDescription").html("");
	$("#div_BoundariesInfo").hide();
	$("#div_BoundariesZoomInfo #table_InfoTable:first-child").html("");	
};

Boundaries.prototype._clearTagOverlays = function(tagName)
{
	if (boundaries._currentTagOverlayCollection !== null)
	{
		boundaries._currentTagOverlayCollection.hideAll(map.getZoom());
	}
};

Boundaries.prototype.onZoomLevelChange = function()
{
	if (boundaries._active)
	{
		var newLevel = map.getZoom();
		
		$("#div_CurrentZoomLevel").text(newLevel);
		
		//var boundaryCode = $("#select_Boundaries").val();
		
		boundaries._currentTagOverlayCollection.hideAll(this._currentZoomLevel);
		boundaries._currentTagOverlayCollection.showAll(newLevel);
		
		this._currentZoomLevel = newLevel;
	}
};

Boundaries.prototype.layerOpacityChanged = function()
{
	if (boundaries._active)
	{
		this.loadSelectedBoundary();
	}
};


Boundaries.prototype.onMapClick = function(latLng)
{
	if (!boundaries._active)
	{
		return;
	}
	
	boundaries._clickLatLng = latLng;
	boundaries._doubleClickFlag = false;
	
	setTimeout("boundaries.checkDoubleClick()", 600);
};

Boundaries.prototype.onMapDblClick = function()
{
	boundaries._doubleClickFlag = true;
};

Boundaries.prototype.checkDoubleClick = function()
{
	if (!boundaries._doubleClickFlag)
	{
		boundaries.addTagOverlay();
	}
};

Boundaries.prototype.addTagOverlay = function()
{
	var tagOverlayCollection = boundaries._tagOverlayCollections[$("#select_Boundaries").val()]; 

	var tagLevel = tagOverlayCollection.tagLevelFromZoomLevel(map.getZoom());

	if (tagLevel == null)
	{
		return;
	}		
	
	var params = "&x=" + boundaries._clickLatLng.lng() + "&y=" +
		boundaries._clickLatLng.lat() + "&level=" + tagLevel;

	util.sendPointLabelRequest("", params, boundaries._onLoadPointLabel);
};


Boundaries.prototype._onLoadPointLabel = function(response)
{
	if (!util.isDefined(response))
	{
		return;
	}
	
	var _this = boundaries;
	
	var tagOverlayCollection = boundaries._tagOverlayCollections[$("#select_Boundaries").val()]; 
	var tagLevel = tagOverlayCollection.tagLevelFromZoomLevel(map.getZoom());
	var tagOverlay = tagOverlayCollection.findOverlayByName(tagLevel, response.NAME);
	 
	if (tagOverlay !== null)
	{
//		map.removeOverlay(tagOverlay);
		tagOverlay.reposition(_this._clickLatLng);
	}
	else
	{
		tagOverlay = new TagOverlay(_this._clickLatLng, response.NAME);
		tagOverlay.setMap(map);
		tagOverlayCollection.addOverlay(tagLevel, tagOverlay);
	};

//	map.addOverlay(tagOverlay);
};



var boundaries = new Boundaries();




