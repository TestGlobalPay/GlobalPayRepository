public class CCcaseExtensionController {

 public List<User> loggedInUser{get;set;}
 public List<Contact> loggedInContact{get;set;}
 private final Case caseNew{get;set;}
 public String pf_filtered{get;set;}
 public  List<selectoption> filtered_options{get;set;}
 public String familySelectedOptions {get;set;}
 
 public CCcaseExtensionController(ApexPages.StandardController controller) {
      
    filtered_options=new List<selectoption>();
      string menuPlanning;
      string possystem;
      string inventory;
      string production;
      string payModel;
    familySelectedOptions  = 'Lunchbox;WebSMARTT';
      this.caseNew=(Case)controller.getrecord();
      loggedInUser=[SELECT Name,ContactId FROM User where Id='00556000000IdYq'/*:UserInfo.getUserId()*/ ];
     
     if(loggedInUser.size()>0){
      loggedInContact=[SELECT Id,Account.Id,Account.HSS_POS_System__c,Account.Menu_Planning__c,Account.Inventory__c,Account.Production__c,Account.Pay_Model__c
                       FROM Contact where Id=:loggedInUser[0].ContactId];
                       
       if(loggedInContact.size()>0){
            
            if(loggedInContact[0].Account.HSS_POS_System__c==null){
              possystem='';
            }else{
              possystem=loggedInContact[0].Account.HSS_POS_System__c;
            }
            if(loggedInContact[0].Account.Menu_Planning__c==null){
              menuPlanning='';
            }else{
             menuPlanning=loggedInContact[0].Account.Menu_Planning__c;
            }
            
            if(loggedInContact[0].Account.Inventory__c==null){
               inventory='';
            }else{
               inventory=loggedInContact[0].Account.Inventory__c;
            }
           
            if(loggedInContact[0].Account.Pay_Model__c==null){
               payModel='';
            }else{
               payModel=loggedInContact[0].Account.Pay_Model__c;
            }
            
            if(loggedInContact[0].Account.Production__c==null){
               production='';
            }else{
              production=loggedInContact[0].Account.Production__c;
            }
           
          
            
       
            if(possystem.startsWith('Café ')){
              SelectOption option = new SelectOption('Café Enterprise', 'Café Enterprise');
              filtered_options.add(option);
             
            }
            if(possystem.startsWithIgnoreCase('Lunchbox')|| inventory.startsWith('CLT') || inventory.startsWith('LunchBox')){
              SelectOption option = new SelectOption('Lunchbox', 'Lunchbox');
              filtered_options.add(option);
              
            }
            if(possystem.startsWith('W')||production=='Websmartt' || menuPlanning=='WebSMARTT' || (inventory.startsWith('W') && (!inventory.contains('Lost')))){
              SelectOption option = new SelectOption('WebSMARTT', 'WebSMARTT');
              filtered_options.add(option);
              
            }
            if(possystem.startsWith('NK ')|| production.startsWith('Nk ') || (Inventory.startsWith('Nutrikids') && (!Inventory.contains('Lost')))  || (menuPlanning.startsWith('Nutrikids') && (!menuPlanning.contains('Lost'))) ){
                SelectOption option = new SelectOption('Nutrikids', 'Nutrikids');
              filtered_options.add(option);
           
            }
            if(possystem.startsWith('MCS -')|| production=='MCS' || Inventory.startsWith('MCS -')  || menuPlanning.startsWith('MCS -') ){
              SelectOption option = new SelectOption('MCS', 'MCS');
              filtered_options.add(option);
         
            }
            
             if(possystem.startsWith('Mosaic')|| Inventory=='Mosaic'  || menuPlanning=='Mosaic' ){
                SelectOption option = new SelectOption('Mosaic', 'Mosaic');
              filtered_options.add(option);
         
            }
            if(payModel=='MLM-Meals' || payModel=='MSB-Meals'){
                SelectOption option = new SelectOption('Online Payments', 'Online Payments');
              filtered_options.add(option);
              
            }
            else{
               SelectOption option = new SelectOption('', 'None');
              filtered_options.add(option);
             
            }
             SelectOption option = new SelectOption('For Finance', 'For Finance');
              filtered_options.add(option);
               SelectOption option2 = new SelectOption('Billing', 'Billing');
              filtered_options.add(option2);
          
            
         
         
            
       
       }
     }

    }
    
    
    public pageReference save(){
     
       try{
       caseNew.ContactId=loggedInContact[0].Id;
       caseNew.AccountId=loggedInContact[0].Account.Id;
          insert caseNew;
          pageReference p=new Pagereference('/apex/CCLandingPage');
          return p;
       }
       catch(System.DMLException e){
          return null;
       }
       
       return null;
    } 

}