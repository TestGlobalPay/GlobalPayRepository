///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/

var outlines = new Outlines();


/////////////////////////////////////////////////////////////////////////////////////
// Outline
/////////////////////////////////////////////////////////////////////////////////////
function Outline()
{
	this.originalOptions = null;
	this.originalName = "";
	this.originalInfo = "";
	
	this.editInputMode = false;

	this.init = function(shape, type, options, name, info, readOnly)
	{
		this.shape = shape;
		this.type = type;
		this.options = options;
		this.name = name;
		this.info = info;
		this.readOnly = readOnly;
		
		if (this.type == "circle")
		{
			this.initCircle();
		}		
		
		
		return this;
	};
	
	
	this.initCircle = function()
	{
		var _this = this;

		google.maps.event.addListener(this.shape, "radius_changed", function()
		{
			_this._timeout = false;
		
			var projection = map.getProjection();
			var centerPoint = util.fromLatLngToPoint(_this.shape.getCenter());
		
			outlines.showCircleDistanceDisplay(centerPoint, _this.shape);
			
			setTimeout(function()
			{
				if (_this._timeout)
				{
					outlines.hideCircleDistanceDisplay();
				}
				
				_this._timeout = true;
			}, 5000);
		});
	};
	
	this.getHtml = function()
	{
		var html = "<div>";
			
		if (browserInfo.isMSIE() && browserInfo.version() < 8)
		{
			html += "<table width='223px' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		else
		{
			html += "<table width='100%' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		
		html += "<div>";
		
		html += "<b>" + this.name + "</b><br/>";

		html += "<div style='max-height:75px; min-width: 250px; overflow-y:auto; '>" + this.info + "</div>";

		html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
		
		if (this.type == "circle")
		{
			var radius = this.shape.getRadius();
			
			html += "<b>" + locale.radius + ":&nbsp;</b>";
			if (radius < 1000)
			{
				html += util.formatNumber(radius, 2) + " m (";
			}
			else
			{
		      	html += util.formatNumber((radius / 1000), 2) + " km (";
			}

		    var britishRadius = radius * 3.2808399;
		    if (britishRadius < 5280)
		    {
		    	html += util.formatNumber(britishRadius, 2) + " ft)";
		    }
		    else
		    {
		     	html += util.formatNumber((britishRadius / 5280), 2) + " mi)";
		    }
		    
		    html += "&nbsp";
		}
		if (this.type == "polyline")
		{
			var meters = google.maps.geometry.spherical.computeLength(this.shape.getPath());
			var kilometers = (Math.round(meters / 10) / 100);
			var miles = Math.round((meters / 1000) * 62.1371192) / 100; 
			
			html += "<b>Distance:</b>&nbsp;" + util.formatNumber(kilometers, 2) + " km (" + util.formatNumber(miles, 2) + " mi)";
		}
		else if (this.type == "polygon" || this.type == "circle" || this.type == "rectangle")
		{
			var squareMeters;
			
			if (this.type == "polygon")
			{
				squareMeters = google.maps.geometry.spherical.computeArea(this.shape.getPath());
			}
			else if (this.type == "circle")
			{
				var radius = this.shape.getRadius();
				squareMeters = Math.PI * radius * radius;
			}
			else if (this.type == "rectangle")
			{
				var latLngBounds = this.shape.getBounds();
				var northEast = latLngBounds.getNorthEast();
				var southWest = latLngBounds.getSouthWest();
				var northWest = new google.maps.LatLng(northEast.lat(), southWest.lng());
				var southEast = new google.maps.LatLng(southWest.lat(), northEast.lng());
				
				squareMeters = google.maps.geometry.spherical.computeArea([northEast, southEast, southWest, northWest]);
			}
			
			
			var squareKilometers = Math.round(squareMeters / 10000) / 100;
			var squareMiles = Math.round((squareMeters / 1000000) * 38.6102159) / 100;
			
			html += "<b>" + locale.area + ":</b>&nbsp;" + util.formatNumber(squareKilometers, 2) + " km<sup>2</sup> (" + util.formatNumber(squareMiles, 2) + " mi<sup>2</sup>)";
		}
		html += "</div>";
		
		if (this.shape.getEditable())
		{
			html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
			html += "<a style='color:blue' href='javascript:outlines.selectedOutline.switchToEditInputMode(InfoWindow.getPosition());'>" + locale.edit + "</a>";
			html += "<a style='color:blue;margin-left:7px' href='javascript:outlines.selectedOutline.switchToSaveTemplateMode();'>" + locale.saveAsTemplate + "</a>";
			html += "<a style='color:blue;margin-left:7px' href='javascript:InfoWindow.close();outlines.removeSelectedOutline();'>" + locale.remove + "</a>";
		}
		
		html += "</td></tr></table><div>";
		
		return html;
	};
	
	this.getEditHtml = function()
	{
		var textLimit = "255";
		var limitTextLengthJavascript = "if(this.value.length&gt;" + textLimit + ")this.value=this.value.substring(0," + textLimit + ");";
	
		var html = "<div>";
			
		if (browserInfo.isMSIE() && browserInfo.version() < 8)
		{
			html += "<table width='223px' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		else
		{
			html += "<table width='100%' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
	 	 
	 	html += "<span style='margin-left:4px; font-weight:bold'>" + locale.title + "&nbsp;</span>";
	 	html += "<input id='input_OutlineName' type='text' size='25' maxlength='80' value='" + this.name + "'/><br/>";
	 	html += "<textarea onkeydown='" + limitTextLengthJavascript + "' id='textarea_OutlineInfo' ";
	 	html += browserInfo.isFirefox() ? "rows='4' " : "rows='5' ";
	 	html += "style='resize:none; width:" + (browserInfo.isMSIE() ? "223px" : "213px") + ";margin-left:4px'>" + util.replaceBr(this.info) + "</textarea><br/>";
	 	
		html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
	 	
		html += "<table cellspacing='3px' cellPadding='0' style='margin: 0px 0px 0px 7px'>" +
			"<tr> \
				<th style='padding-right:10px'><div><b>" + locale.lineColor + "</b></div></th> \
				<th style='padding-right:10px'><div><b>" + locale.lineOpacity + "</b></div></th> \
				<th style='padding-right:10px'><div><b>" + locale.lineSize + "</b></div></th> \
			</tr>" +



			"<tr> \
				<td> \
			   		<div onmousedown='jscolor.color(this,getElementById(\"hidden_OutlineBorderColorValue\"));' styleClass='color {valueElement:\"hidden_OutlineBorderColorValue\"}' style='display:inline-block; width:40px; height:15px; border: 1px solid dimgray; text-align:center; background-color:" + this.options.strokeColor + "; cursor:pointer; ' > \
						<img src='" + territoriesImagePath + "color_grad.png'/> \
			   		<div> \
					<input id='hidden_OutlineBorderColorValue' value='" + this.options.strokeColor + "' type='hidden' onchange='outlines.selectedOutline.options.strokeColor = this.value;outlines.selectedOutline.redraw();'/> \
				</td>" +
				"<td> \
					<select id='select_OutlineBorderOpacity' onchange='outlines.selectedOutline.options.strokeOpacity = this.options[this.selectedIndex].value;outlines.selectedOutline.redraw();'> \
						<option value='0' " + (this.options.strokeOpacity == 0 ? "selected='selected'" : "") + ">0%</option> \
						<option value='.1' " + (this.options.strokeOpacity == .1 ? "selected='selected'" : "") + ">10%</option> \
						<option value='.2' " + (this.options.strokeOpacity == .2 ? "selected='selected'" : "") + ">20%</option> \
						<option value='.3' " + (this.options.strokeOpacity == .3 ? "selected='selected'" : "") + ">30%</option> \
						<option value='.4' " + (this.options.strokeOpacity == .4 ? "selected='selected'" : "") + ">40%</option> \
						<option value='.5' " + (this.options.strokeOpacity == .5 ? "selected='selected'" : "") + ">50%</option> \
						<option value='.6' " + (this.options.strokeOpacity == .6 ? "selected='selected'" : "") + ">60%</option> \
						<option value='.7' " + (this.options.strokeOpacity == .7 ? "selected='selected'" : "") + ">70%</option> \
						<option value='.8' " + (this.options.strokeOpacity == .8 ? "selected='selected'" : "") + ">80%</option> \
						<option value='.9' " + (this.options.strokeOpacity == .9 ? "selected='selected'" : "") + ">90%</option> \
						<option value='1' " + (this.options.strokeOpacity == 1 ? "selected='selected'" : "") + ">100%</option> \
					</select> \
				</td>" +
				"<td> \
					<select id='select_OutlineBorderWeight' onchange='outlines.selectedOutline.options.strokeWeight = this.options[this.selectedIndex].value;outlines.selectedOutline.redraw();'> \
						<option value='1' " + (this.options.strokeWeight == 1 ? "selected='selected'" : "") + ">1</option> \
						<option value='2' " + (this.options.strokeWeight == 2 ? "selected='selected'" : "") + ">2</option> \
						<option value='3' " + (this.options.strokeWeight == 3 ? "selected='selected'" : "") + ">3</option> \
						<option value='4' " + (this.options.strokeWeight == 4 ? "selected='selected'" : "") + ">4</option> \
						<option value='5' " + (this.options.strokeWeight == 5 ? "selected='selected'" : "") + ">5</option> \
						<option value='6' " + (this.options.strokeWeight == 6 ? "selected='selected'" : "") + ">6</option> \
						<option value='7' " + (this.options.strokeWeight == 7 ? "selected='selected'" : "") + ">7</option> \
						<option value='8' " + (this.options.strokeWeight == 8 ? "selected='selected'" : "") + ">8</option> \
						<option value='9' " + (this.options.strokeWeight == 9 ? "selected='selected'" : "") + ">9</option> \
						<option value='10' " + (this.options.strokeWeight == 10 ? "selected='selected'" : "") + ">10</option> \
					</select> \
				</td> \
			</tr>" +
			
			"<tr " + (this.type == "polyline" ? "style='visibility:collapse'" : "") + "><th style='padding:7px 10px 0px 0px'><div><b>" + locale.fillColor + "</b></div></th>" +
			"<th style='padding:7px 10px 0px 0px'><div><b>" + locale.fillOpacity + "</b></div></th></tr>" +

			"<tr " + (this.type == "polyline" ? "style='visibility:collapse'" : "") + "> \
				<td> \
			   		<div onmousedown='jscolor.color(this,getElementById(\"hidden_OutlineFillColorValue\"));' styleClass='color {valueElement:\"hidden_OutlineFillColorValue\"}' style='display:inline-block; width:40px; height:15px; border: 1px solid dimgray; text-align:center; background-color:" + this.options.fillColor + "; cursor:pointer; ' > \
						<img src='" + territoriesImagePath + "color_grad.png'/> \
			   		<div> \
			   		<input id='hidden_OutlineFillColorValue' value='" + this.options.fillColor + "' type='hidden' onchange='outlines.selectedOutline.options.fillColor = this.value;outlines.selectedOutline.redraw();'/> \
				</td>" +
				"<td> \
					<select id='select_OutlineFillOpacity' onchange='outlines.selectedOutline.options.fillOpacity = this.options[this.selectedIndex].value;outlines.selectedOutline.redraw();'> \
						<option value='0' " + (this.options.fillOpacity == 0 ? "selected='selected'" : "") + ">0%</option> \
						<option value='.1' " + (this.options.fillOpacity == .1 ? "selected='selected'" : "") + ">10%</option> \
						<option value='.2' " + (this.options.fillOpacity == .2 ? "selected='selected'" : "") + ">20%</option> \
						<option value='.3' " + (this.options.fillOpacity == .3 ? "selected='selected'" : "") + ">30%</option> \
						<option value='.4' " + (this.options.fillOpacity == .4 ? "selected='selected'" : "") + ">40%</option> \
						<option value='.5' " + (this.options.fillOpacity == .5 ? "selected='selected'" : "") + ">50%</option> \
						<option value='.6' " + (this.options.fillOpacity == .6 ? "selected='selected'" : "") + ">60%</option> \
						<option value='.7' " + (this.options.fillOpacity == .7 ? "selected='selected'" : "") + ">70%</option> \
						<option value='.8' " + (this.options.fillOpacity == .8 ? "selected='selected'" : "") + ">80%</option> \
						<option value='.9' " + (this.options.fillOpacity == .9 ? "selected='selected'" : "") + ">90%</option> \
						<option value='1' " + (this.options.fillOpacity == 1 ? "selected='selected'" : "") + ">100%</option> \
					</select> \
				</td> \
			</tr></table>";
	
		html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
		html += "<span style='margin-left:4px'><input class='btn' onclick='outlines.selectedOutline.saveEdits();outlines.selectedOutline.switchToDisplayMode();' type='button' value='" + locale.ok + "'/></span>";
		html += "<span style='margin-left:4px'><input class='btn' onclick='outlines.selectedOutline.cancelEdits();outlines.selectedOutline.switchToDisplayMode();' type='button' value='" + locale.cancel + "'/></span>";
		html += "</td></tr></table></div>";
	
	 	return html;
	};
	
	this.getSaveTemplateHtml = function()
	{
		var html = "<div>";
			
		if (browserInfo.isMSIE() && browserInfo.version() < 8)
		{
			html += "<table width='223px' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		else
		{
			html += "<table width='100%' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		
		html += "<span><b>" + locale.saveOutlineTemplate + "</b><br/><br/> \
			<span>" + locale.enterNameForTemplate + ":</span><br/> \
			<input id='input_TemplateName' type='text' size='32' style='margin-top:2px'>";
			
		html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
		html += "<span style='margin-left:4px'><input class='btn' onclick='javascript:outlines.saveSelectedOutlineAsTemplate(document.getElementById(\"input_TemplateName\").value);' type='button' value='" + locale.save + "'/></span>";
		html += "<span style='margin-left:4px'><input class='btn' onclick='outlines.selectedOutline.switchToDisplayMode();' type='button' value='" + locale.cancel + "'/></span>";

		html += "</td></tr></table></div>";
		
		return html;
	};
	
	this.switchToEditInputMode = function(latLng)
	{
		this.editInputMode = true;
		
		this.originalOptions = $.extend({}, this.options);
		this.originalName = this.name;
		this.originalInfo = this.info;
		
		InfoWindow.close();
		InfoWindow.setContent(this.getEditHtml());
		InfoWindow.setPosition(latLng);
		InfoWindow.open(map);
	};

	this.switchToSaveTemplateMode = function()
	{
//		var latLng = map.getInfoWindow().getPoint();
		var latLng = InfoWindow.getPosition();
		InfoWindow.setContent(this.getSaveTemplateHtml());
		InfoWindow.open(map);
	}
	
	this.switchToDisplayMode = function(latLng)
	{
		this.editInputMode = false;

		InfoWindow.close();
		InfoWindow.setContent(this.getHtml());
		if (latLng)
		{
			InfoWindow.setPosition(latLng);
		}
		InfoWindow.open(map);
	};
	
	this.saveEdits = function()
	{
		this.name = document.getElementById("input_OutlineName").value;
		this.info = util.replaceCrlf(document.getElementById("textarea_OutlineInfo").value);
	};
	
	this.cancelEdits = function()
	{
		this.options = $.extend({}, this.originalOptions);
		this.name = this.originalName;
		this.info = this.originalInfo;
		
		this.redraw();
	};

	this.getVertices = function()
	{
		if (this.type == "polyline")
		{
			return this.shape.getPath().getArray();
		}
		else if (this.type == "polygon")
		{
			return this.shape.getPaths().getAt(0).getArray();
		}
		else if (this.type == "rectangle")
		{
			var latLngBounds = this.shape.getBounds();
			var northEast = latLngBounds.getNorthEast();
			var southWest = latLngBounds.getSouthWest();
			var northWest = new google.maps.LatLng(northEast.lat(), southWest.lng());
			var southEast = new google.maps.LatLng(southWest.lat(), northEast.lng());
		
			return [northEast, southEast, southWest, northWest, northEast];
		}
		else if (this.type == "circle")
		{
			return [];
		}
	};

	this.containsPoint = function(point)
	{
		if (this.type == "polyline")
		{
			return false;
		}
		else if (this.type == "polygon")
		{
			return util.pointInPolygon(this.getVertices(), point);
		}
		else if (this.type == "rectangle")
		{
			var bounds = this.shape.getBounds();
			var southWest = bounds.getSouthWest();
			var northEast = bounds.getNorthEast();
	
			return (point.lat() >= Math.min(northEast.lat(), southWest.lat()) && point.lat() <= Math.max(northEast.lat(), southWest.lat()) &&
				point.lng() >= Math.min(southWest.lng(), northEast.lng()) && point.lng() <= Math.max(southWest.lng(), northEast.lng()));		

			//return (point.lat() >= northEast.lat() && point.lat() <= southWest.lat() &&
			//	point.lng() >= southWest.lng() && point.lng() <= northEast.lng());		
		}
		else if (this.type == "circle")
		{
			var path = [this.shape.getCenter(), point];
			return google.maps.geometry.spherical.computeLength(path) <= this.shape.getRadius();
		}
	};
				
	this.redraw = function()
	{
		this.shape.setOptions(this.options);
	};

	this.getGeocodes = function()
	{
		var geocodes = "";
	
		if (this.type == "polyline")
		{
			var vertices = this.shape.getPath().getArray();
			
			for (var i = 0; i < vertices.length; i++)
			{
				var vertex = vertices[i];
					
				if (geocodes.length > 0)
				{
					geocodes += ",";
				}
					
				geocodes += String(vertex.lat()) + ',' + String(vertex.lng());
			}
		}
		else if (this.type == "polygon")
		{
			var vertices = this.shape.getPaths().getAt(0).getArray();
			
			for (var i = 0; i < vertices.length; i++)
			{
				var vertex = vertices[i];
					
				if (geocodes.length > 0)
				{
					geocodes += ",";
				}
					
				geocodes += String(vertex.lat()) + ',' + String(vertex.lng());
			}
			
			var vertex = vertices[0];
			geocodes += String(',' + vertex.lat()) + ',' + String(vertex.lng());
			
		}
		else if (this.type == "rectangle")
		{
			var vertices = this.shape.getBounds();
			var northEast = vertices.getNorthEast();
			var southWest = vertices.getSouthWest();
			
			geocodes += (northEast.lat() + "," + southWest.lng() + ",");
			geocodes += (southWest.lat() + "," + northEast.lng());
			
			return separator.brokenBar + geocodes;
		}
		else if (this.type == "circle")
		{
			var center = this.shape.getCenter();
			return separator.currency + center.lat() + "," + center.lng() + "," + this.shape.getRadius();
		}
		
		return geocodes;
		
	};
	
	this.enableEditing = function()
	{
		this.shape.setEditable(true);
		this.shape.setDraggable(true);
	};

	this.disableEditing = function()
	{
		this.shape.setEditable(false);
		this.shape.setDraggable(false);
	};
}


/////////////////////////////////////////////////////////////////////////////////////
// Outlines
/////////////////////////////////////////////////////////////////////////////////////
function Outlines()
{
	this.outlines = [];
	this.readOnlyOutlines = []; // needed for exports
	
	this.circleOutlineIndex = 0;
	
	this.defaultOutlineOptions = {
		strokeColor: "#ff0000",
		strokeWeight: 2,
		strokeOpacity: 0.7,
		fillColor: "#ff0000",
		fillOpacity: 0.2
	};
	
	
			
	this._defaultCircleOptions = {
		fillColor: this.defaultOutlineOptions.fillColor,
		fillOpacity: this.defaultOutlineOptions.fillOpacity,
		strokeColor: this.defaultOutlineOptions.strokeColor,
		strokeOpacity: this.defaultOutlineOptions.strokeOpacity,
		strokeWeight: this.defaultOutlineOptions.strokeWeight,
		clickable: true,
		draggable: true,
		editable: true,
		zIndex: 1
	};



	this._defaultPolygonOptions = {
		fillColor: this.defaultOutlineOptions.fillColor,
		fillOpacity: this.defaultOutlineOptions.fillOpacity,
		strokeColor: this.defaultOutlineOptions.strokeColor,
		strokeOpacity: this.defaultOutlineOptions.strokeOpacity,
		strokeWeight: this.defaultOutlineOptions.strokeWeight,
		clickable: true,
		draggable: false,
		editable: true,
		zIndex: 1
	};

	this._defaultPolylineOptions = {
		strokeColor: this.defaultOutlineOptions.strokeColor,
		strokeOpacity: this.defaultOutlineOptions.strokeOpacity,
		strokeWeight: this.defaultOutlineOptions.strokeWeight,
		clickable: true,
		draggable: false,
		editable: true,
		zIndex: 1
	};
	
	this._defaultRectangleOptions = {
		fillColor: this.defaultOutlineOptions.fillColor,
		fillOpacity: this.defaultOutlineOptions.fillOpacity,
		strokeColor: this.defaultOutlineOptions.strokeColor,
		strokeOpacity: this.defaultOutlineOptions.strokeOpacity,
		strokeWeight: this.defaultOutlineOptions.strokeWeight,
		clickable: true,
		draggable: true,
		editable: true,
		zIndex: 1
	};

	
	this._defaultOutlineName = locale.untitled;
	this._defaultOutlineInfo = "";
	

	this.publicOutlinesSheetKey = "thzPhzM3CbEnraGx1fOouhg";
	
	this.loader = new OutlineLoader();
	
	this.maxVertices = 100;
	this.MAX_OUTLINES = 50;
	
	this.outlinesEditorOpen = false;
	
	this._showInfoWindow = true;
	
	var selectedOutline;

/*
	this.onMapMouseDown = function(latLng)
	{
		if (!this.outlinesEditorOpen)
		{
			return;
		}
		
		alert('test');
	};	
*/
	
	this.initialize = function()
	{
		this.enableEditing();
	};

	this.disableInfoWindow = function()
	{
		this._showInfoWindow = false;
	};
	
	this.enableInfoWindow = function()
	{
		this._showInfoWindow = true;
	};

	this.enableAllCircleOutlineEditing = function()
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			if (this.outlines[i].type == "circle")
			{
				this.outlines[i].enableCircleEditing();
			}
		}
	};
	
	this.getCircleOutline = function(index)
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			if (this.outlines[i].type == "circle" &&
				this.outlines[i].index == index)
			{
				return this.outlines[i];
			}
		}
		
		return null;
	};

	this.appendOutline = function(outline)
	{
		if (outline.readOnly)
		{
			this.readOnlyOutlines.push(outline);
		}
		else
		{
			this.outlines.push(outline);
		}
		
		if (outline.type == "circle")
		{
			outline.setIndex(String(this.circleOutlineIndex++));
		}
	};

	this.addOutline = function(type, geocodes, options, name, info, enableDrawing, enableEditing, readOnly)
	{
		var shape;
		
		if (type == "polygon")
		{
			shape = new google.maps.Polygon(options);
			shape.setPaths(geocodes);
		}
		if (type == "polyline")
		{
			shape = new google.maps.Polyline(options);
			shape.setPath(geocodes);
		}
		else if (type == "circle")
		{
			shape = new google.maps.Circle(options);
			shape.setCenter(geocodes[0]);
			shape.setRadius(geocodes[1]);
		}
		else if (type == "rectangle")
		{
			shape = new google.maps.Rectangle(options);
			var latLngBounds = new google.maps.LatLngBounds(geocodes[0], geocodes[1]);
			shape.setBounds(latLngBounds);
		}

		var outline = new Outline().init(shape, type, options, name, info, readOnly);
		
		this._addClickListener(outline);
		
		if (readOnly)
		{
			this.readOnlyOutlines.push(outline);
			outline.disableEditing();
		}
		else //if (enableEditing)
		{
			this.outlines.push(outline);
		}

		if (enableEditing)
		{
			outline.enableEditing();
		}
		
		shape.setMap(map);		
	};
	
  	this._onShapeDrawingComplete = function(shape, type)
  	{
  		this._drawingManager.setDrawingMode(null);
  	
  	
  		var defaultOptions = {
			fillColor: this.defaultOutlineOptions.fillColor,
			fillOpacity: this.defaultOutlineOptions.fillOpacity,
			strokeColor: this.defaultOutlineOptions.strokeColor,
			strokeOpacity: this.defaultOutlineOptions.strokeOpacity,
			strokeWeight: this.defaultOutlineOptions.strokeWeight,
  		};
  		
		var outline = new Outline().init(shape, type, defaultOptions, this._defaultOutlineName, 
			this._defaultOutlineInfo, false);

		this.outlines.push(outline);	
		this._addClickListener(outline);
	};
	
  	this._addClickListener = function(outline)
  	{
		google.maps.event.addListener(outline.shape, "click",
			function(event)
			{
				outlines.selectedOutline = outline;
				outline.switchToDisplayMode(event.latLng);
			});	
	};
	
	this.getDrawingManager = function()
	{
		if (!this._drawingManager)
		{
			var drawingControlOptions = {
				position: google.maps.ControlPosition.TOP_CENTER,
				drawingModes: [
					google.maps.drawing.OverlayType.CIRCLE,
					google.maps.drawing.OverlayType.POLYGON,
					google.maps.drawing.OverlayType.POLYLINE,
					google.maps.drawing.OverlayType.RECTANGLE
				],
			};
			
			
			var drawingManagerOptions = {
				drawingControl: true,
				drawingControlOptions: drawingControlOptions,
				circleOptions: this._defaultCircleOptions,
				polygonOptions: this._defaultPolygonOptions,
				polylineOptions: this._defaultPolylineOptions,
				rectangleOptions: this._defaultRectangleOptions,
			};

			this._drawingManager = new google.maps.drawing.DrawingManager(drawingManagerOptions);
			
			var _this = this;
			
			google.maps.event.addListener(this._drawingManager, "polygoncomplete", function(polygon)
			{
				_this._onShapeDrawingComplete(polygon, "polygon");					
			});			

			google.maps.event.addListener(this._drawingManager, "polylinecomplete", function(polyline)
			{
				_this._onShapeDrawingComplete(polyline, "polyline");					
			});			

			google.maps.event.addListener(this._drawingManager, "circlecomplete", function(circle)
			{
				_this._onShapeDrawingComplete(circle, "circle");					
			});			
			
			google.maps.event.addListener(this._drawingManager, "rectanglecomplete", function(rectangle)
			{
				_this._onShapeDrawingComplete(rectangle, "rectangle");					
			});			
		}
		
		return this._drawingManager;
	};
	
  	
  	this.showDrawingManager = function()
  	{
		this.getDrawingManager().setMap(map);
  	};
  	
  	this.hideDrawingManager = function()
  	{
		this.getDrawingManager().setMap(null);
  	};
  	
	this.onOpenOutlinesEditor = function()
	{
		InfoWindow.close();

		this.showDrawingManager();
		
		this.outlinesEditorOpen = true;
		this.fetchPublicOutlinesList();
	};
		
	this.onCloseOutlines = function()
	{
		this.outlinesEditorOpen = false;
		
		InfoWindow.close();
		
		this.hideDrawingManager();
		
		if (typeof jscolor != "undefined" &&
			typeof jscolor.hidePicker == "function")
		{		
			jscolor.hidePicker();
		}
		
		this.saveAllOutlineData();
		this.disableEditing()
	};		

	this.onQuickSave = function()
	{
		this.saveAllOutlineData();
	};
		
	this.verifyOutlineCount = function()
	{
		if (this.outlines.length >= this.MAX_OUTLINES)
		{
			alert(locale.outlineLimitReached.replace("{0}", String(this.MAX_OUTLINES)));
			return false;
		}
		
		return true;
	};		
		
	this.fetchPublicOutlinesList = function()
	{
		/*	
		removeOldScriptNodes();

  		var script = document.createElement("script");
    	script.setAttribute("src", "http://spreadsheets.google.com/feeds/cells/" +
    		this.publicOutlinesSheetKey + "/1/public/values?alt=json-in-script&callback=listPublicOutlinesCallback");
		script.setAttribute("id", "outlinesScript");
  		script.setAttribute("type", "text/javascript");
		document.documentElement.firstChild.appendChild(script);
		*/

		this.listPublicOutlines();
	};
	
	this.listPublicOutlines = function(publicOutlinesJson)
	{
		/*	
		for (var i = 0; i < publicOutlinesJson.feed.entry.length; i += 2) 
		{
			var name = publicOutlinesJson.feed.entry[i].content.$t;
			var value = publicOutlinesJson.feed.entry[i + 1].content.$t;
			
			var publicOutlinesListSelect = document.getElementById("select_PublicOutlines");
			util.addSelectListOption(publicOutlinesListSelect, value, name);
		}
		*/
		
		var publicOutlinesListSelect = document.getElementById("select_PublicOutlines");
		util.addSelectListOption(publicOutlinesListSelect, "tMNzi-ZmqAj09jzBdYc10JA", "US States");
		
		util.hideLoadingImage();
	};

	this.publicOutlineTypeSelected = function()
	{
		var selectedType = $("#select_PublicOutlines option:selected").val();
		
		if (selectedType === "NONE")
		{
			$("#span_SelectPublicOutline").hide();
			$("#span_ZipCodeEntry").hide();
			return;
		}
		else if (selectedType === "zipCodes")
		{
			$("#span_ZipCodeEntry").show();
			$("#span_SelectPublicOutline").hide();
		}
		else
		{
			$("#span_SelectPublicOutline").show();
			$("#span_ZipCodeEntry").hide()

			util.showLoadingImage();
			this.fetchPublicOutlineItems();
		}
	};

	this.fetchPublicOutlineItems = function()
	{
		/*
		var publicOutlinesListSelect = $("#select_PublicOutlines").get(0);

		removeOldScriptNodes();

		var outlineItemsSheetKey = publicOutlinesListSelect.options[publicOutlinesListSelect.selectedIndex].value;

  		var script = document.createElement("script");
    	script.setAttribute("src", "http://spreadsheets.google.com/feeds/cells/" +
    		outlineItemsSheetKey + "/1/public/values?alt=json-in-script&callback=listPublicOutlineItemsCallback");
		script.setAttribute("id", "outlinesScript");
  		script.setAttribute("type", "text/javascript");
		document.documentElement.firstChild.appendChild(script);
		*/
		
		this.listPublicOutlineItems();
	};

	this.listPublicOutlineItems = function(publicOutlinesJson)
	{
		var publicOutlinesItemsSelect = document.getElementById("select_PublicOutlineItems");
		
		for (stateAbbr in usStates)
		{
			util.addSelectListOption(publicOutlinesItemsSelect, stateAbbr, usStates[stateAbbr]);
		}
		
	
		/*
		var publicOutlinesItemsSelect = document.getElementById("select_PublicOutlineItems");
	
		for (var i = 0; i < publicOutlinesJson.feed.entry.length; i += 2) 
		{
			var name = publicOutlinesJson.feed.entry[i].content.$t;
			var value = publicOutlinesJson.feed.entry[i + 1].content.$t;
			
			util.addSelectListOption(publicOutlinesItemsSelect, value, name);
		}
		*/
		util.hideLoadingImage();		
	};
	
	this.loadPublicOutline = function()
	{
		if(!this.verifyOutlineCount())
		{
			return;
		}
		
		util.showLoadingImage();
		
		var publicOutlinesListSelect = document.getElementById("select_PublicOutlines");
		var publicOutlinesItemsSelect = document.getElementById("select_PublicOutlineItems");

		var outlineItemsSheetKey = publicOutlinesListSelect.options[publicOutlinesListSelect.selectedIndex].value;
		var columnIndex = publicOutlinesItemsSelect.selectedIndex;
		
		var publicOutlineData = outlineItemsSheetKey + separator.para + String(columnIndex);
		
		outlines.loader.loadPublicOutline(publicOutlineData);
		
		var publicOutlinesItemsSelect = document.getElementById("select_PublicOutlineItems");
		publicOutlinesItemsSelect.selectedIndex = 0;
		
		util.hideLoadingImage();
	};
	
	this.removeSelectedOutline = function()
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			if (this.outlines[i] === this.selectedOutline)
			{
				this.outlines.splice(i, 1)[0].shape.setMap(null);
				return;
			}
		}
	};
	
	this.removeOutlines = function()
	{
		var outlineCount = this.outlines.length;
		
		for (var i = 0; i < outlineCount; i++)
		{
			this.outlines.pop().shape.setMap(null);
		}
		
		outlineCount = this.readOnlyOutlines.length;
		
		for (var i = 0; i < outlineCount; i++)
		{
			this.readOnlyOutlines.pop().shape.setMap(null);
		}
	};
	
	this.clearAllOutlines = function()
	{
		this.removeOutlines();
		this.outlines = [];
		this.readOnlyOutlines = [];
		
//		this.clearAllOutlineData();
	};
	
	this.enableEditing = function()
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			this.outlines[i].enableEditing();
		}
	};
	
	this.disableEditing = function()
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			this.outlines[i].disableEditing();
		}
	};

	this.loadOutlineFromData = function(outlineDataInputId, enableEditing, readOnly)
	{
		var outlineData = document.getElementById(outlineDataInputId).value;
		
		if (outlineData == null || outlineData.length == 0)
		{
			return false;
		}

		var outlineDataItems = outlineData.split(separator.section);
		var outlineName = outlineDataItems[0];
		var outlineInfo = outlineDataItems[1];
		var geocodeData = outlineDataItems[3]; 

	
		var outlineOptionsDataItems = outlineDataItems[2].split(separator.para);

		var options = {
			strokeColor: outlineOptionsDataItems[0],
			strokeWeight: outlineOptionsDataItems[1],
			strokeOpacity: outlineOptionsDataItems[2],
			fillColor: outlineOptionsDataItems[3],
			fillOpacity: outlineOptionsDataItems[4],
		};
		
		var outlineType = "";
		var geocodes = [];
		var keyChar = geocodeData.substr(0, 1);

		if (keyChar == separator.currency)
		{
			var outlineDataItems = geocodeData.slice(1).split(",");
			var center = new google.maps.LatLng(Number(outlineDataItems[0]), Number(outlineDataItems[1]));
			var radius = Number(outlineDataItems[2]);
		
			geocodes.push(center, radius);
		
			outlineType = "circle";
		}
		else if (keyChar == separator.brokenBar)
		{
			var outlineDataItems = geocodeData.slice(1).split(",");
			var northEast = new google.maps.LatLng(Number(outlineDataItems[0]), Number(outlineDataItems[1]));
			var southWest = new google.maps.LatLng(Number(outlineDataItems[2]), Number(outlineDataItems[3]));
		
			geocodes.push(northEast, southWest);
		
			outlineType = "rectangle";
		}
		else
		{
			var outlineGeocodes = geocodeData.split(","); 
				
			for (var i = 0; i < outlineGeocodes.length; i += 2)
			{
				geocodes.push(new google.maps.LatLng(Number(outlineGeocodes[i]), Number(outlineGeocodes[i + 1])));
			}
		
			outlineType = (geocodes[0].lat() == geocodes[geocodes.length - 1].lat() &&
				geocodes[0].lng() == geocodes[geocodes.length - 1].lng()) ? "polygon" : "polyline";
		}
		
		this.addOutline(outlineType, geocodes, options, outlineName, outlineInfo, false, enableEditing, readOnly);
		
		return true;
	};

	this.loadTemplate = function()
	{
		util.hideLoadingImage();
		this.loadOutlineFromData("page_Territories:form_Territories:hidden_OutlineTemplate", true);
		document.getElementById("page_Territories:form_Territories:hidden_OutlineTemplate").value = "";
	};

	this.loadViewOutlines = function(readOnly)
	{
		for (var i = 0; i < this.MAX_OUTLINES; i++)
		{
			if (!this.loadOutlineFromData("page_Territories:form_Territories:hidden_Outline" + String(i + 1), false, readOnly))
			{
				break;
			}
		}

		this.clearAllOutlineData();
	};

	this.saveAllOutlineData = function()
	{
		this.clearAllOutlineData();
		
		for (var i = 0; i < this.outlines.length; i++)
		{
			document.getElementById("page_Territories:form_Territories:hidden_Outline" + String(i + 1)).value =
				this.outlines[i].name + 
				separator.section + 
				this.outlines[i].info + 
				separator.section + 
				this.getOutlineOptionString(this.outlines[i].options) + 
				separator.section + 
				this.outlines[i].getGeocodes();
			 
//				this.getOutlineOptionString(this.outlines[i].options) + separator.section + 
//				this.outlines[i].name + separator.section + this.outlines[i].info + separator.section + 
//				this.outlines[i].getGeocodes();
		}
	};
	
	this.getOutlineOptionString = function(outlineOptions)
	{
		return outlineOptions.strokeColor + separator.para +
			outlineOptions.strokeWeight + separator.para +
			outlineOptions.strokeOpacity + separator.para +
			outlineOptions.fillColor + separator.para +
			outlineOptions.fillOpacity;
	};
	
	this.saveSelectedOutlineAsTemplate = function(templateName)
	{
		if (util.trim(templateName).length == 0)
		{
			alert(locale.enterNameForTemplate);
			return;
		}
		
		var outlineTemplate = 
			templateName + 
			separator.section + 
			separator.section + 
			this.getOutlineOptionString(this.selectedOutline.options) +
			//this.selectedOutline.options.toOptionString() + 
			separator.section + 
			this.selectedOutline.getGeocodes();
			
		InfoWindow.close();			
		util.showLoadingImage();
		saveOutlineTemplate(outlineTemplate);
	};
	
	this.afterSaveTemplate = function()
	{
		util.hideLoadingImage();
		this.selectedOutline.switchToDisplayMode();
	};
	
	this.clearAllOutlineData = function()
	{
		for (var i = 0; i < this.MAX_OUTLINES; i++)
		{
			document.getElementById("page_Territories:form_Territories:hidden_Outline" +
				String(i + 1)).value = "";
		}
	};
	
	this.cleanUp = function()
	{
		this.clearAllOutlines();
				
//		this.outlines.length = 0;
//		this.readOnlyOutlines.length = 0;

	};
	
	
	
	
	
	
	
	
	
	
	
	



	this.getCircleDistanceDisplay = function()
	{
		if (!this.circleDistanceDisplay)
		{
			this.circleDistanceDisplay = $("<div></div>")
				.css("border", "1px solid red")
				.css("backgroundColor", "yellow")
				.css("padding", "0px 3px")
				.css("fontSize", "90%")
				.css("position", "absolute")
				.appendTo(getMapCanvas())
				.hide();

		}
		
		return this.circleDistanceDisplay;
	};
	
	this.showCircleDistanceDisplay = function(point, circle)
	{
		this.getCircleDistanceDisplay()
			.css("left", (point.x + 10) + "px")
			.css("top", (point.y + 10) + "px")
			.html(this.getCircleDisplayText(circle))
			.show();
	};
	
	this.getCircleDisplayText = function(circle)
	{
		var displayText = "<b>" + locale.radius + ":&nbsp;</b>";
		var radius = circle.getRadius();
		
		if (radius < 1000)
		{
			displayText += util.formatNumber(radius, 2) + " m (";
		}
		else
		{
	      	displayText += util.formatNumber((radius / 1000), 2) + " km (";
		}

	    var britishRadius = radius * 3.2808399;
	    if (britishRadius < 5280)
	    {
	    	displayText += util.formatNumber(britishRadius, 2) + " ft)";
	    }
	    else
	    {
	     	displayText += util.formatNumber((britishRadius / 5280), 2) + " mi)";
	    }
	    
	    return displayText;
	};
	
	this.hideCircleDistanceDisplay = function()
	{
		this.circleDistanceDisplay.hide();
	};
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}

/*

/////////////////////////////////////////////////////////////////////////////////////
// CircleDisplayOverlay
/////////////////////////////////////////////////////////////////////////////////////
function CircleDisplayOverlay(center, text)
{
	this._center = center;
	this._text = text;
	this._div = null;
	this._bounds = null;
}

CircleDisplayOverlay.prototype = new google.maps.OverlayView();

CircleDisplayOverlay.prototype.onAdd = function() 
{
	this._div = $("<div></div>")
		.addClass("nameOverlay")
		.text(this._text)
		
	this.getPanes().overlayLayer.appendChild(this._div.get(0));		
};

CircleDisplayOverlay.prototype._setPosition = function()
{
	var projection = this.getProjection();
	
	var centerPoint = projection.fromLatLngToDivPixel(this._center);
	var halfWidth = this._div.width() / 2;
	var halfHeight = this._div.height() / 2;
	
	var southWest = projection.fromDivPixelToLatLng(new google.maps.Point(centerPoint.x - halfWidth, centerPoint.y + halfHeight)); 
	var northEast = projection.fromDivPixelToLatLng(new google.maps.Point(centerPoint.x + halfWidth, centerPoint.y - halfHeight)); 
	
	this._bounds = new google.maps.LatLngBounds(new google.maps.LatLng(southWest.lat(), southWest.lng()),
	    new google.maps.LatLng(northEast.lat(), northEast.lng()));
};

CircleDisplayOverlay.prototype.reposition = function(newCenter)
{
	this._center = newCenter;
	this.setMap(map);
};

CircleDisplayOverlay.prototype.onRemove = function() 
{
	this._div.remove();
};

CircleDisplayOverlay.prototype.copy = function() 
{
	return new CircleDisplayOverlay(this._center, this._text);
};

CircleDisplayOverlay.prototype.draw = function() 
{
	this._setPosition();
	
	var projection = this.getProjection();

	var southWest = projection.fromLatLngToDivPixel(this._bounds.getSouthWest());
	var northEast = projection.fromLatLngToDivPixel(this._bounds.getNorthEast());

	this._div
		.css("left", Math.min(northEast.x, southWest.x) + "px")
		.css("top", Math.min(northEast.y, southWest.y) + "px");
};

CircleDisplayOverlay.prototype.getText = function()
{
	return this._text;
};

*/








/////////////////////////////////////////////////////////////////////////////////////
// OutlineLoader
/////////////////////////////////////////////////////////////////////////////////////
function OutlineLoader()
{
	this.loadPublicOutline = function(publicOutlineData)
	{
/*	
		var outlineDataItems = publicOutlineData.split(separator.para);
		var outlineItemsSheetKey = outlineDataItems[0];
		var columnIndex = outlineDataItems[1];
		
		removeOldScriptNodes();
	
  		var script = document.createElement("script");
    	script.setAttribute("src", "http://spreadsheets.google.com/feeds/cells/" +
    		outlineItemsSheetKey + "/2/public/values?min-col=" + columnIndex +
    		"&max-col=" + columnIndex + "&alt=json-in-script&callback=loadOutlineCallback");
		script.setAttribute("id", "outlinesScript");
  		script.setAttribute("type", "text/javascript");
		document.documentElement.firstChild.appendChild(script);
*/
		this.formatOutlineGeocodes();
		
	};
	
	this.formatOutlineGeocodes = function(publicOutlinesJson)
	{
		var publicOutlinesItemsSelect = document.getElementById("select_PublicOutlineItems");
		var stateAbbr = publicOutlinesItemsSelect.options[publicOutlinesItemsSelect.selectedIndex].value;
	
		var coords = usStatesOutlines[stateAbbr];
		
		var geocodes = [];

		for (var i = 0; i < coords.length; i += 2)	
		{
			var geocode = new google.maps.LatLng(Number(coords[i]), Number(coords[i + 1]));
				
			geocodes.push(geocode);
		}

		outlines.addOutline("polygon", geocodes, outlines.defaultOutlineOptions, 
			outlines._defaultOutlineName, outlines._defaultOutlineInfo, false, true, false);
		
/*	
		var geocodes = [];
		
		for (var i = 1; i < publicOutlinesJson.feed.entry.length; i += 2) 
		{
			var geocode = new google.maps.LatLng(Number(publicOutlinesJson.feed.entry[i].content.$t),
				Number(publicOutlinesJson.feed.entry[i + 1].content.$t));
				
			geocodes.push(geocode);
		}		

		outlines.addOutline("polygon", geocodes, new OutlineOptions(outlines.DEFAULT_OUTLINE_OPTIONS_DATA), 
			outlines.DEFAULT_OUTLINE_NAME, outlines.DEFAULT_OUTLINE_INFO, false, true, false);
*/	
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// Globals
/////////////////////////////////////////////////////////////////////////////////////
/*
function removeOldScriptNodes()
{
	var script = document.getElementById("outlinesScript");
	
  	if (script != null)
  	{
    	script.parentNode.removeChild(script);
  	}
};	

function listPublicOutlinesCallback(publicOutlinesJson)
{
	outlines.listPublicOutlines(publicOutlinesJson);
}

function listPublicOutlineItemsCallback(publicOutlinesJson)
{
	outlines.listPublicOutlineItems(publicOutlinesJson);
}

function loadOutlineCallback(publicOutlinesJson)
{
	outlines.loader.formatOutlineGeocodes(publicOutlinesJson);
}
*/

/////////////////////////////////////////////////////////////////////////////////////
// US States outlines
/////////////////////////////////////////////////////////////////////////////////////

var usStates = {
"AL": "Alabama",
"AZ": "Arizona",
"AR": "Arkansas",
"CA": "California",
"CO": "Colorado",
"CT": "Connecticut",
"DE": "Delaware",
"FL": "Florida",
"GA": "Georgia",
"ID": "Idaho",
"IL": "Illinois",
"IN": "Indiana",
"IA": "Iowa",
"KS": "Kansas",
"KY": "Kentucky",
"LA": "Louisiana",
"ME": "Maine",
"MD": "Maryland",
"MA": "Massachusetts",
"MI": "Michigan",
"MN": "Minnesota",
"MS": "Mississippi",
"MO": "Missouri",
"MT": "Montana",
"NE": "Nebraska",
"NV": "Nevada",
"NH": "New Hampshire",
"NJ": "New Jersey",
"NM": "New Mexico",
"NY": "New York",
"NC": "North Carolina",
"ND": "North Dakota",
"OH": "Ohio",
"OK": "Oklahoma",
"OR": "Oregon",
"PA": "Pennsylvania",
"RI": "Rhode Island",
"SC": "South Carolina",
"SD": "South Dakota",
"TN": "Tennessee",
"TX": "Texas",
"UT": "Utah",
"VT": "Vermont",
"VA": "Virginia",
"WA": "Washington",
"WV": "West Virginia",
"WI": "Wisconsin",
"WY": "Wyoming",
};


var usStatesOutlines = {
"AL" : [
34.957996,
-88.154297,
34.994003,
-85.649414,
32.324276,
-84.946289,
31.653381,
-85.078125,
31.01528,
-84.946289,
30.939924,
-87.583008,
30.448673,
-87.495117,
30.448673,
-88.505859,
34.957996,
-88.154297,
],
"AZ": [
32.546814,
-115.092773,
31.278551,
-110.961914,
31.316101,
-109.072266,
37.055176,
-109.379883,
37.0201,
-111.181641,
36.244274,
-112.060547,
35.995785,
-114.609375,
34.379711,
-114.389648,
32.546814,
-115.092773,
],
"AR": [
36.597889,
-94.570312,
36.562599,
-90.175781,
35.853439,
-90.395508,
36.03133,
-89.648438,
33.797409,
-91.142578,
33.284618,
-91.230469,
33.100746,
-93.911133,
33.61462,
-94.042969,
33.724339,
-94.526367,
35.924644,
-94.526367,
36.597889,
-94.570312,
],
"CA": [
32.620869,
-117.246094,
32.768799,
-114.873047,
34.452217,
-114.433594,
39.027718,
-119.794922,
41.967659,
-119.970703,
42.032974,
-124.365234,
39.639538,
-123.837891,
35.029995,
-120.673828,
33.651207,
-117.773438,
32.620869,
-117.246094,
],
"CO": [
40.913513,
-102.172852,
36.985004,
-102.084961,
37.055176,
-109.116211,
41.046219,
-109.116211,
40.913513,
-102.172852,
],
"CT": [
42.016651,
-71.806641,
41.335575,
-71.828613,
41.26955,
-72.971191,
40.996483,
-73.652344,
42.065605,
-73.45459,
42.016651,
-71.806641,
],
"DE": [
38.82259,
-75.135498,
39.436192,
-75.476074,
39.876019,
-75.498047,
39.67337,
-75.9375,
38.513786,
-75.717773,
38.462193,
-75.025635,
38.82259,
-75.135498,
],
"FL": [
30.259068,
-87.539062,
30.97761,
-87.583008,
31.052935,
-85.03418,
30.600094,
-81.474609,
29.535231,
-81.298828,
26.824072,
-80.024414,
25.125393,
-80.507812,
26.115986,
-81.782227,
27.605671,
-82.749023,
28.806173,
-82.617188,
30.145126,
-83.891602,
30.031055,
-84.550781,
29.688053,
-85.209961,
30.334953,
-86.264648,
30.259068,
-87.539062,
],
"GA": [
34.957996,
-85.693359,
32.287132,
-84.946289,
31.690783,
-85.166016,
31.01528,
-85.03418,
30.713505,
-81.606445,
32.175613,
-80.859375,
33.284618,
-81.826172,
34.597042,
-83.144531,
35.101933,
-83.276367,
34.957996,
-85.693359,
],
"ID": [
42.163403,
-116.982422,
42.098221,
-111.005859,
44.653023,
-111.269531,
44.402393,
-112.939453,
45.521744,
-114.082031,
45.460133,
-114.697266,
46.619263,
-114.433594,
47.989922,
-116.191406,
49.037868,
-116.103516,
48.922501,
-117.158203,
42.163403,
-116.982422,
],
"IL": [
37.0201,
-89.208984,
38.925228,
-90.175781,
39.842285,
-91.538086,
40.580585,
-91.40625,
41.112469,
-90.966797,
41.508575,
-91.142578,
41.771313,
-90.219727,
42.130821,
-90.131836,
42.455887,
-90.615234,
42.553082,
-87.890625,
41.70573,
-87.451172,
39.130058,
-87.670898,
38.719807,
-87.495117,
38.065392,
-88.022461,
37.09024,
-88.505859,
37.0201,
-89.208984,
],
"IN": [
39.164143,
-84.814453,
41.738529,
-84.858398,
41.804077,
-86.572266,
41.541477,
-87.583008,
39.232254,
-87.714844,
38.719807,
-87.495117,
37.961521,
-88.198242,
37.857506,
-87.011719,
38.238178,
-85.957031,
39.164143,
-84.814453,
],
"IA": [
43.484814,
-96.416016,
42.455887,
-96.416016,
40.613953,
-95.537109,
40.613953,
-91.40625,
41.211723,
-90.966797,
41.57436,
-91.098633,
41.804077,
-90.175781,
42.195969,
-90.219727,
42.747013,
-91.010742,
43.516689,
-91.318359,
43.484814,
-96.416016,
],
"KS": [
40.010788,
-102.041016,
40.010788,
-94.921875,
39.402245,
-95.009766,
38.82259,
-94.526367,
36.985004,
-94.746094,
37.09024,
-102.084961,
40.010788,
-102.041016,
],
"KY": [
37.544579,
-82.045898,
38.134556,
-82.661133,
38.616871,
-82.661133,
38.719807,
-83.452148,
38.82259,
-84.418945,
39.164143,
-84.902344,
38.134556,
-85.869141,
37.857506,
-87.1875,
37.857506,
-88.198242,
37.055176,
-88.505859,
37.09024,
-89.165039,
36.527294,
-89.033203,
36.527294,
-83.803711,
37.544579,
-82.045898,
],
"LA": [
33.13755,
-93.867188,
33.284618,
-91.230469,
32.101189,
-90.878906,
30.751278,
-91.757812,
31.128199,
-89.648438,
29.152161,
-89.033203,
29.382175,
-91.757812,
29.993002,
-93.779297,
33.13755,
-93.867188,
],
"ME": [
44.855869,
-66.862793,
45.213005,
-67.214355,
45.166546,
-67.456055,
45.598667,
-67.5,
45.752193,
-67.851562,
47.129951,
-67.807617,
47.457809,
-68.334961,
47.204643,
-68.90625,
47.457809,
-69.191895,
46.739861,
-70.026855,
46.422714,
-70.158691,
46.149395,
-70.334473,
45.58329,
-70.686035,
45.259422,
-71.081543,
42.988575,
-70.839844,
44.119141,
-69.016113,
44.386692,
-68.115234,
44.855869,
-66.862793,
],
"MD": [
38.479397,
-75.146484,
38.548164,
-75.761719,
39.67337,
-75.849609,
39.774769,
-77.958984,
39.478607,
-78.299561,
39.172661,
-77.88208,
39.334297,
-77.67334,
38.82259,
-76.948242,
38.341656,
-77.387695,
37.892197,
-76.113281,
36.809284,
-76.113281,
38.479397,
-75.146484,
],
"MA": [
42.795403,
-73.344727,
42.730873,
-72.575684,
42.674358,
-71.257324,
42.827641,
-71.05957,
43.020714,
-70.883789,
42.64204,
-70.675049,
42.358543,
-71.015625,
42.261047,
-70.784912,
41.934978,
-70.543213,
41.828644,
-69.938965,
41.672913,
-69.960938,
41.401535,
-70.268555,
41.335575,
-70.751953,
41.590797,
-71.015625,
42.049294,
-71.499023,
42.057449,
-73.432617,
42.795403,
-73.344727,
],
"MI": [
41.804077,
-86.660156,
42.455887,
-86.176758,
43.675819,
-86.484375,
44.84029,
-86.132812,
45.8288,
-85.03418,
45.182037,
-83.320312,
44.370987,
-83.452148,
43.92955,
-83.891602,
44.150681,
-82.96875,
42.908161,
-82.265625,
42.326061,
-83.276367,
41.934978,
-83.276367,
41.738529,
-83.979492,
41.804077,
-86.660156,
],
"MN": [
43.452919,
-96.416016,
43.516689,
-91.318359,
43.961189,
-91.230469,
44.902576,
-92.900391,
45.644768,
-92.900391,
46.437859,
-92.109375,
47.931065,
-92.373047,
49.037868,
-95.185547,
49.037868,
-97.294922,
47.04018,
-96.328125,
43.452919,
-96.416016,
],
"MS": [
34.92197,
-88.110352,
30.334953,
-88.461914,
30.221102,
-89.516602,
31.203405,
-89.736328,
31.01528,
-91.538086,
31.690783,
-91.538086,
32.212803,
-91.010742,
33.760883,
-91.186523,
34.957996,
-90.175781,
34.92197,
-88.110352,
],
"MO": [
40.613953,
-91.450195,
39.808537,
-91.494141,
38.719807,
-90.219727,
36.633163,
-89.033203,
36.03133,
-89.736328,
35.924644,
-90.483398,
36.703659,
-90.131836,
36.597889,
-94.790039,
39.027718,
-94.482422,
39.436192,
-94.921875,
39.977119,
-94.833984,
40.111691,
-95.405273,
40.647305,
-95.493164,
40.613953,
-91.450195,
],
"MT": [
48.980217,
-104.0625,
45.089035,
-104.0625,
45.151054,
-111.181641,
44.527843,
-111.09375,
44.402393,
-113.027344,
45.58329,
-114.082031,
45.3367,
-114.873047,
46.739861,
-114.433594,
47.219566,
-116.103516,
49.037868,
-116.015625,
48.980217,
-104.0625,
],
"NE": [
43.06889,
-104.106445,
43.036777,
-98.4375,
42.553082,
-96.416016,
39.943436,
-95.273438,
40.178871,
-102.172852,
40.979897,
-102.084961,
41.013065,
-104.150391,
43.06889,
-104.106445,
],
"NV": [
34.307144,
-114.433594,
35.960224,
-114.697266,
36.315125,
-111.972656,
37.0201,
-111.09375,
37.09024,
-113.994141,
41.902279,
-114.169922,
41.967659,
-119.794922,
39.027718,
-119.794922,
34.307144,
-114.433594,
],
"NH": [
42.940338,
-70.817871,
43.35714,
-70.905762,
45.274887,
-71.191406,
45.274887,
-71.411133,
44.731125,
-71.674805,
44.418087,
-71.652832,
44.245197,
-72.092285,
43.50872,
-72.421875,
42.755081,
-72.608643,
42.650124,
-71.323242,
42.940338,
-70.817871,
],
"NJ": [
40.513798,
-74.311523,
41.062786,
-73.959961,
41.376808,
-74.772949,
40.613953,
-75.234375,
40.19566,
-74.816895,
39.825413,
-75.498047,
39.487083,
-75.541992,
38.993572,
-74.86084,
39.520992,
-74.311523,
40.245991,
-73.959961,
40.513798,
-74.311523,
],
"NM": [
31.353638,
-108.94043,
31.353638,
-108.105469,
31.840233,
-108.149414,
31.989443,
-106.567383,
32.212803,
-102.919922,
36.985004,
-103.007812,
37.0201,
-109.116211,
31.353638,
-108.94043,
],
"NY": [
44.980343,
-73.322754,
45.058002,
-74.772949,
44.182205,
-76.333008,
43.500751,
-76.223145,
43.229195,
-77.453613,
43.389084,
-78.046875,
43.261208,
-79.189453,
42.811523,
-78.815918,
42.163403,
-79.760742,
41.951321,
-79.541016,
42.081917,
-75.344238,
41.376808,
-74.816895,
41.062786,
-73.937988,
40.497093,
-74.289551,
40.563896,
-73.575439,
40.996483,
-71.784668,
41.178654,
-72.290039,
41.004776,
-72.674561,
40.85537,
-73.718262,
40.996483,
-73.652344,
42.666283,
-73.322754,
43.644028,
-73.300781,
44.087585,
-73.45459,
44.980343,
-73.322754,
],
"NC": [
36.633163,
-75.893555,
36.562599,
-81.606445,
36.102375,
-82.265625,
35.532227,
-83.496094,
35.101933,
-84.375,
34.994003,
-83.100586,
35.317368,
-82.397461,
34.849876,
-79.49707,
33.760883,
-78.530273,
34.849876,
-76.948242,
35.532227,
-75.805664,
36.633163,
-75.893555,
],
"ND": [
48.922501,
-97.207031,
45.8288,
-96.591797,
46.012222,
-104.150391,
49.095451,
-104.0625,
48.922501,
-97.207031,
],
"OH": [
38.376114,
-82.661133,
38.582527,
-82.22168,
39.00211,
-82.056885,
39.740986,
-80.859375,
40.363289,
-80.595703,
42.098221,
-80.507812,
41.475658,
-82.30957,
41.804077,
-83.891602,
41.70573,
-85.03418,
39.027718,
-84.726562,
38.376114,
-82.661133,
],
"OK": [
33.651207,
-94.526367,
35.532227,
-94.482422,
36.914764,
-94.790039,
37.055176,
-102.919922,
36.244274,
-102.963867,
36.491974,
-100.063477,
34.488449,
-100.107422,
33.687782,
-96.635742,
33.651207,
-94.526367,
],
"OR": [
42.032974,
-124.277344,
42.098221,
-116.982422,
46.073231,
-116.982422,
45.706181,
-123.837891,
42.032974,
-124.277344,
],
"PA": [
42.326061,
-79.936523,
41.967659,
-79.628906,
42.130821,
-75.366211,
41.409775,
-74.750977,
40.580585,
-75.234375,
40.111691,
-74.750977,
39.67337,
-75.893555,
39.757881,
-80.562744,
42.000324,
-80.507812,
42.326061,
-79.936523,
],
"RI": [
41.327328,
-71.817627,
41.450962,
-71.05957,
41.70573,
-71.147461,
42.041134,
-71.466064,
42.016651,
-71.806641,
41.664703,
-71.784668,
41.327328,
-71.817627,
],
"SC": [
33.870415,
-78.574219,
34.813805,
-79.672852,
35.029995,
-81.035156,
35.281502,
-82.529297,
34.885929,
-83.276367,
32.249973,
-80.81543,
33.027088,
-79.40918,
33.468109,
-79.057617,
33.870415,
-78.574219,
],
"SD": [
43.06889,
-103.974609,
42.940338,
-98.4375,
42.553082,
-96.328125,
45.951149,
-96.503906,
46.073231,
-104.0625,
43.06889,
-103.974609,
],
"TN": [
36.527294,
-89.121094,
36.527294,
-81.738281,
34.957996,
-84.550781,
35.101933,
-90.439453,
36.527294,
-89.121094,
],
"TX": [
36.315125,
-103.007812,
36.456635,
-100.107422,
34.524662,
-100.019531,
33.724339,
-96.855469,
33.797409,
-95.537109,
33.504761,
-93.955078,
30.751278,
-93.691406,
30.600094,
-92.988281,
28.459032,
-96.943359,
26.902477,
-97.734375,
25.641525,
-97.119141,
26.588528,
-99.404297,
27.994402,
-99.755859,
29.764378,
-101.425781,
29.764378,
-102.744141,
28.767658,
-103.095703,
29.61167,
-104.501953,
30.524412,
-105.117188,
32.026707,
-106.611328,
32.175613,
-102.919922,
36.315125,
-103.007812,
],
"UT": [
41.967659,
-114.038086,
37.125286,
-114.082031,
37.09024,
-109.072266,
41.013065,
-109.116211,
41.046219,
-111.225586,
42.032974,
-111.09375,
41.967659,
-114.038086,
],
"VT": [
42.763145,
-72.641602,
42.795403,
-73.366699,
43.659924,
-73.344727,
44.182205,
-73.520508,
45.026951,
-73.366699,
45.026951,
-71.433105,
44.699898,
-71.652832,
44.433781,
-71.652832,
44.276672,
-71.960449,
43.628124,
-72.399902,
42.763145,
-72.641602,
],
"VA": [
36.562599,
-83.891602,
37.47485,
-82.045891,
37.361427,
-81.760254,
37.30027,
-81.430656,
37.47485,
-80.288078,
38.591114,
-79.639893,
38.419167,
-79.420166,
38.634037,
-79.189453,
38.82259,
-79.024658,
38.779781,
-78.815918,
39.436192,
-78.299561,
39.121536,
-77.871094,
39.3088,
-77.684326,
38.754082,
-76.948242,
38.341648,
-77.387688,
37.892189,
-76.113281,
37.622932,
-76.376953,
37.361427,
-76.289062,
37.265308,
-76.508781,
36.976227,
-76.223145,
37.011326,
-75.827637,
36.650791,
-75.959473,
36.562599,
-83.891602,
],
"WA": [
48.400032,
-124.628906,
45.8288,
-123.925781,
46.134171,
-117.158203,
48.980217,
-117.158203,
48.922501,
-123.046875,
48.224674,
-123.134766,
48.400032,
-124.628906,
],
"WV": [
39.842285,
-80.771484,
39.732536,
-80.507812,
39.707188,
-79.508057,
39.698734,
-78.244629,
38.81403,
-78.804932,
38.82259,
-79.024658,
38.444984,
-79.398193,
38.599701,
-79.683838,
37.474857,
-80.244141,
37.309013,
-81.474609,
37.483578,
-82.045898,
38.125916,
-82.650146,
38.350273,
-82.628174,
38.444984,
-82.287598,
38.993572,
-82.056885,
39.842285,
-80.771484,
],
"WI": [
46.830135,
-92.06543,
46.649437,
-90.351562,
45.859413,
-87.93457,
45.182037,
-87.583008,
45.429298,
-86.923828,
44.245197,
-87.670898,
42.585445,
-87.978516,
42.423458,
-90.65918,
42.811523,
-91.098633,
43.961189,
-91.318359,
44.80912,
-92.8125,
45.675484,
-92.900391,
46.377254,
-92.15332,
46.830135,
-92.06543,
],
"WY": [
41.145569,
-111.181641,
40.979897,
-103.974609,
45.058002,
-104.194336,
45.151054,
-111.09375,
41.145569,
-111.181641,
],
};