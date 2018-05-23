/*Apex Class that shows the content of home page of customer connect and will re-direct the unauthorized users back to login page*/
public class CCLandingController {

 public List<Case> recentCases{get;set;}
 public List<Contact> accountInfo{get;set;}
 public List<Contact> relatedContacts{get;set;}
 public List<User> myProfile{get;set;}
 public List<Account> accountRelatedLists{get;set;}
 public List<String> productsAndServices{get;set;}

 public CCLandingController(){
    
 
     productsAndServices=new List<String>();

    //Query Contact Info from logged in user.
    
    myProfile=[SELECT Name,ContactId FROM User where Id='00590000004TtoG'];
    
    if(myProfile.size()>0){
    
    //Query Account information from user contact id.
    accountInfo=[SELECT Account.Id,Account.Name,Account.AccountNumber,Account.BillingCity, Account.BillingStreet, Account.BillingState, 
                        Account.BillingPostalcode, Account.BillingCountry,Account.ShippingCity, Account.ShippingStreet, Account.ShippingState, 
                        Account.ShippingPostalcode, Account.ShippingCountry,Account.HSS_POS_System__c,
                        Account.Menu_Planning__c,Account.Pay_Model__c,Name,Id FROM Contact where Id=:myProfile[0].ContactId];
                     
     if(accountInfo.size()>0){    
     
       //Query Contacts and Cases associated to retrieved account.
      accountRelatedLists=[SELECT Name,(Select Id,Name,Phone,Email From Contacts LIMIT 3),(Select Id,CaseNumber,Status,CreatedDate,contact.Name,Owner.Name FROM Cases Limit 3) 
                                  FROM Account where Account.Id=:accountInfo[0].Account.Id];  
      if(accountInfo[0].Account.HSS_POS_System__c!=null){
       String s=accountInfo[0].Account.HSS_POS_System__c;
       if(s.containsIgnoreCase('Lunchbox')) {
        productsAndServices.add('Lunchbox');
       }
       if(s.contains('WebSMARTT')|| s.contains('WinSNAP')){
        productsAndServices.add('WebSMARTT');
       }   
       if(s.startsWithIgnoreCase('NK ')){
        productsAndServices.add('Nutrikids');
       }
       if(s.contains('Mosaic')){
        productsAndServices.add('Mosaic');
       }
       if(s.contains('Café ')){
        productsAndServices.add('Café Enterprise');
       }
       if(s.startsWith('MCS -')){
        productsAndServices.add('MCS');
       }   
   
     }
     /*Changes by Balaram*/
     Map<String,Product_Services__c> productServicesCustom = Product_Services__c.getAll();
     for(String poductService : productServicesCustom.keySet() ) {
        Product_Services__c customProductService = productServicesCustom.get(poductService);
        if(customProductService.District_Field__c.contains(accountInfo[0].Account.Menu_Planning__c)) {
        
        }
     }

     /*Pre Pay Model Products/Services Filter*/

     if(accountInfo[0].Account.Pay_Model__c!=null){
      String s=accountInfo[0].Account.Pay_Model__c;
      if(s=='MSB-Meals'){
        productsAndServices.add('My School Bucks');
      }
     }

     /*Menu Planning Products/services Filter*/

     if(accountInfo[0].Account.Menu_Planning__c!=null){
      String s=accountInfo[0].Account.Menu_Planning__c;
      if(s.startsWith('MCS -')){
        productsAndServices.add('MCS Menu Planning');
      }
      if(s=='Mosaic'){
        productsAndServices.add('Mosaic menu Planning');
      }
      if(s.contains('WebSMARTT')|| s.contains('WinSNAP')){
        productsAndServices.add('WebSMARTT Menu Planning');
      }
      if(s.startsWith('Nutrikids') && !s.contains('Lost')){
        productsAndServices.add('Nutrikids menu Planning');
      }
     }

     /*Pre pay Store Program Products/Services Filter*/

     /*if(accountInfo[0].Account.Student_Store_Model__c!=null){
      String s=accountInfo[0].Account.Student_Store_Model__c;
      if(s=='MSB-Store'){
        productsAndServices.add('My School Bucks Store');
      }
     }*/

     /*Online App Products/Services Filter*/

     /*if(accountInfo[0].Account.On_Line_Application_Scanning__c!=null){
      String s=accountInfo[0].Account.On_Line_Application_Scanning__c;
      if(s.contains('Heartland')){
        productsAndServices.add('Heartland Online Apps');
      }
      if(s.contains('MCS')){
        productsAndServices.add('MCS Online App');
      }
     }*/
    }
  }
   
 }
  public PageReference forwardToCustomAuthPage() {
  system.debug('guest 222222222login');
        if(UserInfo.getUserType()=='Guest'){
        system.debug('guest login');
            return new PageReference('/CCLogin');
            
        }
        else{
            return null;
        }
    }
    
  public PageReference logout(){
  
     PageReference logoutPage = new PageReference(Site.getBaseSecureUrl()+'/secur/logout.jsp');
            logoutPage.setRedirect(true);
            return logoutPage;
  }
  
  public PageReference goToCaseDetail(){
  
    PageReference CaseDetail=new Pagereference('/apex/CCcaseDetail');
    CaseDetail.setRedirect(true);
    return CaseDetail;
  
  }
  
    public PageReference goToNewCase(){
  
    PageReference CaseDetail=new Pagereference('/apex/CCcaseCreation');
    CaseDetail.setRedirect(true);
    return CaseDetail;
  
  }


}