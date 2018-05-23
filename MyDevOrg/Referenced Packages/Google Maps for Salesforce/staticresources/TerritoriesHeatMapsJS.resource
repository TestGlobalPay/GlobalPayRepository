///**********************************************************************************/
///
///  (c) 2009-2012 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/


/////////////////////////////////////////////////////////////////////////////////////
// TagOverlay
/////////////////////////////////////////////////////////////////////////////////////
function TagOverlay(center, text)
{
	this._center = center;
	this._text = text;
	this._div = null;
	this._bounds = null;
}

TagOverlay.prototype = new google.maps.OverlayView();

TagOverlay.prototype.onAdd = function() 
{
	this._div = $("<div></div>")
		.css("zIndex", "100")
		.addClass("nameOverlay")
		.text(this._text)
		
	this.getPanes().overlayLayer.appendChild(this._div.get(0));		

/*
	this._div = $("<div></div>")
		.addClass("nameOverlay")
		.text(this._text)
		.appendTo($(map.getPane(G_MAP_MARKER_SHADOW_PANE)));
	
	this._setPosition();
*/
};

TagOverlay.prototype._setPosition = function()
{
	var projection = this.getProjection();
	
	var centerPoint = projection.fromLatLngToDivPixel(this._center);
	var halfWidth = this._div.width() / 2;
	var halfHeight = this._div.height() / 2;
	
	var southWest = projection.fromDivPixelToLatLng(new google.maps.Point(centerPoint.x - halfWidth, centerPoint.y + halfHeight)); 
	var northEast = projection.fromDivPixelToLatLng(new google.maps.Point(centerPoint.x + halfWidth, centerPoint.y - halfHeight)); 
	
	this._bounds = new google.maps.LatLngBounds(new google.maps.LatLng(southWest.lat(), southWest.lng()),
	    new google.maps.LatLng(northEast.lat(), northEast.lng()));
	
/*
	var centerPoint = map.fromLatLngToDivPixel(this._center);
	var halfWidth = this._div.width() / 2;
	var halfHeight = this._div.height() / 2;
	
	var southWest = map.fromDivPixelToLatLng(new GPoint(centerPoint.x - halfWidth, centerPoint.y + halfHeight)); 
	var northEast = map.fromDivPixelToLatLng(new GPoint(centerPoint.x + halfWidth, centerPoint.y - halfHeight)); 

	this._bounds = new GLatLngBounds(new GLatLng(southWest.lat(), southWest.lng()),
	    new GLatLng(northEast.lat(), northEast.lng()));
*/	    
};

TagOverlay.prototype.reposition = function(newCenter)
{
	this._center = newCenter;
	this.setMap(map);
	
//	this._setPosition();
};

TagOverlay.prototype.onRemove = function() 
{
	this._div.remove();
};

TagOverlay.prototype.copy = function() 
{
	return new TagOverlay(this._center, this._text);
};

TagOverlay.prototype.draw = function() 
{
	this._setPosition();
	
	var projection = this.getProjection();

	var southWest = projection.fromLatLngToDivPixel(this._bounds.getSouthWest());
	var northEast = projection.fromLatLngToDivPixel(this._bounds.getNorthEast());

	this._div
		.css("left", Math.min(northEast.x, southWest.x) + "px")
		.css("top", Math.min(northEast.y, southWest.y) + "px");
};

TagOverlay.prototype.getText = function()
{
	return this._text;
};

/////////////////////////////////////////////////////////////////////////////////////
// TagOverlayCollection
/////////////////////////////////////////////////////////////////////////////////////
function TagOverlayCollection(tagLevels, tagZoomLevels)
{
	this._tagOverlays = [];
	this._tagZoomLevels = tagZoomLevels;
	
	for (var i = 0; i < tagLevels.length; i++)
	{
		this._tagOverlays[tagLevels[i]] = [];
	}
}
TagOverlayCollection.prototype = {};

TagOverlayCollection.prototype.tagLevelFromZoomLevel = function(zoomLevel)
{
	return this._tagZoomLevels[zoomLevel];
};

TagOverlayCollection.prototype.findOverlayByName = function(tagLevel, name)
{
	for (var i = 0; i < this._tagOverlays[tagLevel].length; i++)
	{
		var tagOverlay = this._tagOverlays[tagLevel][i];
		
		if (tagOverlay.getText() == name)
		{
			return tagOverlay;
		}
	}
	
	return null;
};

TagOverlayCollection.prototype.addOverlay = function(tagLevel, tagOverlay)
{
	this._tagOverlays[tagLevel].push(tagOverlay);
};

TagOverlayCollection.prototype.hideAllOverlays = function()
{
/*
	var tagLevels = Object.keys(this._tagOverlays);
	
	for (var j = 0; j < tagLevels.length; j++)
	{
		var tagLevel = tagLevels[j];
		
		for (var i = 0; i < this._tagOverlays[tagLevel].length; i++)
		{
			if (this._tagOverlays[tagLevel][i])
			{
				this._tagOverlays[tagLevel][i].setMap(null);
			}

		}
	};
*/



	for (var tagLevel in this._tagOverlays)
	{
		for (var i = 0; i < this._tagOverlays[tagLevel].length; i++)
		{
			if (this._tagOverlays[tagLevel][i])
			{
				this._tagOverlays[tagLevel][i].setMap(null);
			}

		}
	};
};

TagOverlayCollection.prototype.hideAll = function(zoomLevel)
{
	var tagLevel = this._tagZoomLevels[zoomLevel];
	
	if (!util.isDefined(tagLevel) || tagLevel === null)
	{
		return;
	}
	
	for (var i = 0; i < this._tagOverlays[tagLevel].length; i++)
	{
		//map.removeOverlay(this._tagOverlays[tagLevel][i]);
		this._tagOverlays[tagLevel][i].setMap(null);
	}
};

TagOverlayCollection.prototype.showAll = function(zoomLevel)
{
	var tagLevel = this._tagZoomLevels[zoomLevel];
	
	if (!util.isDefined(tagLevel) || tagLevel === null)
	{
		return;
	}

	for (var i = 0; i < this._tagOverlays[tagLevel].length; i++)
	{
		this._tagOverlays[tagLevel][i].setMap(map);
//		map.addOverlay(this._tagOverlays[tagLevel][i]);
	}
}



/////////////////////////////////////////////////////////////////////////////////////
// HeatMaps
/////////////////////////////////////////////////////////////////////////////////////

function HeatMaps()
{
	this._initialized = false;
	this._region = userLocale.substr(3).toLowerCase();
	this._country = util.regionCodeToCountryName(this._region);
	this._heatMapFields = [];
	this._areas = [];
	this._level = "";
	this._levels = [];
	
	this._scaleMin = 0;
	this._scaleMax = 0;
	this._scaleStep = 0;
	this._scaleUnits = 10;
	
	this._field = "";
	this._fieldLabel = "";
	this._aggregateFunction = "count";
	this._aggregateFunctionLabel = "Count";
	this._active = false;
	this._zoomFlag = false;
	
	this._doubleClickFlag = false;
	this._clickArea = null;
	this._clickAreaLatLng = null;
	
	this._tagOverlayCollection = null;
}

HeatMaps.prototype = {};

HeatMaps.prototype.init = function()
{
	if (!this._initialized)
	{
		this._initializeLevels();
		this._calculateAggregateValues();
		
		this._tagOverlayCollection = new TagOverlayCollection(["usst", "uszc"], 
			[null,null,null,null,"usst","usst","usst","usst","usst","usst","usst",
			"uszc","uszc","uszc","uszc","uszc"]);
		
		this._initialized = true;
	}

	this._initializeHeatMapsFieldSelect();

	this._currentZoomLevel = map.getZoom();

	$("#div_CurrentZoomLevel").text(this._currentZoomLevel);
};
HeatMaps.prototype.getCountry = function()
{
	return this._country;
};

HeatMaps.prototype._initializeLevels = function()
{
	var opacity = new Number($("#select_LayerOpacity").val());
	
	if (this._region == "us")
	{
		this._levels["STATE"] = { polygonOptions : { 
			strokeColor: "#ff00ff", 
			strokeWeight: 1, 
			strokeOpacity: opacity, 
			fillColor: "#ff7f00", 
			fillOpacity: opacity }};
			
		this._levels["ZIP"] = { polygonOptions : { 
			strokeColor: "#0000ff", 
			strokeWeight: 1, 
			strokeOpacity: opacity, 
			fillColor: "#ff7f00", 
			fillOpacity: opacity }};
	}
};

HeatMaps.prototype._initializeHeatMapsFieldSelect = function()
{
	for (var i = 0; i < territories.view.displayFieldTypes.length; i++)
	{
		var fieldType = territories.view.displayFieldTypes[i];
		if (fieldType == "Currency" || fieldType == "Number")
		{
			this._heatMapFields.push([territories.view.displayFieldNames[i],
				territories.view.displayFieldLabels[i]]);
		}
	}

	var heatMapsFieldSelect = $("#select_HeatMapField").html("");

	$("<option value='SELECT'>-- " + locale.select + " --</option>").appendTo(heatMapsFieldSelect);

	for (var i = 0; i < this._heatMapFields.length; i++)
	{
		var heatMapsFieldItem = this._heatMapFields[i];
		$("<option value='" + heatMapsFieldItem[0] + "'>" + heatMapsFieldItem[1] + "</option>").appendTo(heatMapsFieldSelect);
	}
};

HeatMaps.prototype._calculateAggregateValues = function()
{
	var displayFieldsCount = territories.view.displayFieldNames.length;

	for (var i = 0; i < displayFieldsCount; i++)
	{
		var displayFieldName = territories.view.displayFieldNames[i];

		if (!util.isDefined(territories.view[displayFieldName]))
		{
			continue;
		}

		var indexCount = 2; // state and zip code
		for (var index = 0; index < indexCount; index++)
		{
		
			var areas = Object.keys(territories.view[displayFieldName][index].areas);

			for (var j = 0; j < areas.length; j++)		
			//for (var area in territories.view[displayFieldName][index].areas) 
			{
				var area = areas[j];
			
				// total
				territories.view[displayFieldName][index].overallMin.total = Math.min(territories.view[displayFieldName][index].overallMin.total, territories.view[displayFieldName][index].areas[area].total);				
				territories.view[displayFieldName][index].overallMax.total = Math.max(territories.view[displayFieldName][index].overallMax.total, territories.view[displayFieldName][index].areas[area].total);				
					
				// min
				territories.view[displayFieldName][index].overallMin.min = Math.min(territories.view[displayFieldName][index].overallMin.min, territories.view[displayFieldName][index].areas[area].min);				
				territories.view[displayFieldName][index].overallMax.min = Math.max(territories.view[displayFieldName][index].overallMax.min, territories.view[displayFieldName][index].areas[area].min);	
				
				// max
				territories.view[displayFieldName][index].overallMin.max = Math.min(territories.view[displayFieldName][index].overallMin.max, territories.view[displayFieldName][index].areas[area].max);				
				territories.view[displayFieldName][index].overallMax.max = Math.max(territories.view[displayFieldName][index].overallMax.max, territories.view[displayFieldName][index].areas[area].max);				
					
				// avg
				territories.view[displayFieldName][index].overallMin.avg = Math.min(territories.view[displayFieldName][index].overallMin.avg, territories.view[displayFieldName][index].areas[area].avg);				
				territories.view[displayFieldName][index].overallMax.avg = Math.max(territories.view[displayFieldName][index].overallMax.avg, territories.view[displayFieldName][index].areas[area].avg);
			}
		}
	}
};

HeatMaps.prototype.cleanUp = function()
{
	this._resetAll();
	if (this._tagOverlayCollection !== null)
	{
		this._tagOverlayCollection.hideAllOverlays();
	}
	this._resetAggregateFunction();
};

HeatMaps.prototype.load = function()
{
	var mapBounds = map.getBounds();
	var minX = mapBounds.getSouthWest().lng();
	var minY = mapBounds.getSouthWest().lat();
	var maxX = mapBounds.getNorthEast().lng();
	var maxY = mapBounds.getNorthEast().lat();
	var zoom = map.getZoom();

	var params = "&xmin=" + minX + "&ymin=" + minY + "&xmax=" + 
		maxX + "&ymax=" + maxY + "&zoom=" + zoom;

	var _this = this;
	util.sendPolygonRequest(this._region, params, _this._onLoadPolygons);
};

HeatMaps.prototype._getLevelIndex = function(level)
{
	switch(level)
	{
		default:
		case "STATE":
			return 0;
		case "ZIP":
			return 1;
	}
}

HeatMaps.prototype._onLoadPolygons = function(response)
{
	if (!util.isDefined(response))
	{
		return;
	}

	var _this = heatMaps;
	
	_this._areas = response.AREAS;
	_this._level = response.LEVEL;
	
	_this._setAreaAggregateValues();
	_this._setScales();
	_this._createPolygons();
	_this._setPolygonsFillStyle();
	_this._showPolygons();

	_this._fillDataTable();
	
	_this._active = true;

};

HeatMaps.prototype._getFillColorFromAggValue = function(aggValue)
{
	if (this._scaleStep === 0 || !util.isDefined(aggValue))
	{
		return "transparent";
	}
	
	var colorScale = Math.round((aggValue - this._scaleMin) / this._scaleStep) + 1;
	var scaleUnit = Math.round(0xff / this._scaleUnits); 
	var variableColorValue = util.padLeft((0xff - Math.min(scaleUnit * colorScale, 0xff)).toString(16), "0", 2);

	if (this._level === "STATE")
	{
		return "#ff" + variableColorValue + "ff";
	}
	else if (this._level === "ZIP")
	{
		return "#" + variableColorValue + variableColorValue + "ff";
	}
};

HeatMaps.prototype._setAreaAggregateValues = function()
{
	if (this._field == "SELECT" || this._field == "")
	{
		return;
	}
	
	var levelIndex = this._getLevelIndex(this._level);
	
	for (var i = 0; i < this._areas.length; i++)
	{
		var areaValue = territories.view[this._field][levelIndex].areas[this._areas[i].KEY];

		if (util.isDefined(areaValue))
		{
			this._areas[i].AGGVALUE = areaValue[this._aggregateFunction]; 
		}
	}
	
	this._areas = this._areas.sort(heatMaps._sortAreasByAggValue);
};

HeatMaps.prototype._sortAreasByAggValue = function(value1, value2)
{
	var aggValue1 = util.isDefined(value1.AGGVALUE) ? new Number(value1.AGGVALUE) : 0;
	var aggValue2 = util.isDefined(value2.AGGVALUE) ? new Number(value2.AGGVALUE) : 0;  

	if (aggValue1 === aggValue2)
	{
		return 0;
	}
	
	return aggValue1 > aggValue2 ? -1 : 1;
}

HeatMaps.prototype._setScales = function()
{
	var levelIndex = this._getLevelIndex(this._level);
	this._scaleMin = territories.view[this._field][levelIndex].overallMin[this._aggregateFunction];
	this._scaleMax = territories.view[this._field][levelIndex].overallMax[this._aggregateFunction];
	this._scaleStep = Math.round((this._scaleMax - this._scaleMin) / this._scaleUnits);
	this._scaleStep = this._scaleStep == 0 ? 1 : this._scaleStep;	
};

HeatMaps.prototype._createPolygons = function()
{
	var polygonOptions = this._levels[this._level].polygonOptions;
	
	for (var i = 0; i < this._areas.length; i++)
	{
		this._areas[i].polygons = [];
//		this._areas[i].NAMEOVERLAY = null;
		
		for (var j = 0; j < this._areas[i].POLYGONS.length; j++)
		{
			var vertices = [];

			for (var k = 0; k < this._areas[i].POLYGONS[j].length; k++)
			{
				//vertices.push(google.maps.LatLng.fromUrlValue(this._areas[i].POLYGONS[j][k]));
				
				var latLngArray = this._areas[i].POLYGONS[j][k].split(",");
				vertices.push(new google.maps.LatLng(latLngArray[0], latLngArray[1]));
			}
			
			
			var options = {
				paths: vertices,
				strokeColor: polygonOptions.strokeColor,
				strokeWeight: polygonOptions.strokeWeight,
				strokeOpacity: polygonOptions.strokeOpacity,
				fillColor: "#ffffff",
				fillOpacity: polygonOptions.fillOpacity,
			};
			
			
			var polygon = new google.maps.Polygon(options);
			
//			var polygon = new GPolygon(vertices, polygonOptions.strokeColor,
//				polygonOptions.strokeWeight, polygonOptions.strokeOpacity, "#ffffff", 
//				polygonOptions.fillOpacity) 
			
			this._areas[i].polygons.push(polygon);
			this._areas[i].POLYGONS[j].length = 0;
			
			this._addPolygonListeners(polygon, this._areas[i]);			
		}
	}
};

HeatMaps.prototype._setPolygonsFillStyle = function()
{
	var fillOpacity = this._levels[this._level].polygonOptions.fillOpacity;

	for (var i = 0; i < this._areas.length; i++)
	{
		var fillColor = this._getFillColorFromAggValue(this._areas[i].AGGVALUE);
	
		for (var j = 0; j < this._areas[i].polygons.length; j++)
		{
//			this._areas[i].polygons[j].setFillStyle({color: fillColor, weight: 2, opacity: fillOpacity});

			var fillOptions = {
				fillColor: fillColor,
				fillOpacity: fillOpacity,
			};
			this._areas[i].polygons[j].setOptions(fillOptions);
		}
	}
};

HeatMaps.prototype._showPolygons = function()
{
	for (var i = 0; i < this._areas.length; i++)
	{
		for (var j = 0; j < this._areas[i].polygons.length; j++)
		{
			this._areas[i].polygons[j].setMap(map);
		}
	}
};

HeatMaps.prototype._hidePolygons = function()
{
	for (var i = 0; i < this._areas.length; i++)
	{
		if (util.isDefined(this._areas[i].polygons))
		{
			for (var j = 0; j < this._areas[i].polygons.length; j++)
			{
				this._areas[i].polygons[j].setMap(null);
//				map.removeOverlay(this._areas[i].polygons[j]);
			}
		}
	}
};


HeatMaps.prototype._addPolygonListeners = function(polygon, area)
{
	google.maps.event.addListener(polygon, "click", 
		function(event)
		{
			heatMaps._clickArea = area;

			heatMaps._clickAreaLatLng = event.latLng;
			heatMaps._doubleClickFlag = false;
			setTimeout("heatMaps.checkDoubleClick()", 600);

		}
	);
};

HeatMaps.prototype.onMapDblClick = function()
{
	heatMaps._doubleClickFlag = true;
};

HeatMaps.prototype.checkDoubleClick = function()
{
	if (!heatMaps._doubleClickFlag)
	{
		heatMaps.addTagOverlay(heatMaps._clickAreaLatLng, heatMaps._clickArea.NAME);
	}
};

HeatMaps.prototype.addTagOverlay = function(latLng, areaName)
{
	var tagOverlayCollection = heatMaps._tagOverlayCollection; 
	var tagLevel = tagOverlayCollection.tagLevelFromZoomLevel(map.getZoom());
	var tagOverlay = tagOverlayCollection.findOverlayByName(tagLevel, areaName);
	 
	if (tagOverlay !== null)
	{
		tagOverlay.reposition(latLng);
	}
	else
	{
		tagOverlay = new TagOverlay(latLng, areaName);
		tagOverlayCollection.addOverlay(tagLevel, tagOverlay);
	};

	tagOverlay.setMap(map);
//	map.addOverlay(tagOverlay);
};

HeatMaps.prototype._destroyPolygons = function()
{
	this._hidePolygons();

	for (var i = 0; i < this._areas.length; i++)
	{
		if (!util.isDefined(this._areas[i].polygons))
		{
			continue;
		}
		
		for (var j = 0; j < this._areas[i].polygons.length; j++)
		{
			var polygon = this._areas[i].polygons[j];
			polygon.setMap(null);
//			map.removeOverlay(polygon);
			delete polygon;
		}
		
		this._areas[i].polygons.length = 0;
	}

};

HeatMaps.prototype._resetAll = function()
{
	this._destroyPolygons();
		
	this._areas.length = 0;
	this._level = "";
	
	this._scaleMin = 0;
	this._scaleMax = 0;
	this._scaleStep = 0;
	
	this._heatMapFields.length = 0;
	
	this._clearDataTable();
	
	this._initialized = false;
	this._active = false;
	
};

HeatMaps.prototype._resetAggregateFunction = function()
{
	this._aggregateFunction = "count";
	this._aggregateFunctionLabel = "Count";
};

HeatMaps.prototype._clearDataTable = function()
{
	$("#heatMapsDataTable").html("");
};

HeatMaps.prototype._fillDataTable = function()
{
	this._clearDataTable();
	
	var dataTable = $("#heatMapsDataTable");
	
	$("<tr></tr>")
		.append($("<th></th>")
			.attr("colspan", "2")
			.append($("<div></div>")
				.css("fontWeight", "bold")
				.addClass("heatMapsDataTableHeader")
				.text(territories.view.viewObjectLabel + " " + 
					(this._aggregateFunctionLabel == "Count" ? "" : this._fieldLabel) + " - " + this._aggregateFunctionLabel)))
		.appendTo(dataTable);
		
	var itemCount = 0;
	for (var i = 0; i < this._areas.length; i++)
	{
		var aggValue = this._areas[i].AGGVALUE;
		
		if (!util.isDefined(aggValue))
		{
			if (this._aggregateFunction === "count")
			{
				aggValue = 0;
			}
			else
			{
				continue;
			}
		}
		++itemCount;
		
		$("<tr></tr>")
			.append($("<td></td>")
				.text(this._areas[i].NAME))
			.append($("<td></td>")
				.append($("<div></div>")
					.css("marginLeft", "25px")
					.css("textAlign", "right")
					.text(util.formatNumber(aggValue, 0))))
			.appendTo(dataTable);
	}
	
	if (itemCount == 0)
	{
		$("<tr></tr>")
			.append($("<td></td>").text("No data visible"))
			.append($("<td></td>"))
			.appendTo(dataTable);
	} 
};

HeatMaps.prototype.fieldChanged = function()
{
	this._field = $("#select_HeatMapField").val();
	
	var fieldSelect = $("#select_HeatMapField").get(0);
	this._fieldLabel = fieldSelect.options[fieldSelect.selectedIndex].text;
	
	if (this._field == "SELECT")
	{
		this._hidePolygons();
	}
	else
	{
		if (!this._active)
		{
			this.load();
		}
		else
		{
this._setScales();
this._setAreaAggregateValues();
			this._setPolygonsFillStyle();
//			this._showPolygons();
this._fillDataTable();			
		}
	}
};

HeatMaps.prototype.aggregateFunctionChanged = function()
{
	var functionSelect = $("#select_HeatMapAggregateFunction").get(0);
	heatMaps._aggregateFunctionLabel = functionSelect.options[functionSelect.selectedIndex].text;

	heatMaps._aggregateFunction = $("#select_HeatMapAggregateFunction").val();
	heatMaps._setAreaAggregateValues();
	
	if (this._field == "SELECT" || this._field == "")
	{
		return;
	}

	
	heatMaps._setScales();
	heatMaps._setPolygonsFillStyle();


	heatMaps._fillDataTable();
};

HeatMaps.prototype.onZoomLevelChange = function()
{
	var oldLevel = this._currentZoomLevel;
	this._currentZoomLevel = map.getZoom();
	
	$("#div_CurrentZoomLevel").text(this._currentZoomLevel);
	
	if (heatMaps._active)
	{
		heatMaps._tagOverlayCollection.hideAll(oldLevel);
		heatMaps.reload();
		heatMaps._tagOverlayCollection.showAll(this._currentZoomLevel);
		heatMaps._zoomFlag = true;
	}
	
};

HeatMaps.prototype.onMoveMap = function()
{
	// "moveend" and "zoomend" are fired
	// when zoom level changes
	if (heatMaps._active && !heatMaps._zoomFlag)
	{
		heatMaps.reload();
	}
	
	heatMaps._zoomFlag = false;
};

HeatMaps.prototype.layerOpacityChanged = function()
{
	this._initializeLevels();
	this.reload();
};


HeatMaps.prototype.reload = function()
{
	if (heatMaps._active)
	{
		heatMaps._resetAll();
	}
	
	//heatMaps.load();
	
	var zoom = map.getZoom();
	if (zoom >= 4 && zoom <= 15)
	{
		heatMaps.load();
	}

	heatMaps._active = true;	
};

var heatMaps = new HeatMaps();




