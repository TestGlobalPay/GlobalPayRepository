///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/

var permissions = new Permissions();

/////////////////////////////////////////////////////////////////////////////////////
// Permissions
/////////////////////////////////////////////////////////////////////////////////////
function Permissions()
{
	this.availableGroups = "";
	this.availableRoles = "";

	this.PERMISSION_EVERYONE = "Everyone";
	this.PERMISSION_ME_ONLY = "Me Only";
	this.PERMISSION_SELECTED_USERS = "Selected Users";
	
	this.getAvailableGroups = function(availableInputId)
	{
		if (this.availableGroups.length == 0)
		{
			this.loadAvailableGroups();
		}

		document.getElementById(availableInputId).value = this.availableGroups;
	};

	this.getAvailableRoles = function(availableInputId)
	{
		if (this.availableRoles.length == 0)
		{
			this.loadAvailableRoles();
		}
		
		document.getElementById(availableInputId).value = this.availableRoles;
	};

	this.loadAvailableGroups = function()
	{
		var groups = this.loadGroups();
			
		for (var i = 0; i < groups.length; i++)
		{
			if (i > 0)
			{
				this.availableGroups += separator.section;
			}
				
			this.availableGroups += groups[i].name;
			this.availableGroups += separator.para;
			this.availableGroups += groups[i].id;
		}

		groups.length = 0;
	};

	this.loadAvailableRoles = function()
	{
		var roles = this.loadRoles();
		
		for (var i = 0; i < roles.length; i++)
		{
			if (i > 0)
			{
				this.availableRoles += separator.section;
			}
				
			this.availableRoles += roles[i].name;
			this.availableRoles += separator.para;
			this.availableRoles += roles[i].id;
		}
			
		roles.length = 0;
	};

	this.loadGroups = function()
	{
		var groups = [];
		
    	var groupRecords;
    	var queryResult;
    	var queryString = "SELECT Id, Name FROM Group WHERE Type=\'Regular\' ORDER BY Name";
    	var moreRecords = true;
    
		try
    	{
        	queryResult = sforce.connection.query(queryString);
        	groupRecords = queryResult.getArray('records');
    	} 
    	catch(error)
    	{
        	alert("Fetch Groups failed with error: " + error);
        	return groups;
    	}
	    
    	while (moreRecords)
    	{
        	for (var i = 0; i < groupRecords.length; i++)
        	{
            	groups.push({ id : groupRecords[i].Id, name : groupRecords[i].Name });
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
					groupRecords = queryResult.getArray('records');
				}
		    	catch(error)
		    	{
		        	alert("Fetch Groups failed with error: " + error);
		    	}
			}
		}
		
		return groups;
	};

	this.loadGroupRecords = function()
	{
    	var groupRecords = [];
    	
    	var records;
    	var queryResult;
    	var queryString = "SELECT Id, Type, RelatedId FROM Group WHERE Type != \'Queue\'";
    	var moreRecords = true;
    
		try
    	{
        	queryResult = sforce.connection.query(queryString);
        	records = queryResult.getArray('records');
    	} 
    	catch(error)
    	{
        	alert("Fetch Group Records failed with error: " + error);
    	}
	    
    	while (moreRecords)
    	{
        	for (var i = 0; i < records.length; i++)
        	{
            	groupRecords.push({ id : records[i].Id, type : records[i].Type, 
            			relatedId : records[i].RelatedId });
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
					records = queryResult.getArray('records');
				}
		    	catch(error)
		    	{
		        	alert("Fetch Group Records failed with error: " + error);
		    	}
			}
		}
		
		return groupRecords;
	};

	this.getGroupRecord = function(groupId, groupRecords)
	{
		for (var i = 0; i < groupRecords.length; i++)
		{
			if (groupRecords[i].id == groupId)
			{
				return groupRecords[i];
			}
		}
		
		return null;
	};
	
	this.loadRoles = function()
	{
		var roles = [];
		
	    var roleRecords;
    	var queryResult;
    	var queryString = "SELECT Id, Name, ParentRoleId FROM UserRole ORDER BY Name";
    	var moreRecords = true;

	    try
    	{
        	queryResult = sforce.connection.query(queryString);
        	roleRecords = queryResult.getArray('records');
    	} 
    	catch(error)
    	{
        	alert("Fetch Roles failed with error: " + error);
        	return;
    	}
    
	    while (moreRecords)
    	{
        	for (var i = 0; i < roleRecords.length; i++)
	        {
    	        roles.push({ id: roleRecords[i].Id, name : roleRecords[i].Name, 
    	        	parentId : roleRecords[i].ParentRoleId });
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
					roleRecords = queryResult.getArray('records');
				}
		    	catch(error)
			    {
		        	alert("Fetch Roles failed with error: " + error);
		        	return;
		    	}
			}
    	}
    	
    	return roles;
	};

	this.loadGroupMembers = function()
	{
		var groupMembers = [];
		
    	var groupMemberRecords;
    	var queryResult;
    	var queryString = "SELECT GroupId, UserOrGroupId FROM GroupMember";
    	var moreRecords = true;

	    try
    	{
    		queryResult = sforce.connection.query(queryString);
        	groupMemberRecords = queryResult.getArray('records');
    	} 
    	catch(error)
    	{
        	alert("Query Group Members failed with error: " + error);
        	return;
    	}
    
	    while (moreRecords)
    	{
        	for (var i = 0; i < groupMemberRecords.length; i++)
	        {
           	    groupMembers.push({ groupId : groupMemberRecords[i].GroupId, 
           	    	userOrGroupId : groupMemberRecords[i].UserOrGroupId });
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
					groupMemberRecords = queryResult.getArray('records');
				}
			    catch(error)
			    {
		    	    alert("Query Group Members failed with error: " + error);
		        	return;
			    }
			}
    	}
    	
    	return groupMembers;
	};

	this.getGroupMemberSet = function(groupId, groupMembers)
	{
		var groupMemberSet = [];
		
		for (var i = 0; i < groupMembers.length; i++)
		{
			if (groupMembers[i].groupId == groupId)
			{
				groupMemberSet.push(groupMembers[i]);
			}
		}
		
		return groupMemberSet;
	};
	

	this.loadViews = function()
	{
		var views = [];
		
	    var viewRecords;
    	var queryResult;
    	var queryString = "SELECT Id, Name, pexmaps__PermissionsOption__c, OwnerId, pexmaps__Private__c, \
        	pexmaps__GroupPermissions__c, pexmaps__RolePermissions__c, pexmaps__RoleAndSubordinatePermissions__c, \
        	pexmaps__Type__c, pexmaps__Definition__c \
        	FROM pexmaps__TerritoryView__c ORDER BY Name";
    	var moreRecords = true;

	    try
    	{
        	queryResult = sforce.connection.query(queryString);
        	viewRecords = queryResult.getArray('records');
    	} 
    	catch(error)
    	{
        	alert("Fetch View List failed with error: " + error);
        	return;
    	}
    
	    while (moreRecords)
    	{
        	for (var i = 0; i < viewRecords.length; i++)
	        {
	        	var componentViewIds = "";
	        	
	        	if (viewRecords[i].pexmaps__Type__c == "Combination")
	        	{
	        		var definitionParts = viewRecords[i].pexmaps__Definition__c.split(separator.section);
	        		
	        		for (var j = 0; j < definitionParts.length; j++)
	        		{
	        			if (j > 0)
	        			{
	        				componentViewIds += separator.para;
	        			}
	        			
	        			componentViewIds += definitionParts[j].split(separator.para)[0];
	        		}
	        	}
	        	
    	        views.push({ 
    	        	id : viewRecords[i].Id, 
    	        	name : viewRecords[i].Name,
    	        	type : viewRecords[i].pexmaps__Type__c, 
    	        	ownerId : viewRecords[i].OwnerId,
    	        	viewIds : componentViewIds,
    	        	permissionsOption : this.defaultViewPermissionsOption(viewRecords[i]),
    	        	groupPermissions : viewRecords[i].pexmaps__GroupPermissions__c,
    	        	rolePermissions : viewRecords[i].pexmaps__RolePermissions__c,
    	        	roleAndSubordinatePermissions : viewRecords[i].pexmaps__RoleAndSubordinatePermissions__c });
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
					viewRecords = queryResult.getArray('records');
				}
		    	catch(error)
			    {
		        	alert("Fetch View List failed with error: " + error);
		        	return;
		    	}
			}
    	}
    	
    	return views;
	};

	this.defaultViewPermissionsOption = function(viewRecord)
	{
		if (viewRecord.pexmaps__PermissionsOption__c == null)
		{
			// legacy
			return viewRecord.pexmaps__Private__c == "true" ? this.PERMISSION_ME_ONLY : this.PERMISSION_EVERYONE;
		}
		else if (viewRecord.pexmaps__PermissionsOption__c == this.PERMISSION_SELECTED_USERS &&
			viewRecord.pexmaps__GroupPermissions__c == null && viewRecord.pexmaps__RolePermissions__c == null &&
			viewRecord.pexmaps__RoleAndSubordinatePermissions__c == null)
		{
			return this.PERMISSION_ME_ONLY;
		}
		
		return viewRecord.pexmaps__PermissionsOption__c;
	};

	this.getViewIndex = function(viewSelect, viewId)
	{
		for (var i = 0; i < viewSelect.options.length; i++)
		{
			if (viewSelect.options[i].value.split(separator.section)[0] == viewId)
			{
				return i;
			}
		}
		
		return -1;
	};

	this.getComponentViews = function(combinationView, views)
	{
		var componentViewIds = combinationView.viewIds.split(separator.para);
		var componentViews = [];
		
		for (var i = 0; i < componentViewIds.length; i++)
		{
			var componentView = null;
			for (var j = 0; j < views.length; j++)
			{
				if (views[j].id == componentViewIds[i])
				{
					componentView = views[j];
					break;
				}
			}

			if (componentView != null)
			{
				componentViews.push(componentView)
			}
		}
		
		return componentViews;
	}

	this.setCombinationViewPermission = function(combinationView, views, groupMembers, roles)
	{
		var componentViews = this.getComponentViews(combinationView, views);
		
		// if at least one component view is ME_ONLY, then Combo View is ME_ONLY
		for (var i = 0; i < componentViews.length; i++)
		{
			if (componentViews[i].permissionsOption == this.PERMISSION_ME_ONLY)
			{
				combinationView.permissionsOption = this.PERMISSION_ME_ONLY;
				combinationView.groupPermissions = null;
				combinationView.rolePermissions = null;
				combinationView.roleAndSubordinatePermissions = null;
				return;
			}
		}
		
		// if all component views are EVERYONE, the Combo View is EVERYONE
		var allEveryone = true;
		for (var i = 0; i < componentViews.length; i++)
		{
			if (componentViews[i].permissionsOption != this.PERMISSION_EVERYONE)
			{
				allEveryone = false;
				break;
			}
		}
			
		if (allEveryone)
		{
			combinationView.permissionsOption = this.PERMISSION_EVERYONE;
			combinationView.groupPermissions = null;
			combinationView.rolePermissions = null;
			combinationView.roleAndSubordinatePermissions = null;
			return;
		}
		
		// otherwise, use intersection of component view permissions
		combinationView.groupPermissions = this.intersectPermissions(componentViews, "Group");
			
		combinationView.rolePermissions = this.intersectPermissions(componentViews, "Role");
			
		combinationView.roleAndSubordinatePermissions = this.intersectPermissions(componentViews, "RoleAndSubordinate");
			
		if ((combinationView.groupPermissions == null || combinationView.groupPermissions.length == 0) &&
			(combinationView.rolePermissions == null || combinationView.rolePermissions.length == 0) &&
			(combinationView.roleAndSubordinatePermissions == null || combinationView.roleAndSubordinatePermissions.length == 0))
		{
			combinationView.permissionsOption = this.PERMISSION_ME_ONLY;
		}
		else
		{
			combinationView.permissionsOption = this.PERMISSION_SELECTED_USERS;
		}
	};
	
	this.intersectPermissions = function(views, permissionType)
	{
		var permissions = [];
		var combinedPermissions;
		
		var everyoneFlag = true;
		for (var i = 0; i < views.length; i++)
		{
			if (i == 0)
			{
				if (permissionType == "Group")
				{
				 	combinedPermissions = views[0].groupPermissions == null ?
						[] : views[0].groupPermissions.split(separator.para);
				}
				else if (permissionType == "Role")
				{
				 	combinedPermissions = views[0].rolePermissions == null ?
						[] : views[0].rolePermissions.split(separator.para);
				}
				else if (permissionType == "RoleAndSubordinate")
				{
					combinedPermissions = views[0].roleAndSubordinatePermissions == null ?
						[] : views[0].roleAndSubordinatePermissions.split(separator.para);
				}
					
				everyoneFlag = views[0].permissionsOption == this.PERMISSION_EVERYONE;					
				continue;
			}
			
			if (views[i].permissionsOption == this.PERMISSION_EVERYONE)
			{
				continue;
			}
			
			var nextPermissions;
				
			if (permissionType == "Group")
			{
				nextPermissions = views[i].groupPermissions == null ?
					[] : views[i].groupPermissions.split(separator.para);
			}
			else if (permissionType == "Role")
			{
			 	nextPermissions = views[i].rolePermissions == null ?
					[] : views[i].rolePermissions.split(separator.para);
			}
			else if (permissionType == "RoleAndSubordinate")
			{
				nextPermissions = views[i].roleAndSubordinatePermissions == null ?
					[] : views[i].roleAndSubordinatePermissions.split(separator.para);
			}
				
			if (everyoneFlag)
			{
				combinedPermissions = combinedPermissions.concat(nextPermissions);
				everyoneFlag = false;
				continue;
			}
			everyoneFlag = false;
				
			permissions.length = 0;
			permissions = permissions.concat(combinedPermissions);
			combinedPermissions.length = 0;

			for (var j = 0; j < nextPermissions.length; j++)
			{
				for (var k = 0; k < permissions.length; k++)
				{
					if (nextPermissions[j] == permissions[k])
					{
						combinedPermissions.push(nextPermissions[j]);
					}
				}
			}
				
			if (combinedPermissions.length == 0)
			{
				break;
			}
		}
			
		return combinedPermissions.join(separator.para);
	};

	this.filterViewSelectList = function(viewSelectId)
	{
		var viewSelect = document.getElementById(viewSelectId);
		
		var views = this.loadViews();
		var roles = this.loadRoles();
		var groupMembers = this.loadGroupMembers();
		var groupRecords = this.loadGroupRecords();
		
		for (var i = 0; i < views.length; i++)
		{
			var viewIndex = this.getViewIndex(viewSelect, views[i].id);
			
			if (viewIndex == -1)
			{
				continue;
			}

			try
			{
	    		if (views[i].type == "Combination")
    			{
    				this.setCombinationViewPermission(views[i], views, groupMembers, roles);
	    		}
			
				if(!this.viewIsVisible(views[i], groupMembers, groupRecords, roles))
				{			
					viewSelect.remove(viewIndex);
				}
	    	} 
    		catch(error)
    		{
				viewSelect.remove(viewIndex);
    		}
		}
		
		views.length = 0;
		roles.length = 0;
		groupMembers.length = 0;
	};
	
	this.viewIsVisible = function(view, groupMembers, groupRecords, roles)
	{
		if (view.ownerId == userId)
		{
			return true;
		}
		
    	if (userIsSysAdmin)
    	{
			return true;
		}
    	
    	if (view.permissionsOption == this.PERMISSION_EVERYONE)
    	{
    		return true;
    	}
    	
    	if (view.permissionsOption == this.PERMISSION_ME_ONLY &&
    		view.ownerId != userId)
    	{
    		return false;
    	}
    	
    	if (this.localUserInAllowedGroups(view, groupMembers, groupRecords, roles))
    	{
    		return true;
    	}
    	
    	if (this.localUserInAllowedRoles(view))
    	{
    		return true;
    	}
    	
    	if(this.localUserInAllowedRolesAndSubordinates(view, roles))
    	{
    		return true;
    	}
    	
    	return false;
	};
	
	this.localUserInAllowedGroups = function(view, groupMembers, groupRecords, roles)
	{
		if (view.groupPermissions == null || view.groupPermissions.length == 0)
		{
			return false;
		}

		return this.localUserInGroups(view.groupPermissions.split(separator.para), groupMembers, groupRecords, roles);
	};
	
	this.localUserInGroups = function(groupIds, groupMembers, groupRecords, roles)
	{
		for (var i = 0; i < groupIds.length; i++)
		{
			var groupMemberSet = this.getGroupMemberSet(groupIds[i], groupMembers);

			for (var j = 0; j < groupMemberSet.length; j++)
			{
				if (groupMemberSet[j].userOrGroupId == userId)
				{
					return true;
				}

				var groupRecord = this.getGroupRecord(groupMemberSet[j].userOrGroupId, groupRecords);

				if (groupRecord == null)
				{
					continue;
				}
				
				if (groupRecord.type == "Role")
				{
					if (userRoleId == groupRecord.relatedId)
					{
						return true;
					}
				}
				else if (groupRecord.type == "RoleAndSubordinates")
				{
					if (this.localUserInRolesAndSubordinates([groupRecord.relatedId], roles))
					{
						return true;
					}
				}
				else if (groupRecord.type == "Regular")
				{
					if (this.localUserInGroups([groupMemberSet[j].userOrGroupId], groupMembers, groupRecords, roles))
					{
						return true;
					}
				}
			}
		}
		
		return false;
	}
	
	this.localUserInAllowedRoles = function(view)
	{
    	if (view.rolePermissions == null ||
    		view.rolePermissions.length == 0)
    	{
    		return false;
    	}

		var rolePermissions = view.rolePermissions.split(separator.para)

		for (var i = 0; i < rolePermissions.length; i++)
		{
			if (rolePermissions[i] == userRoleId)
			{
				return true;
			}
		}
		
		return false;
	};
	
	this.localUserInAllowedRolesAndSubordinates = function(view, roles)
	{
    	if (view.roleAndSubordinatePermissions != null &&
    		view.roleAndSubordinatePermissions.length > 0)
    	{
	    	return this.localUserInRolesAndSubordinates(view.roleAndSubordinatePermissions.split(separator.para), roles);
    	}
	};

	this.localUserInRolesAndSubordinates = function(roleIds, roles)
	{
		var nextParentRoleId = userRoleId;
		
		while (nextParentRoleId != null)
		{
			for (var i = 0; i < roleIds.length; i++)
			{
				if (roleIds[i] == nextParentRoleId)
				{
					return true;
				}
			}
			
    		nextParentRoleId = this.getParentRoleId(nextParentRoleId, roles);
		}
		
		return false;
	};
	
	this.getParentRoleId = function(roleId, roles)
	{
		for (var i = 0; i < roles.length; i++)
		{
			if (roles[i].id == roleId)
			{
				return roles[i].parentId;
			}
		}
		
		return null;
	};
}