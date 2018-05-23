///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/


/////////////////////////////////////////////////////////////////////////////////////
// BatchGeocoding
/////////////////////////////////////////////////////////////////////////////////////
function BatchGeocoding()
{
	var geocoder;
    var fieldNames;
    var objectName;
    var objectLabel;
    var addressPrefix;
    var sObjects;
    var batchIndex;
    var totalRecords;
    var totalCompleted;
    var statusCallback;
    var abortCallback;
    var completionCallback;
    var queryResult;
    var firstBatchFetched;
	var iterator;    
    
	this.createGeocoder = function()
	{
		if (!util.isDefined(this.geocoder))
		{
			this.geocoder = new google.maps.Geocoder();
		}
	};

	this.start = function(objectName, objectLabel, addressPrefix, statusCallback, 
		abortCallback, completionCallback)
	{
		this.objectName = objectName;
		this.objectLabel = objectLabel;
		this.addressPrefix = addressPrefix;
		this.statusCallback = statusCallback;
		this.abortCallback = abortCallback;
		this.completionCallback = completionCallback;
				
		this.initFieldNames();		

		this.createGeocoder();

		this.totalRecords = this.getObjectCount();
		
		if (this.totalRecords == 0)
		{
			this.setStatusText(locale.noItemsToGeocode);
			this.setCompletionStatus();
			return;
		}

		this.setStatusText(locale.initializing);

	   	this.firstBatchFetched = false;
		this.totalCompleted = 0;
		this.geocodeNextBatch();
	};

	this.getObjectCount = function()
	{
	    try
	    {
			var queryString = "SELECT Count() FROM " + this.objectName +
				" WHERE " + this.fieldNames.geocodeStatusField + " = null " + 
	    		(this.objectName == "Lead" ? "AND IsConverted = false " : "");
		
			var queryResult = sforce.connection.query(queryString);
			return queryResult.size;
	    } 
	    catch(error)
	    {
	        alert("Fetch count failed with error: " + error);
	    }

        return 0;
	};
	
	this.fetchRecords = function()
	{
		if (!this.firstBatchFetched)
		{
			this.fetchFirstBatch();
			return true;
		}	

		if (this.iterator.hasNext())
		{
			this.fetchNextBatch();
			return true;
		}
		
		return false;
	};
	
	this.fetchFirstBatch = function()
	{
	    this.sObjects = [];
	    var queryString;

		//sforce.debug.trace = true;
	
	    try
	    {
			sforce.connection.batchSize = 200;
			sforce.connection.batchSizeSpecified = true;

	    	queryString = "SELECT Id, " + 
	    		this.fieldNames.streetField + ", " +
	    		this.fieldNames.cityField + ", " +
	    		this.fieldNames.stateField + ", " +
	    		this.fieldNames.postalCodeField + ", " +
	    		this.fieldNames.countyField + ", " +
	    		this.fieldNames.countryField + ", " +
	    		this.fieldNames.geocodeAddressField + ", " +
	    		this.fieldNames.geocodeAccuracyField + ", " +
	    		this.fieldNames.geocodeStatusField + ", " +
	    		this.fieldNames.latitudeField + ", " +
	    		this.fieldNames.longitudeField + 
	    		" FROM " + this.objectName + " WHERE " + 
	    		this.fieldNames.geocodeStatusField + " = null " + 
	    		(this.objectName == "Lead" ? "AND IsConverted = false " : "");
	    		
	        this.queryResult = sforce.connection.query(queryString);

			this.iterator = new sforce.QueryResultIterator(this.queryResult);
			for (var i = 0; i < 200 && this.iterator.hasNext(); i++)
			{
				this.sObjects.push(this.iterator.next());
			}
	        
 			this.setRecordAddresses();

		    this.firstBatchFetched = true;
	    } 
	    catch(error)
	    {
	        alert("Fetch " + this.objectName + " failed with error: " + error);
	    }
	};
	
	this.fetchNextBatch = function()
	{
		this.sObjects.length = 0;	
	
		try
		{
			for (var i = 0; i < 200 && this.iterator.hasNext(); i++)
			{
				this.sObjects.push(this.iterator.next());
			}
			
			this.setRecordAddresses();
		}
	    catch(error)
	    {
	        alert("Fetch next " + this.objectName + " batch failed with error: " + error);
	    }
	};
	
	this.setRecordAddresses = function()
	{
        for (var i = 0; i < this.sObjects.length; i++)
        {
        	var sObject = this.sObjects[i];
        	
        	var street = sObject[this.fieldNames.streetField];
        	var city = sObject[this.fieldNames.cityField];
        	var state = sObject[this.fieldNames.stateField];
        	var postalCode = sObject[this.fieldNames.postalCodeField];
        	var country = sObject[this.fieldNames.countryField];
        	var county = sObject[this.fieldNames.countyField];
        	var address = this.getAddressString(street, city, state, postalCode, country);

			sObject[this.fieldNames.geocodeAddressField] = address;
        }
	};
	
	this.updatePreviousBatch = function() 
	{
		if (this.sObjects == null || this.sObjects.length == 0)
		{
			return;
		}

		var updateArray = this.sObjects;
		
		var geocodeStatus = this.sObjects[this.sObjects.length-1][this.fieldNames.geocodeStatusField];
		
		if (geocodeStatus == null || geocodeStatus.length == 0)
		{
			var updateCount = 0;
			for ( ; updateCount < this.sObjects.length; updateCount++)
			{
				geocodeStatus = this.sObjects[updateCount][this.fieldNames.geocodeStatusField];
				if (geocodeStatus == null || geocodeStatus.length == 0)
				{
					break;
				}	
			}

			updateArray = this.sObjects.splice(0, updateCount);
		}
		
	    try
	    {
	    	sforce.connection.update(updateArray);	
	    } 
	    catch(error)
	    {
	        alert("Update " + this.objectName + " failed with error: " + error);
	        return;
	    }
	};

	this.processNextBatch = function()
	{
		this.batchIndex = 0;
		this.geocodeNextObject();
	};

	this.geocodeNextBatch = function()
	{
		this.updatePreviousBatch();
		
		if (this.fetchRecords())
		{
			this.processNextBatch();
		}
		else
		{
			this.cleanUp();			
			this.setCompletionStatus();
		}		
	};
	
	this.geocodeNextObject = function()
	{
		try
		{
			// google geocoding
			//var address = this.sObjects[this.batchIndex][this.fieldNames.geocodeAddressField];
			//this.geocoder.geocode({address: address,}, this.processGeocode);
			var sObject = this.sObjects[this.batchIndex];
			var street = sObject[this.fieldNames.streetField]; 
			var city = sObject[this.fieldNames.cityField];
			var state = sObject[this.fieldNames.stateField];
			var postalCode = sObject[this.fieldNames.postalCodeField];
			var country = sObject[this.fieldNames.countryField];
			if (street) 
			{
				street = street.replace(/#/gi, ""); 
			}
			var address = encodeURIComponent(this.getAddressString(street, city, state, postalCode, country));
			
			util.sendGoogleGeocodeRequest(address, this.processGoogleGeocode);
			
			// tamu geocoding
			//var sObject = this.sObjects[this.batchIndex];
			//var request = "https://geoservices.tamu.edu/Services/Geocode/WebService/GeocoderWebServiceHttpNonParsedDetailed_V04_01.aspx?" +
			//	"streetAddress=" + encodeURIComponent(sObject[this.fieldNames.streetField]).replace(/\%/gi, "__pct__") + 
			//	"&city=" + encodeURIComponent(sObject[this.fieldNames.cityField]).replace(/\%/gi, "__pct__") +
			//	"&state=" + encodeURIComponent(sObject[this.fieldNames.stateField]).replace(/\%/gi, "__pct__") +
			//	"&zip=" + encodeURIComponent(sObject[this.fieldNames.postalCodeField]).replace(/\%/gi, "__pct__") +
			//	"&apikey=c97a6b4cedc4445e998ffbebfb234fce&format=XML&verbose=true&census=false&notStore=true&version=4.01" +
			//	"&county=false";

			//util.sendTamuGeocodeRequest("request=" + encodeURIComponent(request), this.processTamuGeocode);
			
			
			// yahoo geocoding
			//var sObject = this.sObjects[this.batchIndex];
			//var street = sObject[this.fieldNames.streetField]; 
			//var city = sObject[this.fieldNames.cityField];
			//var state = sObject[this.fieldNames.stateField];
			//var postalCode = sObject[this.fieldNames.postalCodeField];
			//var country = sObject[this.fieldNames.countryField];
			
			//var address = encodeURIComponent(this.getYahooAddressString(street, city, state, postalCode, country));
			//util.sendYahooGeocodeRequest(address, this.processYahooGeocode);
			
		}
		catch(error)
		{
			alert("Geocode Next Object failed with error: " + error);
			this.abortGeocoding();
		}			
	};
	
	this.processYahooGeocode = function(results)
	{
		batchGeocoding.processYahooResponse(results);
	};

	this.processYahooResponse = function(results)
	{
		try
		{
			var _status = "";
			var _results = null;
			
			if (typeof(results.bossresponse) == "undefined" || typeof(results.bossresponse.placefinder.results) == "undefined")
			{
				_status = "LOCATION_TYPE_UNMATCHABLE";
			}
			else
			{
				_status = ((Number(results.bossresponse.placefinder.results[0].quality) < 70) || results.bossresponse.responsecode != "200") ? 
					"LOCATION_TYPE_UNMATCHABLE" : "G_GEO_SUCCESS";
				_results = results.bossresponse.placefinder.results[0];
			}
			
			var sObject = this.sObjects[this.batchIndex]; 							


			sObject[this.fieldNames.geocodeStatusField] = _status;

			if (_status == "G_GEO_SUCCESS")
			{	
				var latitude = _results.latitude;
				var longitude = _results.longitude;
				var geocodeAccuracy = 0; // not used
				var geocodeAddress = this.getYahooResultFormattedAddress(_results);
				var county = util.truncate(_results.county, " County");
				
							
				sObject[this.fieldNames.latitudeField] = latitude;
				sObject[this.fieldNames.longitudeField]  = longitude;
				sObject[this.fieldNames.countyField]  = county;
				sObject[this.fieldNames.geocodeAccuracyField] = geocodeAccuracy;
				sObject[this.fieldNames.geocodeAddressField] = geocodeAddress;
			}
			else
			{
				sObject[this.fieldNames.geocodeAddressField] = "";
			}
			
			
			++this.totalCompleted;
			
			var pctComplete = String(parseInt(String(this.totalCompleted * 100 / this.totalRecords)));
			var statusText = locale.processed;
			statusText = statusText.replace("{0}", String(this.totalCompleted));
			statusText = statusText.replace("{1}", String(this.totalRecords));
			statusText = statusText.replace("{2}", pctComplete);

			// debug output
			//statusText += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + this.sObjects[this.batchIndex].Id + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			//statusText += util.escapeString(this.sObjects[this.batchIndex][this.fieldNames.geocodeAddressField]);


			this.setStatusText(statusText);

			eval("var abort = " + this.abortCallback + "()");
		
			if (abort)
			{
				this.abortGeocoding();			
				return;
			}
		
			++this.batchIndex;

			if (this.batchIndex >= this.sObjects.length)
			{
				this.geocodeNextBatch();	
			}
			else
			{
				setTimeout("batchGeocoding.geocodeNextObject()", 50);
			}
		}
		catch(error)
		{
			alert("Process Geocode Response failed with error: " + error);
			this.abortGeocoding();
		}			
	};
	
	
	this.processTamuGeocode = function(response)
	{
		batchGeocoding.processTamuResponse(response);
	};

	this.processTamuResponse = function(response)
	{
		try
		{
			var status = response.result;
			var sObject = this.sObjects[this.batchIndex]; 							

			sObject[this.fieldNames.geocodeStatusField] = this.convertTamuResponseCode(status);

			if (status != "LOCATION_TYPE_UNKNOWN" &&
				status != "LOCATION_TYPE_UNMATCHABLE")
			{	
				var latitude = response.latitude;
				var longitude = response.longitude;
				var geocodeAccuracy = 0; // not used
				var geocodeAddress = response.formattedAddress.replace(/"/gi, "'"); 
							
				sObject[this.fieldNames.latitudeField] = latitude;
				sObject[this.fieldNames.longitudeField]  = longitude;
				sObject[this.fieldNames.geocodeAccuracyField] = geocodeAccuracy;
				sObject[this.fieldNames.geocodeAddressField] = geocodeAddress;
			}
			else
			{
				sObject[this.fieldNames.geocodeAddressField] = "";
			}

			++this.totalCompleted;
			
			var pctComplete = String(parseInt(String(this.totalCompleted * 100 / this.totalRecords)));
			var statusText = locale.processed;
			statusText = statusText.replace("{0}", String(this.totalCompleted));
			statusText = statusText.replace("{1}", String(this.totalRecords));
			statusText = statusText.replace("{2}", pctComplete);

			// debug output
			//statusText += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + this.sObjects[this.batchIndex].Id + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			//statusText += util.escapeString(this.sObjects[this.batchIndex][this.fieldNames.geocodeAddressField]);


			this.setStatusText(statusText);

			eval("var abort = " + this.abortCallback + "()");
		
			if (abort)
			{
				this.abortGeocoding();			
				return;
			}
		
			++this.batchIndex;

			if (this.batchIndex >= this.sObjects.length)
			{
				this.geocodeNextBatch();	
			}
			else
			{
				setTimeout("batchGeocoding.geocodeNextObject()", 50);
			}
		}
		catch(error)
		{
			alert("Process Geocode Response failed with error: " + error);
			this.abortGeocoding();
		}			
	};
	
	this.processGoogleGeocode = function(response, status)
	{
		batchGeocoding.processGoogleResponse(response);
	};

	this.getGoogleUSCounty = function(result)
	{
		var county = "";
		var found = false;
		for (var i = 0; i < result.address_components.length; i++)
		{
			var addressComponent = result.address_components[i];
			if (addressComponent.types.contains("country") &&
				addressComponent.short_name == "US")
		    {
		    	var found2 = false;
		    	
		    	for (var j = 0; j < result.address_components.length; j++)
		    	{
		    		var addressComponent2 = result.address_components[j];
		    		if (addressComponent2.types.contains("administrative_area_level_2"))
		    		{
		    			county = util.truncate(addressComponent2.long_name, " County");
		    			found = true;
		    			found2 = true;
		    		}
		    		
		    		if (found2)
		    		{
		    			break;
		    		}
		    	}
		    	
		    	if (found)
		    	{
		    		break;
		    	}
		    }
		}
		
		return county;
	};

	this.processGoogleResponse = function(response)
	{
	
		try
		{
//* Cannot read property results of undefined

//			var results = response.results;
//			var status = response.status;
		
			var results = response ? response.results : null;
			var status = response ? response.status : "ZERO_RESULTS";
			
			if (status == "OVER_QUERY_LIMIT")
			{
				this.setStatusText(locale.geocodingOverLimit);
				this.abortGeocoding();
				return;
			}
			
//			if (status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT)
//			{
//				setTimeout("batchGeocoding.geocodeNextObject()", 250);
//				return;
//			}
	
			this.sObjects[this.batchIndex][this.fieldNames.geocodeStatusField] = this.convertResponseCode(status);

			if (status == "OK")//google.maps.GeocoderStatus.OK)
			{	
				var result = results[0];
				
				var latitude = result.geometry.location.lat;
				var longitude = result.geometry.location.lng;
				var county = this.getGoogleUSCounty(result);
				var geocodeAccuracy = 0; // not used
				var geocodeAddress = result.formatted_address.replace(/"/gi, "'"); 
							
				var sObject = this.sObjects[this.batchIndex]; 							
				sObject[this.fieldNames.latitudeField] = latitude;
				sObject[this.fieldNames.longitudeField]  = longitude;
				sObject[this.fieldNames.countyField] = county;
				sObject[this.fieldNames.geocodeAccuracyField] = geocodeAccuracy;
				sObject[this.fieldNames.geocodeAddressField] = geocodeAddress;
			}
			else
			{
				this.sObjects[this.batchIndex][this.fieldNames.geocodeAddressField] = "";
			}

			++this.totalCompleted;
			
			var pctComplete = String(parseInt(String(this.totalCompleted * 100 / this.totalRecords)));
			var statusText = locale.processed;
			statusText = statusText.replace("{0}", String(this.totalCompleted));
			statusText = statusText.replace("{1}", String(this.totalRecords));
			statusText = statusText.replace("{2}", pctComplete);

			// debug output
			//statusText += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + this.sObjects[this.batchIndex].Id + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			//statusText += util.escapeString(this.sObjects[this.batchIndex][this.fieldNames.geocodeAddressField]);


			this.setStatusText(statusText);

			eval("var abort = " + this.abortCallback + "()");
		
			if (abort)
			{
				this.abortGeocoding();			
				return;
			}
		
			++this.batchIndex;

			if (this.batchIndex >= this.sObjects.length)
			{
				this.geocodeNextBatch();	
			}
			else
			{
				setTimeout("batchGeocoding.geocodeNextObject()", 50);
			}
		}
		catch(error)
		{
			console.info(error.stack);
			alert("Process Geocode Response failed with error: " + error);
			this.abortGeocoding();
		}			
	};
	
	this.abortGeocoding = function()
	{
		this.updatePreviousBatch();			
		this.cleanUp();			
	};

	this.cleanUp = function()
	{
		if (util.isDefined(this.sObjects))
		{
			this.sObjects.length = 0;
			this.sObjects = null;
		}
	};

	this.setCompletionStatus = function()
	{
		eval(this.completionCallback + "()");
	};

	this.convertResponseCode = function(code)
	{
/*	
		switch(code)
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

	
	this.getAddressString = function(street, city, state, postalCode, country)
	{
		var addressString = "";

   		if (street == null)
   		{
   			return addressString;
   		}
   		else
   		{
   			addressString += util.stripCrlf(street);
   		}

   		if (city != null)
   		{
   			addressString += "," + city;
   		}

       	if (state != null && street != null && city != null)
       	{ 
           	addressString += "," + state;
       	}
        	
       	if (postalCode != null)
       	{ 
           	addressString += "," + postalCode;
       	}
        	
       	if (country != null)
       	{
       		addressString += "," + country;
       	}
			     	
       	return addressString;
	};

	this.getYahooResultFormattedAddress = function(result)
	{
		var formattedAddress = new StringBuilder();
		
		formattedAddress.append(result.line1);
		
		if (result.line2.length > 0)
		{
			formattedAddress.append(",");
			formattedAddress.append(result.line2);
		}
	
		if (result.line3.length > 0)
		{
			formattedAddress.append(",");
			formattedAddress.append(result.line3);
		}
	
		if (result.line4.length > 0)
		{
			formattedAddress.append(",");
			formattedAddress.append(result.line4);
		}
		
		return formattedAddress.toString().replace(/"/gi, "'");
	};

	this.getYahooAddressString = function(street, city, state, postalCode, country)
	{
		var sb = new StringBuilder();
		
		if (street && street !== null && street.length > 0)
		{
			sb.append(util.replaceCrlf(street, " ") + ", ");
		}
		
		if (city && city !== null && city.length > 0)
		{
			sb.append(util.replaceCrlf(city, " ") + ", ");
		}
		
		var _postalCode = (postalCode && postalCode !== null && postalCode.length > 0);
		var _country = (country && country !== null && country.length > 0);
			
		if (state && state !== null && state.length > 0)
		{
			sb.append(util.replaceCrlf(state, " ") + (_postalCode || _country ? " " : ""));
		}
		
		if (_postalCode)
		{
			sb.append(util.replaceCrlf(postalCode, " ") + (_country ? " " : ""));
		}
	
		if (_country)
		{
			sb.append(", " + util.replaceCrlf(country, " "));
		}
		
		var addressString = sb.toString();
		return addressString.length == 0 ? null : util.trim(addressString);
	};

	this.getIsCustomObject = function()
	{
		return (this.objectName != "Account" &&
			this.objectName != "Lead" && this.objectName != "Contact");
	};

	this.initFieldNames = function()
	{
		if (this.getIsCustomObject())
		{
			this.initCustomObjectFieldNames();
			return;
		}
			
		this.fieldNames = {};
		
		this.fieldNames.streetField = this.addressPrefix + "Street";		
		this.fieldNames.cityField = this.addressPrefix + "City";
		this.fieldNames.stateField = this.addressPrefix + "State";		
		this.fieldNames.postalCodeField = this.addressPrefix + "PostalCode";		
		this.fieldNames.countryField = this.addressPrefix + "Country";
		
		this.addressPrefix = (this.objectName == "Account" ? this.addressPrefix + "_" : "");
		
		this.fieldNames.countyField = "pexmaps__" + this.addressPrefix + "County__c";
		this.fieldNames.geocodeStatusField = "pexmaps__" + this.addressPrefix + "Geocode_Status__c";		
		this.fieldNames.geocodeAddressField = "pexmaps__" + this.addressPrefix + "Geocode_Address__c";		
		this.fieldNames.geocodeAccuracyField = "pexmaps__" + this.addressPrefix + "Geocode_Accuracy__c";		
		this.fieldNames.latitudeField = "pexmaps__" + this.addressPrefix + "Latitude__c";		
		this.fieldNames.longitudeField = "pexmaps__" + this.addressPrefix + "Longitude__c";		
	};

	this.initCustomObjectFieldNames = function()
	{
		var queryString;
		var queryResult;	
		var records;
	
	    try
	    {
			queryString = "SELECT pexmaps__StreetField__c, pexmaps__CityField__c, " +
				"pexmaps__StateField__c, pexmaps__PostalCodeField__c, pexmaps__CountryField__c, pexmaps__CountyField__c, " +
				"pexmaps__GeocodeStatusField__c, pexmaps__GeocodeAddressField__c, " +
				"pexmaps__GeocodeAccuracyField__c, pexmaps__LatitudeField__c, " +
				"pexmaps__LongitudeField__c FROM pexmaps__TerritoryCustomObject__c " +
				"WHERE Name = '" + this.objectName + "'";
		
			queryResult = sforce.connection.query(queryString);
	        records = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Custom Object fields failed with error: " + error);
	    }

		if (records.length == 0)
		{
			return;
		}
		
		this.fieldNames = {};
		
		this.fieldNames.streetField = records[0].pexmaps__StreetField__c;		
		this.fieldNames.cityField = records[0].pexmaps__CityField__c;
		this.fieldNames.stateField = records[0].pexmaps__StateField__c;
		this.fieldNames.postalCodeField = records[0].pexmaps__PostalCodeField__c;	
		this.fieldNames.countryField = records[0].pexmaps__CountryField__c;
		this.fieldNames.countyField = records[0].pexmaps__CountyField__c;
		this.fieldNames.geocodeStatusField = records[0].pexmaps__GeocodeStatusField__c;	
		this.fieldNames.geocodeAddressField = records[0].pexmaps__GeocodeAddressField__c;	
		this.fieldNames.geocodeAccuracyField = records[0].pexmaps__GeocodeAccuracyField__c;	
		this.fieldNames.latitudeField = records[0].pexmaps__LatitudeField__c;		
		this.fieldNames.longitudeField = records[0].pexmaps__LongitudeField__c;		
	};

	this.setStatusText = function(statusText)
	{
		eval(this.statusCallback + "('" + statusText + "')");
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// ClearGeocodeStatus
/////////////////////////////////////////////////////////////////////////////////////
function ClearGeocodeStatus()
{
    var geocodeStatusFieldName;
    var objectName;
    var objectLabel;
    var addressPrefix;
    var statusCallback;
    var completionCallback;
    var sObjects;
    var batchIndex;
    var totalRecords;
    var totalCompleted;
    
   	this.usingManualGeocodes = true;
    
    this.start = function(objectName, objectLabel, addressPrefix, 
    	statusCallback, completionCallback)
    {
		this.objectName = objectName;
		this.objectLabel = objectLabel;
		this.addressPrefix = addressPrefix;
		this.statusCallback = statusCallback;
		this.completionCallback = completionCallback;
				
		this.initGeocodeStatusFieldName();		

		this.totalRecords = this.getObjectCount();
		
		if (this.totalRecords == 0)
		{
			this.setStatusText(locale.geocodeStatusAlreadyCleared);
			this.setCompletionStatus();
			return;
		}
		
	    this.totalCompleted = 0;
		this.clearGeocodes();

		this.setCompletionStatus();
    };
    
    this.setUsingManualGeocodes = function()
    {
	    try
	    {
			sforce.connection.query("SELECT Manual_Geocode__c FROM " + this.objectName + " LIMIT 1");
	    } 
	    catch(error)
	    {
	        this.usingManualGeocodes = false;
	    }
    };
    
 	this.getObjectCount = function()
	{
		this.setUsingManualGeocodes();	

	    try
	    {
			var queryString = "SELECT Count() FROM " + this.objectName +
				" WHERE " + this.geocodeStatusFieldName + " != null " + 
				(this.usingManualGeocodes ? "AND Manual_Geocode__c = false " : "") +
	    		(this.objectName == "Lead" ? "AND IsConverted = false " : "");
		
			var queryResult = sforce.connection.query(queryString);
			return queryResult.size;
	    } 
	    catch(error)
	    {
	        alert("Fetch count failed with error: " + error);
	    }

        return 0;
	};

	this.updateBatch = function(sObjects)
	{
	    try
	    {
	    	sforce.connection.update(sObjects);	
	    } 
	    catch(error)
	    {
	        alert("Update " + this.objectName + " failed with error: " + error);
	    }
	};

 	this.clearGeocodes = function()
	{
	    var sObjects = [];
	    var queryString;
	    var queryResult;

	    try
	    {
	    	queryString = "SELECT Id, " + this.geocodeStatusFieldName + 
		    	" FROM " + this.objectName + 
				" WHERE " + this.geocodeStatusFieldName + " != null " + 
				(this.usingManualGeocodes ? "AND Manual_Geocode__c = false " : "") +
	    		(this.objectName == "Lead" ? "AND IsConverted = false " : "");
	    		
	        queryResult = sforce.connection.query(queryString);
	        
	        
	        
	        
 			iterator = new sforce.QueryResultIterator(queryResult);
 			
 			while (iterator.hasNext())
 			{
 				sObjects.length = 0;
 				
	 			for (var i = 0; i < 200 && iterator.hasNext(); i++)
 				{
 					sObjects.push(iterator.next());	
		        	sObjects[i][this.geocodeStatusFieldName] = null;
 				}
 				
				this.updateBatch(sObjects);
			
				this.totalCompleted += sObjects.length;

				var pctComplete = parseInt(String(this.totalCompleted * 100 / this.totalRecords));
				var statusText = locale.geocodeStatusReset;
				statusText = statusText.replace("{0}", String(this.totalCompleted));
				statusText = statusText.replace("{1}", String(this.totalRecords));
				statusText = statusText.replace("{2}", String(this.objectLabel));
				statusText = statusText.replace("{3}", String(pctComplete));

				this.setStatusText(statusText);
 			}
 			
	    } 
	    catch(error)
	    {
	        alert("Clear geocodes " + this.objectName + " failed with error: " + error);
	        return;
	    }
	};

	this.getIsCustomObject = function()
	{
		return (this.objectName != "Account" &&
			this.objectName != "Lead" && this.objectName != "Contact");
	};
 
 	this.initGeocodeStatusFieldName = function()
	{
		if (this.getIsCustomObject())
		{
			this.initCustomObjectGeocodeStatusFieldName();
			return;
		}
			
		this.addressPrefix = (this.objectName == "Account" ? this.addressPrefix + "_" : "");
		this.geocodeStatusFieldName = "pexmaps__" + this.addressPrefix + "Geocode_Status__c";		
	};

	this.initCustomObjectGeocodeStatusFieldName = function()
	{
		var queryString;
		var queryResult;	
		var records;
	
	    try
	    {
			queryString = "SELECT pexmaps__GeocodeStatusField__c FROM pexmaps__TerritoryCustomObject__c " +
				"WHERE Name = '" + this.objectName + "'";
		
			queryResult = sforce.connection.query(queryString);
	        records = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Custom Object fields failed with error: " + error);
	    }

		if (records.length == 0)
		{
			return;
		}
		
		this.geocodeStatusFieldName = records[0].pexmaps__GeocodeStatusField__c;	
	};

	this.setStatusText = function(statusText)
	{
		eval(this.statusCallback + "('" + statusText + "')");
	};

	this.setCompletionStatus = function()
	{
		eval(this.completionCallback + "()");
	};
}

var batchGeocoding = new BatchGeocoding();
var clearGeocodeStatus = new ClearGeocodeStatus();

