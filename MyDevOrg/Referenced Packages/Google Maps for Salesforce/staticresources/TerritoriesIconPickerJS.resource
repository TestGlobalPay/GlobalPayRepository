///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/

var iconPicker = new IconPicker();

/////////////////////////////////////////////////////////////////////////////////////
// IconPicker
/////////////////////////////////////////////////////////////////////////////////////
function IconPicker()
{
	var picker;
	var resultInput;
	var resultContainer;
	var useIconCheckBox;
	var completionMethod;
	var saveSelectionObjectId;
	
	this.saveSelectedIcon = false;
	
	this.DEFAULT_ICON = "red-dot.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0";
	this.DEFAULT_ICON_PATH = iconsPath + "red-dot.png";
	
	this.useIconChanged = function(resultInput, resultContainer, useIconCheckBox)
	{
		this.resultInput = resultInput;
		this.resultContainer = resultContainer;
		this.useIconCheckBox = useIconCheckBox;

		if (useIconCheckBox.checked)
		{
			if (resultInput.value == null || resultInput.value.length == 0)
			{
				iconPicker.resultInput.value = this.DEFAULT_ICON;
				iconPicker.resultContainer.style.visibility = "visible";
				iconPicker.resultContainer.setAttribute("src", this.DEFAULT_ICON_PATH);
			}
			
			this.showIconPicker(resultInput, resultContainer);
		}
		else 
		{	
			if (resultInput.value != null && resultInput.value.length != 0)
			{
				iconPicker.resultInput.value = "";
				iconPicker.resultContainer.style.visibility = "hidden";
				iconPicker.resultContainer.setAttribute("src", "");
			}
		}
	};
	
	this.setIcon = function(resultContainer, completionMethod, saveSelectionObjectId)
	{
		this.resultContainer = resultContainer;
		this.completionMethod = completionMethod;
		this.saveSelectionObjectId = saveSelectionObjectId;
		this.saveSelectedIcon = true;
		
		this.showIconPicker(resultInput, resultContainer);
	};
	
	this.showIconPicker = function(resultInput, resultContainer)
	{		
		this.resultInput = resultInput;
		this.resultContainer = resultContainer;
		
		if (this.picker == null)
		{
			this.picker = document.createElement("div");
			this.picker.style.position = "absolute";
			this.picker.style.width="600px";
			this.picker.style.height = "400px";
		}

		if (typeof jscolor != "undefined" &&
			typeof jscolor.hidePicker == "function")
		{		
			jscolor.hidePicker();
		}
		
		this.hideIconPicker();

		var targetPos = this.getElementPos(resultContainer);
		var targetSize = this.getElementSize(resultContainer);  			
		this.picker.style.left = Number(targetPos[0]) + Number(targetSize[0]) + 2 + "px";
		this.picker.style.top = (Number(targetPos[1]) - 195) + "px";


		this.picker.style.width = "420px";
		this.picker.style.height = "243px"
		this.picker.style.backgroundImage = "url('" + territoriesImagePath + "gbox2.png')";
		this.picker.style.backgroundRepeat = "no-repeat";

		var table = document.createElement("table");
		table.cellSpacing = "0px";
		table.cellPadding = "0px";

		var row0 = document.createElement("tr");
		var col00 = document.createElement("td");
		var col01 = document.createElement("td");
		var col02 = document.createElement("td");

		col00.width = "98px";
		col00.height = "21px";
		col00.style.width = "98px";
		col00.style.height = "21px";
			
		col01.width = "281px";
		col01.style.width = "281px";
			
		var xButton = document.createElement("img");
		xButton.src = territoriesImagePath + "gbox_x.png";
		xButton.style.cursor = "pointer";
		xButton.style.position = "relative";
		xButton.style.top = "5px";
		xButton.style.left = "-1px";
		xButton.onclick = function() { iconPicker.hideIconPicker(); }

		col02.width = "41px";
		col02.style.width = "41px";
		col02.appendChild(xButton);
			
		row0.appendChild(col00);
		row0.appendChild(col01);
		row0.appendChild(col02);

		var row1 = document.createElement("tr");
		var col10 = document.createElement("td");
		var col11 = document.createElement("td");
		var col12 = document.createElement("td");

		col10.height = "176px";
		col10.style.height = "176px";
			
		col11.id = "cell_Content";
		col11.style.overflow = "visible";
			
		row1.appendChild(col10);
		row1.appendChild(col11);
		row1.appendChild(col12);

		var row2 = document.createElement("tr");
		var col20 = document.createElement("td");
		var col21 = document.createElement("td");
		var col22 = document.createElement("td");

		col20.height = "46px";
		col20.style.height = "46px";

		row2.appendChild(col20);
		row2.appendChild(col21);
		row2.appendChild(col22);

		var tbody = document.createElement("tbody");
		tbody.appendChild(row0);
		tbody.appendChild(row1);
		tbody.appendChild(row2);
		table.appendChild(tbody);

		col11.appendChild(this.createImageTable());
		this.picker.appendChild(table);
		document.getElementsByTagName('body')[0].appendChild(this.picker)
	};
	
	this.createImageTable = function()
	{
		var visibleRows = 5;
		var rowHeight = 32;
		var cellPadding = 4;
		
		var imageNames1 = ["blue-dot.png", "red-dot.png", "green-dot.png",
			"ltblue-dot.png", "yellow-dot.png", "purple-dot.png", "pink-dot.png"];

		var imageNames2 = ["blue.png", "red.png", "green.png",
			"lightblue.png", "yellow.png", "purple.png", "pink.png"];

		var imageNames3 = ["blue-pushpin.png", "red-pushpin.png", "grn-pushpin.png",
			"ltblu-pushpin.png", "ylw-pushpin.png", "purple-pushpin.png", "pink-pushpin.png"];

		var imageNames4 = ["restaurant.png", "coffeehouse.png", "bar.png",
			"snack_bar.png", "man.png", "woman.png", "wheel_chair_accessible.png"];

		var imageNames5 = ["parkinglot.png", "cabs.png", "bus.png",
			"truck.png", "rail.png", "plane.png", "ferry.png"];
			
		var imageNames6 = ["helicopter.png", "subway.png", "tram.png",
			"info.png", "info_circle.png", "flag.png", "rainy.png"];

		var imageNames7 = ["water.png", "snowflake_simple.png", "marina.png",
			"fishing.png", "sailing.png", "swimming.png", "ski.png"];
			
		var imageNames8 = ["tree.png", "campfire.png", "picnic.png",
			"campground.png", "rangerstation.png", "toilets.png", "POI.png"];

		var imageNames9 = ["hiker.png", "cycling.png", "motorcycling.png",
			"horsebackriding.png", "sportvenue.png", "golfer.png", "trail.png"];

		var imageNames10 = ["shopping.png", "movies.png", "grocerystore.png",
			"conveniencestore.png", "arts.png", "homegardenbusiness.png", "electronics.png"];

		var imageNames11 = ["mechanic.png", "gas.png", "realestate.png",
			"salon.png", "dollar.png", "euro.png", "yen.png"];

		var imageNames12 = ["firedept.png", "hospitals.png", "lodging.png",
			"phone.png", "caution.png", "earthquake.png", "fallingrocks.png"];

		var imageNames13 = ["postoffice-us.png", "police.png", "sunny.png",
			"partly_cloudy.png", "volcano.png", "camera.png", "webcam.png"];

		var imagesInfo1 = ["blue-dot.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"red-dot.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"green-dot.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"ltblue-dot.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"yellow-dot.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"purple-dot.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"pink-dot.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];
		
		var imagesInfo2 = ["blue.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"red.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"green.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"lightblue.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"yellow.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"purple.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"pink.png" + separator.leftAngle + "msmarker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "15" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];
		
		var imagesInfo3 = ["blue-pushpin.png" + separator.leftAngle + "pushpin.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"red-pushpin.png" + separator.leftAngle + "pushpin.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"grn-pushpin.png" + separator.leftAngle + "pushpin.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"ltblu-pushpin.png" + separator.leftAngle + "pushpin.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"ylw-pushpin.png" + separator.leftAngle + "pushpin.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"purple-pushpin.png" + separator.leftAngle + "pushpin.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"pink-pushpin.png" + separator.leftAngle + "pushpin.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];
		
		var imagesInfo4 = ["restaurant.png" + separator.leftAngle + "restaurant.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"coffeehouse.png" + separator.leftAngle + "coffeehouse.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"bar.png" + separator.leftAngle + "bar.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"snack_bar.png" + separator.leftAngle + "snack_bar.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"man.png" + separator.leftAngle + "man.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"woman.png" + separator.leftAngle + "woman.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"wheel_chair_accessible.png" + separator.leftAngle + "wheel_chair_accessible.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];
		
		var imagesInfo5 = ["parkinglot.png" + separator.leftAngle + "parkinglot.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"cabs.png" + separator.leftAngle + "cabs.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"bus.png" + separator.leftAngle + "bus.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"truck.png" + separator.leftAngle + "truck.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"rail.png" + separator.leftAngle + "rail.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"plane.png" + separator.leftAngle + "plane.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"ferry.png" + separator.leftAngle + "ferry.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];
		
		var imagesInfo6 = ["helicopter.png" + separator.leftAngle + "helicopter.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"subway.png" + separator.leftAngle + "subway.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"tram.png" + separator.leftAngle + "tram.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"info.png" + separator.leftAngle + "info.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"info_circle.png" + separator.leftAngle + "info_circle.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"flag.png" + separator.leftAngle + "flag.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"rainy.png" + separator.leftAngle + "rainy.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];

		var imagesInfo7 = ["water.png" + separator.leftAngle + "water.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"snowflake_simple.png" + separator.leftAngle + "snowflake_simple.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"marina.png" + separator.leftAngle + "marina.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"fishing.png" + separator.leftAngle + "fishing.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"sailing.png" + separator.leftAngle + "sailing.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"swimming.png" + separator.leftAngle + "swimming.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"ski.png" + separator.leftAngle + "ski.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];

		var imagesInfo8 = ["tree.png" + separator.leftAngle + "tree.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"campfire.png" + separator.leftAngle + "campfire.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"picnic.png" + separator.leftAngle + "picnic.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"campground.png" + separator.leftAngle + "campground.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"rangerstation.png" + separator.leftAngle + "rangerstation.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"toilets.png" + separator.leftAngle + "toilets.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"POI.png" + separator.leftAngle + "POI.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];

		var imagesInfo9 = ["hiker.png" + separator.leftAngle + "hiker.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"cycling.png" + separator.leftAngle + "cycling.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"motorcycling.png" + separator.leftAngle + "motorcycling.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"horsebackriding.png" + separator.leftAngle + "horsebackriding.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"sportvenue.png" + separator.leftAngle + "sportvenue.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"golfer.png" + separator.leftAngle + "golfer.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"trail.png" + separator.leftAngle + "trail.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];

		var imagesInfo10 = ["shopping.png" + separator.leftAngle + "shopping.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"movies.png" + separator.leftAngle + "movies.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"grocerystore.png" + separator.leftAngle + "grocerystore.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"conveniencestore.png" + separator.leftAngle + "conveniencestore.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"arts.png" + separator.leftAngle + "arts.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"homegardenbusiness.png" + separator.leftAngle + "homegardenbusiness.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"electronics.png" + separator.leftAngle + "electronics.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];

		var imagesInfo11 = ["mechanic.png" + separator.leftAngle + "mechanic.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"gas.png" + separator.leftAngle + "gas.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"realestate.png" + separator.leftAngle + "realestate.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"salon.png" + separator.leftAngle + "salon.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"dollar.png" + separator.leftAngle + "dollar.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"euro.png" + separator.leftAngle + "euro.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"yen.png" + separator.leftAngle + "yen.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];

		var imagesInfo12 = ["firedept.png" + separator.leftAngle + "firedept.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"hospitals.png" + separator.leftAngle + "hospitals.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"lodging.png" + separator.leftAngle + "lodging.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"phone.png" + separator.leftAngle + "phone.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"caution.png" + separator.leftAngle + "caution.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"earthquake.png" + separator.leftAngle + "earthquake.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"fallingrocks.png" + separator.leftAngle + "fallingrocks.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];

		var imagesInfo13 = ["postoffice-us.png" + separator.leftAngle + "postoffice-us.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"police.png" + separator.leftAngle + "police.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"sunny.png" + separator.leftAngle + "sunny.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"partly_cloudy.png" + separator.leftAngle + "partly_cloudy.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"volcano.png" + separator.leftAngle + "volcano.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"camera.png" + separator.leftAngle + "camera.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0",
			"webcam.png" + separator.leftAngle + "webcam.shadow.png" + separator.leftAngle + "32" + separator.leftAngle + "32" + separator.leftAngle + "59" + separator.leftAngle + "32" + separator.leftAngle + "9" + separator.leftAngle + "31" + separator.leftAngle + "15" + separator.leftAngle + "0"];
		
		var tbody = document.createElement("tbody");
		tbody.appendChild(this.createImageTableRow(imageNames1, imagesInfo1));
		tbody.appendChild(this.createImageTableRow(imageNames2, imagesInfo2));
		tbody.appendChild(this.createImageTableRow(imageNames3, imagesInfo3));
		tbody.appendChild(this.createImageTableRow(imageNames4, imagesInfo4));
		tbody.appendChild(this.createImageTableRow(imageNames5, imagesInfo5));
		tbody.appendChild(this.createImageTableRow(imageNames6, imagesInfo6));
		tbody.appendChild(this.createImageTableRow(imageNames7, imagesInfo7));
		tbody.appendChild(this.createImageTableRow(imageNames8, imagesInfo8));
		tbody.appendChild(this.createImageTableRow(imageNames9, imagesInfo9));
		tbody.appendChild(this.createImageTableRow(imageNames10, imagesInfo10));
		tbody.appendChild(this.createImageTableRow(imageNames11, imagesInfo11));
		tbody.appendChild(this.createImageTableRow(imageNames12, imagesInfo12));
		tbody.appendChild(this.createImageTableRow(imageNames13, imagesInfo13));

		var table = document.createElement("table");
		table.appendChild(tbody);
		
		var tableDiv = document.createElement("div");
		tableDiv.style.height = ((rowHeight + cellPadding) * visibleRows - cellPadding) + "px";
		tableDiv.style.paddingRight = (browserInfo.isMSIE() && browserInfo.version() >= 8 ? "25" : "10") + "px";
		tableDiv.style.overflowY = "scroll";		
		tableDiv.appendChild(table);
		
		return tableDiv;
	};

	this.createImageTableRow = function(imageNames, imagesInfo)
	{
		var numColumns = 7;
		var images = [];
		
		for (var i = 0; i < numColumns; i++)
		{
			var image = document.createElement("img");
			image.src = iconsPath + imageNames[i];
			image.style.border = "none";
			images.push(image);	
		}
		
		var divs = [];
		
		for (var i = 0; i < numColumns; i++)
		{
			var	div = document.createElement("div");
			div.style.cursor = "pointer";
			div.onclick = new Function("iconPicker.saveSelection('" + imagesInfo[i] + "');");
			div.appendChild(images[i]);
			divs.push(div);
		}
		
		var cols = [];
		
		for (var i = 0; i < numColumns; i++)
		{
			var col = document.createElement("td");
			col.appendChild(divs[i]);
			cols.push(col);
		}
		
		var row = document.createElement("tr");
		
		for (var i = 0; i < numColumns; i++)
		{
			row.appendChild(cols[i]);
		}
		
		return row;
		
	};

	this.hideIconPicker = function()
	{
		if (typeof this.picker != "undefined" &&
			this.picker.parentNode == document.getElementsByTagName('body')[0])
		{
			document.getElementsByTagName('body')[0].removeChild(this.picker);
			this.picker.removeChild(this.picker.firstChild);
		}
	};
	
	this.saveSelection = function(selection)
	{
		iconPicker.resultContainer.style.visibility = "visible";
		iconPicker.resultContainer.setAttribute("src", iconsPath + selection.split(separator.leftAngle)[0]);
		
		if (iconPicker.useIconCheckBox != null)
		{
			iconPicker.useIconCheckBox.checked = true;
		}

		if (this.saveSelectedIcon)
		{
			this.hideIconPicker();
			eval(this.completionMethod + "('" + this.saveSelectionObjectId + "','" + selection + "')");
		}
		else
		{
			iconPicker.resultInput.value = selection;
		}
	}

	this.getElementPos = function(element) 
	{
		var element1 = element;
		var element2 = element;
		var x = 0;
		var y = 0;
		
		if (element1.offsetParent) 
		{
			do 
			{
				x += element1.offsetLeft;
				y += element1.offsetTop;
			} 
			while(element1 = element1.offsetParent);
		}
		
		while((element2 = element2.parentNode) && element2.nodeName != "BODY") 
		{
			x -= element2.scrollLeft;
			y -= element2.scrollTop;
		}
		
		return [x, y]
	};

	this.getElementSize = function(element)
	{
		return [element.offsetWidth, element.offsetHeight];
	};

}

