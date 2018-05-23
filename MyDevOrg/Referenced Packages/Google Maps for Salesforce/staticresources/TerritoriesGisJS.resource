///**********************************************************************************/
///
///  (c) 2009-2011 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/


/////////////////////////////////////////////////////////////////////////////////////
// GIS
/////////////////////////////////////////////////////////////////////////////////////


function GIS()
{
	this._demographicsItems = [];
	this._zoomLevelInfo = [];
	
	this._DEFAULT_DEMOGRAPHIC = "ustp";
	
	this._infoWindowLatLng = null;
//	this._clickListenerActive = true;
	this._doubleClickFlag = false;
	
	this._tagOverlayCollection = null;
	
	this._currentZoomLevel = 0;
	
	this._active = false;
}

GIS.prototype = {};

GIS.prototype.init = function()
{
	this._loadDemographicsList();
	
	this._tagOverlayCollection = new TagOverlayCollection(["usst", "usct", "ustr", "usbg"], 
		[null,null,null,null,"usst","usct","usct","usct","usct","usct",
		"ustr",	"ustr","usbg","usbg"]);
	
	this._active = true;
	
	return this;
};

GIS.prototype.onOpenGis = function()
{
	
};

GIS.prototype.cleanUp = function()
{
	this._clearCurrentDemographic();
	if (this._tagOverlayCollection !== null)
	{
		this._tagOverlayCollection.hideAllOverlays();
	}
	this._active = false;
};





GIS.prototype._loadDemographicsList = function()
{
	var _this = this;
//	util.sendPexysListRequest("DemographicsList", "&lang=" + userLanguage.substr(0, 2), _this.onDemographicsListLoaded);
	util.sendPexysListRequest("DemographicsList", "&lang=en", _this.onDemographicsListLoaded);
};

GIS.prototype.onDemographicsListLoaded = function(response, error)
{
	gis._demographicsItems.length = 0;
	
	for (var i = 0; i < response.demographicsItems.length; i++)
	{
		var demographicsItem = response.demographicsItems[i];
		
		gis._demographicsItems[demographicsItem.code] = {
			name: demographicsItem.name, 
			value : demographicsItem.code, 
			copyright : demographicsItem.copyright, 
			server : demographicsItem.server.replace(/http/, "https"), 
			description : demographicsItem.description,
			legendUrl : demographicsItem.legend.replace(/http/, "https"),
			zoomLayers : demographicsItem.zoomLayer.split(","),
			dataTable : demographicsItem.dataTable,
			chart : demographicsItem.chart,
			overlay : null,
			legend : null };
	}
	
	gis._zoomLevelInfo = response.zoomLevelInfo;
	
	gis._setDemographicsSelectItems();
	
	gis.loadSelectedDemographic(false);
};

GIS.prototype._setDemographicsSelectItems = function()
{
// TODO: use locale here

	var demographicsSelect = $("#select_Demographics").html("");

	//$("<option value='NONE'>-- None --</option>").appendTo(demographicsSelect);

	for (var demographicsItemName in gis._demographicsItems)
	{
		var demographicsItem = gis._demographicsItems[demographicsItemName];
		$("<option " +
			(demographicsItem.value === gis._DEFAULT_DEMOGRAPHIC ? "selected='selected' " : "") +
			"value='" + demographicsItem.value + "'>" + demographicsItem.name + "</option>").appendTo(demographicsSelect);
	}
};


GIS.prototype.loadSelectedDemographic = function(reload)
{
	//map.closeInfoWindow();
	InfoWindow.close();

	this._clearCurrentDemographic();
	
	var _this = this;
	var demographicsCode = $("#select_Demographics").val();

	if (demographicsCode === "NONE")
	{
		return;
	}

	this._currentDemographic = this._demographicsItems[demographicsCode];
	
	if (!util.isDefined(this._currentDemographic))
	{
		return;
	}
	
	if (this._currentDemographic.overlay != null && !reload)
	{
		map.overlayMapTypes.insertAt(0, this._currentDemographic.overlay);
//		map.addOverlay(this._currentDemographic.overlay);
		this._showCurrentDemographicsDetail();
	}
	else
	{
		var opacity = new Number($("#select_LayerOpacity").val());
//		new esri.arcgis.gmaps.TiledMapServiceLayer(this._currentDemographic.server,
//			{opacity: opacity, minResolution:0, maxResolution: 19}, _this.addDemographicsOverlay);

var url = this._currentDemographic.server;
var mapType = new gmaps.ags.MapType(url, {name: "ArcGIS", opacity: opacity});
map.overlayMapTypes.insertAt(0, mapType);


this._currentDemographic.overlay = mapType;
this._showCurrentDemographicsDetail();

this._currentZoomLevel = map.getZoom();


	}
	
	if ((this._currentDemographic.overlay === null || this._currentDemographic.legend === null) && !reload)
	{
		util.sendJsonRequest(this._currentDemographic.legendUrl, _this.addDemographicsLegend);
	}
	else
	{
		this.loadSelectedDemographicLegend();
	}
	
	this._createDemographicsZoomInfo();
};

GIS.prototype._createDemographicsZoomInfo = function()
{
	var demographicsZoomTable = $("#div_DemographicZoomInfo table:first-child");

	$("<tr></tr>")
		.append($("<td></td>")
			.addClass("currentZoomLevelText")
			.text("Current Zoom Level:"))
		.append($("<td></td>")
			.addClass("currentZoomLevel")
			.append($("<div></div>")
				.attr("id", "div_CurrentZoomLevel")
				.text(map.getZoom())))
		.appendTo(demographicsZoomTable);
			
	for (var i = 0; i < this._zoomLevelInfo.length; i++)
	{
		var zoomLevelInfoItem = this._zoomLevelInfo[i];
		
		$("<tr></tr>")
			.append($("<td></td>")
				.css("padding", "0px 10px")
				.text(zoomLevelInfoItem.tag))
			.append($("<td></td>")
				.text(zoomLevelInfoItem.levels))
			.appendTo(demographicsZoomTable);
	}
	 
	$("#div_DemographicZoomInfo").show();
};

/*
GIS.prototype.addDemographicsOverlay = function(tileLayer)
{
	var demographicsItem = gis._currentDemographic;

	var tileLayerOverlay = new GTileLayerOverlay(tileLayer,	{zPriority: 11});
	map.addOverlay(tileLayerOverlay);
	
	demographicsItem.overlay = tileLayerOverlay;
	
	gis._showCurrentDemographicsDetail();

//	util.hideLoadingImage();
};
*/


GIS.prototype._showCurrentDemographicsDetail = function()
{
	$("#span_DemographicName").html(this._currentDemographic.name);
	$("#span_DemographicDescription").html(this._currentDemographic.description);
	$("#div_DemographicDetails").show();
	$("#div_DemographicZoomInfo").show();
	$("#div_CurrentZoomLevel").text(map.getZoom());
};

GIS.prototype.addDemographicsLegend = function(response)
{
	gis._currentDemographic.legend = response;
	gis.loadSelectedDemographicLegend();
};

GIS.prototype.loadSelectedDemographicLegend = function()
{
	var legendTable = $("#table_Legend").html("");

	var zoomLayerIndex = parseInt(gis._currentDemographic.zoomLayers[map.getZoom()]) + 0;
	
	if (zoomLayerIndex === 0)
	{
		$("#div_GisLegendBox").hide();
		return;
	}

	var layer = gis._currentDemographic.legend.layers[zoomLayerIndex - 1];

	for (var i = 0; i < layer.legend.length; i++)
	{
		var colorImageUrl = "url('" + gis._currentDemographic.server + "/" + layer.layerId + "/images/" + layer.legend[i].url + "')";
		
		legendTable
			.append($("<tr></tr>")
				.append($("<td></td>")
					.append($("<div></div>")
						.css("backgroundImage", colorImageUrl)
						.addClass("gisLegendColorBox")))
				.append($("<td></td>")
					.append($("<div></div>")
						.addClass("gisLegendLabel")
						.text(layer.legend[i].label))));
	}
	
	$("#div_GisLegendBox").show();
	$("#div_LegendTitle").text(layer.layerName);
	$("#div_LegendSubtitle").text(gis._currentDemographic.name);
};

GIS.prototype.onZoomLevelChange = function(oldLevel, newLevel)
{
	if (gis._active && util.isDefined(gis._currentDemographic))
	{
		gis._tagOverlayCollection.hideAll(this._currentZoomLevel);
		
this._currentZoomLevel = map.getZoom();
		
		$("#div_CurrentZoomLevel").text(this._currentZoomLevel);
		gis.loadSelectedDemographicLegend();
		gis._tagOverlayCollection.showAll(this._currentZoomLevel);
	}
};

GIS.prototype.onMapClick = function(latLng)
{
	if (!gis._active || gis._currentDemographic == null)
	{
		return;	
	}

	gis._infoWindowLatLng = latLng;

	
//	if (!gis._clickListenerActive)
//	{
//		//gis._clickListenerActive = true;
//		return;
//	}
	
	gis._doubleClickFlag = false;
	
	setTimeout("gis.checkDoubleClick()", 600);
};

GIS.prototype.onMapDblClick = function()
{
	if (gis._active)
	{
		gis._doubleClickFlag = true;
	}
};

GIS.prototype.checkDoubleClick = function()
{
	if (!gis._doubleClickFlag)
	{
		gis.executeQuery();
	}
};

GIS.prototype.addTagOverlay = function(latLng, areaName)
{
	var tagOverlayCollection = gis._tagOverlayCollection; 
	var tagLevel = tagOverlayCollection.tagLevelFromZoomLevel(map.getZoom());
	var tagOverlay = tagOverlayCollection.findOverlayByName(tagLevel, areaName);
	 
	if (tagOverlay !== null)
	{
//		map.removeOverlay(tagOverlay);
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

//GIS.prototype.onInfoWindowOpen = function()
//{
//	gis._clickListenerActive = false;
//};

GIS.prototype.executeQuery = function()
{
	var zoomLayer = parseInt(this._currentDemographic.zoomLayers[map.getZoom()]); 
	var spatialReference = new esri.SpatialReference({wkid: 4326});
	
	var query = new esri.tasks.Query();
	query.returnGeometry = false;
	query.outFields = this._currentDemographic.dataTable.fields;
	query.spatialRelationship = esri.tasks.Query.SPATIAL_REL_WITHIN;
	query.geometry = new esri.geometry.Point(this._infoWindowLatLng.lng(), this._infoWindowLatLng.lat(), 
		spatialReference);
		
//alert(this._currentDemographic.server + "/" + zoomLayer);		

	var queryTask = new esri.tasks.QueryTask(this._currentDemographic.server + "/" + zoomLayer); 
	queryTask.execute(query, this.onQueryResults);	

/*
	var zoomLayer = parseInt(this._currentDemographic.zoomLayers[map.getZoom()]); 
 	var queryTask = new esri.arcgis.gmaps.QueryTask(this._currentDemographic.server + "/" +	zoomLayer);

	var query = new esri.arcgis.gmaps.Query();
	query.returnGeometry = false;
	query.outFields = this._currentDemographic.dataTable.fields;
	query.queryGeometry = this._infoWindowLatLng;

	queryTask.execute(query, false, this.onQueryResults);	
*/
};

GIS.prototype.onQueryResults = function(featureSet)
{
//alert(JSON.stringify(featureSet.features));

////	gis._clickListenerActive = false;
	
	if (featureSet.features.length == 0)
	{
		return;
	}

	gis.addTagOverlay(gis._infoWindowLatLng, featureSet.features[0].attributes["NAME"]);

	InfoWindow.setOptions({
		position: gis._infoWindowLatLng,
		content: gis.getInfoWindowHtml(featureSet),
	});
	InfoWindow.open(map);
	
//gis._clickListenerActive = true;
	
};

GIS.prototype.getInfoWindowHtml = function(featureSet)
{
	var demographicItem = this._currentDemographic;
	var html = "";
	
	
	html += "<table style='border-collapse: 0px; border-spacing: 0px'><tr>";
	
	var demographicItemName = featureSet.features[0].attributes[demographicItem.dataTable.nameField];
	var stateAbbr = featureSet.features[0].attributes["ST_ABBREV"];
	var fontSize = util.isDefined(demographicItem.dataTable.fontSize) ? ("font-size:" + demographicItem.dataTable.fontSize + ";") : "";
	var wrapLabels = util.isDefined(demographicItem.dataTable.wrapLabels);
	var highlightFieldExists = util.isDefined(demographicItem.dataTable.highlightField);
	
	html += "<td><table style='border-collapse: 0px; border-spacing: 0px; font-size: 95%;' id='gisDataTable'>";
	html += "<tr><th colspan='2'><div>" + demographicItem.name +   
		(util.isDefined(demographicItemName) ? (" (" + demographicItemName + ", " + stateAbbr + ")") : "") + 
		"</div></th></tr>";

	for (var i = 0; i < demographicItem.dataTable.fields.length; i++)
	{
		var fieldAlias = demographicItem.dataTable.fields[i];		
		if (util.isDefined(demographicItem.dataTable.fieldsNotListed[fieldAlias]))
		{
			continue;
		}		

		var highlightField = (highlightFieldExists && fieldAlias === demographicItem.dataTable.highlightField);

		html += "<tr><td style='white-space:" + (wrapLabels ? "wrap;" : "nowrap;") + 
			(highlightField ? "font-weight: bold;color:blue" : "") + "'><div style='margin-left:20px;text-indent:-20px;font-size:95%'>" + featureSet.fieldAliases[fieldAlias] + "</div></td>";
			
		var fieldValue = featureSet.features[0].attributes[fieldAlias];
		if (!util.isDefined(demographicItem.dataTable.noNumberFormat[fieldAlias]))
		{
			fieldValue = util.formatNumber(fieldValue, 0);
		}
		
		html += "<td style='text-align:right; white-space:nowrap; font-size:95%; " + 
			(highlightField ? "font-weight: bold;color:blue" : "") + "'>" + fieldValue + "</td></tr>";
	}

	if (util.isDefined(demographicItem.dataTable.info))
	{
		html += "<tr><td colspan='2' style=';padding:10px 0px 0px 0px;background-color:white;max-width:100px;font-size: 95%'>" + demographicItem.dataTable.info + "</td></tr>";
	}

	
	html += "</table></td>";
	
	if (util.isDefined(demographicItem.chart.fields) && demographicItem.chart.fields.length > 0)
	{
		html += "<td><table style='border-collapse: 0px; border-spacing: 0px;' id='gisChartTable'>";
		html += "<tr><td><div id='gisChartHeader'>" + demographicItemName + ", " + stateAbbr + "</div>";
//		html += "<div id='gisChartBox' style='width:" + demographicItem.chart.size[0] + "px;'>" + 
		html += "<div id='gisChartBox'>" + 
			this._getDemographicChartHtml(featureSet) + "</div></td></tr>";
		html += "</table></td>";
	}
	
	html += "</tr></table>";
	
	return $("<div></div>")
		.css("maxHeight", "480px")
		.css("overflowX", "hidden")
		.css("overflowY", "auto")
		.html(html)
		.get(0);
};

GIS.prototype._getDemographicChartHtml = function(featureSet)
{
	var demographicItem = this._currentDemographic;
	var chartTotal = parseInt(featureSet.features[0].attributes[demographicItem.chart.totalField]);
	
	var valueString = "";
	var labelString = "";
	
	for (var i = 0; i < demographicItem.chart.fields.length; i++)
	{
		if (valueString.length > 0)
		{
			valueString += ",";
			labelString += "|";
		}

		var fieldAlias = demographicItem.chart.fields[i];
		var value = parseInt(featureSet.features[0].attributes[fieldAlias]);
		value = (value / chartTotal) * 100;
		
		valueString += value + "";
		labelString += featureSet.fieldAliases[fieldAlias] + " (" + util.formatNumber(value, 0) + "%)"; 
	}


	var chartLabels = "&chdl=" + labelString;
	var chartData = "&chd=t:" + valueString;
	
/*	
//	alert("https://www.pexmaps.com:8443/PexmapsGoogleChartProxy/PexmapsGoogleChartProxyServlet?request=" + url);
	
//alert("http://chart.apis.google.com/chart" + demographicItem.chart.urlParams + chartLabels + chartData);
//alert(request);	
	return "<div><img src='https://www.pexmaps.com:8443/PexmapsGoogleChartProxy/PexmapsGoogleChartProxyServlet?request=" + request + "' /></div>";
*/	

	
//	return "<div><img src='http://chart.apis.google.com/chart" + demographicItem.chart.urlParams + chartLabels + chartData + "' /></div>";
	return "<img width='" + demographicItem.chart.size[0] + "' height='" + demographicItem.chart.size[1] + 
		"' src='http://chart.apis.google.com/chart" + demographicItem.chart.urlParams + chartLabels + chartData + "' />";




/*
	var request = encodeURIComponent("http://chart.apis.google.com/chart" + 
		demographicItem.chart.urlParams.replace(/%/gi, "<_pct_>") + 
		chartLabels.replace(/%/gi, "<_pct_>") + 
		chartData.replace(/%/gi, "<_pct_>"));
	
	return "<div><img width='" + demographicItem.chart.size[0] + "' height='" + demographicItem.chart.size[1] + 
//		"' src='https://www.pexmaps.com:8443/PexmapsGoogleChartProxy/PexmapsGoogleChartProxyServlet?request=" + request + "' /></div>";
		"' src='http://localhost:8080/PexmapsGoogleChartProxy/PexmapsGoogleChartProxyServlet?request=" + request + "' /></div>";
*/

};

GIS.prototype.removeOverlay = function(overlay)
{
	for (var i = 0; i < map.overlayMapTypes.getLength(); i++)
	{
		if (map.overlayMapTypes.getAt(i) == overlay)
		{
			map.overlayMapTypes.removeAt(i);
			break;
		}
	}
};

GIS.prototype._clearCurrentDemographic = function()
{
	if (util.isDefined(this._currentDemographic) && this._currentDemographic != null && 
		this._currentDemographic.overlay != null)
	{
		this.removeOverlay(this._currentDemographic.overlay);	
//		map.removeOverlay(this._currentDemographic.overlay)
	}

	this._currentDemographic = null;
	
	$("#span_DemographicName").html("");
	$("#span_DemographicDescription").html("");
	$("#div_DemographicDetails").hide();
	$("#div_DemographicZoomInfo").hide();

	$("#div_GisLegendBox").hide();
	$("#div_LegendTitle").html("");
	$("#div_LegendSubtitle").html("");
	
	$("#div_DemographicZoomInfo table:first-child").html("");	
	
};




GIS.prototype._formatRequestUrl = function(firstParams)
{
	var urlParameters = "";
	
	for (var i = 0; i < firstParams.length; i++)
	{
		urlParameters += (i == 0 ? "?" : "&");
		urlParameters += (firstParams[i].name + "=" + firstParams[i].value);
	}
	
	var mapBounds = map.getBounds();
	var mapSouthWest = mapBounds.getSouthWest();
	var mapNorthEast = mapBounds.getNorthEast();
	
	urlParameters += 
		"&xmin=" + mapSouthWest.lng() +
		"&ymin=" + mapSouthWest.lat() +
		"&xmax=" + mapNorthEast.lng() +
		"&ymax=" + mapNorthEast.lat() +
		"&zoom=" + map.getZoom();

	return urlParameters;
};

GIS.prototype.layerOpacityChanged = function()
{
	if (util.isDefined(this._currentDemographic))
	{
		this.loadSelectedDemographic(true);
	}
};

var gis = new GIS();
