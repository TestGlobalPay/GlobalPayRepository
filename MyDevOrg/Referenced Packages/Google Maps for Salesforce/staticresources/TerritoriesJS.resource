///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/

var map;
var streetView = new StreetView();
var trafficLayer = null;
var transitLayer = null;
var weatherLayer = null;
var cloudLayer = null;
var trip = new Trip();
var geocoding = new Geocoding();
var territories = new Territories();
var iconMaker = new IconMaker();
var viewListing = new ViewListing();
var addMapMarker = new AddMapMarker();

/////////////////////////////////////////////////////////////////////////////////////
// ViewData
/////////////////////////////////////////////////////////////////////////////////////
function ViewData(id, name, type, viewObject, color, mapIcon)
{
	this.id = id;
	this.name = name;
	this.type = type;
	this.viewObject = viewObject;
	this.color = color;
	this.mapIcon = mapIcon;
}

/////////////////////////////////////////////////////////////////////////////////////
// StandardObject
/////////////////////////////////////////////////////////////////////////////////////
function StandardObject()
{
	this.view = null;
	
	this.id = "";
	this.name = "";
	this.color = "";
	this.mapIcon = "";
	
	this.displayFieldValues = [];

	this.relatedObjectId = "";
	this.relatedObjectName = "";
	
	this.formatDisplayFieldValue = function(displayFieldType, displayFieldValue)
	{
		var formatted = "";
		
		if (displayFieldType == "Date")
		{
			var year = Number(displayFieldValue.substr(0, 4));
			var month = Number(displayFieldValue.substr(5, 2)) - 1;
			var day = Number(displayFieldValue.substr(8, 2));

			var date = new Date(year, month, day);
			formatted += util.getLocalizedDateString(date);
		}
		else if (displayFieldType == "DateTime")
		{
			var year = Number(displayFieldValue.substr(0, 4));
			var month = Number(displayFieldValue.substr(5, 2)) - 1;
			var day = Number(displayFieldValue.substr(8, 2));
			
			var timeParts = displayFieldValue.substr(displayFieldValue.indexOf("T") + 1).split(":");
			var hours = timeParts[0];
			var minutes = timeParts[1];

			var date = new Date(year, month, day, hours, minutes);
			formatted += util.getLocalizedDateTimeString(date);
		}
		else if (displayFieldType == "Currency")
		{
//			formatted += util.formatNumber(displayFieldValue, 2);
			formatted += util.formatNumber((new Number(displayFieldValue)).toFixed(), 2);
		}
		else if (displayFieldType == "Percent")
		{
			formatted += displayFieldValue + "%";
		}
//		else if (displayFieldType == "Number")
//		{
//			formatted += util.formatNumber(displayFieldValue, 0);
//		}
		else if (displayFieldType == "Checkbox")
		{
			formatted += displayFieldValue == "true" ? "Yes" : "No";
		}
		else
		{								
			formatted += displayFieldValue;
		}
		
		return util.replaceDoubleQuotesWithSingleQuotes(formatted);
	};

	this.displayFieldsExist = function()
	{
		var valuesExist = false;		
		for (var i = 0; i < this.displayFieldValues.length; i++)
		{
			if (this.displayFieldValues[i] != null && this.displayFieldValues[i].length > 0)
			{
				return true;
			}
		}	
		
		return false;
	};

	this.getDisplayFieldsHtml = function()
	{
		if (!this.displayFieldsExist())
		{
			return "";
		}

		var html = 
			"<div style='white-space:normal;max-width:400px'><table cellspacing='0px' cellpadding='0px'>";
		
		for (var i = 0; i < this.displayFieldValues.length; i++)
		{
			if (this.displayFieldValues[i] != null && this.displayFieldValues[i].length > 0)
			{
				html += "<tr><td><div style='padding-right:10px;color:#555555'>";
				html += "&#8226;&nbsp;";						
				html += "<b>" + this.view.displayFieldLabels[i] + ":</b>&nbsp;";
				html += this.formatDisplayFieldValue(this.view.displayFieldTypes[i],
					this.displayFieldValues[i]);
				html += "</div></td></tr>"
			}
		}
			
		html +=			
			"</table></div>";

		return html;
	};
	
	this.getRawDisplayFieldsData = function()
	{
		if (!this.displayFieldsExist())
		{
			return "0";
		}

		var data = ""; 
		
		for (var i = 0; i < this.displayFieldValues.length; i++)
		{
			if (this.displayFieldValues[i] != null && this.displayFieldValues[i].length > 0)
			{
				if (data.length > 0)
				{
					data += separator.brokenBar;
				}
				
				data += this.view.displayFieldLabels[i] + separator.section;
				data += this.formatDisplayFieldValue(this.view.displayFieldTypes[i],
					this.displayFieldValues[i]);
			}
		}
		
		return data;
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// MapObject
/////////////////////////////////////////////////////////////////////////////////////
MapObject.prototype = new StandardObject();
function MapObject()
{
	this.address = null;
	this.type = "";

	this.marker = null;
	this.tripMarker = null;
	
	this.tripMarkerVisible = false;
	
	this.multiObject = false;
	this.draggable = false;

	this.listVisibleLineCount = 7;

	this.showMarker = function()
	{
		if (this.tripMarkerVisible)
		{
			this.hideTripMarker();
		}
	
//		map.addOverlay(this.marker);
		this.marker.setMap(map);
	};
	
	this.hideMarker = function()
	{
//		map.removeOverlay(this.marker);
		this.marker.setMap(null);
	};
	
	this.showTripMarker = function(waypointIndex)
	{
//		if (this.tripMarkerVisible)
//		{
//			return;
//		}

		if (this.tripMarker == null)
		{
			this.createTripMarker(this);
		}

//		map.removeOverlay(this.marker);
//		map.addOverlay(this.tripMarker);

		this.marker.setMap(null);

		this.tripMarker.setIcon(iconMaker.getTripIcon(waypointIndex));
		this.tripMarker.setMap(map);	
		
		this.tripMarkerVisible = true;
	};
	
	this.hideTripMarker = function()
	{
		if (!this.tripMarkerVisible)
		{
			return;
		}
		
//		map.removeOverlay(this.tripMarker);
		this.tripMarker.setMap(null);
		
		this.tripMarkerVisible = false;
	};
	
	this.getAccountBackgroundColor = function()
	{
		return "aliceblue";
	};
	
	this.getLeadBackgroundColor = function()
	{
		return "mistyrose";
	};
	
	this.getOpportunityBackgroundColor = function()
	{
		return "cornsilk";
	};
	
	this.getContactBackgroundColor = function()
	{
		return "lavender";
	};

	this.getUserBackgroundColor = function()
	{
		return "whitesmoke";
	};

	this.getAssetBackgroundColor = function()
	{
		return "#d7e5ea";
	};


	this.getCaseBackgroundColor = function()
	{
		return "#e4e1cf";
	};
	
	this.getContractBackgroundColor = function()
	{
		return "#d8dfd6";
	};
	
	this.getCustomObjectBackgroundColor = function()
	{
		return "#eeeeee";
	};
	
	this.getStandardObjectBackgroundColor = function()
	{
		return "#eeeeee";
	};
	
	this.getTaskBackgroundColor = function()
	{
		return "#e6eff2";
	};
	
	this.getEventBackgroundColor = function()
	{
		return "#e6eff2";
	};
	
	this.getHtml = function()
	{
		
	};
	
	this.fetchRelatedObjects = function()
	{
	
	};


	this.createMarkerShape = function(width, height)
	{
  		var coords = [
    		width / 2, height,
    		(7 / 16) * width, (5 / 8) * height,
    		(5 / 16) * width, (7 / 16) * height,
    		(7 / 32) * width, (5 / 16) * height,
    		(5 / 16) * width, (1 / 8) * height,
    		(1 / 2) * width, 0,
    		(11 / 16) * width, (1 / 8) * height,
    		(25 / 32) * width, (5 / 16) * height,
    		(11 / 16) * width, (7 / 16) * height,
    		(9 / 16) * width, (5 / 8) * height
  		];
  		
 		for (var i = 0; i < coords.length; i++) 
 		{
    		coords[i] = parseInt(coords[i]);
  		}
	
		return {type: "poly", coords: coords};
	};
	
	this.createMarker = function(mapObject)
	{
		if (util.isDefined(this.isDuplicateLocation) && this.isDuplicateLocation)
		{
			return;
		}
		
		var markerOptions = {};
		markerOptions.anchorPoint = new google.maps.Point(0, -markerSize /2);//(markerSize / 2, markerSize);
		markerOptions.cursor = "pointer";
		markerOptions.draggable = mapObject.draggable;
		markerOptions.icon = iconMaker.getIcon(this.color, this.mapIcon);
		markerOptions.position = this.address.coordinates;
		markerOptions.title = mapObject.name;
		markerOptions.shape = this.createMarkerShape(markerSize, markerSize);
		
		this.marker = new google.maps.Marker(markerOptions);

		if (mapObject.draggable)
		{
			var marker = this.marker;
		
			google.maps.event.addListener(this.marker, "dragend", 
				function(latLng)
				{
					InfoWindow.close();
					
					var latLng = marker.getPosition();
					
					mapObject.address.coordinates = latLng;
					mapObject.address.geocodeAddress = 
						String(latLng.lat()) + ", " + String(latLng.lng()); 
					updateDraggableCustomLocationCoordinates(mapObject.id,
						latLng.lat(), latLng.lng());
				}
			);
		}

		var _this = this;
		google.maps.event.addListener(this.marker, "click", 
			function()
			{
				territories.selectedObject = mapObject;
				mapObject.fetchRelatedObjects();
				var mapObjectHtml = mapObject.getHtml();

				//var infoWindowOptions = {};
				//infoWindowOptions.maxContent = streetView.getContentDiv();
				//infoWindowOptions.maxTitle = mapObject.name;
				
				InfoWindow.setContent(mapObjectHtml);
				InfoWindow.open(map, _this.marker);

				saveLastSelectedObject(territories.selectedObject.id);
				
				//mapObject.marker.openInfoWindowHtml(mapObjectHtml, infoWindowOptions);
			}
		);
	};

	
	this.createTripMarker = function(mapObject)
	{
		var markerOptions = {};
		markerOptions.anchorPoint = new google.maps.Point(0, -17);
		markerOptions.cursor = "pointer";
		markerOptions.position = this.address.coordinates;
		markerOptions.title = mapObject.name;
		markerOptions.shape = this.createMarkerShape(20, 34);
		
		this.tripMarker = new google.maps.Marker(markerOptions);
	
		var _this = this;
		google.maps.event.addListener(this.tripMarker, "click", 
			function()
			{
				territories.selectedObject = mapObject;
				mapObject.fetchRelatedObjects();
				var mapObjectHtml = mapObject.getHtml();
				
				InfoWindow.setContent(mapObjectHtml);
				InfoWindow.open(map, _this.tripMarker);

				saveLastSelectedObject(territories.selectedObject.id);
			}
		);
		
	};
	
	this.getShowScrollBarOnList = function(standardObjects)
	{
		if (standardObjects.length > this.listVisibleLineCount)
		{
			return true;
		}
		
		var lineCount = 0;
		for (var i = 0; i < standardObjects.length; i++)
		{
			var nonBlankDisplayValues = 0;
			for (var j = 0; j < standardObjects[i].displayFieldValues.length; j++)
			{
				if (standardObjects[i].displayFieldValues[j] != null &&
					standardObjects[i].displayFieldValues[j].length > 0)
				{
					++nonBlankDisplayValues;
				}
			}

			lineCount += nonBlankDisplayValues + 1;

			if (lineCount > this.listVisibleLineCount)
			{
				return true;
			}
		}	
		
		return false;	
	};
	
	this.getSeparatorBarHtml = function()
	{
		if (browserInfo.isMSIE() && browserInfo.version() < 8)
		{
			return "<br/>";
		}
		else
		{				
			return "<hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/>";
		}
	};
	
	this.getButtonBarSeparatorHtml = function()
	{
		if (browserInfo.isMSIE() && browserInfo.version() < 8)
		{
			return "<br/>";
		}
		else
		{
			return "<hr style='height:1px;color:sienna;background-color:sienna'/>";
		}
	};
	
	this.getMapObjectHtml = function(mapObject, backgroundColor, iconImage, childObjectArray, buttonBar, additionalHtml)
	{
		var popupMainObjectTitle = this.view.getParentRelationshipLabel();
		popupMainObjectTitle = popupMainObjectTitle == null ? (mapObject.type == "Custom Object" ? this.view.customObjectLabel : mapObject.type) : popupMainObjectTitle;
		
		if (mapObject.type == "User")
		{
			popupMainObjectTitle = mapObject.type;
		}
		
		var html = "";

		html += "<div style='background:" + backgroundColor + "'>";
		html += "<table cellspacing='0' cellpadding='0' border='0' style='padding: 7px 0px'>";
		html += "<tr><td width='23px'>";
		html += "<div style='padding: 5px 0px 0px 7px'><img src='" + territoriesImagePath + iconImage + "' width='16px'/></div>";
		html += "</td><td><div style='padding:5px 10px 5px 7px;'>";
		html += "<span style='font-weight:bold'>" + popupMainObjectTitle + "</span><br/>";
		html += "<a href=\'/" + mapObject.id + "\'>" + util.escapeString(mapObject.name) + "</a><br/>";
		html += mapObject.address.getAddressHtml();
		html += additionalHtml ? ("<br />" + additionalHtml) : "";
		html += "</div></td></tr></table></div>";
			
			
		var displayFieldsHtml = mapObject.getDisplayFieldsHtml();

		if (displayFieldsHtml.length > 0)
		{
			html += "<div style='margin-top:6px; margin-left:29px'>";
			html += displayFieldsHtml;
			html += "</div>";
		}

		if (util.isDefined(childObjectArray) && childObjectArray !== null)
		{
			for (var i = 0; i < childObjectArray.length; i++)
			{
				if (childObjectArray[i].childObjects.length > 0)
				{
					html += this.getMapObjectsHtml(childObjectArray[i]);
				}
			}
		}

		if (!util.isDefined(buttonBar) || buttonBar)
		{
			html += this.getButtonBarHtml();
		}

		return html;
	};

	this.getButtonBarHtml = function()
	{
		var html = "";
		html += this.getButtonBarSeparatorHtml();
		html += "<div><table cellspacing='0' cellpadding='0' border='0'><tr><td>";
		html += trip.getButtonBarHtml(this);
		html += "</td></tr></table></div>";
		return html;
	};

	this.getMapObjectsHtml = function(mapObjectsData)
	{
		var lineHeight = 15;

		var html = "";
		
		html += this.getSeparatorBarHtml();
	
		html += "<div style='background:" + mapObjectsData.childObjectsBackgroundColor + "'>";

		if (browserInfo.isMSIE() && browserInfo.version() < 8)
		{
			html += "<table width='280px' cellspacing='0' cellpadding='0' border='0'>";
		}
		else
		{
			html += "<table width='100%' cellspacing='0' cellpadding='0' border='0'>";
		}
	
		html += "<tr><td width='23px' valign='top'>";		
		html += "<div style='padding: 5px 0px 0px 7px'><img src='" + territoriesImagePath + mapObjectsData.childObjectsIcon + "' width='16px'/></div>"
		html += "</td><td><div style='padding:5px 10px 10px 7px; white-space:nowrap'><b>" + mapObjectsData.title + "</b><br/>";

		if (this.getShowScrollBarOnList(mapObjectsData.childObjects)) 
		{
			html += "<div style='height:" + (lineHeight * this.listVisibleLineCount + "") + "px; padding-right:" +
				(browserInfo.isMSIE() ? "25" : "10") + "px; overflow-y: scroll; overflow-x:hidden'>";
		}
		else
		{
			html += "<div>";
		}

		html += "<table cellspacing='0' cellpadding='0' border='0'>";
		for (var i = 0; i < mapObjectsData.childObjects.length; i++)
		{
			html += "<tr>";
			if (this.multiObject || ((util.isDefined(this.duplicateLocations) && this.duplicateLocations.length > 0) ||
				(util.isDefined(this.isDuplicateLocation) &&  this.isDuplicateLocation)))
			{
		   		html += "<td style='padding-right:4px;'><div style='height:4px'></div><div style='display:inline-block; width:12px; height: 8px; background-color:" + mapObjectsData.childObjects[i].color + "'></div></td>";
			}
			
			html += "<td><div style='white-space:nowrap;'>";
			html += "<a style='color:black' href=\'/" + mapObjectsData.childObjects[i].id + "\'>" + util.escapeString(mapObjectsData.childObjects[i].name) + "</a></div>";



			if(mapObjectsData.relatedObjectFields)
			{
				html += "<div style='font-size: 85%; min-height: 7px; padding-bottom: 7px;'>";
				for (var j = 0; j < mapObjectsData.relatedObjectFields.length; j++)
				{
					var relatedObjectFieldName = mapObjectsData.relatedObjectFields[j];
					var relatedObjectFieldValue = mapObjectsData.childObjects[i][relatedObjectFieldName];
					
					if (relatedObjectFieldValue == null)
					{
						continue;
					}
					
					if (j > 0) html += "; ";
					
					html += (relatedObjectFieldName + ": ");
					html += ("<b>" + relatedObjectFieldValue + "</b>");
				}
				html += "</div>";
			}




			html += "<div style='margin-left:3px'>";
			html += mapObjectsData.childObjects[i].getDisplayFieldsHtml();
			html += "</div>";
				
			html += "</td></tr>";
			
		}
		html += "</table></div>";
		
		html += "</div></td></tr></table></div>";	
		
		return html;		
	};

	this.getRawMapObjectsData = function(mapObjects, escape)
	{
		var data = "";
		
		for (var i = 0; i < mapObjects.length; i++)
		{
			if (i > 0)
			{
				data += separator.notSign;
			}
			
			data += mapObjects[i].id + separator.macron;
			if (escape)
			{
				data += util.escapeString(mapObjects[i].name);
			}
			else
			{
				data += util.replaceDoubleQuotesWithSingleQuotes(mapObjects[i].name);
			}
			data += separator.macron;
			data += mapObjects[i].getRawDisplayFieldsData(); 
		}
		
		return data;		
	};
	
	this.getRawChildObjectsData = function(escape)
	{
		if (this.view.isAccountBasedView())
		{
			return "0";
		}
		
		var childObjectsData = this.getChildObjectsData();
		
		if (childObjectsData.length == 0)
		{
			return "0";
		}
		
		var data = "";
		
		for (var i = 0; i < childObjectsData.length; i++)
		{		
			if (data.length > 0)
			{
				data += separator.plusMinus;
			}
			
			data += childObjectsData[i].childObjectsBackgroundColor + separator.middleDot;
			data += childObjectsData[i].title + separator.middleDot;
			data += childObjectsData[i].childObjectsIcon + separator.middleDot;
			data += (this.getShowScrollBarOnList(childObjectsData[i].childObjects) ? "1" : "0") + separator.middleDot;
			data += this.getRawMapObjectsData(childObjectsData[i].childObjects, escape);
		}
		
		return data;
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// User
/////////////////////////////////////////////////////////////////////////////////////
User.prototype = new MapObject();
function User()
{
	this.isViewOwner = false;
	
	this.type = "User";

	this.getBackgroundColor = function()
	{
		return this.getUserBackgroundColor();
	};

	this.getHtml = function()
	{
		return this.getMapObjectHtml(this, this.getUserBackgroundColor(), "icon_user.png");
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// Account
/////////////////////////////////////////////////////////////////////////////////////
Account.prototype = new MapObject();
function Account()
{
	this.opportunities = [];
	this.contacts = [];
	this.contracts = [];
	this.assets = [];
	this.cases = [];
	this.customObjects = [];
	this.standardObjects = [];
	this.events = [];
	this.tasks = [];
	
	this.isDuplicateLocation = false;
	this.duplicateLocations = [];
	this.duplicateMaster = null;

	this.relatedObjectsFetched = false;

	this.type = locale.account;

	this.getBackgroundColor = function()
	{
		return this.getAccountBackgroundColor();
	};

	this.getHtml = function()
	{
		var account = this.isDuplicateLocation ? this.duplicateMaster : this;
		
		var backgroundColor = account.view.isAccountBasedView() ? account.getAccountBackgroundColor() : "transparent";
		var childObjectsData = account.getChildObjectsData();

//		return account.getMapObjectHtml(account, backgroundColor, "icon_account.png", childObjectsData);

//		var html = "<div style='max-height:250px; padding-right:" +
//			(browserInfo.isMSIE() ? "25" : "10") + "px; overflow-y: scroll; overflow-x:hidden'>";

		var html = "";
		
		html += account.getMapObjectHtml(account, backgroundColor, "icon_account.png", childObjectsData, false);
		
		for (var i = 0; i < account.duplicateLocations.length; i++)
		{
			html += account.getButtonBarSeparatorHtml();
			
			var duplicateObject = account.duplicateLocations[i];
			
			html += duplicateObject.getMapObjectHtml(duplicateObject, backgroundColor, "icon_account.png", 
				duplicateObject.getChildObjectsData(), false);
		}		

//html += "</div>";
		
		html += account.getButtonBarHtml();
		
		return html;
	};

	this.getChildObjectsData = function()
	{
		var isAccountBasedView = this.view.isAccountBasedView();
		var isCampaignView = this.view.isCampaignView();
		
		var childObjectsData = [];

		if (this.opportunities.length > 0)
		{
			childObjectsData.push({childObjects : this.opportunities, 
				childObjectsBackgroundColor : (isAccountBasedView ? "transparent" : this.getOpportunityBackgroundColor()), 
//				title : (isAccountBasedView ? "Open Opportunities" : this.opportunities[0].view.viewObjectPlural) +
				title : (isAccountBasedView ? locale.opportunities : this.opportunities[0].view.viewObjectPlural) +
				(isCampaignView ? " - Opportunities" : ""), childObjectsIcon : "icon_opp.png"});
		}

		if (this.contacts.length > 0)
		{
			childObjectsData.push({childObjects : this.contacts, 
				childObjectsBackgroundColor : (isAccountBasedView ? "transparent" : this.getContactBackgroundColor()), 
				title : (isAccountBasedView ? locale.contacts : this.contacts[0].view.viewObjectPlural) +
				(isCampaignView ? " - Contacts" : ""), childObjectsIcon : "icon_contact.png", 
				relatedObjectFields: (isAccountBasedView ? ["Phone", "Mobile"] : [])});
		}
		
		if (this.assets.length > 0)
		{
			childObjectsData.push({childObjects : this.assets, childObjectsBackgroundColor : this.getAssetBackgroundColor(), 
				title : this.assets[0].view.viewObjectPlural, childObjectsIcon : "icon_asset.png"});
		}

		if (this.cases.length > 0)
		{
			childObjectsData.push({childObjects : this.cases, childObjectsBackgroundColor : this.getCaseBackgroundColor(), 
				title : this.cases[0].view.viewObjectPlural, childObjectsIcon : "icon_case.png"});
		}
		
		if (this.contracts.length > 0)
		{
			childObjectsData.push({childObjects : this.contracts, childObjectsBackgroundColor : this.getContractBackgroundColor(), 
				title : this.contracts[0].view.viewObjectPlural, childObjectsIcon : "icon_contract.png"});
		}
		
		if (this.customObjects.length > 0)
		{
			childObjectsData.push({childObjects : this.customObjects, childObjectsBackgroundColor : this.getCustomObjectBackgroundColor(), 
				title : this.customObjects[0].view.viewObjectPlural, childObjectsIcon : "icon_custobj.png"});
		}
		
		if (this.standardObjects.length > 0)
		{
			childObjectsData.push({childObjects : this.standardObjects, childObjectsBackgroundColor : this.getStandardObjectBackgroundColor(), 
				title : this.standardObjects[0].view.viewObjectPlural, childObjectsIcon : "icon_custobj.png"});
		}
		
		if (this.tasks.length > 0)
		{
			childObjectsData.push({childObjects : this.tasks, childObjectsBackgroundColor : this.getTaskBackgroundColor(), 
				title : this.tasks[0].view.viewObjectPlural, childObjectsIcon : "icon_task_event.png"});
		}
		
		if (this.events.length > 0)
		{
			childObjectsData.push({childObjects : this.events, childObjectsBackgroundColor : this.getEventBackgroundColor(), 
				title : this.events[0].view.viewObjectPlural, childObjectsIcon : "icon_task_event.png"});
		}
		
		return childObjectsData;
	};

	this.fetchRelatedObjects = function()
	{
		if (territories.view.type == "Combination")
		{
			return;
		}
		
		if (!this.view.showOpenOpportunities && !this.view.showContacts)
		{
			return;
		}
		
		if (this.relatedObjectsFetched)
		{
			return;
		}
		
		util.showLoadingImage();
		
		if (this.view.showOpenOpportunities)
		{
			this.view.loadAccountOpenOpportunities(this);
		}
		
		if (this.view.showContacts)
		{
			this.view.loadAccountContacts(this);
		}
		
		util.hideLoadingImage();
		
		this.relatedObjectsFetched = true;
		
/*		
		if (!this.view.showAccountRelatedObjects)
		{
			return;
		}
		
		if (this.relatedObjectsFetched)
		{
			return;
		}
		
		util.showLoadingImage();
		this.view.loadAccountOpenOpportunities(this);
		this.view.loadAccountContacts(this);
		util.hideLoadingImage();
		
		this.relatedObjectsFetched = true;
*/		
	};
	
}

/////////////////////////////////////////////////////////////////////////////////////
// Lead
/////////////////////////////////////////////////////////////////////////////////////
Lead.prototype = new MapObject();
function Lead()
{
	this.company = "";
	
	this.customObjects = [];
	this.type = "Lead";
	
	this.isDuplicateLocation = false;
	this.duplicateLocations = [];
	this.duplicateMaster = null;
	
	this.getBackgroundColor = function()
	{
		return this.getLeadBackgroundColor();
	};
	
	this.getHtml = function()
	{
		var lead = this.isDuplicateLocation ? this.duplicateMaster : this;

		var backgroundColor = ((lead.view.isLeadBasedView() || lead.view.isCampaignView())? 
			lead.getLeadBackgroundColor() : "transparent");
		var childObjectsData = lead.getChildObjectsData();

//		return this.getMapObjectHtml(this, backgroundColor, "icon_lead.png", childObjectsData);


		var additionalHtml = "";
		if (this.company)
		{
			additionalHtml += "<div style='font-size:85%'><span style='font-weight:bold'>Company:&nbsp;</span>" + this.company + "</div>";
		}
		if (this.phone)
		{
			additionalHtml += "<div style='font-size:85%'><span style='font-weight:bold'>Phone:&nbsp;</span>" + this.phone + "</div>";
		}
		if (this.mobilePhone)
		{
			additionalHtml += "<div style='font-size:85%'><span style='font-weight:bold'>Mobile:&nbsp;</span>" + this.mobilePhone + "</div>";
		}
			


		var html = lead.getMapObjectHtml(lead, backgroundColor, "icon_lead.png", childObjectsData, false, additionalHtml);
		
		for (var i = 0; i < lead.duplicateLocations.length; i++)
		{
			html += lead.getButtonBarSeparatorHtml();
			
			var duplicateObject = lead.duplicateLocations[i];
		
			html += duplicateObject.getMapObjectHtml(duplicateObject, backgroundColor, "icon_lead.png", 
				duplicateObject.getChildObjectsData(), false);
		}		
		
		html += lead.getButtonBarHtml();
		
		return html;
	};

	this.getChildObjectsData = function()
	{
		var isLeadBasedView = this.view.isLeadBasedView();
		var isCampaignView = this.view.isCampaignView(); 

		var childObjectsData = [];
		
		if (this.customObjects.length > 0)
		{
			childObjectsData.push({childObjects : this.customObjects, childObjectsBackgroundColor : this.getCustomObjectBackgroundColor(), 
				title : this.customObjects[0].view.viewObjectPlural, childObjectsIcon : "icon_custobj.png"});
		}
		
		return childObjectsData;
	};	

}

/////////////////////////////////////////////////////////////////////////////////////
// Contact
/////////////////////////////////////////////////////////////////////////////////////
Contact.prototype = new MapObject();
function Contact()
{
	this.cases = [];
	this.customObjects = [];
	
	this.type = "Contact";
	
	this.isDuplicateLocation = false;
	this.duplicateLocations = [];
	this.duplicateMaster = null;
	
	this.getBackgroundColor = function()
	{
		return this.getContactBackgroundColor();
	};
	
	this.getHtml = function()
	{
		var contact = this.isDuplicateLocation ? this.duplicateMaster : this;
	
		var backgroundColor = ((contact.view.isContactBasedView() || contact.view.isCampaignView())? 
			contact.getContactBackgroundColor() : "transparent");
		var childObjectsData = contact.getChildObjectsData();

//		return this.getMapObjectHtml(this, backgroundColor, "icon_contact.png",	childObjectsData);


		var html = contact.getMapObjectHtml(contact, backgroundColor, "icon_contact.png", childObjectsData, false);
		
		for (var i = 0; i < contact.duplicateLocations.length; i++)
		{
			html += contact.getButtonBarSeparatorHtml();
			
			var duplicateObject = contact.duplicateLocations[i];
		
			html += duplicateObject.getMapObjectHtml(duplicateObject, backgroundColor, "icon_contact.png", 
				duplicateObject.getChildObjectsData(), false);
		}		
		
		html += contact.getButtonBarHtml();
		
		return html;

	};
	
	this.getChildObjectsData = function()
	{
		var isContactBasedView = this.view.isContactBasedView();
		var isCampaignView = this.view.isCampaignView(); 

		var childObjectsData = [];
		
		if (this.customObjects.length > 0)
		{
			childObjectsData.push({childObjects : this.customObjects, childObjectsBackgroundColor : this.getCustomObjectBackgroundColor(), 
				title : this.customObjects[0].view.viewObjectPlural, childObjectsIcon : "icon_custobj.png"});
		}
		
		if (this.cases.length > 0)
		{
			childObjectsData.push({childObjects : this.cases, childObjectsBackgroundColor : this.getCaseBackgroundColor(),
				title : this.cases[0].view.viewObjectPlural, childObjectsIcon : "icon_case.png"});
		}
		
		return childObjectsData;
	};	
}

/////////////////////////////////////////////////////////////////////////////////////
// CustomObject
/////////////////////////////////////////////////////////////////////////////////////
CustomObject.prototype = new MapObject();
function CustomObject()
{
	this.type = "Custom Object";

	this.isDuplicateLocation = false;
	this.duplicateLocations = [];
	this.duplicateMaster = null;

	this.getBackgroundColor = function()
	{
		return this.getCustomObjectBackgroundColor();
	};

	this.getHtml = function()
	{
		var customObject = this.isDuplicateLocation ? this.duplicateMaster : this;


//		return this.getMapObjectHtml(this, this.getCustomObjectBackgroundColor(), "icon_custobj.png");

		var backgroundColor = customObject.getCustomObjectBackgroundColor();
		
		var html = customObject.getMapObjectHtml(customObject, backgroundColor, "icon_custobj.png", null, false);
		
		for (var i = 0; i < customObject.duplicateLocations.length; i++)
		{
			html += customObject.getButtonBarSeparatorHtml();
			
			var duplicateObject = customObject.duplicateLocations[i];
		
			html += customObject.getMapObjectHtml(duplicateObject, backgroundColor, "icon_custobj.png", null, false);
		}		
		
		html += customObject.getButtonBarHtml();
		
		return html;
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// CustomLocation
/////////////////////////////////////////////////////////////////////////////////////
CustomLocation.prototype = new MapObject();
function CustomLocation()
{
	this.editMode = false;
	this.type = "Custom Location";
	this.info = "";

	this.getBackgroundColor = function()
	{
		return "transparent";
	};

	this.getHtml = function()
	{
		if (this.editMode)
		{
			return this.getEditHtml();
		}
		
		var html = "<table cellspacing='0px' cellpadding='0px'><tr><td>";
		
		 html += "<b>" + util.escapeString(this.name) + "</b><br/>";
		
		if (this.draggable)
		{
			html += "<div style='max-width:240px; max-height:75px;padding-right:" + (browserInfo.isMSIE() ? "25" : "10") + "px; overflow-y:hidden'>"
			html += "<table cellspacing='0px' cellpadding='0px'><tr><td width='205px'>" + this.info + "</td></tr></table>";
			html += "</div>";
		}
		else
		{
			//html += this.address.getAddressHtml();
			html += "<div style='max-width: 240px;'>" + this.address.geocodeAddress + "</div>";
		}
		
		
		html += "</td></tr></table>";

		if (this.draggable)
		{
			html += this.getSeparatorBarHtml();
			html += "<table cellspacing='0px' cellpadding='0px'><tr>"
			html += "<td><b>Lat:</b></td><td style='padding-left:5px'>" + this.address.coordinates.lat() + "</td></tr><tr>";
			html += "<td><b>Long:</b></td><td style='padding-left:5px'>" + this.address.coordinates.lng() + "</td></tr></table>";
		}
		
		html += this.getButtonBarSeparatorHtml();
		
		html += "<div><table><tr><td>";
			
		var buttonBarHtml = trip.getButtonBarHtml(this, true);
		
		if (this.draggable)
		{
			buttonBarHtml = buttonBarHtml.replace("[LINK_1]",
				'<a style="color:blue" href="javascript:territories.selectedObject.switchToEditMode();">' + locale.edit + '</a>');
			buttonBarHtml = buttonBarHtml.replace("[LINK_2]",
	 			'<a style="color:blue" href="javascript:InfoWindow.close();territories.view.removeCustomLocation(\'' + this.id + '\')">' + locale.remove + '</a>');
//	 			'<a style="color:blue" href="javascript:territories.closeInfoWindow();territories.view.removeCustomLocation(\'' + this.id + '\')">' + locale.remove + '</a>');
		}
		else
		{
			buttonBarHtml = buttonBarHtml.replace("[LINK_1]",
//		 		'<a style="color:blue" href="javascript:territories.closeInfoWindow();territories.view.removeCustomLocation(\'' + this.id + '\')">' + locale.remove + '</a>');
		 		'<a style="color:blue" href="javascript:InfoWindow.close();territories.view.removeCustomLocation(\'' + this.id + '\')">' + locale.remove + '</a>');
			buttonBarHtml = buttonBarHtml.replace("[LINK_2]", "");
		}
		
		html += buttonBarHtml;

		html += "</td></tr></table></div>";

		return html;
	};
	
	this.getEditHtml = function()
	{
		var textLimit = "255";
		var limitTextLengthJavascript = "if(this.value.length&gt;" + textLimit + ")this.value=this.value.substring(0," + textLimit + ");";
	
	 	var html = "<span style='margin-left:4px; font-weight:bold'>" + locale.title + "&nbsp;</span>";
	 	html += "<input id='input_CustomLocationName' type='text' size='23' maxlength='80' value='" + this.name + "'/><br/>";
	 	html += "<textarea onkeydown='" + limitTextLengthJavascript + "' id='textarea_CustomLocationInfo' ";
	 	html += browserInfo.isFirefox() ? "rows='4' " : "rows='5' ";
	 	html += "style='resize:none; width:" + (browserInfo.isMSIE() ? "203px" : "193px") + ";margin-left:4px'>" + util.replaceBr(this.info) + "</textarea><br/>";
	 	html += "<span style='margin-left:4px'><a style='color:blue' href='javascript:territories.view.saveCustomLocationInfo(territories.selectedObject);'>" + locale.save + "</a></span>";
	 	html += "<span style='margin-left:7px'><a style='color:blue' href='javascript:territories.view.cancelCustomLocationInfo(territories.selectedObject);'>" + locale.cancel + "</a></span>";
	 	
	 	
	 	return html;
	};
	
	this.switchToEditMode = function()
	{
		this.editMode = true;
//		this.marker.closeInfoWindow();
		InfoWindow.close();

		InfoWindow.open(null, this.marker);
		InfoWindow.setContent(this.getEditHtml());
		//this.marker.openInfoWindowHtml(this.getEditHtml());
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// Address
/////////////////////////////////////////////////////////////////////////////////////

function Address()
{	  
	this.getAddressHtml = function()
	{
		var addressHtml = '';
		
		if (this.street != null && this.street.length > 0)
		{
			addressHtml += (util.escapeString(this.street) + "<br/>");
		}
		if (this.city != null && this.city.length > 0)
		{
			addressHtml += (util.escapeString(this.city) + ", ");
		}
		if (this.state != null && this.state.length > 0)
		{
			addressHtml += (util.escapeString(this.state) + " ");
			
			if (this.postalCode == null || this.postalCode.length == 0)
			{
				addressHtml += "<br/>";
			}
		}
		if (this.postalCode != null && this.postalCode.length > 0)
		{
			addressHtml += (util.escapeString(this.postalCode) + "<br/>");
		}
		if (this.country != null && this.country.length > 0)
		{
			addressHtml += (util.escapeString(this.country) + "<br/>");
		}
		
		return addressHtml;
	},
	
	this.getAddressString = function()
	{
		var addressString = "";

		if (this.street == null)
		{
			return addressString;
		}
		
		if (this.street != null)
		{
			addressString += (util.stripCrlf(util.replaceDoubleQuotesWithSingleQuotes(this.street)) + ", ");
		}
		if (this.city != null)
		{
			addressString += (util.stripCrlf(util.replaceDoubleQuotesWithSingleQuotes(this.city)) + ", ");
		}
		if (this.state != null)
		{
			addressString += (util.stripCrlf(util.replaceDoubleQuotesWithSingleQuotes(this.state)) + " ");
		}
		if (this.postalCode != null)
		{
			addressString += (util.stripCrlf(util.replaceDoubleQuotesWithSingleQuotes(this.postalCode)) + ", ");
		}
		if (this.country != null)
		{
			addressString += (util.stripCrlf(util.replaceDoubleQuotesWithSingleQuotes(this.country)));
		}
		
		return addressString;
	},
	
	this.getCity = function()
	{
		if (this.city == null)
		{
			return "";
		}
		
		return this.city;
	},
	
	this.getState = function()
	{
		if (this.state == null)
		{
			return "";
		}
		
		return this.state;
	},
	
	this.getPostalCode = function()
	{
		if (this.postalCode == null)
		{
			return "";
		}
		
		return this.postalCode;
	}
	
}

/////////////////////////////////////////////////////////////////////////////////////
// Waypoint
/////////////////////////////////////////////////////////////////////////////////////
function Waypoint(mapObject)
{
	this.mapObject = mapObject;
	
	this.getMapObject = function()
	{
		return this.mapObject;
	}
	
	this.getId = function()
	{
		return this.mapObject.id;
	};
	
	this.getName = function()
	{
		return this.mapObject.name;
	};
	
	this.getAddress = function()
	{
		return this.mapObject.address;
	};
}

	
/////////////////////////////////////////////////////////////////////////////////////
// Trip
/////////////////////////////////////////////////////////////////////////////////////

function Trip()
{
	this.name = locale.untitled;
	this.started = false;
	this.directionsVisible = false;

	this.DIRECTIONS_MAX_CHUNKS = 25;
	this.DIRECTIONS_CHUNK_SIZE = 30000;
	this.MAX_WAYPOINTS = 25;

	this.DirectionsService = new google.maps.DirectionsService();
	
	this.DirectionsRenderers = []; 
	this.DirectionsResponses = [];
	this.MAX_RENDERER_WAYPOINTS = 10;


	this.start = function()
	{
		this.waypoints = [];
		this.directionsVisible = false;
//		this.directionsTravelMode = G_TRAVEL_MODE_DRIVING;
		this.avoidHighways = false;

		if (this.addTripWaypointFromSelectedObject())
		{
			this.started = true;
		}	
	}

	this.createWaypointFromObject = function(object)
	{
		if (object == null)
		{
			return null;
		}

		return new Waypoint(object);
	}
	
	this.load = function(waypointObjectIds)
	{
		var objectIds = waypointObjectIds.split(";");

		this.waypoints = [];

		for (var i = 0; i < objectIds.length; i++)
		{
			var object = territories.view.findObject(objectIds[i]);

			if (object != null)
			{
				this.addTripWaypoint(object, this.waypoints.length);
			}
		}

		if (this.waypoints.length == 0)
		{
			alert(locale.unableToLoadTrip);
			this.close();
			util.hideLoadingImage();
			return;
		}

//		this.directionsTravelMode = G_TRAVEL_MODE_DRIVING;
//		this.avoidHighways = false;

		util.showLoadingImage();
		loadTripWaypoints(this.getWaypointData());
	};
	
	this.getWaypointData = function()
	{
		var waypointsData = "";
	
		for (var i = 0; i < this.waypoints.length; i++)
		{
			if (waypointsData.length > 0)
			{
				waypointsData += separator.para;
			}

			waypointsData += this.waypoints[i].getId() + separator.section;
			waypointsData += this.waypoints[i].getName() + separator.section;
			waypointsData += this.waypoints[i].getAddress().geocodeAddress + separator.section;
			waypointsData += this.waypoints[i].getAddress().coordinates.lat() + separator.section;
			waypointsData += this.waypoints[i].getAddress().coordinates.lng();
		}
		
		return waypointsData;
	};
	
	this.createDirections = function()
	{
		this.directionsPanel = document.getElementById("route");
	
		var rendererCount = Math.floor(this.waypoints.length / this.MAX_RENDERER_WAYPOINTS) + 1;
//alert("rendererCount: " + rendererCount);
	
		this.DirectionsRenderers = [];
		
		for (var i = 0; i < rendererCount; i++)
		{
			this.DirectionsRenderers.push(new google.maps.DirectionsRenderer());
		}

/*	
		if (!util.isDefined(this.directionsRenderer))
		{
			this.directionsPanel = document.getElementById("route");
			
			//this.directions = new GDirections(map, this.directionsPanel);
			
			var options = {
				map: map,
				panel: this.directionsPanel,
			};
			
			this.directionsRenderer = new google.maps.DirectionsRenderer(options); 
			
//			google.maps.event.addListener(this.directions, "error", this.showRouteError);
//			google.maps.event.addListener(this.directions, "addoverlay", this.onDirectionsAddOverlay);
		}
*/		
	};
	
	this.close = function()
	{
		this.resetTripMarkers();
		this.waypoints = null;
//		if (util.isDefined(this.directions))
//		{
//			this.directions.clear();
			this.clearTrip();
			this.hideDirections();
//		}

		this.started = false;
	};

	this.addTripWaypoint = function(object, insertionIndex)
	{
		if (this.waypoints.length == 1)
		{
			this.waypoints[0].getMapObject().hideTripMarker();
		}
		
		var waypoint = this.createWaypointFromObject(object);
		this.waypoints.splice(insertionIndex, 0, waypoint);
		
		if (this.waypoints.length == 1)
		{
			object.showTripMarker(0);
		}
		
/*
		if (this.waypoints.length == 1)
		{
			object.showTripMarker();
		}
		else
		{		
			object.hideMarker();
		}
*/		
	}

	this.insertTripWaypoint = function(object)
	{
		if (object == null)
		{
			return;
		}

		this.addTripWaypoint(object, this.insertingWaypointIndex);
				
		util.showLoadingImage();
		
		insertTripWaypoint(this.getWaypointData());
	};
	
	this.moveTripWaypoint = function(oldIndex, newIndex)
	{
		var waypoint = this.waypoints[oldIndex];
	
		this.waypoints.splice(oldIndex, 1);
		
		if (newIndex >= this.waypoints.length)
		{
			this.waypoints.push(waypoint);
		}
		else
		{
			this.waypoints.splice(newIndex, 0, waypoint);
		}
			
		util.showLoadingImage();

		moveTripWaypoint(this.getWaypointData());
	};
	
	this.removeWaypoint = function(waypointIndex)
	{
//		territories.closeInfoWindow();
		InfoWindow.close();

		if (this.waypoints.length <= waypointIndex)
		{
			return true;
		}
	
		var mapObject = this.waypoints[waypointIndex].getMapObject();
		
		this.waypoints.splice(waypointIndex, 1);

		if (!this.objectInTrip(mapObject))
		{
			mapObject.showMarker();
		}

		if (this.waypoints.length == 0)
		{
			this.close();
		}

		if (this.waypoints != null && this.waypoints.length == 2)
		{
			if (this.waypoints[0].getId() == this.waypoints[1].getId())
			{
				this.waypoints.pop();
			}
		}
	
this.showTripMarkers();

//		if (this.waypoints != null && this.waypoints.length == 1)
//		{
//			this.waypoints[0].getMapObject().showTripMarker();
//		}
		
		util.showLoadingImage();
	
		return true;
	};
	
	this.getWaypointCount = function()
	{
		var hiddenInput = document.getElementById("page_Territories:form_Territories:block_TripPlanner:hidden_TripWaypointCount");
		
		if (hiddenInput == null)
		{
			return 0;
		}
		
		return hiddenInput.value;
	};


	this.clearTrip = function()
	{
		for (var i = 0; i < this.DirectionsRenderers.length; i++)
		{
			this.DirectionsRenderers[i].setMap(null);
		}
		
		$(this.directionsPanel).empty();
		
	};

	this.reloadDirections = function()
	{
		this.clearTrip();
		this.createDirections();
//		this.directions.clear();

//		var waypointAddresses = [];
			
		if (this.waypoints.length > 1)
		{
//			for (var i = 0; i < this.waypoints.length; i++)
//			{
//				waypointAddresses.push(this.waypoints[i].getAddress().geocodeAddress);
//			}
	
			if (!this.directionsVisible)
			{
				this.showDirections();
			}

//			this.loadDirections(waypointAddresses);

			$(this.directionsPanel).empty();
			this.loadDirections(0);
		}
		else if (this.directionsVisible)
		{
			this.hideDirections();
		}
	};


/*	
	this.loadDirections = function(waypointAddresses)
	{
		var directionsOptions = {};
		directionsOptions.travelMode = this.directionsTravelMode;
		directionsOptions.avoidHighways = this.avoidHighways;
		directionsOptions.preserveViewport = true;
		directionsOptions.locale = userLocale;
	
	  	this.directions.loadFromWaypoints(waypointAddresses, directionsOptions);
	 };
*/	  	


	this.loadDirections = function(rendererIndex)
	{
		if (rendererIndex == 0 && this.waypoints.length < 2)
		{
			return;
		}
		
		
		

		var originIndex = rendererIndex == 0 ? 0 : (this.MAX_RENDERER_WAYPOINTS * rendererIndex - rendererIndex);
		var destinationIndex = rendererIndex == 0 ? (Math.min(this.waypoints.length, originIndex + this.MAX_RENDERER_WAYPOINTS) - 1) :
			(originIndex + Math.min(this.waypoints.length - originIndex, this.MAX_RENDERER_WAYPOINTS) - 1);
			
//alert(rendererIndex + ":  " + originIndex + "   " + destinationIndex);

		var originWaypoint = this.waypoints[originIndex];
		var destinationWaypoint = this.waypoints[destinationIndex];
		
		var origin = originWaypoint.getAddress().geocodeAddress;
		var destination = destinationWaypoint.getAddress().geocodeAddress;
		var waypoints = [];
		
		for (var i = originIndex + 1; i < destinationIndex; i++)
		{
			var waypoint = this.waypoints[i];
			waypoints.push({location: waypoint.getAddress().geocodeAddress, stopover: true});
		}
		
		var request = {
			origin: origin,
			destination: destination,
			waypoints: waypoints,
			travelMode: google.maps.TravelMode.DRIVING
			};
		
		var renderOptions = {
			draggable: false,
			markerOptions: {draggable: false},
			preserveViewport: true,
			infoWindow: InfoWindow,
			suppressMarkers: true,
//			panel: this.directionsPanel,
			map: map,
		};

		var renderer = this.DirectionsRenderers[rendererIndex];
		renderer.setOptions(renderOptions);
	
		var _this = this;
		
		this.DirectionsService.route(request, function(response, status) 
		{
	    	if (status == google.maps.DirectionsStatus.OK) 
	    	{
	    		renderer.setDirections(response);
	    		
//	    		_this.showTripMarkers();
	    		
	    		//_this._onRoutingResult({code: "ok", tripHtml: _this._generateTripHtml(response, rendererIndex)});
	    		
	    		//_this._trip._onRoutingResult({code: "ok", tripHtml: _this._generateTripHtml(response, rendererIndex)});
	    		
	    		
	    		_this.onRoutingSuccess(response, rendererIndex);
	    	}
		});

		
	};

	this.onRoutingSuccess = function(response, rendererIndex)
	{
		$(this.directionsPanel).append(this._generateTripHtml(response, rendererIndex));
		

	
	
		this.DirectionsRenderers[rendererIndex].setDirections(response);
		
		if (rendererIndex < this.DirectionsRenderers.length - 1)
		{
			this.loadDirections(rendererIndex + 1);
		}
		
		this.showTripMarkers();
	};


	this._generateTripHtml = function(response, rendererIndex)
	{
		var tripHtml = $("<div></div>");
		var waypointIndex = 0;
		var leg = null;
		
		for (var i = 0; i < response.routes[0].legs.length; i++)
		{
			waypointIndex = i + rendererIndex * this.MAX_RENDERER_WAYPOINTS - rendererIndex;
//			waypointIndex = rendererIndex > 0 ? --waypointIndex : waypointIndex;
			leg = response.routes[0].legs[i];
			tripHtml.append(this._generateTripLegNode(response, leg, waypointIndex));
		}
		
		if (rendererIndex == this.DirectionsRenderers.length - 1)
		{
			tripHtml.append(this._generateTripLegNode(response, leg, ++waypointIndex, true));
			tripHtml.append(this._getTripCopyrights(response));
		}
		
		return tripHtml;
	};
	
	
	this._generateTripLegNode = function(response, leg, waypointIndex, isLastWaypoint)
	{
		var tripLegNode = $("<div></div>")
			.css("paddingRight", "15px");
		
		tripLegNode.append(this._generateTripPlacemark(leg, waypointIndex, isLastWaypoint))
		
		if (isLastWaypoint)
		{
			return tripLegNode;
		}
		
		tripLegNode.append($("<div></div>")
			.addClass("trip-directions-summary trip-directions-row")
			.html(leg.distance.text + " - " + leg.duration.text));
		
		var tripLegTableBody = $("<tbody></tbody>"); 
		
		var tripLegTable = $("<table></table>")
			.css("borderCollapse", "collapse")
			.append(tripLegTableBody)
			.appendTo(tripLegNode);
	
		tripLegNode.append(tripLegTable);
		
		for (var i = 0; i < leg.steps.length; i++)
		{
			var step = leg.steps[i];
			
			tripLegTableBody.append(
				$("<tr></tr>")
					.addClass("trip-directions-row")
					.append($("<td></td>")
						.addClass("trip-directions-cell")
						.html(i + 1 + "."))
					.append($("<td></td>")
						.addClass("trip-directions-cell")
						.css("width", "100%")
						.html(step.instructions))
					.append($("<td></td>")
						.addClass("trip-directions-cell")
						.css("whiteSpace", "nowrap")
						.html(step.distance.text)));
		}
		
		return tripLegNode;
	};
	
	this._generateTripPlacemark = function(leg, waypointIndex, isLastWaypoint)
	{
	
//		var tripWaypoints = this.getWaypoints();
		
//		var mapObject = tripWaypoints[waypointIndex].getMapObject();

		var mapObject = this.waypoints[waypointIndex].mapObject;
		
		
		var placemarkName = $("<div></div>")
			.css("fontWeight", "bold")
			.html(mapObject.name);
		
		var placemarkAddress = $("<div></div>")
			.css("marginBottom", "3px")
			.css("fontSize", "90%")
			.html(isLastWaypoint ? leg.end_address : leg.start_address);
		
//		var placemarkFieldInfo = $("<div></div>")
//			.css("fontSize", "80%");
		
//		var displayFieldsText = mapObject.getTripDisplayFields();
		
//		for (var i = 0; i < displayFieldsText.length; i++)
//		{
//			placemarkFieldInfo.append($("<div></div>")
//				.css("borderTop", "1px solid black")
//				.html(displayFieldsText[i]));
//		}
	
	
		return $("<div></div>")
		.addClass("trip-directions-placemark")
		.append($("<table></table>")
			.css("borderCollapse", "collapse")
			.append($("<tbody></tbody>")
				.append($("<tr></tr>")
					.append($("<td></td>")
						.append($("<div></div>")
							.css("width", "35px")
							.css("height", "35px")
							.css("color", "white")
							.css("backgroundColor", "black")
							.css("fontWeight", "bold")
							.css("fontSize", "20px")
							.css("textAlign", "center")
							.css("paddingTop", "7px")
							.text(this.getWaypointLetterFromIndex(waypointIndex)))
//						.addClass("trip-directions-summary")
//						.css("verticalAlign", "top")
//						.append($("<img></img>")
//							.attr("src", MarkerUtil.getTripMarkerImage(waypointIndex + 1, pexys.maps.const.marker.DEFAULT_HEIGHT, mapObject.getMarker().getAlpha()).src))
						)
					.append($("<td></td>")
						.addClass("trip-directions-summary")
						.css("width", "100%")
						.append(placemarkName)
						.append(placemarkAddress)))));
						
	};
	
	this._getTripCopyrights = function(response)
	{
		return $("<div></div>")
			.addClass("trip-directions-copyright")
			.html(response.routes[0].copyrights);
	};
	
	

	this.showDirections = function()
	{
		document.getElementById("panel_Directions").style.display = "";
		this.directionsVisible = true;
	};

	this.hideDirections = function()
	{
		document.getElementById("panel_Directions").style.display = "none";
		this.directionsVisible = false;
	};

	this.changeTravelMode = function()
	{
		var travelModeSelect = document.getElementById("select_TravelMode");
		var travelModeValue = travelModeSelect.options[travelModeSelect.selectedIndex].value;

		this.directionsTravelMode = travelModeValue == "Walking" ? G_TRAVEL_MODE_WALKING : 
			G_TRAVEL_MODE_DRIVING;
			
		this.setDirectionsTitle();   
		this.reloadDirections();
	};

	this.changeHighwaysUsage = function()
	{
		var highwaysUsageSelect = document.getElementById("select_HighwaysUsage");
		var highwaysUsageValue = highwaysUsageSelect.options[highwaysUsageSelect.selectedIndex].value;

		this.avoidHighways = highwaysUsageValue == "Avoid";		

		this.setDirectionsTitle();   
		this.reloadDirections();
	};

	this.getDirectionsTitle = function()
	{
		var directionsTitle = "";
		
//		if (this.directionsTravelMode == G_TRAVEL_MODE_WALKING)
//		{
//			directionsTitle = locale.walkingDirections;
//		}
//		else
//		{
			directionsTitle = locale.drivingDirections;
//		}
		
//		if (this.avoidHighways)
//		{
//			directionsTitle += " (" + locale.avoidHighways + ")";
//		}

		return directionsTitle;
	};
	
	this.setDirectionsTitle = function()
	{
		var directionsTitleDiv = document.getElementById("div_DirectionsTitle");
		directionsTitleDiv.innerHTML = this.getDirectionsTitle();
	};

	this.showTripMarkers = function()
	{
		for (var i = 0; i < this.waypoints.length; i++)
		{
			this.waypoints[i].getMapObject().showTripMarker(i);
		}
	};

	this.resetTripMarkers = function()
	{
		if (this.waypoints == null)
		{
			return;
		}
		
		for (var i = 0; i < this.waypoints.length; i++)
		{
			this.waypoints[i].getMapObject().showMarker();
		}
	};

	this.isFinalTripObject = function(object)
	{
		return(this.waypoints != null && 
			this.waypoints.length > 0 &&
			this.waypoints[this.waypoints.length - 1].getId() == object.id);
	};
	
	this.objectInTrip = function(object)
	{
		if (this.waypoints == null)
		{
			return false;
		}
	
		for (var i = 0; i < this.waypoints.length; i++)
		{
			if (this.waypoints[i].getId() == object.id)
			{
				return true;
			}
		}
		
		return false;
	};
	
	this.getWaypointIndexFromId = function(waypointId)
	{
		for (var i = 0; i < this.waypoints.length; i++)
		{
			if (this.waypoints[i].getId() == waypointId)
			{
				return i;
			}
		}
		
		return -1;
	};
	
	this.onClickCloseTrip = function()
	{
		this.name = locale.untitled;
		this.close();
//		territories.closeInfoWindow();
		InfoWindow.close();
		addMapMarker.cleanUp();
		
		return true;
	};

	this.moveTripWaypointOfSelectedObject = function()
	{
		var selectList = document.getElementById("select_MoveToPoint");
		
		if (selectList == null)
		{
			return;
		}
		
		var movingWaypointNewIndex = selectList.options[selectList.selectedIndex].value; 
		var movingWaypointOldIndex = this.getWaypointIndexFromId(territories.selectedObject.id);
		
		if (movingWaypointOldIndex == -1)
		{
			return;
		}
		
//		territories.closeInfoWindow();
		InfoWindow.close();
		this.moveTripWaypoint(movingWaypointOldIndex, movingWaypointNewIndex);
	};

	this.addTripWaypointFromSelectedObject = function()
	{
		var selectList = document.getElementById("select_InsertPoint");
		this.insertingWaypointIndex = selectList == null ? this.waypoints.length : 
			selectList.options[selectList.selectedIndex].value; 
	
//		territories.closeInfoWindow();
		InfoWindow.close();
		this.insertTripWaypoint(territories.selectedObject);
		
		return true;
	};
	
	this.afterInsertTripWaypoint = function()
	{
		this.reloadDirections();
		util.hideLoadingImage();
	};
	
	this.afterMoveTripWaypoint = function()
	{
		this.reloadDirections();
		util.hideLoadingImage();
	};
	
	this.afterRemoveTripWaypoint = function()
	{
		this.clearRouteError();

		if (this.started)
		{
			this.reloadDirections();
		}
		
		util.hideLoadingImage();
	};
	
	this.afterLoadTripWaypoints = function()
	{
		this.reloadDirections();
		this.started = true;
		util.hideLoadingImage();
	};
	
	this.showRouteError = function()
	{
		alert(locale.eitherTheStart +
			geocoding.convertResponseCodeToReason(trip.directions.getStatus().code));
			
		trip.removeWaypoint(trip.insertingWaypointIndex);
		removeTripWaypoint(trip.insertingWaypointIndex);
	};

	this.clearRouteError = function()
	{
		document.getElementById("route").innerHTML = "";
	};

/*
	this.onDirectionsAddOverlay = function()
	{
		for (var i = 0; i < trip.waypoints.length; i++)
		{
			var marker = trip.directions.getMarker(i);
			var mapObject = trip.waypoints[i].getMapObject();
			
			trip.remapMarker(marker, mapObject);				
		}
		
		util.hideLoadingImage();		
	};
*/

	this.remapMarker = function(marker, mapObject)
	{
		google.maps.event.addListener(marker, "click", 
			function()
			{
				territories.selectedObject = mapObject;
				mapObject.fetchRelatedObjects();
				var mapObjectHtml = mapObject.getHtml();
				
				InfoWindow.open(null, mapObject.marker);
				InfoWindow.setContent(mapObjectHtml);
//				mapObject.marker.openInfoWindowHtml(mapObjectHtml);
			}
		);
		
	  	google.maps.event.addListener(marker, "infowindowopen", 
	  		function()
	  		{
				saveLastSelectedObject(territories.selectedObject.id);
	  		}
	  	);
	  	google.maps.event.addListener(marker, "infowindowclose", 
	  		function()
	  		{
				saveLastSelectedObject("");
	  		}
	  	);
	};


	this.beforeLoadTrip = function()
	{
		util.showLoadingImage();
		InfoWindow.close();
//		territories.closeInfoWindow();
//		outlines.cleanUp();
		addMapMarker.cleanUp();
		outlines.cleanUp();
		heatMaps.cleanUp();
		gis.cleanUp();
		
		if (trip.started)
		{
			this.close();
		}	
	};
	
	this.loadTrip = function()
	{
		this.beforeLoadTrip();
		loadTrip();
	}	
	
	this.afterLoadTrip = function()
	{
		this.name = document.getElementById("page_Territories:form_Territories:hidden_TripName").value;
		
		var tripWaypoints = document.getElementById("page_Territories:form_Territories:hidden_TripWaypoints").value;

		if (tripWaypoints.length > 0)
		{
			this.load(tripWaypoints);
		}
		else
		{
			util.hideLoadingImage();
		}
	};

	this.saveTrip = function()
	{
		util.showLoadingImage();
		saveTrip(this.getWaypointData());
	};

	this.saveThisTrip = function()
	{
		util.showLoadingImage();
		saveThisTrip(this.getWaypointData());
	};

	this.saveTripAs = function()
	{
		util.showLoadingImage();
		saveTripAs(this.getWaypointData());
	};

	this.beforeCloseTrip = function()
	{
		this.onClickCloseTrip();
		closeTrip();
	};
	
	this.beforeDeleteTrip = function()
	{
		util.showLoadingImage();
		this.onClickCloseTrip();
	};
	
	this.getWaypointLetterFromIndex = function(index)
	{
		var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		
		if (index < 26)
		{
			return alphabet.substr(index, 1);
		}
		
		return alphabet.substr((index / 26) - 1, 1) + alphabet.substr(index % 26, 1);
	};
	
	this.getButtonBarHtml = function(mapObject, addLinks)
	{
		var objectInTrip = this.objectInTrip(mapObject);
		var isFinalTripObject = this.isFinalTripObject(mapObject);
		
		var tripHtml = '<table cellspacing="0" cellpadding="0" border="0">';
	
		if (this.started)
		{
			tripHtml += '<tr>';

			tripHtml += 
				'<td style="vertical-align:middle; font-weight:bold; color:green">' + locale.trip + ':</td>';
			
			var waypointCount = this.getWaypointCount();
			if (waypointCount > 0 && waypointCount < this.MAX_WAYPOINTS)
			{
				if (waypointCount == 1 && territories.selectedObject.id == this.waypoints[0].getId())
				{
					tripHtml += '<td style="padding:0px 4px; vertical-align:middle">' + locale.start + '</td>';
				}
				
				if (!isFinalTripObject)
				{
					tripHtml +=
						'<td style="padding:0px 4px; ' + ((objectInTrip && !isFinalTripObject) ? 'border-right:thin solid silver' : '') + '">';
						tripHtml += 
							'<div style="white-space:nowrap;"> \
							<input class="btn" id="button_AddToTrip" name="button_AddToTrip" onclick="trip.addTripWaypointFromSelectedObject()" value="' + 
								(objectInTrip ? locale.addToEnd : locale.add + ':') + '" type="button" />';
					
					if (!objectInTrip)
					{
						tripHtml +=
							'&nbsp;<select id="select_InsertPoint" style="font-size:90%">'; 
								
							for (var i = 0; i < waypointCount; i++)
							{
								tripHtml +=
									'<option value="' + i + '">' + locale.before + ' ' + this.getWaypointLetterFromIndex(i) + '</option>';
							}	  
		
							tripHtml +=
								'<option value="' + waypointCount + '" selected="selected">' + locale.toEnd + '</option> \
									</select>';
					}
	
					tripHtml +=	'</div></td>';
					
				}
			}

			if (waypointCount > 1 && objectInTrip)
			{
				tripHtml += 
					'<td style="padding:0px 4px;"> \
						<input class="btn" id="button_MoveTo" name="button_MoveTo" onclick="trip.moveTripWaypointOfSelectedObject()" value="' + locale.moveTo + '":" type="button" /> \
							<select id="select_MoveToPoint" style="font-size:90%">'; 
									
							for (var i = 0; i < waypointCount; i++)
							{
								if (territories.selectedObject.id != this.waypoints[i].getId())
								{
									tripHtml +=
										'<option value="' + i + '">' + this.getWaypointLetterFromIndex(i) + '</option>';
								}
							}	  
		
					tripHtml +=
						'</select> \
					</td>';
			}				
			
			tripHtml += '</tr>';
		}
		else
		{	
			tripHtml += 
				'<tr> ';

			var showTripButtons = (territories.view != null && 
				territories.view.id != null &&
				territories.view.id.length > 0);
				
			if (showTripButtons)
			{				
				tripHtml += 
					'<td width="10px"> \
						<input ' + ((browserInfo.isMSIE() && browserInfo.version() < 8) ? 'style="width:80px"' : '') + ' class="btn" id="button_Trip" name="button_Trip" onclick="trip.start()" value="' + locale.startTrip + '" type="button" /> \
					</td>';
			}

			tripHtml += 
				'<td width="10px"> \
				 	<input ' + ((browserInfo.isMSIE() && browserInfo.version() < 8) ? 'style="width:95px"' : '') + ' class="btn" id="button_ShowStreetView" name="button_ShowStreetView" onclick="streetView.showStreetViewOfSelectedObject()" value="' + locale.streetView + '" type="button" /> \
				 </td>';

			if (addLinks)
			{
				tripHtml += 
					'<td style="vertical-align:middle;padding-left:7px;">[LINK_1]</td>';
			

				tripHtml += 
					'<td style="vertical-align:middle;padding-left:7px;">[LINK_2]</td>';
			}
			
			tripHtml += '</tr>';

		}
				
		tripHtml += '</table>';
		
		return tripHtml;
	};
	
	this.clearDirectionsHtml = function()
	{
		document.getElementById("page_Territories:form_Territories:hidden_TripDirectionsViewName").value = "";
	
		for (var i = 1; i <= this.DIRECTIONS_MAX_CHUNKS; i++)
		{ 
			var directionsInput = document.getElementById("page_Territories:form_Territories:hidden_TripDirections" + String(i));
			if (directionsInput != null)
			{
				directionsInput.value = "";
			}
		}
	};
	
	this.generateDirectionsHtml = function()
	{
	


		this.clearDirectionsHtml();

		document.getElementById("page_Territories:form_Territories:hidden_TripDirectionsViewName").value = territories.view.name;
			
/*			
		var directionsChunkNumber = 1;
		var directionsInput = document.getElementById("page_Territories:form_Territories:hidden_TripDirections" + String(directionsChunkNumber));

		directionsInput.value = $(this.directionsPanel).html();
*/


		for (var i = 0; i < this.DIRECTIONS_MAX_CHUNKS; i++)
		{
			var directionsInput = document.getElementById("page_Territories:form_Territories:hidden_TripDirections" + String(i + 1));
			directionsInput.value = $(this.directionsPanel).html().substr(i * this.DIRECTIONS_CHUNK_SIZE, this.DIRECTIONS_CHUNK_SIZE);
		} 
	
/*	
		this.clearDirectionsHtml();

		document.getElementById("page_Territories:form_Territories:hidden_TripDirectionsViewName").value = territories.view.name;
			
		var directionsChunkNumber = 1;
		var directionsInput = document.getElementById("page_Territories:form_Territories:hidden_TripDirections" + String(directionsChunkNumber));
		
		var tripNameInput = document.getElementById("page_Territories:form_Territories:hidden_SelectedTripName");
		var tripName = tripNameInput == null ? "" : (tripNameInput.value == null || tripNameInput.value.length == 0 ? locale.untitled : tripNameInput.value);
		
		var directionsHtml = "";

		directionsHtml += "<div class='dt'>" + this.getDirectionsTitle() + "</div>";

		directionsHtml += 		
			"<br/> \
			<table class='t4'> \
				<tr> \
					<td> \
						<div class='cph'>";
							directionsHtml += '<b>' + locale.tripTotals + ':</b> ' + this.directions.getSummaryHtml();
							directionsHtml +=
						"</div> \
					</td> \
				</tr> \
			</table>";
			
		for (var i = 0; i <= this.directions.getNumRoutes(); i++)
		{
			var mapObject = this.waypoints[i].mapObject;
		
			directionsHtml += 
				"<table class='t1'> \
					<tr> \
						<td> \
							<div class='wpl'>";
								directionsHtml += this.getWaypointLetterFromIndex(i);
								directionsHtml +=
							"</div> \
						</td> \
						<td width='100%'> \
							<div class='wpt'>";
								directionsHtml += mapObject.name; 
								if (mapObject.type == "Lead")
								{
									directionsHtml += " - " + mapObject.company;
								}
								directionsHtml += "<br/>" + mapObject.address.geocodeAddress;
								directionsHtml += 
							"</div> \
						</td> \
					</tr> \
				</table>";
				
			if (i == this.directions.getNumRoutes())
			{
				break;
			}
	
			directionsHtml += 
				"<div class='rsh'>";
					directionsHtml += this.directions.getRoute(i).getSummaryHtml();
					directionsHtml +=
				"</div>";
	
			if (this.directions.getRoute(i).getNumSteps() != 1 || this.directions.getRoute(i).getStep(0).getDescriptionHtml() != '')
			{
				directionsHtml += 		
					"<table class='t2'>";
					
				for (var j = 0; j < this.directions.getRoute(i).getNumSteps(); j++)
				{		
					directionsHtml +=
					"<tr class='str'> \
						<td class='stn'>";
							directionsHtml += String(j + 1);
							directionsHtml +=
						"</td> \
						<td class='stt'>";
							directionsHtml += this.directions.getRoute(i).getStep(j).getDescriptionHtml();
							directionsHtml +=
						"</td> \
						<td class='std'>";
							directionsHtml += this.directions.getRoute(i).getStep(j).getDistance().html;
							directionsHtml +=
						"</td> \
					</tr>";
					
					if (directionsHtml.length > this.DIRECTIONS_CHUNK_SIZE)
					{
						var limitReached = ++directionsChunkNumber > this.DIRECTIONS_MAX_CHUNKS;
						 
						if (limitReached)
						{
							directionsHtml += "<div class='oo'><b>LIMIT REACHED:</b> The remaining directions cannot be \
								displayed because the maximum length for the directions has been exceeded</div>";
						}
					
						directionsInput.value = directionsHtml;
						directionsHtml = "";
						
						if (limitReached)
						{
							return;
						}
						
						directionsInput = document.getElementById("page_Territories:form_Territories:hidden_TripDirections" + String(directionsChunkNumber));
					}
				}
				
				directionsHtml +=
				"</table>";
			}
		}		
		
		directionsHtml += 		
			"<table class='t3'> \
				<tr> \
					<td> \
						<div class='cph'>";
							directionsHtml += this.directions.getCopyrightsHtml();
							directionsHtml +=
						"</div> \
					</td> \
				</tr> \
			</table>";
		
		
		directionsInput.value = directionsHtml;
*/		
	};
	
	this.optimizeDistances = function()
	{
		if (this.waypoints.length <= 2)
		{
			return;
		}
		
		var waypointsCopy = [];
		
		for (var i = 0; i < this.waypoints.length; i++)
		{
			waypointsCopy.push(this.waypoints[i]);
		}
		
		var newWaypoints = [waypointsCopy[0]];
		waypointsCopy.splice(0, 1);
		
		for (var i = 0; i < this.waypoints.length - 2; i++)
		{		
			var currPointCoord = newWaypoints[newWaypoints.length - 1].getAddress().coordinates;
			var shortestDistance = Infinity;
			var shortestDistanceIndex = -1;
			
			for (var j = 0; j < waypointsCopy.length; j++)
			{
				var distance = util.distanceBetween(currPointCoord, waypointsCopy[j].getAddress().coordinates);

				if (Number(distance) < Number(shortestDistance))
				{
					shortestDistance = distance;
					shortestDistanceIndex = j;
				}
			}
			
			newWaypoints.push(waypointsCopy[shortestDistanceIndex]);
			waypointsCopy.splice(shortestDistanceIndex, 1)
		}
		
		newWaypoints.push(waypointsCopy[0]);
	
		this.waypoints = newWaypoints;		
		
		util.showLoadingImage();
		
		insertTripWaypoint(this.getWaypointData());
		
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// Geocoding
/////////////////////////////////////////////////////////////////////////////////////
function Geocoding()
{
	this.uncheckSelectAllItems = function()
	{
	    var checkBox = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:check_SelectAllItems");
	    if (checkBox != null)
	    {
			checkBox.checked = false;
	    }
	};
	
	this.selectAllItems = function(selectAllCheckBox)
	{
		util.selectAllCheckBoxes(selectAllCheckBox,
			"page_Territories:form_Territories:block_ViewListing:table_ViewListing:",
			":check_SelectedItem");
	};

	this.itemSelected = function(itemCheckBox)
	{
		util.checkBoxSelected(itemCheckBox, 
			"page_Territories:form_Territories:block_ViewListing:table_ViewListing:check_SelectAllItems",
			"page_Territories:form_Territories:block_ViewListing:table_ViewListing:", ":check_SelectedItem");
	};
	
	this.checkAnyItemsSelected = function()
	{
		return util.checkAnySelected("page_Territories:form_Territories:block_ViewListing:table_ViewListing:",
			":check_SelectedItem");
	};

	this.createGeocoder = function()
	{
		if (!util.isDefined(this.geocoder))
		{
			//this.geocoder = new GClientGeocoder();
			this.geocoder = new google.maps.Geocoder();
		}
	};
	
	this.convertTamuResponseCode = function(code)
	{
		switch(code)
		{
		case "LOCATION_TYPE_UNKNOWN":
		case "LOCATION_TYPE_UNMATCHABLE":
			return "G_GEO_UNKNOWN_ADDRESS";
		default:
			return "G_GEO_SUCCESS";
		}
	};

	this.convertResponseCode = function(code)
	{
		switch(code)
		{
			case "OK":
				return "G_GEO_SUCCESS";
			case "ZERO_RESULTS":
				return "G_GEO_UNKNOWN_ADDRESS";
			case "OVER_QUERY_LIMIT":
				return "G_GEO_TOO_MANY_QUERIES";
			default:
			case "REQUEST_DENIED":
			case "INVALID_REQUEST":
			case "UNKNOWN_ERROR":
				return "G_GEO_BAD_REQUEST";
		}
	
/*	
		switch (code)
		{
		case google.maps.GeocoderStatus.OK:
			return "G_GEO_SUCCESS";
		case google.maps.GeocoderStatus.INVALID_REQUEST:
			return "G_GEO_UNKNOWN_ADDRESS";
		case google.maps.GeocoderStatus.OVER_QUERY_LIMIT:
			return "G_GEO_TOO_MANY_QUERIES";
		case google.maps.GeocoderStatus.ERROR:
			return "G_GEO_SERVER_ERROR";
		default:
		case google.maps.GeocoderStatus.REQUEST_DENIED:
		case google.maps.GeocoderStatus.UNKNOWN_ERROR:
			return "G_GEO_BAD_REQUEST";
		case google.maps.GeocoderStatus.ZERO_RESULTS:
			return "G_GEO_UNKNOWN_ADDRESS";
			
		}
*/		
/*	
		switch(code)
		{
			case 200:
				return "G_GEO_SUCCESS";
			default:			
			case 400:
				return "G_GEO_BAD_REQUEST";
			case 500:
				return "G_GEO_SERVER_ERROR";
			case 601:
				return "G_GEO_MISSING_ADDRESS";
			case 602:
				return "G_GEO_UNKNOWN_ADDRESS";
			case 603:
				return "G_GEO_UNAVAILABLE_ADDRESS";
			case 604:
				return "G_GEO_UNKNOWN_DIRECTIONS";
			case 610:
				return "G_GEO_BAD_KEY";
			case 620:
				return "G_GEO_TOO_MANY_QUERIES";
		}
*/		
	};

	this.convertResponseCodeToReason = function(code)
	{
		switch(code)
		{
		case google.maps.GeocoderStatus.OK:
			return "No errors occurred; the address was successfully parsed and its geocode has been returned.";;
		case google.maps.GeocoderStatus.INVALID_REQUEST:
			return "No corresponding geographic location could be found for the specified address. This may be due to the fact that the address is relatively new, or it may be incorrect.";
		case google.maps.GeocoderStatus.OVER_QUERY_LIMIT:
			return "The given key has gone over the requests limit in the 24 hour period or has submitted too many requests in too short a period of time. If you're sending multiple requests in parallel or in a tight loop, use a timer or pause in your code to make sure you don't send the requests too quickly.";
		case google.maps.GeocoderStatus.ERROR:
			return "A geocoding, directions or maximum zoom level request could not be successfully processed, yet the exact reason for the failure is not known.";
		default:
		case google.maps.GeocoderStatus.REQUEST_DENIED:
		case google.maps.GeocoderStatus.UNKNOWN_ERROR:
			return "A directions request could not be successfully parsed. For example, the request may have been rejected if it contained more than the maximum number of waypoints allowed.";
		case google.maps.GeocoderStatus.ZERO_RESULTS:
			return "No corresponding geographic location could be found for the specified address. This may be due to the fact that the address is relatively new, or it may be incorrect.";
		}
		
		return "";
	
	
/*	
		switch(code)
		{
			case 200:
			 	return "No errors occurred; the address was successfully parsed and its geocode has been returned.";
			case 400:
			 	return "A directions request could not be successfully parsed. For example, the request may have been rejected if it contained more than the maximum number of waypoints allowed.";
			case 500:
				return "A geocoding, directions or maximum zoom level request could not be successfully processed, yet the exact reason for the failure is not known.";
			case 601:
				return "An empty address was specified as input. For directions requests, this means that no query was specified in the input.";
			case 602:
				return "No corresponding geographic location could be found for the specified address. This may be due to the fact that the address is relatively new, or it may be incorrect.";
			case 603:
				return "The geocode for the given address or the route for the given directions query cannot be returned due to legal or contractual reasons.";
			case 604:
				return "The GDirections object could not compute directions between the points mentioned in the query. This is usually because there is no route available between the two points, or because we do not have data for routing in that region.";
			case 610:
				return "The given key is either invalid or does not match the domain for which it was given."
			case 620:
				return "The given key has gone over the requests limit in the 24 hour period or has submitted too many requests in too short a period of time. If you're sending multiple requests in parallel or in a tight loop, use a timer or pause in your code to make sure you don't send the requests too quickly." 
		}
		
		return "";
*/		
	};

	this.initializeCompletionStatus = function()
	{
		for (var i = 0; i < this.geocodeCount; i++)
		{
			var completionInput = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + i + ":hidden_GeocodeComplete");
			var geocodeStatus = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + i + ":hidden_GeocodeStatus").value;
			completionInput.value = (geocodeStatus == "G_GEO_SUCCESS" ? "true" : "false");
		}
	};

	this.setUpdated = function()
	{
		document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_Updated").value = "true";
		++geocoding.updatedCount;		
	};
	
	this.setCompletionStatus = function()
	{
/*	
		var completedItemId = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeItemId").value;
	
		for (var i = 0; i < this.geocodeCount; i++)
		{
			var geocodeItemId = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + i + ":hidden_GeocodeItemId").value;
			var completionInput = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + i + ":hidden_GeocodeComplete");
			completionInput.value = geocodeItemId == completedItemId ? "true" : "false";
		}
*/


		var completedItemId = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeItemId").value;
	
		for (var i = geocoding.geocodeIndex; i < this.geocodeCount; i++)
		{
			var geocodeItemId = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + i + ":hidden_GeocodeItemId").value;
			var completionInput = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + i + ":hidden_GeocodeComplete");
			
			if (completionInput.value == "true")
			{
				continue;
			}
			
			completionInput.value = (geocodeItemId == completedItemId ? "true" : "false");
		}
		
	};

	this.start = function()
	{
		if (!this.checkAnyItemsSelected())
		{
			return;
		}
				
		util.showLoadingImage();
	
		this.geocodeIndex = 0;
		this.geocodeCount = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing").rows.length - 1;
		this.updatedCount = 0;

		this.initializeCompletionStatus();

		this.createGeocoder();
		this.geocodeItem();
	};

	this.geocodeItem = function()
	{
		if (this.geocodeIndex >= this.geocodeCount)
		{
			processGeocodedItems();
			return;
		}
		
		var itemSelected = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":check_SelectedItem").checked;
		var checkBoxVisible = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":check_SelectedItem").style.visibility == "visible";
		var itemCompleted = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_GeocodeComplete").value == "true";

		if (!itemSelected || !checkBoxVisible || itemCompleted)
		{
			++this.geocodeIndex;
			this.geocodeItem();
			return;
		}

		// Google Geocoding
		//var address = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_Address").value;
		//this.geocoder.geocode({address: address,}, this.processGeocode);

		var street = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressStreet").value; 
		var city = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressCity").value;
		var state = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressState").value;
		var postalCode = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressPostalCode").value;
		var country = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressPostalCode").value;
		if (street) 
		{
			street = street.replace(/#/gi, ""); 
		}
		var address = encodeURIComponent(batchGeocoding.getAddressString(street, city, state, postalCode, country));
		util.sendGoogleGeocodeRequest(address, this.processGoogleGeocode);

		// TAMU Geocoding
		//var street = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressStreet").value;
		//var city = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressCity").value;
		//var state = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressState").value;
		//var zip = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressPostalCode").value;
		//var request = "https://geoservices.tamu.edu/Services/Geocode/WebService/GeocoderWebServiceHttpNonParsedDetailed_V04_01.aspx?" +
		//	"streetAddress=" + encodeURIComponent(street).replace(/\%/gi, "__pct__") + 
		//	"&city=" + encodeURIComponent(city).replace(/\%/gi, "__pct__") +
		//	"&state=" + encodeURIComponent(state).replace(/\%/gi, "__pct__") +
		//	"&zip=" + encodeURIComponent(zip).replace(/\%/gi, "__pct__") +
		//	"&apikey=c97a6b4cedc4445e998ffbebfb234fce&format=XML&verbose=true&census=false&notStore=true&version=4.01" +
		//	"&county=false";
		//util.sendTamuGeocodeRequest("request=" + encodeURIComponent(request), this.processTamuGeocode);

		// Yahoo Geocoding
		//var street = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressStreet").value;
		//var city = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressCity").value;
		//var state = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressState").value;
		//var postalCode = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressPostalCode").value;
		//var country = document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + this.geocodeIndex + ":hidden_AddressPostalCode").value;
		//var address = encodeURIComponent(batchGeocoding.getYahooAddressString(street, city, state, postalCode, country));
		//util.sendYahooGeocodeRequest(address, this.processYahooGeocode);
	};

	this.processYahooGeocode = function(results)
	{
		var status = "";
		var result = null;
		
		if (typeof(results.bossresponse) == "undefined" || typeof(results.bossresponse.placefinder.results) == "undefined")
		{
			status = "LOCATION_TYPE_UNMATCHABLE";
		}
		else
		{
			status = ((Number(results.bossresponse.placefinder.results[0].quality) < 70) || results.bossresponse.responsecode != "200") ? 
				"LOCATION_TYPE_UNMATCHABLE" : "G_GEO_SUCCESS";
			result = results.bossresponse.placefinder.results[0];
		}

		document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeStatus").value =
			status;

		if (status == "G_GEO_SUCCESS")
		{		
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_Latitude").value =
				result.latitude;
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_Longitude").value =
				result.longitude;
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeCounty").value =
				util.truncate(result.county, " County");
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeAccuracy").value =
				0; // not used
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeAddress").value =
				batchGeocoding.getYahooResultFormattedAddress(result);
		}
		
		geocoding.setUpdated();
		geocoding.setCompletionStatus();

		++geocoding.geocodeIndex;
		setTimeout("geocoding.geocodeItem()", 50);
	};
	
	this.processTamuGeocode = function(response)
	{
		var status = response.result;
		
		document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeStatus").value =
			geocoding.convertTamuResponseCode(status);

		if (status != "LOCATION_TYPE_UNKNOWN" &&
			status != "LOCATION_TYPE_UNMATCHABLE")
		{		
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_Latitude").value =
				response.latitude;
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_Longitude").value =
				response.longitude;
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeAccuracy").value =
				0; // not used
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeAddress").value =
				response.formattedAddress.replace(/"/gi, "'");
		}
		
		geocoding.setUpdated();
		geocoding.setCompletionStatus();

		++geocoding.geocodeIndex;
		setTimeout("geocoding.geocodeItem()", 250);
	};
	
	this.processGoogleGeocode = function(response)//results, status)
	{
	
	
//		var results = response.results;
//		var status = response.status;

		var results = response ? response.results : null;
		var status = response ? response.status : "ZERO_RESULTS";


		if (status == "OVER_QUERY_LIMIT")
		{
			alert(locale.geocodingOverLimit);
			processGeocodedItems();
			return;
		}

	
		document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeStatus").value =
			geocoding.convertResponseCode(status);

		if (status == "OK")//google.maps.GeocoderStatus.OK)
		{		
			var result = results[0];
			
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_Latitude").value =
				result.geometry.location.lat;
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_Longitude").value =
				result.geometry.location.lng;
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeCounty").value =
				 util.truncate(batchGeocoding.getGoogleUSCounty(result), " County");;
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeAccuracy").value =
				1; // not used
			document.getElementById("page_Territories:form_Territories:block_ViewListing:table_ViewListing:" + geocoding.geocodeIndex + ":hidden_GeocodeAddress").value =
				result.formatted_address.replace(/"/gi, "'");
		}
		
		geocoding.setUpdated();
		geocoding.setCompletionStatus();

		++geocoding.geocodeIndex;
		setTimeout("geocoding.geocodeItem()", 250);
	};

	this.afterProcessGeocodedItems = function()
	{
	    this.uncheckSelectAllItems();
		util.hideLoadingImage();

		if (this.updatedCount > 0)
		{		
			territories.reloadView();
		}		
	};

	this.geocodeCustomLocation = function(customLocation, processMethod)
	{
		this.createGeocoder();
		
		var locationName = customLocation.address.street;
		if (locationName == null || locationName.length == 0)
		{
			locationName = customLocation.name;
		}

//		this.geocoder.getLocations(locationName, processMethod);
		this.geocoder.geocode({address: locationName,}, processMethod);
	};
}


/////////////////////////////////////////////////////////////////////////////////////
// StreetView
/////////////////////////////////////////////////////////////////////////////////////

function StreetView()
{

	this.showStreetViewOfSelectedObject = function()
	{
		var streetViewLatLng = territories.selectedObject.address.coordinates;


		map.setCenter(streetViewLatLng);


		var panoramaOptions = {
			position: streetViewLatLng,
			enableCloseButton: true,
  			pov: {
    			heading: 34,
    			pitch: 10
  			},
		};
				
		var panorama = new google.maps.StreetViewPanorama(getMapCanvas(), panoramaOptions);
		map.setStreetView(panorama);
	};

/*
	this.getContentDiv = function()
	{
		this.contentDiv = document.createElement("div");
		this.contentDiv.style.width = "656px";
		this.contentDiv.style.height = "100%";

		return this.contentDiv;
	};

	this.openStreetView = function()
	{
		streetView.getStreetViewClient().getNearestPanoramaLatLng(territories.selectedObject.address.coordinates,
			streetView.processPanoramaLookup);
	};

	this.closeStreetView = function()
	{
		if (util.isDefined(this.streetViewPanorama) &&
			this.streetViewPanorama != null)
		{
			this.streetViewPanorama.hide();
			this.streetViewPanorama.remove();
		}
	
		if (util.isDefined(this.contentDiv) &&
			this.contentDiv != null)
		{
			if (this.contentDiv.parentNode != null)
			{
				this.contentDiv.parentNode.removeChild(this.contentDiv);
			}
		}
	}

	this.showStreetViewOfSelectedObject = function()
	{
		map.getInfoWindow().maximize();
	};
	
	this.processPanoramaLookup = function(latlng)
	{
		if (latlng == null)
		{
			streetView.contentDiv.style.textAlign = "center";
			streetView.contentDiv.style.color = "dimgray";
			streetView.contentDiv.style.marginTop = "40px";
			streetView.contentDiv.innerHTML = locale.noStreetView;//"Google Maps has no Street View for this location.";
		}
		else
		{
			streetView.streetViewPanorama = new GStreetviewPanorama(streetView.contentDiv);
			
			google.maps.event.addListener(streetView.streetViewPanorama, "error", 
				function(errorCode)
				{
			  		if (errorCode == 603)
			  		{
			  			streetView.contentDiv.innerHTML = 
			  				"StreetView requires Adobe Flash plugin. Click <a href='http://get.adobe.com/flashplayer/' target='_blank'>here</a> to download."
			    		return;
			  		}
				}
			);

			streetView.streetViewPanorama.setLocationAndPOV(latlng);
		}
	};

	this.getStreetViewClient = function()
	{
		if (!util.isDefined(this.streetViewClient))
		{
			this.streetViewClient = new GStreetviewClient();
		}
		
		return this.streetViewClient;
	}
*/

}

/////////////////////////////////////////////////////////////////////////////////////
// TrafficControl
/////////////////////////////////////////////////////////////////////////////////////

function TrafficControl(controlDiv)
{
	this.layerVisible = false;
	
	controlDiv.style.padding = '5px';

	var controlUI = document.createElement('div');
	controlUI.style.backgroundColor = 'white';
	controlUI.style.border = '1px solid darkgray';
	controlUI.style.borderWidth = '1px';
	controlUI.style.cursor = 'pointer';
	controlUI.style.textAlign = 'center';
	controlUI.title = 'Traffic Layer';
	controlDiv.appendChild(controlUI);

	var controlText = document.createElement('div');
  	controlText.style.fontFamily = 'Arial,sans-serif';
  	controlText.style.color = "#666666";
  	controlText.style.fontSize = '11px';
  	controlText.style.padding = '2px 6px';
  	controlText.innerHTML = 'Traffic';
  	controlUI.appendChild(controlText);

	var _this = this;
	google.maps.event.addDomListener(controlUI, 'click', function() 
	{
		if (_this.layerVisible)
		{
			controlUI.style.backgroundColor = "white";
			controlText.style.color = "#666666";
			
			trafficLayer.setMap(null);
	    	_this.layerVisible = false;
		}
		else
		{
			controlUI.style.backgroundColor = "darkgray";
			controlText.style.color = "white";
		
			trafficLayer.setMap(map);
	    	_this.layerVisible = true;
		}
  	});
}

/////////////////////////////////////////////////////////////////////////////////////
// TransitControl
/////////////////////////////////////////////////////////////////////////////////////

function TransitControl(controlDiv)
{
	this.layerVisible = false;
	
	controlDiv.style.padding = '5px';

	var controlUI = document.createElement('div');
	controlUI.style.backgroundColor = 'white';
	controlUI.style.border = '1px solid darkgray';
	controlUI.style.borderWidth = '1px';
	controlUI.style.cursor = 'pointer';
	controlUI.style.textAlign = 'center';
	controlUI.title = 'Transit Layer';
	controlDiv.appendChild(controlUI);

	var controlText = document.createElement('div');
  	controlText.style.fontFamily = 'Arial,sans-serif';
  	controlText.style.color = "#666666";
  	controlText.style.fontSize = '11px';
  	controlText.style.padding = '2px 6px';
  	controlText.innerHTML = 'Transit';
  	controlUI.appendChild(controlText);

	var _this = this;
	google.maps.event.addDomListener(controlUI, 'click', function() 
	{
		if (_this.layerVisible)
		{
			controlUI.style.backgroundColor = "white";
			controlText.style.color = "#666666";
			
			transitLayer.setMap(null);
	    	_this.layerVisible = false;
		}
		else
		{
			controlUI.style.backgroundColor = "darkgray";
			controlText.style.color = "white";
		
			transitLayer.setMap(map);
	    	_this.layerVisible = true;
		}
  	});
}

/////////////////////////////////////////////////////////////////////////////////////
// WeatherControl
/////////////////////////////////////////////////////////////////////////////////////

function WeatherControl(controlDiv)
{
	this.layerVisible = false;
	
	controlDiv.style.padding = '5px';

	var controlUI = document.createElement('div');
	controlUI.style.backgroundColor = 'white';
	controlUI.style.border = '1px solid darkgray';
	controlUI.style.borderWidth = '1px';
	controlUI.style.cursor = 'pointer';
	controlUI.style.textAlign = 'center';
	controlUI.title = 'Weather Layer';
	controlDiv.appendChild(controlUI);

	var controlText = document.createElement('div');
  	controlText.style.fontFamily = 'Arial,sans-serif';
  	controlText.style.color = "#666666";
  	controlText.style.fontSize = '11px';
  	controlText.style.padding = '2px 6px';
  	controlText.innerHTML = 'Weather';
  	controlUI.appendChild(controlText);

	var _this = this;
	google.maps.event.addDomListener(controlUI, 'click', function() 
	{
		if (_this.layerVisible)
		{
			controlUI.style.backgroundColor = "white";
			controlText.style.color = "#666666";
			
			weatherLayer.setMap(null);
			cloudLayer.setMap(null);
	    	_this.layerVisible = false;
		}
		else
		{
			controlUI.style.backgroundColor = "darkgray";
			controlText.style.color = "white";
		
			weatherLayer.setMap(map);
			cloudLayer.setMap(map);
	    	_this.layerVisible = true;
		}
  	});
}

/////////////////////////////////////////////////////////////////////////////////////
// View
/////////////////////////////////////////////////////////////////////////////////////
function View()
{
	this.accounts = null;
	this.leads = null;
	this.contacts = null;
	this.customLocations = null;
	this.users = null;
	this.customObjects = null;
	this.displayFieldNames = null;
	this.displayFieldLabels = null;

	this.owner = null;

	this.DEFAULT_MARKER_COLOR = "#FF776B";

	this.initialize = function()
	{
		this.accounts = [];
		this.leads = [];
		this.contacts = [];
		this.customLocations = [];
		this.users = [];
		this.customObjects = [];
		this.displayFieldNames = [];
		this.displayFieldLabels = [];
		this.displayFieldTypes = [];
	
		var overLimit = document.getElementById("page_Territories:form_Territories:hidden_OverLimit").value == "true" ? true : false;

		if (overLimit)
		{
			return false;
		}
		
		this.definition = document.getElementById('page_Territories:form_Territories:hidden_ViewDefinition').value;
		this.type = document.getElementById('page_Territories:form_Territories:hidden_ViewType').value;
		this.id = document.getElementById("page_Territories:form_Territories:hidden_ViewId").value;
		this.name = document.getElementById("page_Territories:form_Territories:hidden_ViewName").value;
		this.viewObject = document.getElementById("page_Territories:form_Territories:hidden_ViewObject").value;
		this.viewObjectLabel = document.getElementById("page_Territories:form_Territories:hidden_ViewObjectLabel").value;
		this.viewObjectPlural = document.getElementById("page_Territories:form_Territories:hidden_ViewObjectPlural").value;
		this.selectedAccountId = document.getElementById("page_Territories:form_Territories:hidden_SelectedAccountId").value;
		this.selectedAccountName = document.getElementById("page_Territories:form_Territories:hidden_SelectedAccountName").value;
		this.selectedViewId = document.getElementById("page_Territories:form_Territories:hidden_SelectedViewId").value;
		this.selectedTripId = document.getElementById("page_Territories:form_Territories:hidden_SelectedTripId").value;
		this.showUserMarkers = document.getElementById("page_Territories:form_Territories:hidden_ShowUserMarkers").value == "true" ? true : false;
		this.ownerId = document.getElementById("page_Territories:form_Territories:hidden_ViewOwnerId").value;
		this.showOwnerMarker = document.getElementById("page_Territories:form_Territories:hidden_ShowOwnerMarker").value == "true" ? true : false;
		this.userMarkerColor = document.getElementById("page_Territories:form_Territories:hidden_UserMarkerColor").value;
		this.userMapIcon = document.getElementById("page_Territories:form_Territories:hidden_UserMapIcon").value;		
		this.customLocationMarkerColor = document.getElementById("page_Territories:form_Territories:hidden_CustomLocationMarkerColor").value;
		this.customLocationMapIcon = document.getElementById("page_Territories:form_Territories:hidden_CustomLocationMapIcon").value;
		this.mapAddressType = document.getElementById("page_Territories:form_Territories:hidden_MapAddressType").value; 
		this.multiFieldFilterWhereClause = document.getElementById("page_Territories:form_Territories:hidden_MultiFieldFilterWhereClause").value;
		this.singleFieldFilterWhereClause = document.getElementById("page_Territories:form_Territories:hidden_SingleFieldFilterWhereClause").value;
		this.useFilterColorScheme = document.getElementById("page_Territories:form_Territories:hidden_UseFilterColorScheme").value;
		this.multiObjectMarkerColor = document.getElementById("page_Territories:form_Territories:hidden_MultiObjectMarkerColor").value;
		this.multiObjectMapIcon = document.getElementById("page_Territories:form_Territories:hidden_MultiObjectMapIcon").value;
		this.showAccountRelatedObjects = document.getElementById("page_Territories:form_Territories:hidden_ShowAccountRelatedObjects").value == "true" ? true : false;
		this.showOpenOpportunities = document.getElementById("page_Territories:form_Territories:hidden_ShowOpenOpportunities").value == "true" ? true : false;
		this.showContacts = document.getElementById("page_Territories:form_Territories:hidden_ShowContacts").value == "true" ? true : false;
		this.useContactAddress = document.getElementById("page_Territories:form_Territories:hidden_UseContactAddress").value == "true" ? true : false;
		this.useShortLegend = document.getElementById("page_Territories:form_Territories:hidden_UseShortLegend").value == "true" ? true : false;		
		this.viewMapType = document.getElementById("page_Territories:form_Territories:hidden_ViewMapType").value; 
		this.viewMapCenterLatitude = document.getElementById("page_Territories:form_Territories:hidden_ViewMapCenterLatitude").value;
		this.viewMapCenterLongitude = document.getElementById("page_Territories:form_Territories:hidden_ViewMapCenterLongitude").value;
		this.viewMapZoom = document.getElementById("page_Territories:form_Territories:hidden_ViewMapZoom").value;
		this.retainViewColors = document.getElementById("page_Territories:form_Territories:hidden_RetainViewColors").value == "true";
		this.masterDetailRelationshipName = document.getElementById("page_Territories:form_Territories:hidden_MasterDetailRelationshipName").value;

		this.isCustomObjectView = document.getElementById("page_Territories:form_Territories:hidden_IsCustomObjectView").value == "true" ? true : false;
		this.customObjectUseLookupField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectUseLookupField").value == "true" ? true : false;
		this.customObjectLookupField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectLookupField").value;
		this.customObjectLookupFieldType = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectLookupFieldType").value;
		this.customObjectLookupRelationshipName = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectLookupRelationshipName").value;
		this.customObjectName = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectName").value;
		this.customObjectLabel = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectLabel").value;
		this.customObjectNameField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectNameField").value;
		this.customObjectStreetField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectStreetField").value;
		this.customObjectCityField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectCityField").value;
		this.customObjectStateField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectStateField").value;
		this.customObjectPostalCodeField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectPostalCodeField").value;
		this.customObjectCountryField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectCountryField").value;
		this.customObjectGeocodeStatusField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectGeocodeStatusField").value;
		this.customObjectGeocodeAddressField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectGeocodeAddressField").value;
		this.customObjectGeocodeAccuracyField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectGeocodeAccuracyField").value;
		this.customObjectLatitudeField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectLatitudeField").value;
		this.customObjectLongitudeField = document.getElementById("page_Territories:form_Territories:hidden_CustomObjectLongitudeField").value;

		this.parentRelationship = document.getElementById("page_Territories:form_Territories:hidden_ParentRelationship").value;
		
		this.limitMarkersToOutlines = document.getElementById("page_Territories:form_Territories:hidden_LimitMarkersToShapes").value == "true" ? true : false;;
		

		var displayField1Name = document.getElementById("page_Territories:form_Territories:hidden_DisplayField1Name").value;
		if (displayField1Name != null && displayField1Name.length > 0) this.displayFieldNames.push(displayField1Name);
		var displayField2Name = document.getElementById("page_Territories:form_Territories:hidden_DisplayField2Name").value;
		if (displayField2Name != null && displayField2Name.length > 0) this.displayFieldNames.push(displayField2Name);
		var displayField3Name = document.getElementById("page_Territories:form_Territories:hidden_DisplayField3Name").value;
		if (displayField3Name != null && displayField3Name.length > 0) this.displayFieldNames.push(displayField3Name);
		var displayField4Name = document.getElementById("page_Territories:form_Territories:hidden_DisplayField4Name").value;
		if (displayField4Name != null && displayField4Name.length > 0) this.displayFieldNames.push(displayField4Name);
		var displayField5Name = document.getElementById("page_Territories:form_Territories:hidden_DisplayField5Name").value;
		if (displayField5Name != null && displayField5Name.length > 0) this.displayFieldNames.push(displayField5Name);

		var displayField1Label = document.getElementById("page_Territories:form_Territories:hidden_DisplayField1Label").value;
		if (displayField1Label != null && displayField1Label.length > 0) this.displayFieldLabels.push(displayField1Label);
		var displayField2Label = document.getElementById("page_Territories:form_Territories:hidden_DisplayField2Label").value;
		if (displayField2Label != null && displayField2Label.length > 0) this.displayFieldLabels.push(displayField2Label);
		var displayField3Label = document.getElementById("page_Territories:form_Territories:hidden_DisplayField3Label").value;
		if (displayField3Label != null && displayField3Label.length > 0) this.displayFieldLabels.push(displayField3Label);
		var displayField4Label = document.getElementById("page_Territories:form_Territories:hidden_DisplayField4Label").value;
		if (displayField4Label != null && displayField4Label.length > 0) this.displayFieldLabels.push(displayField4Label);
		var displayField5Label = document.getElementById("page_Territories:form_Territories:hidden_DisplayField5Label").value;
		if (displayField5Label != null && displayField5Label.length > 0) this.displayFieldLabels.push(displayField5Label);

		var displayField1Type = document.getElementById("page_Territories:form_Territories:hidden_DisplayField1Type").value;
		if (displayField1Type != null && displayField1Type.length > 0) this.displayFieldTypes.push(displayField1Type);
		var displayField2Type = document.getElementById("page_Territories:form_Territories:hidden_DisplayField2Type").value;
		if (displayField2Type != null && displayField2Type.length > 0) this.displayFieldTypes.push(displayField2Type);
		var displayField3Type = document.getElementById("page_Territories:form_Territories:hidden_DisplayField3Type").value;
		if (displayField3Type != null && displayField3Type.length > 0) this.displayFieldTypes.push(displayField3Type);
		var displayField4Type = document.getElementById("page_Territories:form_Territories:hidden_DisplayField4Type").value;
		if (displayField4Type != null && displayField4Type.length > 0) this.displayFieldTypes.push(displayField4Type);
		var displayField5Type = document.getElementById("page_Territories:form_Territories:hidden_DisplayField5Type").value;
		if (displayField5Type != null && displayField5Type.length > 0) this.displayFieldTypes.push(displayField5Type);

		for (var i = 0; i < this.displayFieldNames.length; i++)
		{
			var displayFieldType = this.displayFieldTypes[i];
			if (displayFieldType == "Number" || displayFieldType == "Currency")
			{
				var displayFieldName = this.displayFieldNames[i];
				 
				this[displayFieldName] = [{areas:[]}, {areas:[]}]; // state and zip
				this[displayFieldName][0].overallMin = {count: 0, min: Infinity, max: Infinity, avg: Infinity, total: Infinity};
				this[displayFieldName][0].overallMax = {count: 0, min: -Infinity, max: -Infinity, avg: -Infinity, total: -Infinity};
				this[displayFieldName][1].overallMin = {count: 0, min: Infinity, max: Infinity, avg: Infinity, total: Infinity}; 
				this[displayFieldName][1].overallMax = {count: 0, min: -Infinity, max: -Infinity, avg: -Infinity, total: -Infinity}; 
			}
		}
		
		return true;
	};

	this.onSaveOutlines = function()
	{
		util.showLoadingImage();
		outlines.onCloseOutlines();
		this.limitMarkersToOutlines = document.getElementById("page_Territories:form_Territories:block_Outlines:check_LimitMarkersToOutlines").checked ? true : false;
		
		saveOutlines(this.limitMarkersToOutlines);
	};
	
	this.onOpenOutlines = function()
	{
		document.getElementById("page_Territories:form_Territories:block_Outlines:check_LimitMarkersToOutlines").checked =
			this.limitMarkersToOutlines ? "checked" : null;
	
	};

	this.saveStatistics = function()
	{	
		if (this.isCustomObjectView)
		{
			if (this.customObjectUseLookupField)
			{
				if (this.customObjectLookupFieldType == "Account")
				{
					this.saveChildStatistics("customObjects", "accounts");
				}
				else if (this.customObjectLookupFieldType == "Contact")
				{
					this.saveChildStatistics("customObjects", "contacts");
				}
				else if (this.customObjectLookupFieldType == "Lead")
				{
					this.saveChildStatistics("customObjects", "leads");
				}
			}
		}
		else
		{
			if (this.viewObject == "Opportunity")
			{
				this.saveChildStatistics("opportunities", "accounts");
			}
			else if (this.viewObject == "Case")
			{
				this.saveChildStatistics("cases", "accounts");
			}
			else if (this.viewObject == "Asset")
			{
				this.saveChildStatistics("assets", "accounts");
			}
			else if (this.viewObject == "Contract")
			{
				this.saveChildStatistics("contracts", "accounts");
			}
			else if (this.viewObject == "Event")
			{
				this.saveChildStatistics("events", "accounts");
			}
			else if (this.viewObject == "Task")
			{
				this.saveChildStatistics("tasks", "accounts");
			}
			else if (this.viewObject == "Contact" && !this.useContactAddress)
			{
				this.saveChildStatistics("contacts", "accounts");
			}
			else
			{
				this.saveChildStatistics("standardObjects", "accounts");
			}
		}
	}
	
	
	this.isAccountBasedView = function()
	{
		return (this.type == "Single Role" || this.type == "Multiple Role" || this.type == "List Based") &&
			this.viewObject == "Account";
	};

	this.isContactBasedView = function()
	{
		return this.viewObject == "Contact";
	};

	this.isLeadBasedView = function()
	{
		return this.viewObject == "Lead";
	};
	
	this.isCampaignView = function()
	{
		return this.viewObject == "CampaignMember";
	};
	
	this.getParentRelationshipName = function()
	{
		if (this.parentRelationship == null || this.parentRelationship.length == 0)
		{
			return null;
		}
		
		return this.parentRelationship.split(separator.para)[2];
	};

	this.getParentRelationshipLabel = function()
	{
		if (this.parentRelationship == null || this.parentRelationship.length == 0)
		{
			return null;
		}
		
		return this.parentRelationship.split(separator.para)[3];
	};

	this.getDisplayFieldNames = function()
	{
		var displayFieldNames = "";	
	
		for (var i = 0; i < this.displayFieldNames.length; i++)
		{
			displayFieldNames += ", " + this.displayFieldNames[i];
		}
		
		return displayFieldNames;
	};
	
	this.findDisplayField = function(displayFieldName)
	{
		for (var i = 0; i < this.displayFieldNames.length; i++)
		{
			if (this.displayFieldNames[i] == displayFieldName)
			{
				return this.displayFieldNames[i];
			}
		}
		
		return null;
	};
	
	this.beforeSaveViewState = function()
	{
		util.showLoadingImage();

		document.getElementById("page_Territories:form_Territories:hidden_ViewMapType").value =
			util.getV2MapType(map.getMapTypeId());
			//util.getMapTypeFromName(map.getCurrentMapType().getName());
		document.getElementById("page_Territories:form_Territories:hidden_ViewMapCenterLatitude").value =
			String(map.getCenter().lat());
		document.getElementById("page_Territories:form_Territories:hidden_ViewMapCenterLongitude").value =
			String(map.getCenter().lng());
		document.getElementById("page_Territories:form_Territories:hidden_ViewMapZoom").value =
			map.getZoom(); 
	};
	
	this.afterSaveViewState = function()
	{
		this.viewMapType = document.getElementById("page_Territories:form_Territories:hidden_ViewMapType").value; 
		this.viewMapCenterLatitude = document.getElementById("page_Territories:form_Territories:hidden_ViewMapCenterLatitude").value;
		this.viewMapCenterLongitude = document.getElementById("page_Territories:form_Territories:hidden_ViewMapCenterLongitude").value;
		this.viewMapZoom = document.getElementById("page_Territories:form_Territories:hidden_ViewMapZoom").value;
	
		util.hideLoadingImage();
		alert(locale.viewStateSaved);
	};
		
	this.setMapState = function()
	{
		if (this.viewMapType != null && this.viewMapType.length != 0)
		{
			territories.resetMapFromViewState();
	    }
	    else
	    {
	    	territories.resetMap();
	    }
	};

	this.hideLegend = function()
	{
		$("#colorLegendSide").hide();
	};
	
	this.showLegend = function()
	{
		$("#colorLegendSide").empty();
		
		if (this.useShortLegend)
		{
			$("#colorLegend").detach().appendTo($("#colorLegendSide"));	
			$("#colorLegendSide").show();
		}
		else
		{
			$("#fullLegend").show();
		}
	
	};
	
	
	this.pointInOutlines = function(point)
	{
		for (var i = 0; i < outlines.outlines.length; i++)
		{
			if (outlines.outlines[i].containsPoint(point))
			{
				return true;
			}
		}

		for (var i = 0; i < outlines.readOnlyOutlines.length; i++)
		{
			if (outlines.readOnlyOutlines[i].containsPoint(point))
			{
				return true;
			}
		}
		
		return false;
	
	};
	
	this.refreshMarkers = function()
	{
		this.hideMarkers();
		this.showMarkers();
	};
	
	this.showMarker = function(viewObject)
	{
		return (!this.limitMarkersToOutlines || this.pointInOutlines(viewObject.address.coordinates))
	};
	
	this.showMarkers = function()
	{
		for (var i = 0; i < this.accounts.length; i++)
		{
			if (!this.accounts[i].isDuplicateLocation)
			{
				if (this.showMarker(this.accounts[i]))
				{
					this.accounts[i].marker.setMap(map);
				}
			}
		}
		for (var i = 0; i < this.leads.length; i++)
		{
			if (!this.leads[i].isDuplicateLocation)
			{
				if (this.showMarker(this.leads[i]))
				{
					this.leads[i].marker.setMap(map);
				}
			}
		}
		for (var i = 0; i < this.contacts.length; i++)
		{
			if (!this.contacts[i].isDuplicateLocation)
			{
				if (this.showMarker(this.contacts[i]))
				{
					this.contacts[i].marker.setMap(map);
				}
			}
		}
		for (var i = 0; i < this.customObjects.length; i++)
		{
			if (!this.customObjects[i].isDuplicateLocation)
			{
				if (this.showMarker(this.customObjects[i]))
				{
					this.customObjects[i].marker.setMap(map);
				}
			}
		}
		for (var i = 0; i < this.users.length; i++)
		{
			if (this.showMarker(this.users[i]))
			{
				this.users[i].marker.setMap(map);
			}
		}
		for (var i = 0; i < this.customLocations.length; i++)
		{
		
			if (this.showMarker(this.customLocations[i]))
			{
				this.customLocations[i].marker.setMap(map);
			}
		}	
	};
	
	this.hideMarkers = function()
	{
		for (var i = 0; i < this.accounts.length; i++)
		{
			if (!this.accounts[i].isDuplicateLocation)
			{
				this.accounts[i].marker.setMap(null);
			}
		}
		for (var i = 0; i < this.leads.length; i++)
		{
			if (!this.leads[i].isDuplicateLocation)
			{
				this.leads[i].marker.setMap(null);
			}
		}
		for (var i = 0; i < this.contacts.length; i++)
		{
			if (!this.contacts[i].isDuplicateLocation)
			{
				this.contacts[i].marker.setMap(null);
			}
		}
		for (var i = 0; i < this.customObjects.length; i++)
		{
			if (!this.customObjects[i].isDuplicateLocation)
			{
				this.customObjects[i].marker.setMap(null);
			}
		}
		for (var i = 0; i < this.users.length; i++)
		{
			this.users[i].marker.setMap(null);
		}
		for (var i = 0; i < this.customLocations.length; i++)
		{
			this.customLocations[i].marker.setMap(null);
		}	
	};
	
	
	this.getType = function()
	{
	
	};

	this.findObject = function(objectId)
	{
		var customLocation = this.findCustomLocation(objectId);
		
		if (customLocation != null)
		{
			return customLocation;
		}
	
		var prefix = objectId.substr(0, 3);
		
		if (prefix == '001')
		{
			return this.findAccount(objectId);
		}
		else if (prefix == '005')
		{
			return this.findUser(objectId);
		}
		else if (prefix == '00Q')
		{
			return this.findLead(objectId);
		}
		else if (prefix == '003')
		{
			return this.findContact(objectId);
		}
		else
		{
			return this.findCustomObject(objectId);
		}
		
		return null;
	};

	this.findCustomLocation = function(customLocationId)
	{
		for (var i = 0; i < this.customLocations.length; i++)
		{
			if (this.customLocations[i].id == customLocationId)
			{
				return this.customLocations[i];
			}
		}
		
		return null;
	};

	this.findAccount = function(accountId)
	{
		for (var i = 0; i < this.accounts.length; i++)
		{
			if (this.accounts[i].id == accountId)
			{
				return this.accounts[i];
			}
		}
		
		return null;
	};

	this.findUser = function(userId)
	{
		for (var i = 0; i < this.users.length; i++)
		{
			if (this.users[i].id == userId)
			{
				return this.users[i];
			}
		}
		
		return null;
	};

	this.findLead = function(leadId)
	{
		for (var i = 0; i < this.leads.length; i++)
		{
			if (this.leads[i].id == leadId)
			{
				return this.leads[i];
			}
		}
		
		return null;
	};

	this.findContact = function(contactId)
	{
		for (var i = 0; i < this.contacts.length; i++)
		{
			if (this.contacts[i].id == contactId)
			{
				return this.contacts[i];
			}
		}
	
		return null;
	};
		
	this.findCustomObject = function(customObjectId)
	{
		for (var i = 0; i < this.customObjects.length; i++)
		{
			if (this.customObjects[i].id == customObjectId)
			{
				return this.customObjects[i];
			}
		}
	
		return null;
	};
	
	this.appendMultiFieldFilterWhereClause = function(whereClause)
	{
		var appendedClause = whereClause;
		
		if (whereClause.length > 0 && this.multiFieldFilterWhereClause.length > 0)
		{
			appendedClause += " AND ";
		}
		
		appendedClause += this.multiFieldFilterWhereClause;
		
		return appendedClause;
	};

	this.appendSingleFieldFilterWhereClause = function(whereClause)
	{
		var appendedClause = whereClause;

		var singleFieldFilterWhereClause = this.parseSingleFieldFilterWhereClause();
		
		if (whereClause.length > 0 && singleFieldFilterWhereClause.length > 0)
		{
			appendedClause += " AND ";
		}
		
		appendedClause += singleFieldFilterWhereClause;
		
		return appendedClause;
	};
	
	this.parseSingleFieldFilterWhereClause = function()
	{
		if (this.singleFieldFilterWhereClause.length == 0)
		{
			return "";
		}
		
		var whereClauseDefinitions = this.singleFieldFilterWhereClause.split(separator.section);
		var whereClause = "((";
				
		for (var i = 0; i < whereClauseDefinitions.length; i++)
		{
			var whereClauseParts = whereClauseDefinitions[i].split(separator.para);
			
			if (i > 0)
			{
				whereClause += ") OR (";
			}

			var filterWhereClause = (whereClauseParts.length < 3) ? whereClauseParts[1] : whereClauseParts[2];
			whereClause += filterWhereClause;
		}
		
		whereClause += "))";
		
		return whereClause;
	};
	
	this.parseColorsAndWhereClauses = function(colors, mapIcons, whereClauses, color, mapIcon, whereClause)
	{
		if (this.useFilterColorScheme == "true" &&
			this.singleFieldFilterWhereClause.length > 0)
		{
			var whereClauseDefinitions = this.singleFieldFilterWhereClause.split(separator.section);
			
			for (var i = 0; i < whereClauseDefinitions.length; i++)
			{
				var whereClauseParts = whereClauseDefinitions[i].split(separator.para);

				var filterColor = whereClauseParts[0];
				var filterMapIcon = (whereClauseParts.length < 3) ? null : whereClauseParts[1];
				var filterWhereClause = (whereClauseParts.length < 3) ? whereClauseParts[1] : whereClauseParts[2];
	
				colors.push(filterColor);
				mapIcons.push(filterMapIcon);

				whereClauses.push((whereClause.length > 0 ? whereClause + " AND " : "") + filterWhereClause);
			}
		}
		else
		{
			colors.push(color);
			mapIcons.push(mapIcon);
			whereClauses.push(this.appendSingleFieldFilterWhereClause(whereClause));
		}
	};
	
	this.loadMapObjects = function(colors, mapIcons, whereClauses, view)
	{
		var relationshipName = this.getParentRelationshipName();
	    var queryString;
	
		for (var i = 0; i < whereClauses.length; i++)
		{
			var whereClause = (whereClauses[i] == "" ? "" : " AND " + whereClauses[i]);
			
			if (this.viewObject == "Account")
			{
			    if (this.mapAddressType == "Shipping")
			    {
				    queryString = "SELECT Id, Name, pexmaps__Shipping_Latitude__c, " +
				    	"pexmaps__Shipping_Longitude__c, pexmaps__Shipping_Geocode_Status__c, ShippingStreet, " +
				    	"ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, " +
				    	"pexmaps__Shipping_Geocode_Accuracy__c, pexmaps__Shipping_Geocode_Address__c " +
				    	this.getDisplayFieldNames() +
				    	" FROM Account WHERE pexmaps__Shipping_Geocode_Status__c = \'G_GEO_SUCCESS\'" +
				    	whereClause;
				}	
				else
				{
				    queryString = "SELECT Id, Name, pexmaps__Billing_Latitude__c, " +
				    	"pexmaps__Billing_Longitude__c, pexmaps__Billing_Geocode_Status__c, BillingStreet, " +
				    	"BillingCity, BillingState, BillingPostalCode, BillingCountry, " +
				    	"pexmaps__Billing_Geocode_Accuracy__c, pexmaps__Billing_Geocode_Address__c " +
				    	this.getDisplayFieldNames() +
				    	" FROM Account WHERE pexmaps__Billing_Geocode_Status__c = \'G_GEO_SUCCESS\'" +
				    	whereClause;
				}

				view.accounts = view.accounts.concat(this.loadAccounts(colors[i], mapIcons[i], queryString, view));
			}
			else if (this.viewObject == "Opportunity")
			{
				var relationship = relationshipName == null ? "Account" : relationshipName;

			    queryString = "SELECT Id, Name, " +
			    	relationship + ".Id, " +
			    	relationship + ".Name " +
			    	this.getDisplayFieldNames() +
			    	" FROM Opportunity WHERE " +
			    	relationship + ".Id != null AND " +
			    	relationship + ".pexmaps__Billing_Geocode_Status__c = \'G_GEO_SUCCESS\'" +
				    whereClause + " ORDER BY Name";

				this.loadOpportunities(colors[i], mapIcons[i], queryString, view);
			}
			else if (this.viewObject == "User")
			{
			    queryString = "SELECT Id, Name, pexmaps__Latitude__c, " +
			    	"pexmaps__Longitude__c, pexmaps__Geocode_Status__c, Street, " +
			    	"City, State, PostalCode, Country, pexmaps__Geocode_Accuracy__c, " +
			    	"pexmaps__Geocode_Address__c " +
			    	this.getDisplayFieldNames() +
			    	" FROM User WHERE pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\'" +
			    	whereClause;
		
				view.users = view.users.concat(this.loadUserViewUsers(colors[i], mapIcons[i], queryString));
			}
			else if (this.viewObject == "Lead")
			{
				var companyIsDisplayedField = this.findDisplayField("Company") != null;
				var phoneIsDisplayedField = this.findDisplayField("Phone") != null;
				var mobilePhoneIsDisplayedField = this.findDisplayField("MobilePhone") != null;

			    queryString = "SELECT Id, Name, " + (!companyIsDisplayedField ? "Company, " : "") + 
			    	(!phoneIsDisplayedField ? "Phone, " : "") +
			    	(!mobilePhoneIsDisplayedField ? "MobilePhone, " : "") +
			    	"pexmaps__Latitude__c, " +
			    	"pexmaps__Longitude__c, pexmaps__Geocode_Status__c, Street, " +
			    	"City, State, PostalCode, Country, pexmaps__Geocode_Accuracy__c, " +
			    	"pexmaps__Geocode_Address__c " +
			    	this.getDisplayFieldNames() +
			    	" FROM Lead WHERE IsConverted = false AND pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\'" +
			    	whereClause;
		
		
				view.leads = view.leads.concat(this.loadLeads(colors[i], mapIcons[i], queryString, view));
				
			}
			else if (this.viewObject == "Contact")
			{
				if (this.useContactAddress)
				{
				    queryString = "SELECT Id, Name, Account.Id, Account.Name, pexmaps__Latitude__c, pexmaps__Longitude__c, " +
				    	"pexmaps__Geocode_Status__c, MailingStreet, " +
				    	"MailingCity, MailingState, MailingPostalCode, MailingCountry, " +
				    	"pexmaps__Geocode_Accuracy__c, pexmaps__Geocode_Address__c " +
			    		this.getDisplayFieldNames() +
				    	" FROM Contact WHERE pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\'" +
				    	whereClause;
				}
				else
				{
				    queryString = "SELECT Id, Name, Account.Id, Account.Name, Account.pexmaps__Billing_Geocode_Status__c, " +
				    	"pexmaps__Latitude__c, pexmaps__Longitude__c, pexmaps__Geocode_Status__c, MailingStreet, " +
				    	"MailingCity, MailingState, MailingPostalCode, MailingCountry, " +
				    	"pexmaps__Geocode_Accuracy__c, pexmaps__Geocode_Address__c " +
			    		this.getDisplayFieldNames() +
			    		" FROM Contact WHERE ((AccountId != null AND Account.pexmaps__Billing_Geocode_Status__c = \'G_GEO_SUCCESS\') " +
				    	"OR (AccountId = null AND pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\'))" +
				    	whereClause;
				}
				
				view.contacts = view.contacts.concat(this.loadContacts(colors[i], mapIcons[i], queryString, view));
			}
			else if (this.viewObject == "Asset")
			{
				var relationship = relationshipName == null ? "Account" : relationshipName;

			    queryString = "SELECT Id, Name, " +
			    	relationship + ".Id, " +
			    	relationship + ".Name " +
			    	this.getDisplayFieldNames() +
			    	" FROM Asset WHERE " +
			    	relationship + ".Id != null AND " +
			    	relationship + ".pexmaps__" + this.mapAddressType + "_Geocode_Status__c = \'G_GEO_SUCCESS\'" +
				    whereClause + " ORDER BY Name";
				
				this.loadAssets(colors[i], mapIcons[i], queryString, view);
			}
			else if (this.viewObject == "Case")
			{
			    queryString = "SELECT Id, CaseNumber, AccountId, Account.Name, ContactId, Contact.Name " +
			    	this.getDisplayFieldNames() +
			    	" FROM Case WHERE ((AccountId != null AND Account.pexmaps__Billing_Geocode_Status__c = \'G_GEO_SUCCESS\') " +
			    		"OR (AccountId = null AND Contact.pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\'))" +
			    	whereClause + " ORDER BY CaseNumber";

				this.loadCases(colors[i], mapIcons[i], queryString, view);
			}
			else if (this.viewObject == "Contract")
			{
				var relationship = relationshipName == null ? "Account" : relationshipName;

			    queryString = "SELECT Id, ContractNumber, " +
			    	relationship + ".Id, " +
			    	relationship + ".Name " +
			    	this.getDisplayFieldNames() +
			    	" FROM Contract WHERE " +
			    	relationship + ".Id != null AND " +
			    	relationship + ".pexmaps__Billing_Geocode_Status__c = \'G_GEO_SUCCESS\'" +
				    whereClause + " ORDER BY ContractNumber";
				
				this.loadContracts(colors[i], mapIcons[i], queryString, view);
			}
			else if (this.viewObject == "Task")
			{
			    queryString = "SELECT Id, Subject, Account.Id, Account.Name " +
			    	this.getDisplayFieldNames() +
			    	" FROM Task WHERE Account.pexmaps__" + this.mapAddressType + "_Geocode_Status__c = \'G_GEO_SUCCESS\' " +
			    	whereClause + " ORDER BY Subject";

				this.loadTasks(colors[i], mapIcons[i], queryString, view);
			}
			else if (this.viewObject == "Event")
			{
			    queryString = "SELECT Id, Subject, Account.Id, Account.Name " +
			    	this.getDisplayFieldNames() +
			    	" FROM Event WHERE Account.pexmaps__" + this.mapAddressType + "_Geocode_Status__c = \'G_GEO_SUCCESS\' " +
			    	whereClause + " ORDER BY Subject";

				this.loadEvents(colors[i], mapIcons[i], queryString, view);
			}
			else if (this.isCustomObjectView)
			{
//				if (relationshipName != null)
//				{
//					queryString = "SELECT Id, " +
//						this.customObjectNameField + ", " +
//						relationshipName + ".Id, " +
//						relationshipName + ".Name " +
//				    	this.getDisplayFieldNames() +
//						" FROM " + this.customObjectName + " WHERE " + relationshipName + ".Id != null AND ";
//
//					queryString += relationshipName + ".pexmaps__" + this.mapAddressType + "_Geocode_Status__c" +
//						" = \'G_GEO_SUCCESS\'";
//				}
//				else
//				{
					if (this.customObjectUseLookupField)
					{
						queryString = "SELECT Id, " +
							this.customObjectNameField + ", " +
							this.customObjectLookupRelationshipName + ".Id, " +
							this.customObjectLookupRelationshipName + ".Name " +
					    	this.getDisplayFieldNames() +
							" FROM " + this.customObjectName + " WHERE " + this.customObjectLookupField + " != null AND ";
	
						queryString += this.customObjectLookupRelationshipName +
							(this.customObjectLookupFieldType == "Account" ? ".pexmaps__" + this.mapAddressType + "_Geocode_Status__c" : ".pexmaps__Geocode_Status__c") +
 							" = \'G_GEO_SUCCESS\'";
					}
					else
					{
					    queryString = "SELECT Id, " + 
					    	this.customObjectNameField + ", " +
					    	this.customObjectLatitudeField + ", " +
					    	this.customObjectLongitudeField + ", " +
					    	this.customObjectGeocodeStatusField + ", " +
				    		this.customObjectStreetField + ", " +
				    		this.customObjectCityField + ", " +
					    	this.customObjectStateField + ", " +
					    	this.customObjectPostalCodeField + ", " +
					    	this.customObjectCountryField + ", " +
					    	this.customObjectGeocodeAccuracyField + ", " +
					    	this.customObjectGeocodeAddressField +
				    		this.getDisplayFieldNames() +
							" FROM " + this.customObjectName + " WHERE ";

						queryString += this.customObjectGeocodeStatusField + " = \'G_GEO_SUCCESS\'";
					}
//				}
				
				queryString += whereClause;

			    this.loadCustomObjects(colors[i], mapIcons[i], queryString, view);
			}
			else // standard object with account lookup
			{
			    queryString = "SELECT Id, Name, " +
			    	relationshipName + ".Id, " +
			    	relationshipName + ".Name " +
			    	this.getDisplayFieldNames() +
			    	" FROM " + this.viewObject + " WHERE " +
			    	relationshipName + ".Id != null AND " +
			    	relationshipName + ".pexmaps__" + this.mapAddressType + "_Geocode_Status__c = \'G_GEO_SUCCESS\'" +
				    whereClause + " ORDER BY Name";

				this.loadStandardObjects(colors[i], mapIcons[i], queryString, view);

			}
		}
	};
	
	this.loadLeads = function(color, mapIcon, queryString, view)
	{
		var leads = [];
	    var leadRecords;
	    var queryResult;
	    var moreRecords = true;

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        leadRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Leads failed with error: " + error);
	        return leads;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < leadRecords.length; i++)
	        {
				var leadRecord = util.isDefined(leadRecords[i].Lead) ? 
					leadRecords[i].Lead : leadRecords[i];
					
				var lead = view.createLead(leadRecord, color, mapIcon, this);
				
				if (!this.flagDuplicateLocation(lead, view.leads) &&
					!this.flagDuplicateLocation(lead, leads))
				{
					lead.createMarker(lead);
				}
				
				leads.push(lead);

	        }
	
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					leadRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Leads failed with error: " + error);
			        return leads;
			    }
			}
		}
		
		return leads;
	};

	this.createLead = function(leadRecord, color, mapIcon, view)
	{
		var lead = new Lead();
	
		lead.view = view;
		lead.id = leadRecord.Id;
		lead.name = leadRecord.Name;
		lead.company = leadRecord.Company;
		lead.phone = leadRecord.Phone;
		lead.mobilePhone = leadRecord.MobilePhone;
		lead.color = color;
		lead.mapIcon = allowIcons ? mapIcon : null;

		lead.address = new Address();

		lead.address.street = leadRecord.Street;
		lead.address.city = leadRecord.City;
		lead.address.state = leadRecord.State;
		lead.address.postalCode = leadRecord.PostalCode;
		lead.address.country = leadRecord.Country;
		lead.address.geocodeStatus = leadRecord.pexmaps___Geocode_Status__c;
		lead.address.coordinates = new google.maps.LatLng(leadRecord.pexmaps__Latitude__c,
			leadRecord.pexmaps__Longitude__c);
		lead.address.geocodeAccuracy = leadRecord.pexmaps__Geocode_Accuracy__c;
		lead.address.geocodeAddress = leadRecord.pexmaps__Geocode_Address__c;


		if (this.viewObject == "Lead")
		{
			var stateAndZip = this.getStateZipForStatistics(lead.address.geocodeAddress);
			var calculateStatistics = (typeof(stateAndZip) != "undefined") && stateAndZip.length > 0; 
					
			lead.displayFieldValues = [];
			for (var i = 0; i < this.displayFieldNames.length; i++)
			{
				var displayFieldName = this.displayFieldNames[i];
				var displayFieldType = this.displayFieldTypes[i];
				var displayFieldValue = leadRecord[displayFieldName];
				
				if (calculateStatistics &&
					(displayFieldType == "Number" || displayFieldType == "Currency") && 
					(!isNaN(displayFieldValue)))
				{
					this.saveStateZipStatistics(displayFieldName, displayFieldValue, 0, stateAndZip[0]);			
					this.saveStateZipStatistics(displayFieldName, displayFieldValue, 1, stateAndZip[1]);			
				}
	
				lead.displayFieldValues.push(displayFieldValue);
			}
		}


//		lead.displayFieldValues = [];
//		for (var i = 0; i < this.displayFieldNames.length; i++)
//		{
//			eval("lead.displayFieldValues.push(leadRecord." + this.displayFieldNames[i] +")");
//		}

		return lead;
		
		
	};

	this.loadContacts = function(color, mapIcon, queryString, view)
	{
		var contacts = [];
	    var contactRecords;
	    var queryResult;
	    var moreRecords = true;
		var relatedContacts = [];

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        contactRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Contacts failed with error: " + error);
	        return contacts;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < contactRecords.length; i++)
	        {
	        	var contactRecord = util.isDefined(contactRecords[i].Contact) ? 
	        		contactRecords[i].Contact : contactRecords[i];

	        	var contact = view.createContact(contactRecord, color, mapIcon, this);

//				if (contactRecord.Account != null)
				if (!this.useContactAddress)
				{
					relatedContacts.push(contact);
				}
				else
	        	{
					if (!this.flagDuplicateLocation(contact, view.contacts) &&
						!this.flagDuplicateLocation(contact, contacts))
					{
						contact.createMarker(contact);
					}

					contacts.push(contact);
				}
				
				if (relatedContacts.length >= 100)
				{
					view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedContacts, color, mapIcon, "contacts", "Account", this));//view));
				}
	        }
	
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					contactRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Contacts failed with error: " + error);
			        return contacts;
			    }
			}
		}
		
		view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedContacts, color, mapIcon, "contacts", "Account", this));//view));
		
		for (var i = 0; i < view.accounts.length; i++)
		{
			view.accounts[i].contacts.sort(util.nameSort)
		}
		
		return contacts;
	};

	this.createContact = function(contactRecord, color, mapIcon, view)
	{
		var contact = new Contact();

       	contact.view = view;//this;
		contact.id = contactRecord.Id;
		contact.name = contactRecord.Name;
		contact.relatedObjectId = null;
		contact.relatedObjectName = null;
		contact.color = color;
		contact.mapIcon = allowIcons ? mapIcon : null;



		if (contactRecord.Account != null)
		{
			contact.relatedObjectId = contactRecord.Account.Id;
			contact.relatedObjectName = contactRecord.Account.Name;
		}
		
		if (this.useContactAddress)
		{
			contact.address = new Address();
	
			contact.address.street = contactRecord.MailingStreet;
			contact.address.city = contactRecord.MailingCity;
			contact.address.state = contactRecord.MailingState;
			contact.address.postalCode = contactRecord.MailingPostalCode;
			contact.address.country = contactRecord.MailingCountry;
			contact.address.geocodeStatus = contactRecord.pexmaps___Geocode_Status__c;
			contact.address.coordinates = new google.maps.LatLng(contactRecord.pexmaps__Latitude__c,
				contactRecord.pexmaps__Longitude__c);
			contact.address.geocodeAccuracy = contactRecord.pexmaps__Geocode_Accuracy__c;
			contact.address.geocodeAddress = contactRecord.pexmaps__Geocode_Address__c;
		}


/*
		if (contactRecord.Account != null)
		{
			contact.relatedObjectId = contactRecord.Account.Id;
			contact.relatedObjectName = contactRecord.Account.Name;
		}
		else
		{
			contact.address = new Address();
	
			contact.address.street = contactRecord.MailingStreet;
			contact.address.city = contactRecord.MailingCity;
			contact.address.state = contactRecord.MailingState;
			contact.address.postalCode = contactRecord.MailingPostalCode;
			contact.address.country = contactRecord.MailingCountry;
			contact.address.geocodeStatus = contactRecord.pexmaps___Geocode_Status__c;
			contact.address.coordinates = new google.maps.LatLng(contactRecord.pexmaps__Latitude__c,
				contactRecord.pexmaps__Longitude__c);
			contact.address.geocodeAccuracy = contactRecord.pexmaps__Geocode_Accuracy__c;
			contact.address.geocodeAddress = contactRecord.pexmaps__Geocode_Address__c;
		}
*/
		if (this.viewObject == "Contact")
		{
			var stateAndZip = this.useContactAddress ? this.getStateZipForStatistics(contact.address.geocodeAddress) : "";
			var calculateStatistics = (typeof(stateAndZip) != "undefined") && stateAndZip.length > 0; 
			
			contact.displayFieldValues = [];
			for (var i = 0; i < this.displayFieldNames.length; i++)
			{
				var displayFieldName = this.displayFieldNames[i];
				var displayFieldType = this.displayFieldTypes[i];
				var displayFieldValue = contactRecord[displayFieldName];
				
				if (this.useContactAddress)
				{
					if (calculateStatistics &&
						(displayFieldType == "Number" || displayFieldType == "Currency") && 
						(!isNaN(displayFieldValue)))
					{
						this.saveStateZipStatistics(displayFieldName, displayFieldValue, 0, stateAndZip[0]);			
						this.saveStateZipStatistics(displayFieldName, displayFieldValue, 1, stateAndZip[1]);			
					}
				}
				
				contact.displayFieldValues.push(contactRecord[displayFieldName]);
			}
		}


//		contact.displayFieldValues = [];
//		for (var i = 0; i < this.displayFieldNames.length; i++)
//		{
//			var displayFieldName = this.displayFieldNames[i];
//			contact.displayFieldValues.push(contactRecord[displayFieldName]);
//		}


		return contact;
	};

	this.loadCustomObjects = function(color, mapIcon, queryString, view)
	{
	    var customObjectRecords;
	    var queryResult;
	    var moreRecords = true;
		var relatedCustomObjects = [];
		
		var relationship = this.getParentRelationshipName();
		var lookupType;
		
		if (this.customObjectUseLookupField)
		{
			relationship = this.customObjectLookupRelationshipName;
			lookupType = this.customObjectLookupFieldType;
		}
	
		
	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        customObjectRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Custom Objects failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < customObjectRecords.length; i++)
	        {
	        	var customObject = this.createCustomObject(customObjectRecords[i], color, mapIcon);
	        	
	        	
				if (relationship != null)
				{
					relatedCustomObjects.push(customObject);
				}
				else
	        	{
					if (!this.flagDuplicateLocation(customObject, view.customObjects))
					{
						customObject.createMarker(customObject);
					}

					view.customObjects.push(customObject);
				}
				
				if (relatedCustomObjects.length >= 100)
				{
					if (lookupType == "Account")
					{
						view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedCustomObjects, color, mapIcon, "customObjects", "Account", this));//view));
					}
					else if (lookupType == "Contact")
					{
						view.contacts = view.contacts.concat(this.loadRelatedObjects(relatedCustomObjects, color, mapIcon, "customObjects", "Contact", this));//view));
					}
					else if (lookupType == "Lead")
					{
						view.leads = view.leads.concat(this.loadRelatedObjects(relatedCustomObjects, color, mapIcon, "customObjects", "Lead", this));//view));
					}
				}

//				customObject.displayFieldValues = [];
//				for (var j = 0; j < this.displayFieldNames.length; j++)
//				{
//					var displayFieldName = this.displayFieldNames[j];
//					customObject.displayFieldValues.push(customObjectRecords[i][displayFieldName]);
//				}
	        }
	
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					customObjectRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Custom Objects failed with error: " + error);
			        return;
			    }
			}
		}
		
		if (lookupType == "Account")
		{
			view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedCustomObjects, color, mapIcon, "customObjects", "Account", this));//view));
		}
		else if (lookupType == "Contact")
		{
			view.contacts = view.contacts.concat(this.loadRelatedObjects(relatedCustomObjects, color, mapIcon, "customObjects", "Contact", this));//view));
		}
		else if (lookupType == "Lead")
		{
			view.leads = view.leads.concat(this.loadRelatedObjects(relatedCustomObjects, color, mapIcon, "customObjects", "Lead", this));//view));
		}


		for (var i = 0; i < view.accounts.length; i++)
		{
			view.accounts[i].customObjects.sort(util.nameSort)
		}

		for (var i = 0; i < view.contacts.length; i++)
		{
			view.contacts[i].customObjects.sort(util.nameSort)
		}

		for (var i = 0; i < view.leads.length; i++)
		{
			view.leads[i].customObjects.sort(util.nameSort)
		}
	};

	this.createCustomObject = function(customObjectRecord, color, mapIcon)
	{
		var customObject = new CustomObject();

       	customObject.view = this;
		customObject.id = customObjectRecord.Id;
		eval("customObject.name = customObjectRecord." + this.customObjectNameField);
		customObject.relatedObjectId = null;
		customObject.relatedObjectName = null;
		customObject.color = color;
		customObject.mapIcon = allowIcons ? mapIcon : null;

		var relationship = this.getParentRelationshipName();
		relationship = (relationship == null && this.customObjectUseLookupField) ? 
			this.customObjectLookupRelationshipName : relationship;

		if (relationship != null)
		{
			eval("customObject.relatedObjectId = customObjectRecord." + relationship + ".Id");
			eval("customObject.relatedObjectName = customObjectRecord." + relationship + ".Name");
		}
		else
		{
			customObject.address = new Address();
	
			eval("customObject.address.street = customObjectRecord." + this.customObjectStreetField);
			eval("customObject.address.city = customObjectRecord." + this.customObjectCityField);
			eval("customObject.address.state = customObjectRecord." + this.customObjectStateField);
			eval("customObject.address.postalCode = customObjectRecord." + this.customObjectPostalCodeField);
			eval("customObject.address.country = customObjectRecord." + this.customObjectCountryField);
			eval("customObject.address.geocodeStatus = customObjectRecord." + this.customObjectGeocodeStatusField);
			eval("customObject.address.coordinates = new google.maps.LatLng(customObjectRecord." + this.customObjectLatitudeField + 
				", customObjectRecord." + this.customObjectLongitudeField + ")");
			eval("customObject.address.geocodeAccuracy = customObjectRecord." + this.customObjectGeocodeAccuracyField);
			eval("customObject.address.geocodeAddress = customObjectRecord." + this.customObjectGeocodeAddressField);
		}

		var dontUseLookup = (this.isCustomObjectView && !this.customObjectUseLookupField);
		var stateAndZip = dontUseLookup ? this.getStateZipForStatistics(customObject.address.geocodeAddress) : "";
		var calculateStatistics = (typeof(stateAndZip) != "undefined") && stateAndZip.length > 0; 
		
		customObject.displayFieldValues = [];
		for (var i = 0; i < this.displayFieldNames.length; i++)
		{
			var displayFieldName = this.displayFieldNames[i];
			var displayFieldType = this.displayFieldTypes[i];
			var displayFieldValue = customObjectRecord[displayFieldName];
			
			if (dontUseLookup)
			{
				if (calculateStatistics &&
					(displayFieldType == "Number" || displayFieldType == "Currency") && 
					(!isNaN(displayFieldValue)))
				{
					this.saveStateZipStatistics(displayFieldName, displayFieldValue, 0, stateAndZip[0]);			
					this.saveStateZipStatistics(displayFieldName, displayFieldValue, 1, stateAndZip[1]);			
				}
			}
			
			customObject.displayFieldValues.push(displayFieldValue);
		}


//		customObject.displayFieldValues = [];
//		for (var i = 0; i < this.displayFieldNames.length; i++)
//		{
//			eval("customObject.displayFieldValues.push(customObjectRecord." + this.displayFieldNames[i] +")");
//		}

		return customObject;
	};

	this.loadStandardObjects = function(color, mapIcon, queryString, view)
	{
	    var standardObjectRecords;
	    var queryResult;
	    var moreRecords = true;
	    
	    var relatedStandardObjects = [];
		var relationship = this.getParentRelationshipName();

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        standardObjectRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Standard Objects failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < standardObjectRecords.length; i++)
	        {
	        	var standardObject = new StandardObject();
	        	standardObject.view = this;
	        	standardObject.id = standardObjectRecords[i].Id;
	        	standardObject.name = standardObjectRecords[i].Name;
	        	standardObject.color = color;
	        	standardObject.mapIcon = allowIcons ? mapIcon : null;

	        	eval("standardObject.relatedObjectId = standardObjectRecords[i]." + relationship + ".Id");
	        	eval("standardObject.relatedObjectName = standardObjectRecords[i]." + relationship + ".Name"); 

				relatedStandardObjects.push(standardObject);

				if (relatedStandardObjects.length >= 100)
				{
					view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedStandardObjects, color, mapIcon, "standardObjects", "Account", this));//view));
				}

				standardObject.displayFieldValues = [];
				for (var j = 0; j < this.displayFieldNames.length; j++)
				{
					eval("standardObject.displayFieldValues.push(standardObjectRecords[i]." + this.displayFieldNames[j] +")");
				}
	        }
	        
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					assetRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Standard Objects failed with error: " + error);
			        return;
			    }
			}
		}

		view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedStandardObjects, color, mapIcon, "standardObjects", "Account", this));//view));

		for (var i = 0; i < view.accounts.length; i++)
		{
			view.accounts[i].standardObjects.sort(util.nameSort)
		}
	};

	this.loadOwner = function(ownerId, view)
	{
		this.loadUsers("\'" + ownerId  + "\'", view.userMarkerColor, view.userMapIcon, this);
		view.owner = view.findUser(ownerId);
	}
	
	this.loadUsers = function(userIds, color, mapIcon, view)
	{
	    var userRecords;
	    var queryResult;
	    var moreRecords = true;

	    var queryString = "SELECT Id, Name, Street, City, State, PostalCode, Country, " +
	    	"pexmaps__Geocode_Status__c, pexmaps__Latitude__c, pexmaps__Longitude__c, " +
	    	"pexmaps__Geocode_Accuracy__c, pexmaps__Geocode_Address__c " +
	    	"FROM User WHERE Id IN (" + userIds + ") AND pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\'";

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        userRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Users failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < userRecords.length; i++)
	        {
	        	var user = this.createUser(userRecords[i], color, mapIcon);

				if (!this.findUser(user.id))
				{
					view.users.push(user);
				}
	        }
	
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					userRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Users failed with error: " + error);
			    }
			}
		}
	};

	this.createUser = function(userRecord, color, mapIcon)
	{
		var user = new User();
		
		user.id = userRecord.Id;
		user.view = this;
		user.name = userRecord.Name;
		user.color = color;
		user.mapIcon = allowIcons ? mapIcon : null;

		user.address = new Address();
		
		user.address.street = userRecord.Street;
		user.address.city = userRecord.City;
		user.address.state = userRecord.State;
		user.address.postalCode = userRecord.PostalCode;
		user.address.country = userRecord.Country;
		user.address.geocodeStatus = userRecord.pexmaps__Geocode_Status__c;
		user.address.geocodeAccuracy = userRecord.pexmaps__Geocode_Accuracy__c;
		user.address.geocodeAddress = userRecord.pexmaps__Geocode_Address__c;
		user.address.coordinates = new google.maps.LatLng(userRecord.pexmaps__Latitude__c,
			userRecord.pexmaps__Longitude__c);

		if (this.type == "User")
		{
			user.displayFieldValues = [];
			for (var i = 0; i < this.displayFieldNames.length; i++)
			{
				eval("user.displayFieldValues.push(userRecord." + this.displayFieldNames[i] +")");
			}
		}
				
		user.createMarker(user);
		
		return user;
	};
	
	this.loadUserViewUsers = function(color, mapIcon, queryString)
	{
		var users = [];
	    var userRecords;
	    var queryResult;
	    var moreRecords = true;

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        userRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Users failed with error: " + error);
	        return users;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < userRecords.length; i++)
	        {
				var userRecord = userRecords[i];
					
				var user = this.createUser(userRecord, color, mapIcon);
				user.view = this;
				users.push(user);

	        }
	
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					userRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Users failed with error: " + error);
			        return users;
			    }
			}
		}
		
		return users;
	};
	
	this.flagDuplicateLocation = function(mapObject, mapObjectArray)
	{
		var latitude = mapObject.address.coordinates.lat();
		var longitude = mapObject.address.coordinates.lng();
		var arrayLength = mapObjectArray.length;
	
		for (var i = 0; i < arrayLength; i++)
		{
			var latitude2 = mapObjectArray[i].address.coordinates.lat();
			var longitude2 = mapObjectArray[i].address.coordinates.lng();
			
			if (mapObjectArray[i].id === mapObject.id)
			{
				continue;
			}

			//if (Math.abs(latitude - latitude2) < 0.00001 && Math.abs(longitude - longitude2) < 0.00001)
			if (latitude === latitude2 && longitude === longitude2)
			{
				if (!mapObjectArray[i].multiObject)
				{
					mapObjectArray[i].multiObject = true;
					mapObjectArray[i].color = this.multiObjectMarkerColor;
					mapObjectArray[i].mapIcon = allowIcons ? this.multiObjectMapIcon : null;
					
					mapObjectArray[i].createMarker(mapObjectArray[i]);
				}
			
				mapObject.isDuplicateLocation = true;
				mapObject.duplicateMaster = mapObjectArray[i];
				mapObject.marker = mapObjectArray[i].marker;
				
				mapObjectArray[i].duplicateLocations.push(mapObject);
				return true;
			}
		}
		
		return false;
	};
	
	this.loadAccounts = function(color, mapIcon, queryString, view)
	{
		var accounts = [];
	    var accountRecords;
	    var queryResult;
	    var moreRecords = true;
	
	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        accountRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Accounts failed with error: " + error);
	        return accounts;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < accountRecords.length; i++)
	        {
	        	var account = view.createAccount(accountRecords[i], color, mapIcon, this);

				if (!this.flagDuplicateLocation(account, view.accounts) &&
					!this.flagDuplicateLocation(account, accounts))
				{
					account.createMarker(account);
				}
	        	
	        	accounts.push(account);
	        }
	
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					accountRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Accounts failed with error: " + error);
			        return accounts;
			    }
			}
		}
		
		return accounts;
	};

	this.loadOpportunities = function(color, mapIcon, queryString, view)
	{
	    var opportunityRecords;
	    var queryResult;
	    var moreRecords = true;
	    
	    var relatedOpportunities = [];
		var relationship = this.getParentRelationshipName();
		relationship = relationship == null ? "Account" : relationship;

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        opportunityRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Opportunities failed with error: " + error);
	        return accounts;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < opportunityRecords.length; i++)
	        {
	        	var opportunity = new StandardObject();
	        	opportunity.view = this;
	        	opportunity.id = opportunityRecords[i].Id;
	        	opportunity.name = opportunityRecords[i].Name;
	        	opportunity.color = color;
	        	opportunity.mapIcon = allowIcons ? mapIcon : null;
	        	eval("opportunity.relatedObjectId = opportunityRecords[i]." + relationship + ".Id");
	        	eval("opportunity.relatedObjectName = opportunityRecords[i]." + relationship + ".Name");

				relatedOpportunities.push(opportunity);

				if (relatedOpportunities.length >= 100)
				{
					view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedOpportunities, color, mapIcon, "opportunities", "Account", this));//view));
				}
				
				opportunity.displayFieldValues = [];
				for (var j = 0; j < this.displayFieldNames.length; j++)
				{
					var displayFieldName = this.displayFieldNames[j];
					opportunity.displayFieldValues.push(opportunityRecords[i][displayFieldName]);
				}
	        }
	        
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					opportunityRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Opportunities failed with error: " + error);
			        return accounts;
			    }
			}
		}
		
		view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedOpportunities, color, mapIcon, "opportunities", "Account", this));//view));
		
		for (var i = 0; i < view.accounts.length; i++)
		{
			view.accounts[i].opportunities.sort(util.nameSort)
		}
	};

	this.loadAssets = function(color, mapIcon, queryString, view)
	{
	    var assetRecords;
	    var queryResult;
	    var moreRecords = true;
	    
	    var relatedAssets = [];
		var relationship = this.getParentRelationshipName();
		relationship = relationship == null ? "Account" : relationship;

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        assetRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Assets failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < assetRecords.length; i++)
	        {
	        	var asset = new StandardObject();
	        	asset.view = this;
	        	asset.id = assetRecords[i].Id;
	        	asset.name = assetRecords[i].Name;
	        	asset.color = color;
	        	asset.mapIcon = allowIcons ? mapIcon : null;

	        	eval("asset.relatedObjectId = assetRecords[i]." + relationship + ".Id");
	        	eval("asset.relatedObjectName = assetRecords[i]." + relationship + ".Name"); 

				relatedAssets.push(asset);

				if (relatedAssets.length >= 100)
				{
					view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedAssets, color, mapIcon, "assets", "Account", this));//view));
				}

				asset.displayFieldValues = [];
				for (var j = 0; j < this.displayFieldNames.length; j++)
				{
					var displayFieldName = this.displayFieldNames[j];
					asset.displayFieldValues.push(assetRecords[i][displayFieldName]);
//					eval("asset.displayFieldValues.push(assetRecords[i]." + this.displayFieldNames[j] +")");
				}
	        }
	        
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					assetRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Assets failed with error: " + error);
			        return;
			    }
			}
		}

		view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedAssets, color, mapIcon, "assets", "Account", this));//view));

		for (var i = 0; i < view.accounts.length; i++)
		{
			view.accounts[i].assets.sort(util.nameSort)
		}
	};

	this.loadCases = function(color, mapIcon, queryString, view)
	{
	    var caseRecords;
	    var queryResult;
	    var moreRecords = true;
		var accountRelatedCases = [];
		var contactRelatedCases = [];

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        caseRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Cases failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < caseRecords.length; i++)
	        {
	        	var caseItem = new StandardObject();
	        	caseItem.view = this;
	        	caseItem.id = caseRecords[i].Id;
	        	caseItem.name = caseRecords[i].CaseNumber;
	        	caseItem.color = color;
	        	caseItem.mapIcon = allowIcons ? mapIcon : null;

	        	var accountId = caseRecords[i].AccountId;
	        	var contactId = caseRecords[i].ContactId;

	        	if (accountId != null)
	        	{
		        	caseItem.relatedObjectId = accountId;
		        	caseItem.relatedObjectName = caseRecords[i].Account.Name; 

					accountRelatedCases.push(caseItem);

					if (accountRelatedCases.length >= 100)
					{
						view.accounts = view.accounts.concat(this.loadRelatedObjects(accountRelatedCases, color, mapIcon, "cases", "Account", this));//view));
					}
		        }
		        else if (contactId != null)
		        {
		        	caseItem.relatedObjectId = contactId;
		        	caseItem.relatedObjectName = caseRecords[i].Contact.Name; 
		        
					contactRelatedCases.push(caseItem);

					if (contactRelatedCases.length >= 100)
					{
						view.contacts = view.contacts.concat(this.loadRelatedObjects(contactRelatedCases, color, mapIcon, "cases", "Contact", this));//view));
					}
		        }
		        
		        

				caseItem.displayFieldValues = [];
				for (var j = 0; j < this.displayFieldNames.length; j++)
				{
					var displayFieldName = this.displayFieldNames[j];
					caseItem.displayFieldValues.push(caseRecords[i][displayFieldName]);
//					eval("caseItem.displayFieldValues.push(caseRecords[i]." + this.displayFieldNames[j] +")");
				}
	        }
	        
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					caseRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Cases failed with error: " + error);
			        return;
			    }
			}
		}
		
		view.accounts = view.accounts.concat(this.loadRelatedObjects(accountRelatedCases, color, mapIcon, "cases", "Account", this));//view));
		view.contacts = view.contacts.concat(this.loadRelatedObjects(contactRelatedCases, color, mapIcon, "cases", "Contact", this));//view));
		
		for (var i = 0; i < view.accounts.length; i++)
		{
			view.accounts[i].cases.sort(util.nameSort)
		}

		for (var i = 0; i < view.contacts.length; i++)
		{
			view.contacts[i].cases.sort(util.nameSort)
		}
	};

	this.loadContracts = function(color, mapIcon, queryString, view)
	{
	    var contractRecords;
	    var queryResult;
	    var moreRecords = true;

	    var relatedContracts = [];
		var relationship = this.getParentRelationshipName();
		relationship = relationship == null ? "Account" : relationship;

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        contractRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Contracts failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < contractRecords.length; i++)
	        {
	        	var contract = new StandardObject();
	        	contract.view = this;
	        	contract.id = contractRecords[i].Id;
	        	contract.name = contractRecords[i].ContractNumber;
	        	contract.color = color;
	        	contract.mapIcon = allowIcons ? mapIcon : null;

	        	eval("contract.relatedObjectId = contractRecords[i]." + relationship + ".Id");
	        	eval("contract.relatedObjectName = contractRecords[i]." + relationship + ".Name"); 

				relatedContracts.push(contract);

				if (relatedContracts.length >= 100)
				{
					view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedContracts, color, mapIcon, "contracts", "Account", this));//view));
				}

				contract.displayFieldValues = [];
				for (var j = 0; j < this.displayFieldNames.length; j++)
				{
					var displayFieldName = this.displayFieldNames[j];
					contract.displayFieldValues.push(contractRecords[i][displayFieldName]);

//					eval("contract.displayFieldValues.push(contractRecords[i]." + this.displayFieldNames[j] +")");
				}
	        }
	        
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					contractRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Contracts failed with error: " + error);
			        return;
			    }
			}
		}
		
		view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedContracts, color, mapIcon, "contracts", "Account", this));//view));

		for (var i = 0; i < view.accounts.length; i++)
		{
			view.accounts[i].contracts.sort(util.nameSort)
		}
	};

	this.loadTasks = function(color, mapIcon, queryString, view)
	{
	    var taskRecords;
	    var queryResult;
	    var moreRecords = true;

	    var relatedTasks = [];
		var relationship = this.getParentRelationshipName();
		relationship = relationship == null ? "Account" : relationship;

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        taskRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Tasks failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < taskRecords.length; i++)
	        {
	        	var task = new StandardObject();
	        	task.view = this;
	        	task.id = taskRecords[i].Id;
	        	task.name = taskRecords[i].Subject;
	        	task.color = color;
	        	task.mapIcon = allowIcons ? mapIcon : null;

	        	eval("task.relatedObjectId = taskRecords[i]." + relationship + ".Id");
	        	eval("task.relatedObjectName = taskRecords[i]." + relationship + ".Name"); 

				relatedTasks.push(task);

				if (relatedTasks.length >= 100)
				{
					view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedTasks, color, mapIcon, "tasks", "Account", this));//view));
				}

				task.displayFieldValues = [];
				for (var j = 0; j < this.displayFieldNames.length; j++)
				{
					eval("task.displayFieldValues.push(taskRecords[i]." + this.displayFieldNames[j] +")");
				}
	        }
	        
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					taskRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Tasks failed with error: " + error);
			        return;
			    }
			}
		}
		
		view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedTasks, color, mapIcon, "tasks", "Account", this));//view));

		for (var i = 0; i < view.accounts.length; i++)
		{
			view.accounts[i].tasks.sort(util.nameSort)
		}
	};

	this.loadEvents = function(color, mapIcon, queryString, view)
	{
	    var eventRecords;
	    var queryResult;
	    var moreRecords = true;

	    var relatedEvents = [];
		var relationship = this.getParentRelationshipName();
		relationship = relationship == null ? "Account" : relationship;

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        eventRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Events failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < eventRecords.length; i++)
	        {
	        	var event = new StandardObject();
	        	event.view = this;
	        	event.id = eventRecords[i].Id;
	        	event.name = eventRecords[i].Subject;
	        	event.color = color;
	        	event.mapIcon = allowIcons ? mapIcon : null;

	        	eval("event.relatedObjectId = eventRecords[i]." + relationship + ".Id");
	        	eval("event.relatedObjectName = eventRecords[i]." + relationship + ".Name"); 

				relatedEvents.push(event);

				if (relatedEvents.length >= 100)
				{
					view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedEvents, color, mapIcon, "events", "Account", this));//view));
				}

				event.displayFieldValues = [];
				for (var j = 0; j < this.displayFieldNames.length; j++)
				{
					var displayFieldName = this.displayFieldNames[j];
					event.displayFieldValues.push(eventRecords[i][displayFieldName]);
//					eval("event.displayFieldValues.push(eventRecords[i]." + this.displayFieldNames[j] +")");
				}
	        }
	        
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					eventRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Events failed with error: " + error);
			        return;
			    }
			}
		}
		
		view.accounts = view.accounts.concat(this.loadRelatedObjects(relatedEvents, color, mapIcon, "events", "Account", this));//view));

		for (var i = 0; i < view.accounts.length; i++)
		{
			view.accounts[i].events.sort(util.nameSort)
		}
	};
	
	this.loadRelatedObjects = function(mapObjects, color, mapIcon, destinationArray, relatedObjectType, view)
	{
		var relatedObjectIds = "";
		var relatedObjects = [];
		
		if (mapObjects.length == 0)
		{
			return relatedObjects;
		}
		
		for (var i = mapObjects.length - 1; i >= 0; i--)
		{
			var mapObject = mapObjects[i];
			
			eval("var existingRelatedObject = territories.view.find" + relatedObjectType + "(mapObject.relatedObjectId)");
			
			if (existingRelatedObject != null)
			{
				if (existingRelatedObject.color != color && !existingRelatedObject.multiObject)
				{
					existingRelatedObject.multiObject = true;
					existingRelatedObject.color = view.multiObjectMarkerColor;
					existingRelatedObject.mapIcon = allowIcons ? view.multiObjectMapIcon : null;
					existingRelatedObject.createMarker(existingRelatedObject);
				}
			
				mapObjects.splice(i, 1);
				eval("existingRelatedObject." + destinationArray + ".push(mapObject)");
			}
			else
			{
				if (relatedObjectIds.length > 0)
				{
					relatedObjectIds += ",";
				}
				
				relatedObjectIds += "\'" + mapObject.relatedObjectId + "\'";
			}
		}

		if (relatedObjectIds.length == 0)
		{
			mapObjects.length = 0;
			return relatedObjects;
		}
		
		var queryString;
		var addressType = view.mapAddressType;
		
		if (relatedObjectType == "Account")
		{		
		    queryString = "SELECT Id, Name, pexmaps__" + addressType + "_Latitude__c, " +
		    	"pexmaps__" + addressType + "_Longitude__c, pexmaps__" + addressType + "_Geocode_Status__c, " + addressType + "Street, " +
		    	"" + addressType + "City, " + addressType + "State, " + addressType + "PostalCode, " + addressType + "Country, " +
		    	"pexmaps__" + addressType + "_Geocode_Accuracy__c, pexmaps__" + addressType + "_Geocode_Address__c " +
		    	"FROM Account WHERE Id IN (" + relatedObjectIds + ")";
		}
		else if (relatedObjectType == "Contact")
		{
		    queryString = "SELECT Id, Name, pexmaps__Latitude__c, " +
		    	"pexmaps__Longitude__c, pexmaps__Geocode_Status__c, MailingStreet, " +
		    	"MailingCity, MailingState, MailingPostalCode, MailingCountry, " +
		    	"pexmaps__Geocode_Accuracy__c, pexmaps__Geocode_Address__c " +
		    	"FROM Contact WHERE Id IN (" + relatedObjectIds + ")";
		}
		else if (relatedObjectType == "Lead")
		{
		    queryString = "SELECT Id, Name, pexmaps__Latitude__c, " +
		    	"pexmaps__Longitude__c, pexmaps__Geocode_Status__c, Street, " +
		    	"City, State, PostalCode, Country, " +
		    	"pexmaps__Geocode_Accuracy__c, pexmaps__Geocode_Address__c " +
		    	"FROM Lead WHERE Id IN (" + relatedObjectIds + ")";
		}
				
		eval("relatedObjects = this.load" + relatedObjectType + "s(color, mapIcon, queryString, view)");

		var mapObjectCount = mapObjects.length;
		
		for (var i = 0; i < mapObjectCount; i++)
		{
			var mapObject = mapObjects.shift();
			
			for (var j = 0; j < relatedObjects.length; j++)
			{
				if (mapObject.relatedObjectId == relatedObjects[j].id)
				{
					eval("relatedObjects[j]." + destinationArray + ".push(mapObject)");
					break;
				}
			}
		}		
		
		mapObjects.length = 0;
		return relatedObjects;
	}

	this.createAccount = function(accountRecord, color, mapIcon, view)
	{
		var account = new Account();
	
		account.view = view;//this;
		account.id = accountRecord.Id;
		account.name = accountRecord.Name;
		account.color = (account.id == this.selectedAccountId) ? "#0066CC" : color;
		account.mapIcon = allowIcons ? mapIcon : null;

		account.address = new Address();

		if (view.mapAddressType == "Billing")
		{
			account.address.street = accountRecord.BillingStreet;
			account.address.city = accountRecord.BillingCity;
			account.address.state = accountRecord.BillingState;
			account.address.postalCode = accountRecord.BillingPostalCode;
			account.address.country = accountRecord.BillingCountry;
			account.address.geocodeStatus = accountRecord.pexmaps__Billing_Geocode_Status__c;
			account.address.coordinates = new google.maps.LatLng(accountRecord.pexmaps__Billing_Latitude__c,
				accountRecord.pexmaps__Billing_Longitude__c);
			account.address.geocodeAccuracy = accountRecord.pexmaps__Billing_Geocode_Accuracy__c;
			account.address.geocodeAddress = accountRecord.pexmaps__Billing_Geocode_Address__c;
		}
		else
		{	
			account.address.street = accountRecord.ShippingStreet;
			account.address.city = accountRecord.ShippingCity;
			account.address.state = accountRecord.ShippingState;
			account.address.postalCode = accountRecord.ShippingPostalCode;
			account.address.country = accountRecord.ShippingCountry;
			account.address.geocodeStatus = accountRecord.pexmaps__Shipping_Geocode_Status__c;
			account.address.coordinates = new google.maps.LatLng(accountRecord.pexmaps__Shipping_Latitude__c,
				accountRecord.pexmaps__Shipping_Longitude__c);
			account.address.geocodeAccuracy = accountRecord.pexmaps__Shipping_Geocode_Accuracy__c;
			account.address.geocodeAddress = accountRecord.pexmaps__Shipping_Geocode_Address__c;
		}

		if (this.viewObject == "Account")
		{
			var stateAndZip = this.getStateZipForStatistics(account.address.geocodeAddress);
			var calculateStatistics = (typeof(stateAndZip) != "undefined") && stateAndZip.length > 0; 
					
			account.displayFieldValues = [];
			for (var i = 0; i < this.displayFieldNames.length; i++)
			{
				var displayFieldName = this.displayFieldNames[i];
				var displayFieldType = this.displayFieldTypes[i];
				var displayFieldValue = accountRecord[displayFieldName];

				if (calculateStatistics &&
					(displayFieldType == "Number" || displayFieldType == "Currency") && 
					(!isNaN(displayFieldValue)))
				{
					this.saveStateZipStatistics(displayFieldName, displayFieldValue, 0, stateAndZip[0]);			
					this.saveStateZipStatistics(displayFieldName, displayFieldValue, 1, stateAndZip[1]);			
				}
	
				account.displayFieldValues.push(displayFieldValue);
			}
		}
		
		//account.createMarker(account);
		
		return account;
	};

/*
	
	this.getStateZipForStatistics = function(geocodeAddress)
	{
		if (geocodeAddress == null)
		{
			return;
		}

		var geocodeAddressParts = geocodeAddress.split(", ");
		var lastIndex = geocodeAddressParts.length - 1;
		
		if (geocodeAddressParts[lastIndex] !== heatMaps.getCountry())
		{
			return [];
		} 
		
		var stateZip = geocodeAddressParts[lastIndex - 1].split(" ");
		
		if (stateZip.length != 2)
		{
			return [];	
		}

		var state = stateZip[0].toUpperCase();
		var zip = stateZip[1].substr(0, 5); 
		
		if (isNaN(zip))
		{
			return [];
		}
		
		return [state, zip];
	};
*/
	
	this.getStateZipForStatistics = function(geocodeAddress)
	{
		if (geocodeAddress == null)
		{
			return;
		}

		var geocodeAddressParts = geocodeAddress.split(",");
		
		if (geocodeAddressParts.length == 1)
		{
			return;
		}
		
		var lastIndex = geocodeAddressParts.length - 1;
		
		var stateZip = util.trim(geocodeAddressParts[lastIndex - 1]);
		var lastSpace = stateZip.lastIndexOf(" ");
		
		if (lastSpace == -1)
		{
			return [];
		}

		var state = util.left(stateZip, lastSpace).toUpperCase();
		var zip = util.right(stateZip, lastSpace + 1);
		
		return [state, zip];
	};

	this.saveStateZipStatistics = function(displayFieldName, displayFieldValue, index, area)
	{
		displayFieldValue = new Number(displayFieldValue).toFixed();
		
		if (!util.isDefined(this[displayFieldName][index].areas[area])) 
		{
			this[displayFieldName][index].areas[area] = {count: 0, min: Infinity, max: -Infinity, avg: 0, total: 0};
		}
		
		this[displayFieldName][index].areas[area].count++;
		
		this[displayFieldName][index].areas[area].total += Number(displayFieldValue);
		
		this[displayFieldName][index].areas[area].avg = this[displayFieldName][index].areas[area].total / 
			this[displayFieldName][index].areas[area].count;

		this[displayFieldName][index].areas[area].min = Math.min(displayFieldValue, this[displayFieldName][index].areas[area].min);
		this[displayFieldName][index].areas[area].max = Math.max(displayFieldValue, this[displayFieldName][index].areas[area].max);

		this[displayFieldName][index].overallMin.count = Math.min(this[displayFieldName][index].overallMin.count, this[displayFieldName][index].areas[area].count);
		this[displayFieldName][index].overallMax.count = Math.max(this[displayFieldName][index].overallMax.count, this[displayFieldName][index].areas[area].count);
	};
	
	
	this.saveChildStatistics = function(childObject, parentObject)
	{
	
		if (!util.isDefined(this[parentObject]))
		{
			return;
		}
	
		var parentObjectsLength = this[parentObject].length;
		
		for (var i = 0; i < parentObjectsLength; i++)
		{
			var stateAndZip = this.getStateZipForStatistics(this[parentObject][i].address.geocodeAddress);

			if (typeof(stateAndZip) == "undefined")
			{
				continue;
			}

			var calculateStatistics = stateAndZip.length > 0;
			if (!calculateStatistics)
			{
				continue;
			} 
			
			var childObjectsLength = this[parentObject][i][childObject].length;
			for (var j = 0; j < childObjectsLength; j++)
			{
				var child = this[parentObject][i][childObject][j];
				
				for (var k = 0; k < this.displayFieldNames.length; k++)
				{
					var displayFieldName = this.displayFieldNames[k];
					var displayFieldType = this.displayFieldTypes[k];
					var displayFieldValue = child.displayFieldValues[k];
					
					if ((displayFieldType == "Number" || displayFieldType == "Currency") && 
						(!isNaN(displayFieldValue)))
					{
						this.saveStateZipStatistics(displayFieldName, displayFieldValue, 0, stateAndZip[0]);			
						this.saveStateZipStatistics(displayFieldName, displayFieldValue, 1, stateAndZip[1]);			
					}
				}
			}
		}
	};
	
	this.loadAccountOpenOpportunities = function(account)
	{
	    var opportunityRecords;
	    var queryResult;
	    var moreRecords = true;

		var queryString = "SELECT Id, Name FROM Opportunity WHERE AccountId = \'" +
			account.id + "\' AND IsClosed = false ORDER BY Name";

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        opportunityRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Account Open Opportunities failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < opportunityRecords.length; i++)
	        {
	        	var opportunity = new StandardObject();
	        	opportunity.id = opportunityRecords[i].Id;
	        	opportunity.name = opportunityRecords[i].Name;
	        	
	        	account.opportunities.push(opportunity);
	        }
	        
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					opportunityRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Account Open Opportunities failed with error: " + error);
			        return;
			    }
			}
		}
	};
	
	this.loadAccountContacts = function(account)
	{
	    var contactRecords;
	    var queryResult;
	    var moreRecords = true;

		var queryString = "SELECT Id, Name, Phone, MobilePhone FROM Contact WHERE AccountId = \'" +
			account.id + "\' ORDER BY LastName";

	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        contactRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Account Contacts failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < contactRecords.length; i++)
	        {
	        	var contact = new Contact();
	        	contact.id = contactRecords[i].Id;
	        	contact.name = contactRecords[i].Name;
	        	contact.Phone = contactRecords[i].Phone;
	        	contact.Mobile = contactRecords[i].MobilePhone;
	        	
	        	account.contacts.push(contact);
	        }
	
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					contactRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Account Contacts failed with error: " + error);
			        return;
			    }
			}
		}
	};
	
	this.loadCustomLocations = function(color, mapIcon, view)
	{
		this.customLocations = [];
		
	    var customLocationRecords;
	    var queryResult;
	    var queryString = "SELECT Id, Name, pexmaps__Latitude__c, " +
	    	"pexmaps__Longitude__c, pexmaps__Geocode_Status__c, " +
	    	"pexmaps__Street__c, pexmaps__City__c, pexmaps__State__c, pexmaps__Postal_Code__c, " +
	    	"pexmaps__Country__c, pexmaps__Geocode_Accuracy__c, pexmaps__Geocode_Address__c, " +
	    	"pexmaps__MapIconInfo__c, pexmaps__Draggable__c, pexmaps__Info__c " + 
	    	"FROM pexmaps__TerritoryCustomLocation__c WHERE pexmaps__View__c != null " +
	    	"AND pexmaps__View__c = \'" + this.id + "\' " +
	    	"AND pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\'";
	    var moreRecords = true;
	
	    try
	    {
	        queryResult = sforce.connection.query(queryString);
	        customLocationRecords = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Custom Locations failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < customLocationRecords.length; i++)
	        {
				var customLocation = new CustomLocation();
				
				customLocation.view = view;
				customLocation.id = customLocationRecords[i].Id;
				customLocation.name = customLocationRecords[i].Name;
				customLocation.color = color;
				customLocation.mapIcon = allowCustomLocationIcons ? 
					(customLocationRecords[i].pexmaps__MapIconInfo__c == null ? (allowIcons ? mapIcon : null) : customLocationRecords[i].pexmaps__MapIconInfo__c) :
					(allowIcons ? mapIcon : null);
				customLocation.draggable = !util.isDefined(customLocationRecords[i].pexmaps__Draggable__c) ? false :
					(customLocationRecords[i].pexmaps__Draggable__c == "true" ? true : false);
				customLocation.info = customLocationRecords[i].pexmaps__Info__c == null ? "" :
					customLocationRecords[i].pexmaps__Info__c;
				
				customLocation.address = new Address();

				customLocation.address.street = customLocationRecords[i].pexmaps__Street__c;
				customLocation.address.city = customLocationRecords[i].pexmaps__City__c;
				customLocation.address.state = customLocationRecords[i].pexmaps__State__c;
				customLocation.address.postalCode = customLocationRecords[i].pexmaps__Postal_Code__c;
				customLocation.address.country = customLocationRecords[i].pexmaps__Country__c;
				customLocation.address.geocodeStatus = customLocationRecords[i].pexmaps__Geocode_Status__c;
				customLocation.address.coordinates = new google.maps.LatLng(customLocationRecords[i].pexmaps__Latitude__c,
					customLocationRecords[i].pexmaps__Longitude__c);
				customLocation.address.geocodeAccuracy = customLocationRecords[i].pexmaps__Geocode_Accuracy__c;
				customLocation.address.geocodeAddress = customLocationRecords[i].pexmaps__Geocode_Address__c;
					
				customLocation.createMarker(customLocation);
					
				view.customLocations.push(customLocation);
	        }
	
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					customLocationRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch Custom Locations failed with error: " + error);
			        return;
			    }
			}
		}
	};

	this.afterInsertCustomLocation = function(customLocation)
	{
		this.customLocations.push(customLocation);
		
//		map.addOverlay(customLocation.marker);
		customLocation.marker.setMap(map);

		territories.selectedObject = customLocation;

		customLocation.editMode = customLocation.draggable;
		
		this.openCustomLocationInfoWindow(customLocation);

		document.getElementById("input_CustomLocationName").value = "";
		document.getElementById("input_CustomLocationAddress").value = "";
		util.hideLoadingImage();
	};

	this.openCustomLocationInfoWindow = function(customLocation)
	{
		var infoWindowOptions = {};
		
		//if (!customLocation.editMode)
		//{
		//	infoWindowOptions.maxContent = streetView.getContentDiv();
		//	infoWindowOptions.maxTitle = customLocation.name;
		//}

		InfoWindow.open(null, customLocation.marker);
		InfoWindow.setContent(customLocation.getHtml());
//		customLocation.marker.openInfoWindowHtml(customLocation.getHtml(), infoWindowOptions);
		
	  	google.maps.event.addListener(customLocation.marker, "infowindowopen", 
	  		function()
	  		{
				saveLastSelectedObject(territories.selectedObject.id);
	  		}
	  	);
	  	google.maps.event.addListener(customLocation.marker, "infowindowclose", 
	  		function()
	  		{
				saveLastSelectedObject("");
//				streetView.closeStreetView();
	  		}
	  	);
	};

	this.removeCustomLocation = function(customLocationId)
	{
		var customLocation = this.findCustomLocation(customLocationId);
		
		if (customLocation != null)
		{
//			map.removeOverlay(customLocation.marker);
			customLocation.marker.setMap(null);
		}

		util.showLoadingImage();	
		removeCustomLocation(customLocationId);
	};
	
	this.afterRemoveCustomLocation = function()
	{
		util.hideLoadingImage();
	};	
	
	this.saveCustomLocationIcon = function(customLocationId, customLocationIconInfo)
	{
		util.showLoadingImage();
		
		var customLocation = this.findCustomLocation(customLocationId);
		
		if (customLocation != null)
		{
//			map.removeOverlay(customLocation.marker);
			customLocation.marker.setMap(null);
			customLocation.mapIcon = customLocationIconInfo == null ?
				this.customLocationMapIcon : customLocationIconInfo;
			customLocation.createMarker(customLocation);
//			map.addOverlay(customLocation.marker);
			customLocation.marker.setMap(map);
		}
		
		saveCustomLocationIcon(customLocationId, customLocationIconInfo);
	};
	
	this.saveCustomLocationInfo = function(customLocation)
	{
		var customLocationName = util.trim(document.getElementById("input_CustomLocationName").value);
		if (customLocationName.length == 0)
		{
			customLocationName = locale.untitled;
		}
		
		var customLocationInfo = document.getElementById("textarea_CustomLocationInfo").value;
		customLocationInfo = util.replaceCrlf(customLocationInfo);

		customLocation.name = util.escapeString(customLocationName);
		customLocation.info = customLocationInfo;
		
//		customLocation.marker.closeInfoWindow();
		InfoWindow.close();
		customLocation.editMode = false;
		
		this.openCustomLocationInfoWindow(customLocation);

		util.showLoadingImage();
		
		saveCustomLocationInfo(customLocation.id, customLocationName, customLocationInfo);
	};

	this.cancelCustomLocationInfo = function(customLocation)
	{
//		customLocation.marker.closeInfoWindow();
		InfoWindow.close();
		customLocation.editMode = false;
		this.openCustomLocationInfoWindow(customLocation);
	};

}
/////////////////////////////////////////////////////////////////////////////////////
// AddMapMarker
/////////////////////////////////////////////////////////////////////////////////////
function AddMapMarker()
{
	this.cleanUp = function()
	{
		var handButton = document.getElementById("button_Hand");
		if (handButton != null)
		{ 
			handButton.style.backgroundImage = "url('" + territoriesImagePath + "Bsd.png')";
		}
		
		var markerButton = document.getElementById("button_PlaceMarker");
		if (markerButton != null)
		{ 
			markerButton.style.backgroundImage = "url('" + territoriesImagePath + "Bmu.png')";
		}
		
		if (this.draggableCustomLocationListener != null)
		{
			google.maps.event.removeListener(this.draggableCustomLocationListener);
			this.draggableCustomLocationListener = null;
		}
	};
	
	this.addDraggableCustomLocation = function()
	{
		document.getElementById("button_Hand").style.backgroundImage = "url('" + territoriesImagePath + "Bsu.png')";
		document.getElementById("button_PlaceMarker").style.backgroundImage = "url('" + territoriesImagePath + "Bmd.png')";
		
		var listener = google.maps.event.addListener(map, "click", 
			function(event) 
			{
				var latLng = event.latLng;
				
    			if (latLng != null) 
    			{
    				InfoWindow.close();
//    				territories.closeInfoWindow();
    				
					document.getElementById("button_Hand").style.backgroundImage = "url('" + territoriesImagePath + "Bsd.png')";
					document.getElementById("button_PlaceMarker").style.backgroundImage = "url('" + territoriesImagePath + "Bmu.png')";

      				google.maps.event.removeListener(listener);
      				addMapMarker.draggableCustomLocationListener = null;
      				
					addMapMarker.draggableCustomLocation = new CustomLocation();
					addMapMarker.draggableCustomLocation.address = new Address();
					addMapMarker.draggableCustomLocation.address.coordinates = latLng;
					addMapMarker.draggableCustomLocation.address.geocodeAddress = 
						String(latLng.lat()) + ", " + String(latLng.lng());      				
					
					util.showLoadingImage();
					insertDraggableCustomLocation(latLng.lat(), latLng.lng());
				}
			}
		);
		
		addMapMarker.draggableCustomLocationListener = listener;
	};
	
	this.afterInsertDraggableCustomLocation = function()
	{
		var customLocation = addMapMarker.draggableCustomLocation;
		customLocation.id = 
			document.getElementById("page_Territories:form_Territories:hidden_InsertCustomLocationId").value;
		customLocation.name = locale.untitled;
		customLocation.address.geocodeStatus = "G_GEO_SUCCESS";
		customLocation.address.geocodeAccuracy = 9;
		customLocation.view = territories.view;
		customLocation.color = territories.view.customLocationMarkerColor;
		customLocation.mapIcon = allowIcons ? territories.view.customLocationMapIcon : null;
		customLocation.draggable = true;

		customLocation.createMarker(customLocation);

		territories.view.afterInsertCustomLocation(customLocation);
	};	

	this.addGeocodeCustomLocation = function()
	{
		util.showLoadingImage();

		this.cleanUp();

		var locationName = document.getElementById("input_CustomLocationName").value;
		var locationAddress = document.getElementById("input_CustomLocationAddress").value;
		
		this.startGeocodeCustomLocation(locationName, locationAddress);
	};

	this.startGeocodeCustomLocation = function(locationName, locationAddress)
	{
		if (locationName.length == 0)
		{
			util.hideLoadingImage();
			alert(locale.pleaseEnterAName);
			return;
		}
		
		this.geocodingCustomLocation = new CustomLocation();
		this.geocodingCustomLocation.name = locationName;
		this.geocodingCustomLocation.address = new Address();
		
		if (util.isDefined(territories.view))
		{
			this.geocodingCustomLocation.color = territories.view.customLocationMarkerColor;
			this.geocodingCustomLocation.mapIcon = allowIcons ? territories.view.customLocationMapIcon : null;
		}

		if (locationAddress != null && locationAddress.length > 0)
		{
			this.geocodingCustomLocation.address.street = locationAddress;
		}
		
		
		geocoding.geocodeCustomLocation(this.geocodingCustomLocation,
			this.processGeocodeCustomLocation);
	};

	this.processGeocodeCustomLocation = function(results, status)
	{
		addMapMarker.geocodingCustomLocation.address.geocodeStatus = 
			geocoding.convertResponseCode(status);
		
		var latitude = "0.0";
		var longitude = "0.0";
		
		if (status == google.maps.GeocoderStatus.OK)
		{
			var result = results[0];
			
			latitude = result.geometry.location.lat();
			longitude = result.geometry.location.lng();
			
			addMapMarker.geocodingCustomLocation.address.coordinates = new google.maps.LatLng(latitude, longitude);
			
			if (util.isDefined(territories.view))
			{
				addMapMarker.geocodingCustomLocation.createMarker(addMapMarker.geocodingCustomLocation);
			}
		}
		else
		{
			alert(locale.couldNotResolveName.replace("{0}", addMapMarker.geocodingCustomLocation.name));
			addMapMarker.insertGeocodeCustomLocationFailed();				
			return;
		}

		if (!addMapMarker.initCustomLocationFromGeocodeResult(result))
		{
			alert(locale.errorParsingGeocode);
			addMapMarker.insertGeocodeCustomLocationFailed();				
			return;
		}
		
		eval('insertGeocodeCustomLocation("' +
			addMapMarker.geocodingCustomLocation.name + '","' +
			addMapMarker.geocodingCustomLocation.address.geocodeStatus + '","' +
			latitude + '","' + 
			longitude + '","' + 
			addMapMarker.geocodingCustomLocation.address.street + '","' + 
			addMapMarker.geocodingCustomLocation.address.city + '","' + 
			addMapMarker.geocodingCustomLocation.address.state + '","' + 
			addMapMarker.geocodingCustomLocation.address.postalCode + '","' + 
			addMapMarker.geocodingCustomLocation.address.country + '","' +
			addMapMarker.geocodingCustomLocation.address.geocodeAddress + '",' +
			addMapMarker.geocodingCustomLocation.address.geocodeAccuracy + ');');
	};

	this.afterInsertGeocodeCustomLocation = function()
	{
		this.geocodingCustomLocation.id =
			document.getElementById("page_Territories:form_Territories:hidden_InsertCustomLocationId").value;

		territories.view.afterInsertCustomLocation(this.geocodingCustomLocation);
	};

	this.insertGeocodeCustomLocationFailed = function()
	{
		document.getElementById("input_CustomLocationName").value = "";
		document.getElementById("input_CustomLocationAddress").value = "";
		util.hideLoadingImage();
	};
	
	this.initCustomLocationFromGeocodeResult = function(result)
	{
		addMapMarker.geocodingCustomLocation.address.street = "";
		addMapMarker.geocodingCustomLocation.address.city = "";
		addMapMarker.geocodingCustomLocation.address.state = "";
		addMapMarker.geocodingCustomLocation.address.postalCode = "";
		addMapMarker.geocodingCustomLocation.address.country = "";
		addMapMarker.geocodingCustomLocation.address.geocodeAccuracy = 0;
		addMapMarker.geocodingCustomLocation.address.geocodeAddress = result.formatted_address.replace(/"/gi, "'");

		for (var i = 0; i < result.address_components.length; i++)
		{
			var addressComponent = result.address_components[i];
			
			if (addressComponent.types.contains("establishment"))
			{
				addMapMarker.geocodingCustomLocation.name = addressComponent.long_name;
			}
			else if (addressComponent.types.contains("street_number"))
			{
				addMapMarker.geocodingCustomLocation.address.street += (addressComponent.long_name + " ");
			}
			else if (addressComponent.types.contains("route"))
			{
				addMapMarker.geocodingCustomLocation.address.street += addressComponent.short_name;
			}
			else if (addressComponent.types.contains("locality") &&
				addressComponent.types.contains("political"))
			{
				addMapMarker.geocodingCustomLocation.address.city = addressComponent.long_name;
			}
			else if (addressComponent.types.contains("administrative_area_level_1") &&
				addressComponent.types.contains("political"))
			{
				addMapMarker.geocodingCustomLocation.address.state = addressComponent.long_name;
			}
			else if (addressComponent.types.contains("postal_code"))
			{
				addMapMarker.geocodingCustomLocation.address.postalCode += addressComponent.long_name;
			}
			else if (addressComponent.types.contains("country") &&
				addressComponent.types.contains("political"))
			{
				addMapMarker.geocodingCustomLocation.address.ccountry = addressComponent.short_name;
			}
		}

		return true;
	};
	
}

/////////////////////////////////////////////////////////////////////////////////////
// RoleBasedView
/////////////////////////////////////////////////////////////////////////////////////
RoleBasedView.prototype = new View();
function RoleBasedView()
{
	this.load = function(view)
	{
		var useAllUsersAndRoles = false;
		var roleDefinitions = this.definition.split(separator.currency);
		var userIds = "";

		for (var i = 0; i < roleDefinitions.length; i++)
		{
			var roleDefinition = roleDefinitions[i];
			var usersData = roleDefinition.split(separator.section);
			var roleData = usersData[0].split(separator.para); 
			
			var roleId = roleData[0];
			var roleColor = roleData[1];
			var roleMapIcon = (roleData.length >= 3) ? roleData[2] : null;

			if (roleId == null || roleId.length == 0)
			{
				this.useAllUsersAndRoles = true;
			}

			for (var j = 1; j < usersData.length; j++)
			{
				var userDataItems = usersData[j].split(separator.para);
				var userId = userDataItems[0]; 
				var userObjectColor = userDataItems[1];
				var userMapIcon = (userDataItems.length >= 3) ? userDataItems[2] : null;
				
				var color = this.type == "Single Role" ? userObjectColor : roleColor;
				var mapIcon = this.type == "Single Role" ? userMapIcon : roleMapIcon;

				var whereClause = "";
				
				if (!this.useAllUsersAndRoles)
				{
					if (this.viewObject == "Asset")
					{
						whereClause += "Account.OwnerId";
					}
					else if (this.viewObject == "Product2")
					{
						whereClause += this.getParentRelationshipName() + ".OwnerId";
					}
					else
					{
						var masterDetailRelationshipName = this.masterDetailRelationshipName;
						if (masterDetailRelationshipName != null &&
							masterDetailRelationshipName.length > 0)
						{
							masterDetailRelationshipName += ".";
						}
						else
						{
							masterDetailRelationshipName = "";
						}
						
						whereClause += masterDetailRelationshipName + "OwnerId";
					}
					
					whereClause += " = '" + userId + "'";
				}		

		    	whereClause = this.appendMultiFieldFilterWhereClause(whereClause); 

				var colors = [];
				var mapIcons = [];
				var whereClauses = [];
				
				if (view.type == "Combination" && !view.retainViewColors)
				{
					colors.push(view.getViewColor(this.id));
					mapIcons.push(view.getViewMapIcon(this.id));

					whereClauses.push(this.appendSingleFieldFilterWhereClause(whereClause));
				}
				else
				{
					this.parseColorsAndWhereClauses(colors, mapIcons, whereClauses, color, mapIcon, whereClause);
				}
				
				this.loadMapObjects(colors, mapIcons, whereClauses, view);
				
				if (userIds.length > 0)
				{
					userIds += ",";
				}
				userIds += "\'" + userId + "\'";
			}
			
		}

		this.saveStatistics();
		
		if (this.showUserMarkers)
		{
			this.loadUsers(userIds, view.userMarkerColor, view.userMapIcon, view);
		}

		if (this.showOwnerMarker)
		{
			this.loadOwner(this.ownerId, view);
		}

		this.loadCustomLocations(view.customLocationMarkerColor, view.customLocationMapIcon, view);
		
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// ListBasedView
/////////////////////////////////////////////////////////////////////////////////////
ListBasedView.prototype = new View();
function ListBasedView()
{
	this.load = function(view)
	{
		var viewData = this.definition.split(separator.para);
		
		var itemColor = viewData[0];
		var itemIds = viewData[1];
		var mapIcon = viewData.length < 3 ? null : viewData[2]; 
		
		var colors = [];
		var mapIcons = [];
		var whereClauses = [];
		var whereClause = "Id IN (" + itemIds + ") ";
		
		whereClause = this.appendMultiFieldFilterWhereClause(whereClause); 
		
		
		if (view.type == "Combination" && !view.retainViewColors)
		{
			colors.push(view.getViewColor(this.id));
			mapIcons.push(view.getViewMapIcon(this.id));
			whereClauses.push(whereClause);
		}
		else
		{
			this.parseColorsAndWhereClauses(colors, mapIcons, whereClauses, itemColor, mapIcon, whereClause);
		}

		this.saveStatistics();
		
		this.loadMapObjects(colors, mapIcons, whereClauses, view);

		if (this.showOwnerMarker)
		{
			this.loadOwner(this.ownerId, view);
		}

		this.loadCustomLocations(view.customLocationMarkerColor, view.customLocationMapIcon, view);
	};

}


/////////////////////////////////////////////////////////////////////////////////////
// CampaignView
/////////////////////////////////////////////////////////////////////////////////////
CampaignView.prototype = new View();
function CampaignView()
{
	this.load = function(view)
	{
		var viewData = this.definition.split(separator.para);
		this.campaignId = viewData[0];
		
		var campaignContactMarkerColor = viewData[1];
		var campaignLeadMarkerColor = viewData[2];
		var campaignOpportunityMarkerColor = viewData[3];
		var campaignMultiObjectMarkerColor = viewData[4];
		var campaignContactMapIcon = viewData.length < 8 ? null : viewData[5];
		var campaignLeadMapIcon = viewData.length < 8 ? null : viewData[6];
		var campaignOpportunityMapIcon = viewData.length < 8 ? null : viewData[7];

		var color = campaignLeadMarkerColor;
		var whereClause = " AND Id != null";
    	whereClause += this.multiFieldFilterWhereClause.length == 0 ? "" : " AND " + this.multiFieldFilterWhereClause; 
		var colors = [];
		var mapIcons = [];
		var whereClauses = [];
		
		if (view.type == "Combination" && !view.retainViewColors)
		{
			colors.push(view.getViewColor(this.id));
			mapIcons.push(view.getViewMapIcon(this.id));
			whereClauses.push(this.appendSingleFieldFilterWhereClause(whereClause));
		}
		else
		{
			this.parseColorsAndWhereClauses(colors, mapIcons, whereClauses, color, campaignLeadMapIcon, whereClause);
		}	
		this.loadMapObjects(colors, mapIcons, whereClauses, "Lead", view);

		color = campaignContactMarkerColor;
		colors = [];
		mapIcons = [];
		whereClauses = [];
		if (view.type == "Combination")
		{
			colors.push(view.getViewColor(this.id));
			mapIcons.push(view.getViewMapIcon(this.id));
			whereClauses.push(this.appendSingleFieldFilterWhereClause(whereClause));
		}
		else
		{
			this.parseColorsAndWhereClauses(colors, mapIcons, whereClauses, color, campaignContactMapIcon, whereClause);
		}	
		this.loadMapObjects(colors, mapIcons, whereClauses, "Contact", view);

		color = campaignOpportunityMarkerColor;
		colors = [];
		mapIcons = [];
		whereClauses = [];
		if (view.type == "Combination")
		{
			colors.push(view.getViewColor(this.id));
			mapIcons.push(view.getViewMapIcon(this.id));
			whereClauses.push(this.appendSingleFieldFilterWhereClause(whereClause));
		}
		else
		{
			this.parseColorsAndWhereClauses(colors, mapIcons, whereClauses, color, campaignOpportunityMapIcon, whereClause);
		}	
		this.loadMapObjects(colors, mapIcons, whereClauses, "Opportunity", view);

		if (this.showOwnerMarker)
		{
			this.loadOwner(this.ownerId, view);
		}
		
		this.loadCustomLocations(view.customLocationMarkerColor, view.customLocationMapIcon, view);
	};

	this.loadMapObjects = function(colors, mapIcons, whereClauses, campaignMemberType, view)
	{
	    var queryString;
	
		for (var i = 0; i < whereClauses.length; i++)
		{
			if (campaignMemberType == "Opportunity")
			{
				if (this.singleFieldFilterWhereClause == "" && this.multiFieldFilterWhereClause == "")
				{
				    queryString = "SELECT Id, Name, Account.Id, Account.Name " +
				    	"FROM Opportunity WHERE CampaignId = \'" + this.campaignId + "\' AND Account.Id != null AND " + 
				    	"Opportunity.Account.pexmaps__Billing_Geocode_Status__c = \'G_GEO_SUCCESS\' " +
				    	whereClauses[i];

					this.loadOpportunities(colors[i], mapIcons[i], queryString, view);
				}
			}
			else if (campaignMemberType == "Lead")
			{
			    queryString = "SELECT Lead.Id, Lead.Name, Lead.Company, Lead.Phone, Lead.MobilePhone, Lead.pexmaps__Latitude__c, " +
			    	"Lead.pexmaps__Longitude__c, Lead.pexmaps__Geocode_Status__c, Lead.Street, " +
			    	"Lead.City, Lead.State, Lead.PostalCode, Lead.Country, Lead.pexmaps__Geocode_Accuracy__c, " +
			    	"Lead.pexmaps__Geocode_Address__c " +
			    	"FROM CampaignMember WHERE CampaignId = \'" + this.campaignId + "\' AND " +
			    	"Lead.IsConverted = false AND Lead.pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\' " +
			    	whereClauses[i];
					    	
				view.leads = view.leads.concat(this.loadLeads(colors[i], mapIcons[i], queryString, view));
			}
			else if (campaignMemberType == "Contact")
			{
				if (this.useContactAddress)
				{
				    queryString = "SELECT Contact.Id, Contact.Name, Contact.Account.Id, Contact.Account.Name, Contact.pexmaps__Latitude__c, " +
				    	"Contact.pexmaps__Longitude__c, Contact.pexmaps__Geocode_Status__c, Contact.MailingStreet, " +
				    	"Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.MailingCountry, " +
				    	"Contact.pexmaps__Geocode_Accuracy__c, Contact.pexmaps__Geocode_Address__c " +
				    	"FROM CampaignMember WHERE CampaignId = \'" + this.campaignId + "\' AND " +
			    		"Contact.pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\' " +
				    	whereClauses[i];
				}
				else
				{
				    queryString = "SELECT Contact.Id, Contact.Name, Contact.Account.Id, Contact.Account.Name, Contact.pexmaps__Latitude__c, " +
				    	"Contact.pexmaps__Longitude__c, Contact.pexmaps__Geocode_Status__c, Contact.MailingStreet, " +
				    	"Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.MailingCountry, " +
				    	"Contact.pexmaps__Geocode_Accuracy__c, Contact.pexmaps__Geocode_Address__c, " +
				    	"Contact.Account.pexmaps__Billing_Geocode_Status__c " +
				    	"FROM CampaignMember WHERE CampaignId = \'" + this.campaignId + "\' AND " +
					 	"((Contact.AccountId != null AND Contact.Account.pexmaps__Billing_Geocode_Status__c = \'G_GEO_SUCCESS\') " +
						"OR (Contact.AccountId = null AND Contact.pexmaps__Geocode_Status__c = \'G_GEO_SUCCESS\')) " +
				    	whereClauses[i];
				}
	    	
				view.contacts = view.contacts.concat(this.loadContacts(colors[i], mapIcons[i], queryString, view));
			}
		}
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// CustomView
/////////////////////////////////////////////////////////////////////////////////////
CustomView.prototype = new View();
function CustomView()
{
	this.load = function(view)
	{
		if (this.showOwnerMarker)
		{
			this.loadOwner(this.ownerId, view);
		}
		
		var color = (view.type == "Combination" && !view.retainViewColors) ?
			view.getViewColor(this.id) : this.customLocationMarkerColor;
		
		var mapIcon = (view.type == "Combination" && !view.retainViewColors) ?
			view.getViewMapIcon(this.id) : this.customLocationMapIcon;

		this.saveStatistics();
		
		this.loadCustomLocations(color, mapIcon, view);
	};

	this.findObject = function(objectId)
	{
		return this.findCustomLocation(objectId);
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// UserView
/////////////////////////////////////////////////////////////////////////////////////
UserView.prototype = new View();
function UserView()
{
	this.load = function(view)
	{
		var color = this.userMarkerColor;
		var mapIcon = this.userMapIcon;

		var whereClause = "";
				
    	whereClause = this.appendMultiFieldFilterWhereClause(whereClause); 

		var colors = [];
		var mapIcons = [];
		var whereClauses = [];
				
		if (view.type == "Combination" && !view.retainViewColors)
		{
			colors.push(view.getViewColor(this.id));
			mapIcons.push(view.getViewMapIcon(this.id));

			whereClauses.push(this.appendSingleFieldFilterWhereClause(whereClause));
		}
		else
		{
			this.parseColorsAndWhereClauses(colors, mapIcons, whereClauses, color, mapIcon, whereClause);
		}
				
		this.loadMapObjects(colors, mapIcons, whereClauses, view);
				
		this.saveStatistics();
		
		if (this.showOwnerMarker)
		{
			this.loadOwner(this.ownerId, view);
		}

		this.loadCustomLocations(view.customLocationMarkerColor, view.customLocationMapIcon, view);
	};
	
	this.findObject = function(objectId)
	{
		return this.findUser(objectId);
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// CombinationView
/////////////////////////////////////////////////////////////////////////////////////
CombinationView.prototype = new View();
function CombinationView()
{
	this.viewData = [];
	this.views = [];
	
	this.load = function(view)
	{
		var viewDefinitions = this.definition.split(separator.section);
		
		for (var i = 0; i < viewDefinitions.length; i++)
		{
			var viewDefinition = viewDefinitions[i].split(separator.para);
			
			var viewMapIcon = viewDefinition.length < 6 ? null : viewDefinition[5];
			
			this.viewData.push(new ViewData(viewDefinition[0],
				viewDefinition[1], viewDefinition[2], viewDefinition[3],
				viewDefinition[4], viewMapIcon));
		}

		util.showLoadingImage();

		territories.setAbortLoadCombinationView(false);
		this.loadNextView();
	};
	
	this.addView = function(nextView)
	{
		this.views.push(nextView);
	};
	
	this.loadNextView = function()
	{
		if (this.views.length >= this.viewData.length)
		{
			endLoadingViews();
		}
	
		var viewId = this.viewData[this.views.length].id;
		
		loadNextView(viewId);
	};

	this.getViewColor = function(viewId)
	{
		for (var i = 0; i < this.viewData.length; i++)
		{
			if (this.viewData[i].id == viewId)
			{
				return this.viewData[i].color;
			}
		}
		
		return this.DEFAULT_MARKER_COLOR;
	};

	this.getViewMapIcon = function(viewId)
	{
		for (var i = 0; i < this.viewData.length; i++)
		{
			if (this.viewData[i].id == viewId)
			{
				return this.viewData[i].mapIcon;
			}
		}
		
		return null;
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// Territories
/////////////////////////////////////////////////////////////////////////////////////
function Territories()
{
	this.init = function()
	{
		//if (GBrowserIsCompatible())
		//{
			this.createMap();
			this.initMap();
	  	//}
	};

	this.createMap = function()
	{
		map = new google.maps.Map(getMapCanvas(), {overviewMapControl: true});
	};

	this.initMap = function()
	{
	    this.resetMap();
	    
	   	//map.setUIToDefault();
		
/*		
		if (!printView)
		{	
			map.enableGoogleBar();

			map.addControl(new GOverviewMapControl());
			map.addMapType(G_PHYSICAL_MAP);
			map.addControl(new GMenuMapTypeControl());
 			map.addControl(new MoreControl());
 			map.addControl(new TrafficControl());
		}

		map.addControl(new GLargeMapControl3D());
		this.createDragZoomControl();
		this.addDragZoomControl();
*/
	
		if (!printView)
		{
	  		new SearchBoxControl().create().init();
	  	}


	    	






		var trafficControlDiv = document.createElement('div');
  		var trafficControl = new TrafficControl(trafficControlDiv);
  		trafficControlDiv.index = 1;
  		map.controls[google.maps.ControlPosition.TOP_RIGHT].push(trafficControlDiv);
		trafficLayer = new google.maps.TrafficLayer();



		var transitControlDiv = document.createElement('div');
  		var transitControl = new TransitControl(transitControlDiv);
  		transitControlDiv.index = 2;
  		map.controls[google.maps.ControlPosition.TOP_RIGHT].push(transitControlDiv);
		transitLayer = new google.maps.TransitLayer();



		var weatherControlDiv = document.createElement('div');
  		var weatherControl = new WeatherControl(weatherControlDiv);
  		weatherControlDiv.index = 3;
  		map.controls[google.maps.ControlPosition.TOP_RIGHT].push(weatherControlDiv);
		weatherLayer = new google.maps.weather.WeatherLayer({temperatureUnits: google.maps.weather.TemperatureUnit.FAHRENHEIT});
  		cloudLayer = new google.maps.weather.CloudLayer();
  
  	
		
		//google.maps.event.addListener(map.getInfoWindow(), "maximizeend", 
		//	function()
		//	{
		//		streetView.openStreetView();
		//	}
		//);
		
		//google.maps.event.addListener(map.getInfoWindow(), "restoreclick", 
		//	function()
		//	{
		//		streetView.closeStreetView();
		//	}
		//);

		google.maps.event.addListener(InfoWindow, "closeclick", 
			function()
			{
				saveLastSelectedObject("");
//				streetView.closeStreetView();
			}
		);
		
		google.maps.event.addListener(map, "zoom_changed",
			function()
			{
				gis.onZoomLevelChange();
				heatMaps.onZoomLevelChange();
				boundaries.onZoomLevelChange();
			}
		);

		
/*
		// REDONE! DON'T NEED
		google.maps.event.addListener(map, "infowindowopen", 
			function()
			{
				gis.onInfoWindowOpen();
			}
		);

		google.maps.event.addListener(map, "infowindowclose", 
			function()
			{
				if (typeof jscolor != "undefined" &&
					typeof jscolor.hidePicker == "function")
				{		
					jscolor.hidePicker();
				}
			}
		);
		
*/

		google.maps.event.addListener(map, "dragend",
			function()
			{
				heatMaps.onMoveMap();
			}
		);

		google.maps.event.addListener(map, "dblclick", 
			function()
			{
				gis.onMapDblClick();
				heatMaps.onMapDblClick();
				boundaries.onMapDblClick();
			}
		);

		google.maps.event.addListener(map, "click",
			function(event)
			{
				gis.onMapClick(event.latLng);
				boundaries.onMapClick(event.latLng);
			}
		);
		
//		google.maps.event.addListener(map, "mousedown",
//			function(event)
//			{
//				outlines.onMapMouseDown(event.latLng);
//			}
//		);
		
		
	};
/*
	this.addDragZoomControl = function()
	{
		if (this.dragZoomControl != null && this.dragZoomControlVisible == false)
		{
	        map.addControl(this.dragZoomControl, new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(28 ,300)));
	        this.dragZoomControlVisible = true;
	    }
	};
	
	this.removeDragZoomControl = function()
	{
		if (this.dragZoomControl != null && this.dragZoomControlVisible == true)
		{
			map.removeControl(this.dragZoomControl);
			this.dragZoomControlVisible = false;
		}
	};

	this.createDragZoomControl = function()
	{
        var boxStyleOptions = {};
        boxStyleOptions.opacity = .2;
        boxStyleOptions.fillColor = "black";
        boxStyleOptions.border = "1px solid black";
        
        var otherOptions = {};
        otherOptions.buttonStyle = "background:transparent";
        otherOptions.buttonZoomingStyle = "background:transparent";
        otherOptions.buttonHTML = "<img src='" + territoriesImagePath + "drag_zoom_inactive.png' title='" + locale.dragZoom + "'/>";
        otherOptions.buttonZoomingHTML = "<img src='" + territoriesImagePath + "drag_zoom_active.png'/>";
        otherOptions.buttonStartingStyle = {width: '19px', height: '19px'};
        otherOptions.overlayRemoveTime = 0;
        otherOptions.rightMouseZoomOutEnabled = true;
        
        this.dragZoomControl = new DragZoomControl(boxStyleOptions, otherOptions, {});
        this.dragZoomControlVisible = false;
	};
*/
	this.resetMap = function()
	{
		map.setOptions({
			center: new google.maps.LatLng(centerLatitude, centerLongitude),
			zoom: initialZoom,
			mapTypeId: mapType });	
	
//		map.setMapTypeId(mapType);
//	    map.setCenter(new google.maps.LatLng(centerLatitude, centerLongitude));
//	    map.setZoom(initialZoom);
	};

	this.resetMapFromViewState = function()
	{
		map.setOptions({
			center: new google.maps.LatLng(Number(this.view.viewMapCenterLatitude), 
    			Number(this.view.viewMapCenterLongitude)),
			zoom: Number(this.view.viewMapZoom),
			mapTypeId: mapTypeIds[this.view.viewMapType] });	
	
	
//		//map.setMapType(util.getMapTypeFromTypeString(this.view.viewMapType));
//		map.setMapTypeId(this.view.viewMapType);
//    	map.setCenter(new google.maps.LatLng(Number(this.view.viewMapCenterLatitude), 
//    		Number(this.view.viewMapCenterLongitude)), Number(this.view.viewMapZoom));
	};

	this.loadExistingView = function()
	{
		this.beforeLoadView();
		this.afterLoadView();
	};	
	
	this.loadExistingTrip = function()
	{
		if (!printView)
		{
			return;
		}
		
		if (util.isDefined(this.view) && this.view != null)
		{
			if (this.view.selectedTripId != null &&
				this.view.selectedTripId.length > 0 &&
				this.view.selectedTripId != "000000000000000000")
			{
				trip.loadTrip();				
			}
		}
	};
	
	this.getTypedView = function()
	{
		var view;
		
		var viewDefinition = document.getElementById('page_Territories:form_Territories:hidden_ViewDefinition').value;
		var viewType = document.getElementById('page_Territories:form_Territories:hidden_ViewType').value;

		if ((viewDefinition == null || viewDefinition.length == 0) && 
			(viewType == null || viewType.length == 0))
		{
			return;
		}

		switch(viewType)
		{
			case 'Custom':
				view = new CustomView();
				break;
			case 'Campaign':
				view = new CampaignView();
				break;
			case 'List Based':
				view = new ListBasedView();
				break;
			case 'Single Role':
			case 'Multiple Role':
				view = new RoleBasedView();
				break;
			case 'Combination':
				view = new CombinationView();
				break;
			case 'User':
				view = new UserView();
				break;
			default:
				return null;
		}
		
		return view;
	};
	
	this.createView = function()
	{
		var view = this.getTypedView();
		
		if (view == null)
		{
			var selectedAccountId = document.getElementById("page_Territories:form_Territories:hidden_SelectedAccountId").value;		

			if (selectedAccountId == "000000000000000")
			{
				alert(locale.noAssignedRole);
			}
			
			return false;
		} 

		if (!view.initialize())
		{
			return false;
		}

		var readOnlyOutlines = false;

		if (this.view != null &&
			this.view.type == "Combination")
		{
			readOnlyOutlines = true;
			this.view.addView(view);
		}
		else
		{
			this.view = view;
		}
		
		this.view.setMapState();

		view.load(this.view);

		outlines.loadViewOutlines(readOnlyOutlines);		
		
		view.showMarkers();
		
		return true;
		
	}

	this.showSelectedAccountInfoWindow = function()
	{
		if (this.view != null && this.view.selectedAccountId != null &&
			this.view.selectedAccountId.length > 0)
		{
			var selectedAccount = this.view.findAccount(this.view.selectedAccountId);

			if (selectedAccount != null)
			{			
				this.popupInfoWindow(selectedAccount);
			}
			else
			{
				alert(locale.accountNotOnMap.replace("{0}", this.view.selectedAccountName));
			}
		}
	};
	
	this.showLastSelectedObjectInfoWindow = function()
	{
		var lastSelectedObjectId = document.getElementById("page_Territories:form_Territories:hidden_LastSelectedObjectId").value;
		
		if (this.view != null &&
			lastSelectedObjectId != null && lastSelectedObjectId.length > 0)
		{
			this.popupInfoWindowFromId(lastSelectedObjectId);
		}
	};
	
	this.popupInfoWindowFromId = function(mapObjectId)
	{
		var mapObject = this.view.findObject(mapObjectId);
		
		if (mapObject != null)
		{
			this.popupInfoWindow(mapObject);
		}
	};
	
	this.popupInfoWindow = function(mapObject)
	{
		territories.selectedObject = mapObject;
		mapObject.fetchRelatedObjects();
		var mapObjectHtml = mapObject.getHtml();
		
		//var infoWindowOptions = {};
		//infoWindowOptions.maxContent = streetView.getContentDiv();
		//infoWindowOptions.maxTitle = mapObject.name;


		InfoWindow.setContent(mapObjectHtml);
		InfoWindow.open(map, mapObject.marker);

//		mapObject.marker.openInfoWindowHtml(mapObjectHtml, infoWindowOptions);

/*
		DONE!
	  	google.maps.event.addListener(mapObject.marker, "infowindowclose", 
	  		function()
	  		{
				streetView.closeStreetView();
	  		}
	  	);
	  	
*/	  	
	};

	this.clearAllMapMarkers = function()
	{
		if (this.view != null)
		{
			this.view.hideMarkers();
		}
		
//		map.clearOverlays();
	};
	
/*	
	this.closeInfoWindow = function()
	{
		if (util.isDefined(this.selectedObject))
		{
			this.selectedObject.closeInfoWindow();
		}
	};
*/
	
	this.beforeLoadView = function()
	{
		util.showLoadingImage();
		InfoWindow.close();
//		this.closeInfoWindow();
		
		if (this.view != null)
		{
			this.view.hideLegend();
this.view.hideMarkers();			
		};		
		
		// If a non-combo view is selected after a combination view is loaded
		// and this isn't set, it appears as if the newly loaded
		// view is part of the combination
		this.view = null;
		
		if (trip.started)
		{
			trip.onClickCloseTrip();
		}
	};
	
	this.loadSelectedView = function()
	{
	
		addMapMarker.cleanUp();
		outlines.cleanUp();
		heatMaps.cleanUp();
		gis.cleanUp();
		
		
if (trip.started)
{
	trip.onClickCloseTrip();
}
this.clearAllMapMarkers();


		this.beforeLoadView();
		
		
		loadSelectedView();
	};

	this.reloadView = function()
	{
		this.beforeLoadView();
		reloadView();
	};
	
	this.afterLoadView = function()
	{
//		this.clearAllMapMarkers();
		outlines.clearAllOutlines();		

		if (!this.createView())
		{
			util.hideLoadingImage();
			return;
		}

//		outlines.loadViewOutlines(false);		
	
		if (this.view == null ||
			this.view.type != "Combination")
		{
			util.hideLoadingImage();
			this.showInitialPopups();
			if (this.view != null)
			{
				this.view.setMapState();
				this.view.showLegend();
			}			
		}
	};

	this.afterLoadNextView = function()
	{
		if (this.getAbortLoadCombinationView())
		{
			util.hideLoadingImage();
			return;
		}

		this.createView();
//		outlines.loadViewOutlines(this.view.type == "Combination");		

		this.view.loadNextView();
	};

	this.onEndLoadingViews = function()
	{
		this.view.showLegend();
		this.view.showMarkers();
		util.hideLoadingImage();
	};

	this.getAbortLoadCombinationView = function()
	{
		return document.getElementById("page_Territories:form_Territories:hidden_AbortCombinationViewLoad").value == "true" ? true : false;
	};

	this.setAbortLoadCombinationView = function(abort)
	{
		document.getElementById("page_Territories:form_Territories:hidden_AbortCombinationViewLoad").value = abort ? "true" : "false";
	};
	
	
	this.showInitialPopups = function()
	{
		this.showSelectedAccountInfoWindow();
		this.showLastSelectedObjectInfoWindow();
		
		if (util.isDefined(this.selectedObject))
		{
		    map.setCenter(this.selectedObject.marker.getPosition(), initialZoom);
		}
	};
	
	this.getMapCenterAndZoom = function()
	{
		document.getElementById("page_Territories:form_Territories:block_Territories:hidden_CurrentMapCenterAndZoom").value =
			map.getCenter().lat() + separator.para + map.getCenter().lng() + separator.para + map.getZoom();
	};

}

/////////////////////////////////////////////////////////////////////////////////////
// ViewListing
/////////////////////////////////////////////////////////////////////////////////////
function ViewListing(letter)
{
	this.changeLetterFilter = function(letter)
	{
		util.showLoadingImage();
		letterFilterChanged(letter);
	};
	
	this.afterChangeLetterFilter = function()
	{
		util.hideLoadingImage();
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// IconMaker
/////////////////////////////////////////////////////////////////////////////////////
function IconMaker()
{
	this.getIcon = function(color, mapIcon)
	{
		if (!util.isDefined(this.icons))
		{
			this.icons = [];
		}

		if (mapIcon != null && mapIcon.length > 0)
		{
			var iconDefinition = mapIcon.split(separator.leftAngle);
			var iconName = iconDefinition[0];
			
			if (!util.isDefined(this.icons[iconName]))
			{
/*			
				var icon = new GIcon();
				icon.image = mapIconImagePath + iconDefinition[0];
				icon.shadow = mapIconImagePath + iconDefinition[1];
				icon.iconSize = new GSize(Number(iconDefinition[2]), Number(iconDefinition[3]));
				icon.shadowSize = new GSize(Number(iconDefinition[4]), Number(iconDefinition[5]));
				icon.iconAnchor = new GPoint(Number(iconDefinition[6]), Number(iconDefinition[7]));
				icon.dragCrossAnchor = new GPoint(0, 8);
				icon.infoWindowAnchor = new GPoint(Number(iconDefinition[8]), Number(iconDefinition[9]));
				this.icons[iconName] = icon;
*/				

				this.icons[iconName] = {
					anchor: new google.maps.Point(Number(iconDefinition[6]), Number(iconDefinition[7])),
					size: new google.maps.Size(Number(iconDefinition[2]), Number(iconDefinition[3])),
					url: mapIconImagePath + iconDefinition[0]
				};
			}
			
			return this.icons[iconName];
		}
		else
		{		
			if (!util.isDefined(this.icons[color]))
			{
				var iconOptions = {};
				iconOptions.width = markerSize;
				iconOptions.height = markerSize;
				iconOptions.primaryColor = color;
				iconOptions.cornerColor = "#FFFFFF";
				iconOptions.strokeColor = "#000000";
				this.icons[color] = MapIconMaker.createMarkerIcon(iconOptions);
			}
			
			return this.icons[color];
		}
	};
	
	this.getTripIcon = function(waypointIndex)
	{
		var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		
		return {
			anchor: new google.maps.Point(10, 34),
			size: new google.maps.Size(20, 34),
			url: iconsPath + "marker_green" + letters[waypointIndex] + ".png",
		};
	};
	
/*
	this.getTripIcon = function(color)
	{
		if (!util.isDefined(this.tripStartIcon))
		{
			this.tripStartIcon = {
				anchor: new google.maps.Point(17, 34),
				size: new google.maps.Size(34, 34),
				url: territoriesImagePath + "trip_a.png"
			};

//			this.tripStartIcon = new GIcon();
//			this.tripStartIcon.image = territoriesImagePath + "trip_a.png";
//			this.tripStartIcon.shadow = territoriesImagePath + "trip_a_shadow.png";
//			this.tripStartIcon.iconSize = new GSize(34, 34);
//			this.tripStartIcon.shadowSize = new GSize(59, 34);
//			this.tripStartIcon.iconAnchor = new GPoint(17, 34);
//			this.tripStartIcon.infoWindowAnchor = new GPoint(17, 0);
			
		}

		return this.tripStartIcon;
	};
*/	
}

function __HIDE_EXPORT_FUNCTION(orgId)
{
	return [
    	//"00DA0000000HtXN", // development org
    	//"00DF00000008PJU", // test EE org
    	"00D300000006mYC" //0003
    ].contains(orgId);
};
