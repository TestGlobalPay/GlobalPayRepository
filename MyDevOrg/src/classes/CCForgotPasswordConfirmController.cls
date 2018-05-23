/**
This class is to confirm forgot password
**/
public class CCForgotPasswordConfirmController {

    /*This method is to return login page after successfull confirm password*/
    public PageReference goBack(){
      PageReference pr=new Pagereference('/CCLogin');
      pr.setredirect(true);
      
      return pr;
    }
    
}