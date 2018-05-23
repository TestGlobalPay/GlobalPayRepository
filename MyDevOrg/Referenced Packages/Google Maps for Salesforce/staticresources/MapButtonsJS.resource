/////////////////////////////////////////////////////////////////////////////////////
// MoreControl
/////////////////////////////////////////////////////////////////////////////////////

/*

var chosen = [];
var timer;
var layers = [
	{ name: "Pano", obj: new GLayer("com.panoramio.all") },
	{ name: "Tube", obj: new GLayer("com.youtube.all") },
	{ name: "Wiki", obj: new GLayer("org.wikipedia.en") },
	{ name: "Cams", obj: new GLayer("com.google.webcams") }
	];

MoreControl.prototype = new GControl();
function MoreControl()
{
	this.initialize = function(map)
	{
		var more = document.getElementById("outer_more");
 		var buttonDiv = document.createElement("div");
 		buttonDiv.id = "morebutton";
 		buttonDiv.title = locale.showHideLayers;
 		buttonDiv.style.border = "1px solid black";
 		buttonDiv.style.width = "86px";
 		
		var textDiv = document.createElement("div");
 		textDiv.id = "more_inner";
 		textDiv.appendChild(document.createTextNode(locale.more + "..."));
 		buttonDiv.appendChild(textDiv);

		more.onmouseover = showLayerBox;
		more.onmouseout = setClose;
		buttonDiv.onclick = toggleLayers;

		more.insertBefore(buttonDiv, more.firstChild);
 		map.getContainer().appendChild(more);
 
 		return more;
	};

	this.getDefaultPosition = function()
	{
		var left = mapWidth - 184;
		return new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(left, 7));
	};
}

function showLayerBox()
{
	if (window.timer)
	{
		clearTimeout(timer);
	}
	
	document.getElementById("box").style.display = "block";
	
	var button = document.getElementById("more_inner");
	button.style.borderBottomWidth = "4px";
	button.style.borderBottomColor = "white";
}

function setClose()
{
	var layerbox = document.getElementById("box");
	var button = document.getElementById("more_inner");
	var bottomColor = checkChecked() ? "#6495ed" : "#c0c0c0";

	timer = window.setTimeout(
		function()
		{
  			layerbox.style.display = "none";
  			button.style.borderBottomWidth = "1px";
  			button.style.borderBottomColor = bottomColor;
 		}, 400);
}

function toggleLayers()
{
	if(chosen.length > 0 ) 
	{
		var copy = chosen.slice();
		
		for(var i = 0; i < copy.length; i++)
		{
			var index = parseInt(copy[i]);
			switchLayer(true, layers[index].obj);
			document.getElementsByName("mark")[index].checked = true;
   		}
 	}
	else
	{
		hideAll();
	}
}

function checkChecked()
{
	var boxes = document.getElementsByName("mark");
	
	for(var i = 0; i < boxes.length; i++)
	{
		if(boxes[i].checked) return true;
 	}
 	
	return false;
}
function switchLayer(checked, layer) 
{
	var layerBox = document.getElementById("box");
	var boxLink = document.getElementById("boxlink");
	var button = document.getElementById("more_inner");

	if(checked)
	{
		map.addOverlay(layer);
		chosen.length = 0;

		boxLink.className ="highlight";
		layerBox.className ="highlight";
		button.className ="highlight";
	}
	else
	{
		map.removeOverlay(layer);
		
		if(!checkChecked())
		{
			boxLink.blur();
			boxLink.className ="";
			layerBox.className ="";
			button.className ="";
   		}
 	}
}

function hideAll()
{
	var boxes = document.getElementsByName("mark");
	
	for(var i = 0; i < boxes.length; i++)
	{
		if(boxes[i].checked)
		{
			boxes[i].checked = false;
			switchLayer(false, layers[i].obj);
			chosen.push(i);
		}
 	}
}



/////////////////////////////////////////////////////////////////////////////////////
// TrafficControl
/////////////////////////////////////////////////////////////////////////////////////
var trafficToggleState = false;
var trafficOverlay;

TrafficControl.prototype = new GControl();
function TrafficControl()
{
	this.initialize = function(map)
	{
		var traffic = document.getElementById("outer_traffic");
		
 		var buttonDiv = document.createElement("div");
 		buttonDiv.id = "trafficbutton";
 		buttonDiv.title = locale.showHideTraffic;
 		buttonDiv.style.border = "1px solid black";
 		buttonDiv.style.width = "86px";
 		
		var textDiv = document.createElement("div");
 		textDiv.id = "traffic_inner";
 		textDiv.appendChild(document.createTextNode(locale.traffic));
 		buttonDiv.appendChild(textDiv);

		buttonDiv.onclick = toggleTraffic;

		traffic.insertBefore(buttonDiv, traffic.firstChild);
 		map.getContainer().appendChild(traffic);
 
		trafficOverlay = new GTrafficOverlay({incidents:true});
 
 		return traffic;
	};

	this.getDefaultPosition = function()
	{
		var left = mapWidth - 278;
		return new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(left, 7));
	};
}

function toggleTraffic()
{
	if (trafficToggleState)
	{
		map.removeOverlay(trafficOverlay);
		trafficToggleState = false;
		document.getElementById("traffic_inner").className = "";
	}
	else
	{
		map.addOverlay(trafficOverlay);
		trafficToggleState = true;
		document.getElementById("traffic_inner").className = "highlight";
	}
}
*/