public with sharing class AccountTriggerHelper {
private static boolean isDeletedUpdation = false;
private static boolean parentIdChanged = false;
    public static void isParentStatusUpdate(List<Account> accounts,List<Account> oldAccounts, boolean isInsert, boolean isUpdate, boolean isDeleted, Map<Id,Account> oldAccMap ) {
      List<String> accountIds = new List<String>();
      Map<String,List<Account>> parentChaildMap = new Map<String,List<Account>>();
      List<String> parentHavingAccountsUpdate = new List<String>();
      Map<String,String> accountIdAndParentId = new Map<String,String>();
      Map<String,Account> accountIdAndParent = new Map<String,Account>();
      List<String> parentHavingAccounts = new List<String>();
      Map<String,List<Account>> parentIdWithChilds = new Map<String,List<Account>>();
      List<String> accountDeletedParentIds = new List<String>();
      List<String> oldParentIds = new List<String>();
      Map<String,List<Account>> oldParentChildMap = new Map<String,List<Account>>();
      List<Account> oldAccountList_To_Update = new List<Account>();
      List<String> newParentIds = new List<String>();
      if(isInsert) {
      for(Account account_new : accounts) {
            if(account_new.ParentId != null) {
                parentHavingAccounts.add(account_new.Id);
            }
       }
       if(!parentHavingAccounts .isEmpty()) {
            List<Account> parentAccounts = [select id,name,Is_Parent__C from account where id in :parentHavingAccounts ];
            if(parentAccounts  != null && !parentAccounts.isEmpty()) {
                for(Account acc : parentAccounts ) {
                    acc.is_Parent__c = 'Yes';
                }
            }
            
            update parentAccounts;
        }
      }
      if(isUpdate) {
          if(!isDeletedUpdation ) {
            
              for(Account ac : accounts) {
                  accountIds.add(ac.Id);
                  if(oldAccMap != null && oldAccMap.get(ac.Id) != null && oldAccMap.get(ac.Id).parentId != ac.parentId ) {
                    oldParentIds.add(oldAccMap.get(ac.Id).parentId);                    
                  }
                  if(ac.parentId != null) {
                      newParentIds.add(ac.parentId );
                  }
              }
              if(!oldParentIds.isEmpty()) {
                  parentIdChanged = true;
                  List<Account> childAccounts = [select id,name,is_parent__c,parent.id from account where parent.id in :oldParentIds ];
                  List<Account> oldAccountsList = [select id,name,is_parent__c,parent.id from account where id in :oldParentIds ];
                  if(childAccounts != null && !childAccounts.isEmpty()) {
                      for(Account parentChildAccount : childAccounts ) {
                          if(oldParentChildMap.containsKey(parentChildAccount.parent.id)) {
                              oldParentChildMap.get(parentChildAccount.parent.id).add(parentChildAccount);
                          }else {
                              List<Account> childAccountsList = new List<Account>();
                              childAccountsList .add(parentChildAccount );
                              oldParentChildMap.put(parentChildAccount.parent.id,childAccountsList );
                          }
                           
                      }
                  }
                  if(!oldAccountsList.isEmpty()) {
                    for(Account acct : oldAccountsList) {
                        if(oldParentChildMap.get(acct.Id) == null || (oldParentChildMap.get(acct.Id) != null && oldParentChildMap.get(acct.Id).size()<=1 )) {
                            acct.is_Parent__C = 'No';
                        }
                        oldAccountList_To_Update.add(acct);
                    }
                  }
                  if(!newParentIds.isEmpty()) {
                      List<Account> newParentId_Accounts = [select id,name,is_parent__c,parent.id from account where id in: newParentIds ];
                      for(Account accccc : newParentId_Accounts ) {
                          accccc.is_Parent__c = 'Yes';
                      }
                      if(newParentId_Accounts != null && !newParentId_Accounts.isEmpty()) {
                          update newParentId_Accounts;
                      }
                  }
                  
                  if(!oldAccountList_To_Update.isEmpty()) {
                    update oldAccountList_To_Update;
                  }
              } else if(!parentIdChanged ){
                  for(Account ac : accounts) {          
                    if(ac.ParentId != null) {
                        parentHavingAccountsUpdate.add(ac.ParentId);
                        accountIdAndParentId.put(ac.ParentId,ac.Id);
                    }
                  }
                  if(accountIds != null && !accountIds.isEmpty()) {
                      List<Account> childAccounts = [select id,name,is_parent__c,parent.id from account where parent.id in :accountIds ];
                      if(childAccounts != null && !childAccounts.isEmpty()) {
                          for(Account parentChildAccount : childAccounts ) {
                              if(parentChaildMap.containsKey(parentChildAccount.parent.id)) {
                                  parentChaildMap.get(parentChildAccount.parent.id).add(parentChildAccount);
                              }else {
                                  List<Account> childAccountsList = new List<Account>();
                                  childAccountsList .add(parentChildAccount );
                                  parentChaildMap.put(parentChildAccount.parent.id,childAccountsList );
                              }
                               
                          }
                      }
                  }
                  if(parentHavingAccountsUpdate != null && !parentHavingAccountsUpdate.isEmpty()) {
                    List<Account> parentAccounts = [select id,name,is_parent__c from account where id in :parentHavingAccountsUpdate ];
                    if(parentAccounts != null && !parentAccounts.isEmpty()) {
                        for(Account parentAccount : parentAccounts) {
                            parentAccount.is_Parent__c = 'Yes';
                            if(accountIdAndParentId.get(parentAccount.Id) != null) {
                                accountIdAndParent.put(accountIdAndParentId.get(parentAccount.Id),parentAccount);
                            }               
                        }
                        update parentAccounts;
                    }
                  }

                  for(Account acc : accounts) {
                    if(parentChaildMap.get(acc.Id) != null && parentChaildMap.get(acc.Id).size()>0) {
                        acc.is_Parent__c = 'Yes';
                    }else if(acc.parentId != null) {
                        if(accountIdAndParent.get(acc.Id) != null) {
                            acc.parentId = accountIdAndParent.get(acc.Id).Id;
                        }
                        acc.is_Parent__c = 'No';
                    }
                  }
                }
          }
     }
     
     if(isDeleted ) {
       for(Account accountDelete: oldAccounts) {
           if(accountDelete.parentId != null) {
                accountDeletedParentIds.add(accountDelete.parentId);
            }
       }

       Map<String,Account> parentAccounts = new Map<String,Account>([select id,name, is_parent__c,parent.Id from account where id in : accountDeletedParentIds]);
       if(!accountDeletedParentIds.isEmpty()) {
           List<Account> accountsWhichhavingParentIds = [select id, name, is_Parent__C,parent.Id from account where parent.id in : accountDeletedParentIds];
           if(accountsWhichhavingParentIds  != null && !accountsWhichhavingParentIds.isEmpty()) {
               for(Account accountss: accountsWhichhavingParentIds ) {
                   if(parentIdWithChilds.containsKey(accountss.parent.id)) {
                       parentIdWithChilds.get(accountss.parent.id).add(accountss);
                   }else {
                       List<Account> childs = new List<Account>();
                       childs.add(accountss);
                       parentIdWithChilds.put(accountss.parent.id,childs  );
                   }
               }
           }
       }

       List<Account> changedParentAccounts = new List<Account>();
       for(Account accountDelete_A: oldAccounts) {
           //if(accountDelete_A.is_Parent__c != 'Yes') {
               if(accountDelete_A.parentId != null) {
                   if(parentIdWithChilds.get(accountDelete_A.parentId )!= null && parentIdWithChilds.get(accountDelete_A.parentId ).size() <=1 ) {
                       if(parentAccounts.get(accountDelete_A.parentId ) != null ) {
                          Account account_parent = parentAccounts.get(accountDelete_A.parentId );
                          account_parent.Is_Parent__c = 'No';
                          changedParentAccounts.add(account_parent);
                       }
                   }
               }
           //}
       }
       if(!changedParentAccounts.isEmpty()) {
           isDeletedUpdation = true;
           update changedParentAccounts;
       }
     }
     
  }
 }