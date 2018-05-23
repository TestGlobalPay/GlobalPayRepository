/*Apex page that exposes functionality of community login*/
global class CCLoginController {
   global String username{get;set;}
   global String password{get;set;}   
   
   /*This method is to show custom login Page*/
   global PageReference forwardToCustomAuthPage() {
         return new PageReference( '/CCLogin');
   }
   
   /*This is the method that validate user name and password */
   global PageReference login(){
      if(username==''&&password==''){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'Please enter Username/Password'));
           return null;
       }else
        return Site.Login(username, password, null);
     } 
    
    /*This is the method to show custom forgot password page*/  
    global PageReference forwardToForgotPassword(){      
       return new PageReference('/CCForgotPassword');
    }
}