/* Apex class that exposes forgot password functionality and redirects to Email sent confirmation page if username is entered*/
public with sharing class CCForgotPasswordController {

   public string username{get;set;}
 
     /*This method is to redirect to forgot password page*/
     public PageReference forgotPassword() {          
       if(username!='') {
            Boolean isSuccess=Site.forgotPassword(username);
            PageReference pr = new PageReference('/CCForgotPasswordconfirm');
            pr.setRedirect(true);
            if(isSuccess){
             return pr;
            } else {
                PageReference pr_login=new Pagereference('/CCLogin');
                pr_login.setredirect(true);
                return pr_login;
            } 
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Enter User Name'));
            return null;
        }       
     }
 
     public PageReference goBack() {
          PageReference pr=new Pagereference('/CCLogin');
          pr.setredirect(true);
          return pr;
     }
     
}