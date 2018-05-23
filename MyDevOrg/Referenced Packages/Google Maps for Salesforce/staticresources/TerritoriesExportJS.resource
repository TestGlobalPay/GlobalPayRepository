///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/

var exports = new Exports();

/////////////////////////////////////////////////////////////////////////////////////
// Export
/////////////////////////////////////////////////////////////////////////////////////
function Exports()
{
	//var EXPORT_REQUEST_URL = "http://localhost:8888/pexmapsdataprocessor";
	var EXPORT_REQUEST_URL = "https://pexmapsdataproc.appspot.com/pexmapsdataprocessor";
	
	//var EXPORT_REQUEST_CSV_URL = "http://localhost:8080/PexmapsExport/PexmapsExportCsv";
	var EXPORT_REQUEST_CSV_URL = "https://www.pexmaps.com:8443/PexmapsExport/PexmapsExportCsv";
	
	var EXPORT_REQUEST_HTM_URL = "https://www.pexmaps.com:8443/PexmapsExport/PexmapsExportHtm";
	
	var exportFormat;
	var isTrip;
	var requestForm;
	var requestFormDataInput;
	var requestDocNameInput;
	var requestFormatInput;
	var requestOutlinesInput;
	var requestTripInput;
	var requestBoundsInput;
	var showFullDetails;
	var reqData = "";

	var minLat = 91.0;
	var maxLat = -91.0;
	var minLng = 181.0;
	var maxLng = -181.0;
	
	var objectIndex = [];
	objectIndex["accounts"] = "0";
	objectIndex["leads"] = "1";
	objectIndex["contacts"] = "2";
	objectIndex["customObjects"] = "3";
	objectIndex["customLocations"] = "4";
	objectIndex["users"] = "5";


	this.requestExport = function(format, exportTrip)
	{
		
		this.setupFields(format, exportTrip);

		showFullDetails = document.getElementById("check_KmlShowFullDetails").checked;

		exportFormat = format;
		isTrip = exportTrip;
		
		if ((format != "htm" && format != "csv") || exportTrip)
		{
			requestFormatInput.value = format;
		}

		var requestGenerated = exportTrip ? this.generateTripRequest() : this.generateViewRequest();
		 
		if (requestGenerated)
		{
			this.sendRequest();
		}
	};

	this.setupFields = function(exportFormat, exportTrip)
	{
		if ((exportFormat == "htm" || exportFormat == "csv") && !exportTrip)
		{
			requestForm = document.getElementById(exportFormat + "PostingForm");
			requestDocNameInput = document.getElementById(exportFormat + "ExportDocName");
			requestFormDataInput = document.getElementById(exportFormat + "ExportPostData");
			
			if (exportFormat == "csv")
			{
				requestForm.action = EXPORT_REQUEST_CSV_URL;
			}
			else if (exportFormat == "htm")
			{
				requestForm.action = EXPORT_REQUEST_HTM_URL;
			}
		}
		else
		{
			requestForm = document.getElementById("form_ExportRequest");
			requestForm.action = EXPORT_REQUEST_URL;
			requestFormDataInput = document.getElementById("input_Export");
			requestDocNameInput = document.getElementById("input_ExportDocName");
			
			requestFormatInput = document.getElementById("input_ExportFormat");
			requestOutlinesInput = document.getElementById("input_ExportOutlines");
			requestTripInput = document.getElementById("input_ExportTrip");
			requestBoundsInput = document.getElementById("input_ExportBounds");
		}
	};

	this.generateTripRequest = function()
	{
		requestDocNameInput.value = trip.name;

		var tripMapObjects = this.getTripMapObjects("Account");
		this.generateViewObjectsRequest("accounts", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("Lead");
		this.generateViewObjectsRequest("leads", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("Contact");
		this.generateViewObjectsRequest("contacts", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("Custom Object");
		this.generateViewObjectsRequest("customObjects", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("Custom Location");
		this.generateViewObjectsRequest("customLocations", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("User");
		this.generateViewObjectsRequest("users", tripMapObjects);

		if (!this.verifyRequestLength())
		{
			reqData = "";
			return false;
		}		

		requestFormDataInput.value = reqData;
		reqData = "";
		
		if (exportFormat == "gpx")
		{
			requestBoundsInput.value = this.generateBounds();

			this.generateTripRouteRequest();

			if (!this.verifyRequestLength())
			{
				reqData = "";
				requestFormDataInput.value = "";
				return false;
			}		

			requestTripInput.value = reqData;
			reqData = "";
		}

		return true;
	};

	this.getTripMapObjects = function(mapObjectType)
	{
		var tripMapObjects = [];
		for (var i = 0; i < trip.waypoints.length; i++)
		{
			if (trip.waypoints[i].mapObject.type == mapObjectType)
			{
				tripMapObjects.push(trip.waypoints[i].mapObject);
			}
		}

		return tripMapObjects;
	};
	
	this.generateViewRequest = function()
	{
		if ((exportFormat == "htm" || exportFormat == "csv") && !isTrip)
		{
			return this.generateViewRequest2();
		}
	
		requestDocNameInput.value = territories.view.name;

		this.generateViewObjectsRequest("accounts", territories.view.accounts);
		this.generateViewObjectsRequest("leads", territories.view.leads);
		this.generateViewObjectsRequest("contacts", territories.view.contacts);
		this.generateViewObjectsRequest("customObjects", territories.view.customObjects);
		this.generateViewObjectsRequest("customLocations", territories.view.customLocations);
		this.generateViewObjectsRequest("users", territories.view.users);

		if (!this.verifyRequestLength())
		{
			reqData = "";
			return false;
		}		

		requestFormDataInput.value = reqData;
		reqData = "";

		if (exportFormat == "kml")
		{
			this.generateOutlinesRequest();

			if (!this.verifyRequestLength())
			{
				reqData = "";
				requestFormDataInput.value = "";
				return false;
			}		

			requestOutlinesInput.value = reqData;
			reqData = "";
		}

		if (exportFormat == "gpx")
		{
			requestBoundsInput.value = this.generateBounds();
		}
		
		return true;
	};

	this.verifyRequestLength = function()
	{
		if (requestFormDataInput.value.length + reqData.length > 125000)
		{
			alert("Request is too large. Reduce the number of items mapped.");
			return false;			
		}
		
		return true;
	}

	this.generateViewObjectsRequest = function(objectType, viewObjects)
	{
		for (var i = 0; i < viewObjects.length; i++)
		{
			if (document.getElementById("check_ExportVisibleItemsOnly").checked && 
				!territories.view.showMarker(viewObjects[i]))
			{
				continue;
			}
			
			if (exportFormat == "kml")
			{
				this.generateMapObjectForKml(objectType, viewObjects[i]);
			}
			else if (exportFormat == "gpx")
			{
				this.generateMapObjectForGpx(objectType, viewObjects[i]);
			}
			else if (exportFormat == "csv")
			{
				if (isTrip)
				{
					this.generateMapObjectForCsv(objectType, viewObjects[i]);
				}
				else
				{
					this.generateMapObjectForCsv2(objectType, viewObjects[i],  viewObjects[i]);
				}
			}
			else if (exportFormat == "htm")
			{
				if (isTrip)
				{
					//this.generateMapObjectForHtm(objectType, viewObjects[i]);
				}
				else
				{
					this.salesforceDomain = util.getSalesforceDomain();
					this.generateMapObjectForHtm2(objectType, viewObjects[i],  viewObjects[i]);
				}
			}
		}
		
	};
	
	this.generateViewRequest2 = function()
	{
		requestDocNameInput.value = util.fixFileName(territories.view.name);

		this.generateViewObjectsRequest("accounts", territories.view.accounts);
		this.generateViewObjectsRequest("leads", territories.view.leads);
		this.generateViewObjectsRequest("contacts", territories.view.contacts);
		this.generateViewObjectsRequest("customObjects", territories.view.customObjects);
		this.generateViewObjectsRequest("customLocations", territories.view.customLocations);
		this.generateViewObjectsRequest("users", territories.view.users);
		
		if (exportFormat == "htm")
		{	
			this.endHtmGeneration();
		}
		
		
//alert(this.reqData);

		requestFormDataInput.value = this.reqData;
		delete this.reqData;
		this.reqData = undefined;
		
		return true;
	};








	this.generateMapObjectForHtm2 = function(objectType, mapObject, addressObject)
	{
		var isAccount = objectType == "accounts";
		var isContact = objectType == "contacts";
		var isLead = objectType == "leads";
//		var isParent = isAccount || isContact || isLead;
		var isParent = mapObject.getChildObjectsData && mapObject.getChildObjectsData().length > 0;

		if (isParent)
		{
			var childObjectData = mapObject.getChildObjectsData();
			
			for (var i = 0; i < childObjectData.length; i++)
			{
				var childObjectDataItem = childObjectData[i];
				for (var j = 0; j < childObjectDataItem.childObjects.length; j++)
				{
					this.generateMapObjectForHtm2("", childObjectDataItem.childObjects[j], mapObject);
				}
			}
			
			return;
		}

	
	
		var isCustomLocation = objectType == "customLocations";
		var isUser = objectType == "users";
	
		if (!this.reqData)
		{
			this.reqData = new StringBuilder();
			this.initHtmGeneration();
			this.generateHtm2HeaderRow(mapObject);
		}

		this.reqData.append("<tr>\n");
		
//		this.reqData.append("<td>\n");
//		this.reqData.append(mapObject.id);
//		this.reqData.append("</td>\n");

		
		this.reqData.append("<td>\n");
		this.reqData.append("<a target='_blank' href='");
		this.reqData.append(this.salesforceDomain + util.replaceDoubleQuotesWithSingleQuotes(mapObject.id));
		this.reqData.append("'>");
		this.reqData.append(util.replaceDoubleQuotesWithSingleQuotes(mapObject.name));
		this.reqData.append("</a>");
		this.reqData.append("</td>\n");
		
		this.reqData.append("<td>\n");
		this.reqData.append(addressObject.address.getAddressString());
		this.reqData.append("</td>\n");

		this.reqData.append("<td>\n");
		this.reqData.append(addressObject.address.getCity());
		this.reqData.append("</td>\n");

		this.reqData.append("<td>\n");
		this.reqData.append(addressObject.address.getState());
		this.reqData.append("</td>\n");

		this.reqData.append("<td>\n");
		this.reqData.append(addressObject.address.getPostalCode());
		this.reqData.append("</td>\n");

		this.reqData.append("<td>\n");
		if (isContact)
		{
			if (mapObject != addressObject && mapObject.relatedObjectName)
			{
				this.reqData.append("<a target='_blank' href='");
				this.reqData.append(this.salesforceDomain + mapObject.relatedObjecId);
				this.reqData.append("'>");
				this.reqData.append(util.replaceDoubleQuotesWithSingleQuotes(mapObject.relatedObjectName));
				this.reqData.append("</a>");
			}
		}
		else
		{
			if (mapObject != addressObject && addressObject.name)
			{
				this.reqData.append("<a target='_blank' href='");
				this.reqData.append(this.salesforceDomain + addressObject.id);
				this.reqData.append("'>");
				this.reqData.append(util.replaceDoubleQuotesWithSingleQuotes(addressObject.name));
				this.reqData.append("</a>");
			}
		}
		this.reqData.append("</td>\n");

		this.reqData.append("<td>\n");
		this.reqData.append(addressObject.address.coordinates.lat().toString());
		this.reqData.append("</td>\n");

		this.reqData.append("<td>\n");
		this.reqData.append(addressObject.address.coordinates.lng().toString());
		this.reqData.append("</td>\n");

		this.reqData.append("<td>\n");
		if (isCustomLocation || isUser)
		{
			this.reqData.append("");
		}
		else
		{
			var otherData = new StringBuilder();
			
			for (var i = 0; i < mapObject.displayFieldValues.length; i++)
			{
				var displayFieldValue = mapObject.displayFieldValues[i];
				
				if (displayFieldValue != null && displayFieldValue.length > 0)
				{
					displayFieldValue = mapObject.formatDisplayFieldValue(mapObject.view.displayFieldTypes[i],
						displayFieldValue);				
				
					otherData.append(mapObject.view.displayFieldLabels[i]);
					otherData.append(" : ");
					otherData.append(displayFieldValue);
					otherData.append("   |    ");
					
				}
			}
			this.reqData.append(otherData.toString());
		}
		this.reqData.append("</td>\n");

		this.reqData.append("</tr>\n");
		

	};

	this.initHtmGeneration = function()
	{
		this._htmExtraColumnCount = 0; 

		if (this.reqData)
		{
			this.reqData.clear();
		}
		
		this.reqData.append("<html>\n");
		this.reqData.append("<head>\n");

		this.reqData.append("<title>\nGoogle Maps for Salesforce\n</title>");
		
		this.reqData.append("<style>\n");
		this.reqData.append("table tr:nth-child(even)\n{\nbackground-color: beige;\n}\n");
		this.reqData.append("table tr:nth-child(odd)\n{\nbackground-color: wheat;\n}\n");
		this.reqData.append("table th\n{\ncolor: white; background-color: sandybrown;\n}\n");
		this.reqData.append("table\n{\nfont-family: sans-serif;\nfont-size:14px;\ncolor:#444444\n}\n");
		this.reqData.append("body\n{\npadding: 40px;\n}\n");
		this.reqData.append("th\n{\npadding: 5px 10px;\n}\n");
		this.reqData.append("td\n{\npadding: 3px 10px;\n}\n");
		this.reqData.append("a:link, a:visited, a:hover, a:active\n{\ntext-decoration: none;\ncolor: #444444;\nfont-weight:bold;\n}\n");
		this.reqData.append("</style>\n");

		
		this.reqData.append("</head>\n");
		this.reqData.append("<body>\n");
		
		this.reqData.append("<div style='font-size:12px; font-family:sans-serif'>\n");
		this.reqData.append("Google Maps for Salesforce\n");
		this.reqData.append("</div>\n");
		this.reqData.append("<div style='font-size:20px; font-weight: bold; font-family:sans-serif'>\n");
		this.reqData.append(territories.view.name);
		this.reqData.append("</div>\n");
		this.reqData.append("\n<br />");
		
		this.reqData.append("<table>\n");
		this.reqData.append("<tr>\n");
	};

	this.endHtmGeneration = function()
	{
		this.reqData.append("</table>\n");
		this.reqData.append("</body>\n");
		this.reqData.append("</html>\n");
	};
	
	this.generateHtm2HeaderRow = function(mapObject)
	{
//		this.reqData.append("<th>Id</th>\n");
		this.reqData.append("<th>Name</th>\n");
		this.reqData.append("<th>Address</th>\n");
		this.reqData.append("<th>City</th>\n");
		this.reqData.append("<th>State</th>\n");
		this.reqData.append("<th>Postal Code</th>\n");
		this.reqData.append("<th>RelatedTo</th>\n");
		this.reqData.append("<th>Latitude</th>\n");
		this.reqData.append("<th>Longitude</th>\n");
		this.reqData.append("<th>Display Fields</th>\n");
		
		this.reqData.append("</tr>\n");
		
		this._htmExtraColumnCount = 1;
		
	};























	this.generateMapObjectForCsv2 = function(objectType, mapObject, addressObject)
	{
		var isAccount = objectType == "accounts";
		var isContact = objectType == "contacts";
		var isLead = objectType == "leads";
//		var isParent = isAccount || isContact || isLead;
		var isParent = mapObject.getChildObjectsData && mapObject.getChildObjectsData().length > 0;

		if (isParent)
		{
			var childObjectData = mapObject.getChildObjectsData();
			
			for (var i = 0; i < childObjectData.length; i++)
			{
				var childObjectDataItem = childObjectData[i];
				for (var j = 0; j < childObjectDataItem.childObjects.length; j++)
				{
					this.generateMapObjectForCsv2("", childObjectDataItem.childObjects[j], mapObject);
				}
			}
			
			return;
		}

	
	
		var isCustomLocation = objectType == "customLocations";
		var isUser = objectType == "users";
	
		if (!this.reqData)
		{
			this.reqData = new StringBuilder();
			this.initCsvGeneration();
			this.generateCsv2HeaderRow(mapObject);
		}
		
		this.reqData.append('"');
		this.reqData.append(mapObject.id);
		this.reqData.append('","');
		this.reqData.append(util.replaceDoubleQuotesWithSingleQuotes(mapObject.name));
		this.reqData.append('","');
		this.reqData.append(addressObject.address.getAddressString());
		this.reqData.append('","');
		this.reqData.append(addressObject.address.getCity());
		this.reqData.append('","');
		this.reqData.append(addressObject.address.getState());
		this.reqData.append('","');
		this.reqData.append(addressObject.address.getPostalCode());
		this.reqData.append('","');


		
		if (isContact)
		{
			this.reqData.append(mapObject.relatedObjectName ? util.replaceDoubleQuotesWithSingleQuotes(mapObject.relatedObjectName) : '');
		}
		else
		{
			this.reqData.append(mapObject !== addressObject ? util.replaceDoubleQuotesWithSingleQuotes(addressObject.name) : '');
		}
		
		this.reqData.append('","');
		this.reqData.append(addressObject.address.coordinates.lat().toString());
		this.reqData.append('","');
		this.reqData.append(addressObject.address.coordinates.lng().toString());
		this.reqData.append('",');
		
		if (isCustomLocation || isUser)
		{
//			for (var i = 0; i < this._csvExtraColumnCount; i++)
//			{
//				this.reqData.append(',""');
//			}
			
			this.reqData.append('""');
		}
		else
		{
			var otherData = new StringBuilder();
			otherData.append('"');
			
			for (var i = 0; i < mapObject.displayFieldValues.length; i++)
			{
				var displayFieldValue = mapObject.displayFieldValues[i];
				
				if (displayFieldValue != null && displayFieldValue.length > 0)
				{
					displayFieldValue = mapObject.formatDisplayFieldValue(mapObject.view.displayFieldTypes[i],
						displayFieldValue);				
				
					otherData.append(mapObject.view.displayFieldLabels[i]);
					otherData.append(' : ');
					otherData.append(displayFieldValue);
					otherData.append('   |    ');
					
				}
			}
			
			otherData.append('"');
			this.reqData.append(otherData.toString());
			
			
						
/*		
			for (var i = 0; i < mapObject.displayFieldValues.length; i++)
			{
				this.reqData.append(',"');
			
				var displayFieldValue = mapObject.displayFieldValues[i];
				
				if (displayFieldValue != null && displayFieldValue.length > 0)
				{
					this.reqData.append(displayFieldValue);
				}
				
				this.reqData.append('"');
			}
*/			
		}
		
		this.reqData.append('\n');
	};

	this.initCsvGeneration = function()
	{
		this._csvExtraColumnCount = 0; 

		if (this.reqData)
		{
			this.reqData.clear();
		}
		
	};
	
	this.generateCsv2HeaderRow = function(mapObject)
	{
		this.reqData.append('"Id",');
		this.reqData.append('"Name",');
		this.reqData.append('"Address",');
		this.reqData.append('"City",');
		this.reqData.append('"State",');
		this.reqData.append('"Postal Code",');
		this.reqData.append('"Related To",');
		this.reqData.append('"Latitude",');
		this.reqData.append('"Longitude",');
		
		this.reqData.append('"Display Fields"');
		this._csvExtraColumnCount = 1;
		
/*		
		for (var i = 0; i < mapObject.view.displayFieldLabels.length; i++)
		{
			this.reqData.append(',"' + mapObject.view.displayFieldLabels[i] + '"');
			this._csvExtraColumnCount++;
		} 
*/		
		this.reqData.append('\n');
	};
	 
	this.generateMapObjectForCsv = function(objectType, mapObject)
	{
		var isCustomLocation = objectType == "customLocations";
		var isUser = objectType == "users";
		var isAccount = objectType == "accounts";
		var isContact = objectType == "contacts";
		var isLead = objectType == "leads";
		var isParent = isAccount || isContact || isLead;
		
		eval("var typeIndex = objectIndex['" + objectType + "'];");
		var lat = mapObject.address.coordinates.lat();
		var lng = mapObject.address.coordinates.lng();
		
		reqData += reqData.length > 0 ? separator.currency : "";
		reqData += util.replaceDoubleQuotesWithSingleQuotes(mapObject.name) + separator.para + 
			mapObject.id + separator.para + typeIndex + separator.para + 
			mapObject.address.getAddressString() + separator.para + 
			lat + separator.para + lng + separator.para;
   		reqData += (!isCustomLocation && !isUser ?  mapObject.getRawDisplayFieldsData() : "0") + separator.para;
		reqData += isParent ?  mapObject.getRawChildObjectsData(false) : "0";
	};


	this.generateMapObjectForKml = function(objectType, mapObject)
	{
		var isCustomLocation = objectType == "customLocations";
		var isUser = objectType == "users";
		var isAccount = objectType == "accounts";
		var isContact = objectType == "contacts";
		var isLead = objectType == "leads";
		var isParent = isAccount || isContact || isLead;
		
		eval("var iconFile = objectIndex['" + objectType + "'];");
		var infoHtml = isCustomLocation && mapObject.draggable ? mapObject.info + "<br/>" : mapObject.address.getAddressHtml();
		var lat = mapObject.address.coordinates.lat();
		var lng = mapObject.address.coordinates.lng();
		
		reqData += reqData.length > 0 ? separator.currency : "";
		reqData += util.escapeString(mapObject.name) + separator.para + mapObject.id + separator.para + iconFile + separator.para + infoHtml + separator.para + lng + separator.para + lat + separator.para;
   		reqData += (isCustomLocation ? "0" : util.getSalesforceServer()) + separator.para;
   		reqData += (!isCustomLocation && !isUser && showFullDetails ? mapObject.getRawDisplayFieldsData() : "0") + separator.para;
		reqData += isParent && showFullDetails ? mapObject.getRawChildObjectsData(true) : "0";
	};
	
	this.generateOutlinesRequest = function()
	{
		for (var i = 0; i < outlines.outlines.length; i++)
		{
			this.generateOutlineRequest(outlines.outlines[i]);
		}

		for (var i = 0; i < outlines.readOnlyOutlines.length; i++)
		{
			this.generateOutlineRequest(outlines.readOnlyOutlines[i]);
		}
	};
		
	this.generateOutlineRequest = function(outline)
	{
		var poly = outline.polyline;
		var options = this.getOutlineOptions(outline);

		reqData += (reqData.length > 0 ? separator.currency : "");

		reqData += outline.name + separator.para;
		reqData += outline.info + separator.para;
		reqData += options.lineColor + separator.para;
		reqData += options.lineWidth + separator.para;
		reqData += (outline.type != "polyline" ? options.fillColor : "") + separator.para;
			
		for (var j = 0; j < poly.getVertexCount(); j++)
		{
			reqData += poly.getVertex(j).lng();
			reqData += ",";
			reqData += poly.getVertex(j).lat();
			reqData += ",0 ";
		}
	};	
		
	this.getOutlineOptions = function(outline)
	{
		var lineOpacity = (Math.round(Number(outline.options.borderOpacity) * 256)).toString(16);
		var lineColor = outline.options.borderColor;
		lineColor = lineOpacity + lineColor.slice(5) + lineColor.slice(3, 5) + lineColor.slice(1, 3);
		var fillOpacity = (Math.round(Number(outline.options.fillOpacity) * 256)).toString(16);
		var fillColor = outline.options.fillColor;
		fillColor = fillOpacity + fillColor.slice(5) + fillColor.slice(3, 5) + fillColor.slice(1, 3);
		
		return { 
			lineColor : lineColor,
			lineWidth : outline.options.borderWeight,
			fillColor : fillColor };
	};

	this.generateMapObjectForGpx = function(objectType, mapObject)
	{
		var isCustomLocation = objectType == "customLocations";
		
		var infoHtml = isCustomLocation && mapObject.draggable ? mapObject.info : mapObject.address.getAddressString();
		var lat = mapObject.address.coordinates.lat();
		var lng = mapObject.address.coordinates.lng();

		minLat = lat < minLat ? lat : minLat;
		maxLat = lat > maxLat ? lat : maxLat;
		minLng = lng < minLng ? lng : minLng;
		maxLng = lng > maxLng ? lng : maxLng;
		
		reqData += reqData.length > 0 ? separator.currency : "";
		reqData += mapObject.name + separator.para + infoHtml + separator.para + lng + separator.para + lat;
	};

	this.generateBounds = function()
	{
		return minLat + separator.para + minLng + separator.para + maxLat + separator.para + maxLng; 
	};
	
	
	this.generateTripRouteRequest = function()
	{
		if(!trip.started)
		{
			return;
		}
		
		var numRoutes = trip.directions.getNumRoutes(); 
		
		if (numRoutes == 0)
		{
			return;
		}
		
		for (var i = 0; i < numRoutes; i++)
		{
			var route = trip.directions.getRoute(i);
			var numSteps = route.getNumSteps();
			
			for (var j = 0; j < numSteps; j++)
			{
				var stepLatLng = route.getStep(j).getLatLng();
				
				if (reqData.length > 0)
				{
					reqData += separator.para;
				}
				
				reqData += stepLatLng.lat() + separator.para + stepLatLng.lng(); 
			}
		}
		
		var endLatLng = trip.directions.getRoute(numRoutes - 1).getEndLatLng();
		reqData += separator.para + endLatLng.lat() + separator.para + endLatLng.lng(); 
	};
	
	this.sendRequest = function()
	{
		requestForm.submit();
	};
}
