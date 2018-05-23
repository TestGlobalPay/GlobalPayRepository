///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/

/////////////////////////////////////////////////////////////////////////////////////
// DuelingListBoxes
/////////////////////////////////////////////////////////////////////////////////////

function DuelingListBoxes(enableSelectedReorder, noneLabel, maximumSelected)
{
	this.availableListBox = null;
	this.selectedListBox = null;
	this.addButton = null;
	this.removeButton = null;
	this.availableItemsInput = null;
	this.selectedItemsInput = null;
	this.enableSelectedReorder = enableSelectedReorder;
	this.maximumSelected = maximumSelected == null ? -1 : maximumSelected;
	
	this.NONE_ITEM_VALUE = "-- None --";
	this.NONE_ITEM_TEXT = "-- " + noneLabel + " --";
	
	this.init = function(itemPrefix, disable, availableListBoxId, selectedListBoxId, addButtonId,
		removeButtonId, availableItemsInputId, selectedItemsInputId)
	{
		this.availableListBox = document.getElementById(availableListBoxId);
		this.selectedListBox = document.getElementById(selectedListBoxId);
		this.addButton = document.getElementById(addButtonId);
		this.removeButton = document.getElementById(removeButtonId);
		this.availableItemsInput = document.getElementById(availableItemsInputId);
		this.selectedItemsInput = document.getElementById(selectedItemsInputId);

		if (disable)
		{
			this.disableAdd();
			this.disableRemove();
		}

		util.clearSelect(this.availableListBox);
		util.clearSelect(this.selectedListBox);

		this.initListBoxes(itemPrefix);		
	};

	this.initListBoxes = function(itemPrefix)
	{
		var availableItemsDataInput = util.trim(this.availableItemsInput.value);
		var selectedItemsDataInput = util.trim(this.selectedItemsInput.value);






		var availableItemsData = availableItemsDataInput.length == 0 ? [] : availableItemsDataInput.split(separator.section);
		var selectedItemsData = selectedItemsDataInput.length == 0 ? [] : selectedItemsDataInput.split(separator.para);

		for (var i = 0; i < availableItemsData.length; i++)
		{
			var availableItemData = availableItemsData[i].split(separator.para);
			var itemText = (itemPrefix != null && itemPrefix.length > 0 ? itemPrefix : "") + availableItemData[0];
			var itemValue = availableItemData[1];
			var item = util.createSelectOption({ text: itemText, value: itemValue}); 
			var itemIsSelected = false;
			
			for (var j = 0; j < selectedItemsData.length; j++)
			{
				if (item.value == selectedItemsData[j])
				{
					itemIsSelected = true;
					break;		
				}
			}

			if (itemIsSelected)
			{
				util.addSelectOption(this.selectedListBox, item);
			}
			else
			{
				util.addSelectOption(this.availableListBox, item);
			}
		}

		this.addNoneItem(this.availableListBox);
		this.addNoneItem(this.selectedListBox);
	};

	this.addNoneItem = function(listBox)
	{
    	if (listBox.options.length == 0)
    	{
    		util.addSelectOption(listBox, 
    			util.createSelectOption({text: this.NONE_ITEM_TEXT, value:this.NONE_ITEM_VALUE}));
    	}
	};
	
	this.removeNoneItem = function(listBox)
	{
		if (listBox.options.length == 1 &&
			listBox.options[0].value == this.NONE_ITEM_VALUE)
		{
			listBox.remove(0);
		}
	};

	this.disableAdd = function()
	{
		this.addButton.href = "javascript:void(0)";
	};

	this.disableRemove = function()
	{
		this.removeButton.href = "javascript:void(0)";
	};
	
	this.addSelectedAvailableItems = function()
	{
		if (this.maximumSelected > 0 &&
			this.selectedListBox.options.length >= this.maximumSelected)
		{
			return;
		}
		
		util.clearSelectSelections(this.selectedListBox);
		this.addItems(this.selectedListBox, this.removeSelectedItems(this.availableListBox));
		
		if (!this.enableSelectedReorder)
		{
			util.sortSelect(this.selectedListBox);
		}

		this.outputSelectedItems();
	};
	
	this.removeSelectedSelectedItems = function()
	{
		util.clearSelectSelections(this.availableListBox);
		this.addItems(this.availableListBox, this.removeSelectedItems(this.selectedListBox));
		util.sortSelect(this.availableListBox);

		this.outputSelectedItems();
	};
	
	this.removeSelectedItems = function(listBox)
	{
		var removedItems = [];
		
	    for (var i = listBox.options.length - 1; i >= 0; i--)
    	{
        	if (listBox.options[i].selected)
        	{	
        		removedItems.push(listBox.options[i]);
        		listBox.remove(i);
        	}
    	}
    	
    	this.addNoneItem(listBox);
    	
    	return removedItems;
	};
	
	this.addItems = function(listBox, items)
	{
		this.removeNoneItem(listBox);

	    for (var i = 0; i < items.length; i++)
    	{
    		util.addSelectOption(listBox, items[i]);
    	}
	};
	
	this.moveSelectedUp = function()
	{
		for (var i = 1; i < this.selectedListBox.length; i++)
		{
			if (this.selectedListBox.options[i].selected)
			{
				var selectedOption = this.selectedListBox.options[i];
				this.selectedListBox.remove(i);
				this.selectedListBox.add(selectedOption, this.selectedListBox.options[i - 1]);
			}
		}		

		this.outputSelectedItems();
	};

	this.moveSelectedDown = function()
	{
		for (var i = this.selectedListBox.length - 2; i >= 0; i--)
		{
			if (this.selectedListBox.options[i].selected)
			{
				var selectedOption = this.selectedListBox.options[i];
				this.selectedListBox.remove(i);
				this.selectedListBox.add(selectedOption, 
					this.selectedListBox.options[i + 1]);
			}
		}		

		this.outputSelectedItems();
	};
	
	this.moveSelectedToTop = function()
	{
		var selectedItems = [];
		
		for (var i = this.selectedListBox.length - 1; i >= 0; i--)
		{
			if (this.selectedListBox.options[i].selected)
			{
				selectedItems.push(this.selectedListBox.options[i]);
				this.selectedListBox.remove(i);
			}
		}		

		for (var i = 0; i < selectedItems.length; i++)
		{
			this.selectedListBox.add(selectedItems[i], this.selectedListBox.options[0]);
		}

		this.outputSelectedItems();
	};
	
	this.moveSelectedToBottom = function()
	{
		var selectedItems = [];
		
		for (var i = this.selectedListBox.length - 1; i >= 0; i--)
		{
			if (this.selectedListBox.options[i].selected)
			{
				selectedItems.push(this.selectedListBox.options[i]);
				this.selectedListBox.remove(i);
			}
		}		

		for (var i = selectedItems.length - 1; i >= 0; i--)
		{
			this.selectedListBox.add(selectedItems[i], null);
		}
		
		this.outputSelectedItems();
	};
	
	this.outputSelectedItems = function()
	{
		if (this.selectedListBox.options.length == 1 &&
			this.selectedListBox.options[0].value == this.NONE_ITEM_VALUE)
		{
			this.selectedItemsInput.value = "";
			return;
		}
		
		var selectedItemsString = "";
		
		for (var i = 0; i < this.selectedListBox.length; i++)
		{
			if (i > 0)
			{
				selectedItemsString += separator.para;
			}
			
			selectedItemsString += this.selectedListBox[i].value;
		}
		
		this.selectedItemsInput.value = selectedItemsString;
	};
}
