@RestResource(urlMapping = '/AccountInfo/*')
global class AccountClass {

@HttpGet
global static List<Account> getAccountInfo() {
    /*RestRequest req = RestContext.request;       
        String iddd = req.requestURI.substring(
                                  req.requestURI.lastIndexOf('/')+1);*/
    List<Account> accountsList =[select id,name from account];
    return accountsList;
}


}