///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/


var util = new Utility();
var browserInfo = new BrowserInfo();
var jsonDump = new JsonDump();

var separator = { section : String.fromCharCode(167), para : String.fromCharCode(182),
		currency : String.fromCharCode(164), leftAngle : String.fromCharCode(171),
		brokenBar : String.fromCharCode(166), notSign : String.fromCharCode(172),
		macron : String.fromCharCode(175), plusMinus : String.fromCharCode(177),
		middleDot : String.fromCharCode(183) }; 
		
		
///////////////////////////////////////////////////////////////////////////
// Array
///////////////////////////////////////////////////////////////////////////

Array.prototype.append = Array.prototype.push;
Array.prototype.clone = function() { return this.slice(0); }

Array.prototype.toString = function(separator) 
{
	return this.join(separator || "");
};

Array.prototype.contains = function(object)
{
	for (var i = 0; i < this.length; i++)
	{
		if (this[i] === object)
		{
			return true;
		}
	}
	
	return false;
};

Array.prototype.containsKeyValue = function(key, value)
{
	for (var i = 0; i < this.length; i++)
	{
		var object = this[i];
		var keys = Object.keys(object);
		
		for (var j = 0; j < keys.length; j++)
		{
			var _key = keys[j];
			
			if (_key == key && object[_key] == value)
			{
				return true;
			}
		}
	}
	
	return false;
};

Array.prototype.compact = function()
{
	for (var i = this.length - 1; i >= 0; i--)
	{
		if (this[i] === null)
		{
			this.splice(i, 1);
		}
	}
	
	return this;
};

Array.prototype.filter = function(testFunction)
{
	var result = [];
	
	for (var i = 0; i < this.length; i++)
	{
		if (testFunction(this[i]))
		{
			result.push(this[i]);
		}
	}
	
	return result;
};

Array.prototype.remove = function(item)
{
	for (var i = 0; i < this.length; i++)
	{
		if (this[i] === item)
		{
			this.splice(i, 1);
			return;
		}
	}
};

Array.prototype.select = function(key)
{
	var values = [];
	
	for (var i = 0; i < this.length; i++)
	{
		values.push(this[i][key]);
	}
	
	return values;
};
		
///////////////////////////////////////////////////////////////////////////
// StringBuilder
///////////////////////////////////////////////////////////////////////////

function StringBuilder(blockSize)
{
	this._blockSize = blockSize || 100;
	this._stringLength = 0;
	this.length = blockSize;
}
StringBuilder.prototype = new Array();
StringBuilder.prototype.constructor = StringBuilder;

StringBuilder.prototype.append = function(string)
{
	if (this._stringLength + string.length > this.length)
	{
		this.length += this._blockSize;
	}
	
	for (var i = 0; i < string.length; i++, this._stringLength++)
	{
		this[this._stringLength] = string[i];
	}
	
	return this;
};

StringBuilder.prototype.toString = function()
{
	this.length = this._stringLength;
	return Array.prototype.toString.call(this, "");
};

StringBuilder.prototype.clear = function()
{
	this.length = this._blockSize;
	this._stringLength = 0;
};
		

/////////////////////////////////////////////////////////////////////////////////////
// BrowserInfo
/////////////////////////////////////////////////////////////////////////////////////
function BrowserInfo()
{
	this.isOpera = function()
	{
		return (navigator.userAgent.toLowerCase().indexOf('opera') >= 0) ? true : false;
	};

	this.isFirefox = function()
	{
		return (navigator.userAgent.toLowerCase().indexOf('firefox') >= 0) ? true : false;
	};
	
	this.isMSIE = function()
	{
		return (navigator.userAgent.toLowerCase().indexOf('msie') >= 0) ? true : false;
	};
	
	this.isSafari = function()
	{
		return (navigator.userAgent.toLowerCase().indexOf('safari') >= 0) ? true : false;
	};
	
	this.version = function()
	{
		return navigator.appVersion.replace(/.*?MSIE (\d\.\d).*/g,'$1')/1;
	}	
}

/////////////////////////////////////////////////////////////////////////////////////
// Utility
/////////////////////////////////////////////////////////////////////////////////////

function Utility()
{
	this.selectAllCheckBoxes = function(checkBox, idPart1, idPart2)
	{
		var i = 0;
	    var nextCheckBox = null;
	    var isChecked = checkBox.checked;
	
	    while (true)
	    {
	        nextCheckBox = document.getElementById(idPart1 + (i++) + idPart2);
	        
	        if (nextCheckBox == null)
	        {
	        	break;
	        }

			if (nextCheckBox.style.visibility == "hidden")
			{
				continue;
			}
	
	        nextCheckBox.checked = isChecked;
	    }
	};
	
	this.checkBoxSelected = function(checkBox, selectAllCheckBoxId, idPart1, idPart2)
	{
	    if (checkBox.checked == false)
	    {
	        document.getElementById(selectAllCheckBoxId).checked = false;
	    }
	    else if (this.checkAllSelected(idPart1, idPart2))
	    {
	        document.getElementById(selectAllCheckBoxId).checked = true;
	    }
	};
	
	this.checkAllSelected = function(idPart1, idPart2)
	{
	    var i = 0;
	    var nextCheckBox = null;
	    var checkBoxId = "";
	
	    while (true)
	    {
	        checkBoxId = idPart1 + (i++) + idPart2;
	        nextCheckBox = document.getElementById(checkBoxId);

	        if (nextCheckBox == null)
	        {
	            break;
	        }
	
			if (!nextCheckBox.checked)
			{
				return false;
			}
	    }
	    
	    return true;
	};

	this.checkAnySelected = function(idPart1, idPart2)
	{
	    var i = 0;
	    var nextCheckBox = null;
	    var checkBoxId = "";
	
	    while (true)
	    {
	        checkBoxId = idPart1 + (i++) + idPart2;
	        nextCheckBox = document.getElementById(checkBoxId);
	
	        if (nextCheckBox == null)
	        {
	            break;
	        }
	
			if (nextCheckBox.checked)
			{
				return true;
			}
	    }
	    
	    alert('No items have been selected.');
	    
	    return false;
	};

	this.showLoadingImage = function()
	{
		document.getElementById("page_Territories:image_Loader").style.visibility = "visible";
		return true;
	};
	
	this.hideLoadingImage = function()
	{
		document.getElementById("page_Territories:image_Loader").style.visibility = "hidden";
	};
	
	this.showViewLoadingImage = function()
	{
		document.getElementById("page_TerritoriesViewEdit:image_Loader").style.visibility = "visible";
		return true;
	};
	
	this.hideViewLoadingImage = function()
	{
		document.getElementById("page_TerritoriesViewEdit:image_Loader").style.visibility = "hidden";
	};
	
	this.scrollToMap = function()
	{
		window.scrollTo(0, 180);
	};
	
	this.isDefined = function(obj)
	{
		return (typeof(obj) != 'undefined');
	};

	this.getLeftPos = function(element)
	{	  
		var returnValue = element.offsetLeft;

		while ((element = element.offsetParent) != null)
		{
	  		if (element.tagName == 'HTML')
			{
				break;
			}
			
  			returnValue += element.offsetLeft;

  			if (document.all)
			{
				returnValue += element.clientLeft;
			}
		}

		return returnValue;
	};
	
	this.getTopPos = function(element)
	{	  
		var returnValue = element.offsetTop;

		while ((element = element.offsetParent) != null)
		{
	  		if (element.tagName == 'HTML')
			{
				break;
			}
			
  			returnValue += element.offsetTop;

  			if (document.all)
			{
				returnValue += element.clientTop;
			}
		}

		return returnValue;
	};

	this.launchLookup = function()
	{
		openLookup("/_ui/common/data/LookupPage?lkfm=page_TerritoriesViewEdit:form_TerritoriesViewEdit&lknm=aro&sn=1&lktp=" + 
			getElementByIdCS("aro_lktp").value, 670, "1", "&lksrch=" + escapeUTF(getElementByIdCS("aro").value));
	};
	this.launchSingleFieldFilterLookup = function()
	{
		openLookup("/_ui/common/data/LookupPage?lkfm=page_TerritoriesViewEdit:form_TerritoriesViewEdit&lknm=s_aro&sn=1&lktp=" + 
			getElementByIdCS("s_aro_lktp").value, 670, "1", "&lksrch=" + escapeUTF(getElementByIdCS("s_aro").value));
	};
	this.launchMultiFieldFilterLookup = function()
	{
		openLookup("/_ui/common/data/LookupPage?lkfm=page_TerritoriesViewEdit:form_TerritoriesViewEdit&lknm=m_aro&sn=1&lktp=" + 
			getElementByIdCS("m_aro_lktp").value, 670, "1", "&lksrch=" + escapeUTF(getElementByIdCS("m_aro").value));
	};

	this.fixId = function(Id)
	{
		var fixedId = Id;
	   	var caseList = [];
	    var lowerCaseID = Id.toLowerCase();
	   
	   	var char1 = 0;
	   	var char2 = 0;
	   	var char3 = 0;
	   
	   	if(Id.length == 15)
	   	{  
	    	for (var i = 0; i < 15; i++)
	    	{
		    	var beforeCaseChg = Id.substr(i, 1);
	     		var afterCaseChg = lowerCaseID.substr(i, 1);
	     
		     	if (beforeCaseChg == afterCaseChg)
		     	{
		      		caseList.push(0);       
		     	}
		     	else
		     	{
		      		caseList.push(1); 
		     	}
		   	}
	    
		    for (var i = 0; i < 15; i++)
		    {
		     	var index = caseList[i];
		     
		     	if (i >= 0 && i <= 4)
		     	{
		      		if (index == 1 && i == 0)
		      		{
		       			char1 += 1; 
		      		}
		      		else if (index == 1 && i == 1)
		      		{
		       			char1 += 2;
		      		}
		      		else if (index == 1 && i == 2)
		      		{
		       			char1 += 4;
		      		}
		      		else if (index == 1 && i == 3)
		      		{
		       			char1 += 8;
		      		}
		      		else if (index == 1 && i == 4)
		      		{
		       			char1 += 16;
		      		}
		     	}
		     	else if (i >= 5 && i <= 9)
		     	{
		      		if (index == 1 && i == 5)
		      		{
		       			char2 += 1; 
		      		}
		      		else if (index == 1 && i == 6)
		      		{
		       			char2 += 2; 
		      		}
		      		else if (index == 1 && i == 7)
		      		{
		       			char2 += 4; 
		      		}
		      		else if (index == 1 && i == 8)
		      		{
		       			char2 += 8; 
		      		}
		      		else if (index == 1 && i == 9)
		      		{
		       			char2 += 16; 
		      		}
		     	}
		     	else if (i >= 10 && i <= 14)
		     	{
		      		if (index == 1 && i == 10)
		      		{
		       			char3 += 1; 
		      		}
		      		else if (index == 1 && i == 11)
		      		{
		       			char3 += 2; 
		      		}
		      		else if (index == 1 && i == 12)
		      		{
		       			char3 += 4; 
		      		}
		      		else if (index == 1 && i == 13)
		      		{
		       			char3 += 8; 
		      		}
		      		else if (index == 1 && i == 14)
		      		{
		       			char3 += 16; 
		      		}
		     	}
		    }
		    
		    var charIndex = [];
		    charIndex.push(char1);
		    charIndex.push(char2);
		    charIndex.push(char3);
		 
		    var charMap = [];
		    charMap["0"] = "A";
		    charMap["1"] = "B";
		    charMap["2"] = "C";
		    charMap["3"] = "D";
		    charMap["4"] = "E";
		    charMap["5"] = "F";
		    charMap["6"] = "G";
		    charMap["7"] = "H";
		    charMap["8"] = "I";
		    charMap["9"] = "J";
		    charMap["10"] = "K";
		    charMap["11"] = "L";
		    charMap["12"] = "M";
		    charMap["13"] = "N";
		    charMap["14"] = "O";
		    charMap["15"] = "P";
		    charMap["16"] = "Q";
		    charMap["17"] = "R";
		    charMap["18"] = "S";
		    charMap["19"] = "T";
		    charMap["20"] = "U";
		    charMap["21"] = "V";
		    charMap["22"] = "W";
		    charMap["23"] = "X";
		    charMap["24"] = "Y";
		    charMap["25"] = "Z";
		    charMap["26"] = "0";
		    charMap["27"] = "1";
		    charMap["28"] = "2";
		    charMap["29"] = "3";
		    charMap["30"] = "4";
		    charMap["31"] = "5";
		    
		    for (var i = 0; i < 3; i++)
		    {
		     	var fixChar = charMap[charIndex[i] + ""]; 
		     	fixedId = fixedId + fixChar;
		    }
	   } 
	       
	   return fixedId;
	};

	this.escapeString = function(inString)
	{
		if (inString == null || inString.length == 0)
		{
			return "";
		}
	
		var outString = inString;
		
		outString = outString.replace(/&/gi, "&amp;");
		outString = outString.replace(/</gi, "&lt;");
		outString = outString.replace(/>/gi, "&gt;");
		outString = outString.replace(/'/gi, "&#39;");
		outString = outString.replace(/"/gi, "&quot;");
		
		return outString;
	};

	this.unescapeString = function(inString)
	{
		if (inString == null || inString.length == 0)
		{
			return "";
		}
	
		var outString = inString;
		
		outString = outString.replace(/&lt;/gi, "<");
		outString = outString.replace(/&gt;/gi, ">");
		outString = outString.replace(/&#39;/gi, "'");
		outString = outString.replace(/&quot;/gi, "\"");
		outString = outString.replace(/&nbsp;/gi, " ");
		outString = outString.replace(/&amp;/gi, "&");
		
		return outString;
	};

	this.fixFileName = function(fileName)
	{
		var outString = this.replaceDoubleQuotesWithSingleQuotes(fileName);
		return outString.replace(new RegExp("[* :?/<>\'|]", "gi"), "_");
	};
		
	
	this.replaceDoubleQuotesWithSingleQuotes = function(inString)
	{
		if (inString == null || inString.length == 0)
		{
			return "";
		}
	
		var outString = inString;
		
		outString = outString.replace(/"/gi, "'");
		
		return outString;
	};
	
	this.escapeQuotes = function(inString)
	{
		if (inString == null || inString.length == 0)
		{
			return "";
		}
	
		var outString = inString;
		
		outString = outString.replace(/'/gi, "&#39;");
		outString = outString.replace(/"/gi, "&quot;");
		
		return outString;
	};
	
	this.replaceCrlf = function(inString)
	{
		var outString = inString;
		
		outString = outString.replace(/\r\n/gi, "<br/>");
		outString = outString.replace(/\r/gi, "<br/>");
		outString = outString.replace(/\n/gi, "<br/>");
		
		return outString;
	};

	this.replaceBr = function(inString)
	{
		return inString.replace(/<br\/>/gi, "\r\n");
	};

	this.stripCrlf = function(inString)
	{
		var outString = inString.replace(/\r/gi, " ");
		return outString.replace(/\n/gi, "");
	};
	
	this.getV2MapType = function(V3MapTypeId)
	{
		switch(V3MapTypeId)
		{
			case google.maps.MapTypeId.HYBRID:
				return "G_HYBRID_MAP";
			case google.maps.MapTypeId.ROADMAP:
				return "G_NORMAL_MAP";
			case google.maps.MapTypeId.SATELLITE:
				return "G_STATELLITE_MAP";
			case google.maps.MapTypeId.TERRAIN:
				return "G_PHYSICAL_MAP";
		}
	};
/*	
	this.getMapTypeFromName = function(mapTypeName)
	{
		switch(mapTypeName)
		{
			case "Map":
				return "G_NORMAL_MAP";
			case "Satellite":
				return "G_SATELLITE_MAP";
			case "Hybrid":
				return "G_HYBRID_MAP";
			case "Terrain":
				return "G_PHYSICAL_MAP";
			default:
				return "";
		}
	};

	this.getMapTypeFromTypeString = function(mapTypeString)
	{
		switch(mapTypeString)
		{
			case "G_NORMAL_MAP":
				return G_NORMAL_MAP;
			case "G_SATELLITE_MAP":
				return G_SATELLITE_MAP;
			case "G_HYBRID_MAP":
				return G_HYBRID_MAP;
			case "G_PHYSICAL_MAP":
				return G_PHYSICAL_MAP;
			default:
				return -1;
		}
	};
*/	
	this.addSelectListOption = function(selectList, value, text)
	{
        var newOption = document.createElement("option");
        newOption.value = value;
        newOption.text = text;
        
        try
        {
            selectList.add(newOption, null);
        }
        catch(e)
        {
            selectList.add(newOption);
        }
	};
	
	this.formatNumber = function(number, decimalPlaces)
	{
		var formattedNumber = String(number);
	
		var pointIndex = formattedNumber.lastIndexOf(".");
		
		if (pointIndex == -1)
		{
			if (decimalPlaces > 0)
			{
				formattedNumber += ".";
			}
				
			for (var i = 0; i < decimalPlaces; i++)
			{
				formattedNumber += "0";
			}
		}
		else
		{
			var decimalDiff = formattedNumber.length - pointIndex - 1;
		
			if (decimalDiff > decimalPlaces)
			{
				formattedNumber = formattedNumber.substring(0, pointIndex + decimalPlaces + 
					(decimalPlaces == 0 ? 0 : 1));
			}
			else if (decimalDiff < decimalPlaces)
			{
				for (var i = 0; i < (decimalPlaces - decimalDiff); i++)
				{
					formattedNumber += "0";
				}
			}
		}
		
		pointIndex = formattedNumber.lastIndexOf(".");
		var commaPosition = (pointIndex == -1 ? formattedNumber.length : pointIndex) - 3;

		while(commaPosition > 0)
		{
			formattedNumber = formattedNumber.substring(0, commaPosition) + "," +
				formattedNumber.substr(commaPosition); 
			commaPosition -= 3;
		}
		
		return formattedNumber;
	};
	
	this.setSelectValue = function(select, value)
	{
		for (var i = 0; i < select.options.length; i++)
		{
			if (select.options[i].value == value)
			{
				select.selectedIndex = i;
				return;
			}
		}
	};

	this.padLeft = function(stringToPad, padCharacter, length)
	{
		var pad = "";
		var padLength = length - stringToPad.length;
		
		while(pad.length < padLength)
		{
			pad += padCharacter;
		}
		
		return pad + stringToPad;
	};

	this.padRight = function(stringToPad, padCharacter, length)
	{
		var pad = "";
		var padLength = length - stringToPad.length;
		
		while(pad.length < padLength)
		{
			pad += padCharacter;
		}
		
		return stringToPad + pad;
	};

	this.left = function(inString, numChars)
	{
		return inString.substr(0, numChars);
	};

	this.right = function(inString, numChars)
	{
		return inString.substr(inString.length - numChars);
	};

	this.endsWith = function(stringToCheck, ending)
	{
		return stringToCheck.lastIndexOf(ending) === (stringToCheck.length - ending.length); 
	};

	this.truncate = function(stringToTruncate, ending)
	{
		if (!stringToTruncate || stringToTruncate.length == 0)
		{
			return stringToTruncate;
		}
		
		if (this.endsWith(stringToTruncate, ending))
		{
			stringToTruncate = this.left(stringToTruncate, stringToTruncate.length - ending.length);
		}
		
		return stringToTruncate; 
	};
	
	this.replaceCrlf = function(inString, replaceWith)
	{
		var outString = inString;
		
		outString = outString.replace(/\r\n/gi, replaceWith);
		outString = outString.replace(/\r/gi, replaceWith);
		outString = outString.replace(/\n/gi, replaceWith);
		
		return outString;
	};
	
	this.trim = function(stringToTrim)
	{
		return stringToTrim.replace(/^\s+|\s+$/g,"");
	};
	
	this.ltrim = function(stringToTrim)
	{
		return stringToTrim.replace(/^\s+/,"");
	};
	
	this.rtrim = function(stringToTrim) 
	{
		return stringToTrim.replace(/\s+$/,"");
	};

	this.sortSelect = function(selectToSort) 
	{
    	var selectOptions = [];

	    for (var i = 0; i < selectToSort.options.length; i++)
    	{
        	selectOptions[i] = [];
        	selectOptions[i][0] = selectToSort.options[i].text;
        	selectOptions[i][1] = selectToSort.options[i].value;
        	selectOptions[i][2] = selectToSort.options[i].selected;
    	}

	    selectOptions.sort();

    	for (var i = 0; i < selectToSort.options.length; i++)
    	{
        	selectToSort.options[i].text = selectOptions[i][0];
        	selectToSort.options[i].value = selectOptions[i][1];
        	selectToSort.options[i].selected = selectOptions[i][2];
    	}
	};
	
	this.clearSelectSelections = function(selectToClear)
	{
    	for (var i = 0; i < selectToClear.options.length; i++)
    	{
        	selectToClear.options[i].selected = false;
    	}
	};

	this.clearSelect = function(selectToClear)
	{
		var count = selectToClear.options.length;
		
    	for (var i = 0; i < count; i++)
    	{
        	selectToClear.remove(0);
    	}
	};
	
	this.createSelectOption = function(optionData)
	{
        var option = document.createElement("option");
        option.value = optionData.value;
        option.text = optionData.text;
        
        return option;
	}
	
	this.addSelectOption = function(select, option)
	{
        try
        {
            select.add(option, null);
        }
        catch(e)
        {
            select.add(option);
        }
	};

	this.nameSort = function(a, b)
	{
		if (a.name > b.name)
		{
			return 1;
		}
		else if (a.name < b.name)
		{
			return -1;
		}
		return 0; 
	};
	
	this.getSalesforceDomain = function()
	{
		var server = document.domain.split(".")[1];
		return "https://" + server + ".salesforce.com/"
	};

	this.getSalesforceServer = function()
	{
		return document.domain.split(".")[1];
	};
	
	this.degreesToRadians = function(degrees)
	{
		return degrees * Math.PI / 180;
	};
	
	this.radiansToDegrees = function(radians)
	{
		return radians * 180 / Math.PI;
	};
	
	this.lightenColor = function(color)
	{
		var r = parseInt(color.substring(1, 3), 16);
		var g = parseInt(color.substring(3, 5), 16);
		var b = parseInt(color.substring(5, 7), 16);
		
		r = Math.min(255, r + 128);
		g = Math.min(255, g + 128);
		b = Math.min(255, b + 128);
		
		return "#" + r.toString(16) + g.toString(16) + b.toString(16);
	};
	
	this.getLocalizedDateString = function(date)
	{
		var localized = locale.dateFormat;
		localized = localized.replace(/yyyy/, date.getFullYear());
		localized = localized.replace(/dd/, date.getDate());
		localized = localized.replace(/MMM/, this.getLocalizedMonthName(date.getMonth()));
		return localized;
	};

	this.getLocalizedDateTimeString = function(date)
	{
		date.setTime(date.getTime() + (date.getTimezoneOffset() * -60000));	

		var localized = locale.dateTimeFormat;
		var amPm = localized.indexOf("a") !== -1;

		localized = localized.replace(/a/, "");
		localized = localized.replace(/yyyy/, date.getFullYear());
		localized = localized.replace(/dd/, date.getDate());
		localized = localized.replace(/MMM/, this.getLocalizedMonthName(date.getMonth()));
		localized = localized.replace(/hh/, this.padLeft(String(date.getHours()), "0", 2));
		localized = localized.replace(/mm/, this.padLeft(String(date.getMinutes()), "0", 2));
		
		if (amPm)
		{
			var hours = date.getHours();
			var dateHours = hours;
			var minutes = date.getMinutes();
			
			if (dateHours > 12)
			{
				dateHours = String(parseInt(dateHours) - 12);
			}
			
			localized += "(" + dateHours + ":" + this.padLeft(String(date.getMinutes()), "0", 2) + (hours >= 12 ? " pm)" : " am)");
		}
		
		return localized;
	};

	this.getLocalizedMonthName = function(monthNumber)
	{
		switch(monthNumber)
		{
			default:
			case 0: return locale.jan;
			case 1: return locale.feb;
			case 2: return locale.mar;
			case 3: return locale.apr;
			case 4: return locale.may;
			case 5: return locale.jun;
			case 6: return locale.jul;
			case 7: return locale.aug;
			case 8: return locale.sep;
			case 9: return locale.oct;
			case 10: return locale.nov;
			case 11: return locale.dec;
		}
	};

	this.regionCodeToCountryName = function(regionCode)
	{
		// country name should be exactly as appears in "Geocode_Address"
		
		switch(regionCode)
		{
			case "us":
				return "USA";
			default:
				return "";
		}
	};
	
	this.pointInPolygon = function(polygon, point)
	{
		var result = false;
		
		for(var i = -1, l = polygon.length, j = l - 1; ++i < l; j = i)
		{
			((polygon[i].lat() <= point.lat() && point.lat() < polygon[j].lat()) || (polygon[j].lat() <= point.lat() && point.lat() < polygon[i].lat()))
			&& (point.lng() < (polygon[j].lng() - polygon[i].lng()) * (point.lat() - polygon[i].lat()) / (polygon[j].lat() - polygon[i].lat()) + polygon[i].lng())
			&& (result = !result);
		}
	
		return result;
	};

	this.pointInCircle = function(center, radius, point)
	{
		return this.distanceBetween(center, point) <= radius;
	};
	
	this.distanceBetween = function(p1, p2) 
	{
  		var R = 6371;
  		var dLat = (p2.lat() - p1.lat()) * Math.PI / 180;
		var dLong = (p2.lng() - p1.lng()) * Math.PI / 180;

		var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
			Math.cos((p1.lat()) * Math.PI / 180) * Math.cos((p2.lat()) * Math.PI / 180) * Math.sin(dLong/2) * Math.sin(dLong/2);
		var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
		var d = R * c;

		return d.toFixed(3);
	};
	
	this.fromLatLngToPoint = function(latLng) 
	{
		var topRight = map.getProjection().fromLatLngToPoint(map.getBounds().getNorthEast());
		var bottomLeft = map.getProjection().fromLatLngToPoint(map.getBounds().getSouthWest());
		var scale = Math.pow(2, map.getZoom());
		var worldPoint = map.getProjection().fromLatLngToPoint(latLng);
		return new google.maps.Point((worldPoint.x - bottomLeft.x) * scale, (worldPoint.y - topRight.y) * scale);
	};
	
	
	
	this.sendPexysListRequest = function(list, params, callback)
	{


	
//		this.sendJsonRequest("http://127.0.0.1:8888/pexmapsgislistserver?list=" + list + params, callback);
		//this.sendJsonRequest("https://pexmapsgislist.appspot.com/pexmapsgislistserver?list=" + list + params, callback);
		this.sendJsonRequest("https://www.pexmaps.com:8443/PexmapsListServer/GisListServlet?list=" + list + params, callback);
	};

	this.sendPolygonRequest = function(rgn, params, callback)
	{
		this.sendJsonRequest("https://www.pexmaps.com:8443/PexmapsGisPolygonServer/pexmapspolygons?rgn=" + rgn + params, callback);
//		this.sendJsonRequest("http://www.pexmaps.com:8080/PexmapsGisPolygonServer/pexmapspolygons?rgn=" + rgn + params, callback);
	};
	
	this.sendPointLabelRequest = function(rgn, params, callback)
	{

//		this.sendJsonRequest("http://71.63.154.17:8080/PexmapsGisPolygonServer/pexmapspoints?rgn=" + rgn + params, callback);
//		this.sendJsonRequest("http://www.pexmaps.com:8080/PexmapsGisPolygonServer/pexmapspoints?rgn=" + rgn + params, callback);
		
		this.sendJsonRequest("https://www.pexmaps.com:8443/PexmapsGisPolygonServer/pexmapspoints?" + params, callback);
		
	}

	this.sendTamuGeocodeRequest = function(params, callback)
	{
		this.sendJsonRequest("https://www.pexmaps.com:8443/PexmapsTamuGeocoding/TamuGeocoding?" + params, callback);
//		this.sendJsonRequest("http://69.80.107.160:8080/PexmapsTamuGeocoding/TamuGeocoding?" + params, callback);
	}

	this.sendYahooGeocodeRequest = function(params, callback)
	{
		this.sendJsonRequest("https://www.pexmaps.com:8443/PexmapsYahooGeocoding/YahooGeocoding?request=" + params, callback);
	}

	this.sendGoogleGeocodeRequest = function(params, callback)
	{
		//this.sendJsonRequest("https://www.pexmaps.com:8443/PexmapsGoogleGeocoding/GoogleGeocoding?request=" + params, callback);
		
		//this.sendJsonRequest("http://66.41.248.198:8080/PexmapsGoogleGeocoding/GoogleGeocoding?request=" + params, callback);
		this.sendJsonRequest("https://www.pexmaps.com:8443/PexmapsGoogleGeocoding/GoogleGeocoding?org=" + OrgId + "&request=" + params, callback);
	}
	
	this.sendJsonRequest = function(url, callback)
	{
		$.getJSON(url + "&format=json&callback=?", callback);
	};

}

/////////////////////////////////////////////////////////////////////////////////////
// JsonDump
//
// sample call: document.writeln(jsonDump.dump(object));
//
/////////////////////////////////////////////////////////////////////////////////////
function JsonDump()
{
	var MAX_DEPTH = 10;


	this.str_repeat = function(str, repeat)
	{
		var output = '';

		for (var i = 0; i < repeat; i++) 
  		{
    		output += str;
  		}

  		return output;
	}


	this.dump = function(obj, indent, depth) 
	{
  		var ws = '&nbsp;&nbsp;&nbsp;&nbsp;';
  		var output = '';

  		indent = (!indent) ? 5 : indent;
  		depth = (!depth) ? 0 : depth;

  		if (depth > MAX_DEPTH) 
  		{
    		return this.str_repeat(ws, indent) + '*Maximum Depth Reached*<br/>';
  		}

  		if (typeof(obj) == "object") 
  		{
    		output += (indent == 0) ? typeof(obj) + '<br/>(<br/>' : '';
    		indent++;

    		var child = '';

    		for (var key in obj) 
    		{
      			try 
      			{
        			child = obj[key];
      			}
      			catch (e) 
      			{
        			child = '*Unable To Evaluate*';
      			}

      			output += this.str_repeat(ws, indent) + '['+key+'] => ';

      			if (typeof(child) == "object") 
      			{
        			indent++;
        			output += typeof(child) + '<br/>';
        			output += this.str_repeat(ws, indent) + '(<br/>';
        			output += this.dump(child, indent, depth+1);
        			output += this.str_repeat(ws, indent) + ')<br/>';
        			indent--;
      			}
      			else 
      			{
        			output += child + '<br/>';
      			}
    		}

    		indent--;
    		output += (indent == 0) ? ')<br/>' : '';

    		return output;
  		}
  		else 
  		{
    		return this.str_repeat(ws, indent) + obj + '<br/>';
  		}
	}
}
