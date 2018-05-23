///**********************************************************************************/
///
///  (c) 2009-2012 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/


/////////////////////////////////////////////////////////////////////////////////////
// SearchBoxControl
/////////////////////////////////////////////////////////////////////////////////////
function SearchBoxControl()
{

};

SearchBoxControl.prototype.create = function()
{
	this._markers = [];
	var _this = this;
	
	this._searchInput = $("<input></input>")
		.attr("id", "searchBoxInput")
		.css("padding", "2px")
		.css("fontSize", "16px")
		.css("color", "#666666")
		.attr("size", "35")
		.attr("maxLength", "80")
		.attr("type", "text")
		.attr("placeholder", "search")
		.keydown(function(event)
		{
			if(event.keyCode == 13)
			{
				event.preventDefault();
			}
		});

		
	
	this._searchBoxControl = $("<div></div>")
		.css("padding", "10px")
		.css("margin", "10px")
		.css("backgroundColor", "rgba(0, 0, 0, 0.5)")
		.css("boxShadow", "inset -1px -1px 1px rgba(0, 0, 0, 0.5), inset 1px 1px 1px rgba(150,150,150,0.8), 0px 0px 5px rgba(0, 0, 0, 0.5)")
		.css("border", "1px solid rgba(0, 0, 0, 0.5)")
		.css("borderRadius", "10px")
		.append($("<table></table>")
			.css("borderCollapse", "0px")
			.css("borderSpacing", "0px")
			.append($("<tr></tr>")
				.append($("<td></td>")
					.css("paddingRight", "2px")
					.append($("<img />")
						.attr("src", logosPath + "google-g-logo-2012.25.png")))
				.append($("<td></td>")
					.append(this._searchInput))
				.append($("<td></td>")
					.css("paddingLeft", "2px")
					.append($("<div></div>")
						.css("display", "none")
						.css("cursor", "pointer")
						.attr("id", "closeSearchBoxSearch")
						.click(function()
						{
							_this._clearSearch();
						})
						.append($("<img />")
							.attr("src", imagesPath + "icon-circle-x-red.png"))))));

		
	return this;
};

SearchBoxControl.prototype.getControlElement = function()
{
	return this._searchBoxControl.get(0);
};

SearchBoxControl.prototype.getSearchInputElement = function()
{
	return this._searchInput.get(0);
};

SearchBoxControl.prototype.init = function()
{
	var searchInputElement = this.getSearchInputElement();
	searchInputElement.index = 1;

	var searchControlElement = this.getControlElement();

	map.controls[google.maps.ControlPosition.BOTTOM_LEFT].push(searchControlElement);

	this._searchBox = new google.maps.places.SearchBox(searchInputElement);

	var _this = this;
	
	google.maps.event.addListener(this._searchBox, "places_changed", function() 
	{
		_this._clearSearch();
		_this._places = _this._searchBox.getPlaces();

		var bounds = new google.maps.LatLngBounds();
		
		for (var i = 0; i < _this._places.length; i++)
		{
			var place = _this._places[i];
			
  			var image = {
		        url: iconsPath + "purple-dot.png",
		        size: new google.maps.Size(32, 32),
		        origin: new google.maps.Point(0, 0),
		        anchor: new google.maps.Point(16, 32),
		    };
		
  			//var image = {
		    //  url: place.icon,
		    //  size: new google.maps.Size(71, 71),
		    //  origin: new google.maps.Point(0, 0),
		    //  anchor: new google.maps.Point(17, 34),
		    //  scaledSize: new google.maps.Size(25, 25)
		    //};
		    
			var markerOptions = {};
			markerOptions.anchorPoint = new google.maps.Point(0, -16);
			markerOptions.cursor = "pointer";
			markerOptions.icon = image;
			markerOptions.position = place.geometry.location;
			markerOptions.title = place.name;
			markerOptions.map = map;
		    
		    var marker = new google.maps.Marker(markerOptions);
		    
      		_this._markers.push(marker);
      		
      		place.marker = marker;
      		
			bounds.extend(place.geometry.location);
			
			$("#closeSearchBoxSearch").show();
    	}
    	
		_this._addMarkerClickHandlers();
		
    	map.fitBounds(bounds);
	});

	google.maps.event.addListener(map, "bounds_changed", function() 
	{
		var bounds = map.getBounds();
		_this._searchBox.setBounds(bounds);
	});

};

SearchBoxControl.prototype._addMarkerClickHandlers = function()
{
	for (var i = 0; i < this._markers.length; i++)
	{
		var place = this._places[i];
		var marker = this._markers[i];
		
		this._addMarkerClickHandler(marker, place);
	}
};

SearchBoxControl.prototype._addMarkerClickHandler = function(marker, place)
{
	var _this = this;
	
	google.maps.event.addListener(marker, "click", 
		function()
		{
			InfoWindow.setContent(_this._getPlaceHtml(place));
			InfoWindow.open(map, marker);
		}
	);
};

SearchBoxControl.prototype._getPlace = function(index)
{
	return this._places[index];
};

SearchBoxControl.prototype._getPlaceHtml = function(place)
{
	var _this = this;
	
	var node = $("<div></div>")
		.css("maxWidth", "200px")
		.append($("<div></div>")
			.css("fontWeight", "bold")
			.text(place.name))
		.append($("<div></div>")
			.text(place.formatted_address))

	var showButton = (territories.view != null && 
		territories.view.id != null &&
		territories.view.id.length > 0);


	if (showButton)
	{
		node.append($("<hr />")
				.css("height", "1px")
				.css("borderWidth", "0px")
				.css("color", "gainsboro")
				.css("backgroundColor", "gainsboro"))
			.append($("<input></input>")
				.attr("type", "button")
				.click(function()
				{
					place.marker.setMap(null);
					_this._addMapViewCustomLocation(place);
				})
				.attr("value", "Add to map view"));
	}
			
	return node.get(0);
		
		

		
};

SearchBoxControl.prototype._addMapViewCustomLocation = function(place)
{
	var address = place.formatted_address.replace(/"/gi, "'");
	var latitude = place.geometry.location.lat();
	var longitude = place.geometry.location.lng();

	addMapMarker.geocodingCustomLocation = new CustomLocation();
	addMapMarker.geocodingCustomLocation.name = place.name;
	addMapMarker.geocodingCustomLocation.address = new Address();
	addMapMarker.geocodingCustomLocation.address.street = "";
	addMapMarker.geocodingCustomLocation.address.city = "";
	addMapMarker.geocodingCustomLocation.address.state = "";
	addMapMarker.geocodingCustomLocation.address.postalCode = "";
	addMapMarker.geocodingCustomLocation.address.country = "";
	addMapMarker.geocodingCustomLocation.address.geocodeAccuracy = 0;
	addMapMarker.geocodingCustomLocation.address.geocodeAddress = address;
	addMapMarker.geocodingCustomLocation.address.coordinates = new google.maps.LatLng(latitude, longitude);
	
	addMapMarker.geocodingCustomLocation.createMarker(addMapMarker.geocodingCustomLocation);
	
	if (util.isDefined(territories.view))
	{
		addMapMarker.geocodingCustomLocation.color = territories.view.customLocationMarkerColor;
		addMapMarker.geocodingCustomLocation.mapIcon = allowIcons ? territories.view.customLocationMapIcon : null;
	}

	eval('insertGeocodeCustomLocation("' +
		place.name + '","' +
		'G_GEO_SUCCESS","' +
		place.geometry.location.lat() + '","' + 
		place.geometry.location.lng() + '","","","","","","' +
		address + '",0);');

};

SearchBoxControl.prototype._clearSearch = function()
{
	for (var i = 0; i < this._markers.length; i++) 
	{
		this._markers[i].setMap(null);
	}
	
	this._markers = [];
	this._places = [];
	
	this._searchInput.val("");
	
	$("#closeSearchBoxSearch").hide();
};