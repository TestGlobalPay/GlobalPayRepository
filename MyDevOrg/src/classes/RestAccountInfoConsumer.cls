global class RestAccountInfoConsumer
{
    
    global static string method1()
    {
         Http htAuth = new Http();
         HttpRequest hReqAuth = new HttpRequest();
         HttpResponse hResAuth = new HttpResponse();
         
         string clientId = '3MVG9fMtCkV6eLheicg73ZCApG1kOoYofOEs9ROa4HOk81W0hVdGqlrTwxgh0Za36usOGxrw7XxSHYtugxJVT';
         string clientSecret = '5747580895244639937';
         string UserName = 'sumanth.a8@gmail.com';
         String password = 'anumukond@8891';
    String secToken = 'SxLNAJdwgpvXlG6dexZlTEjd';
    String requestBody = 'grant_type=password'+
                        '&client_id='+clientId+
                        '&client_secret='+clientSecret+
                        '&username='+userName+
                        '&password='+password+secToken;
               string accesstoken = null;         
          hReqAuth.setBody(requestBody);
    hReqAuth.setMethod('POST');
    hReqAuth.setEndPoint('https://na16.salesforce.com/services/oauth2/token');
    
    hResAuth = htAuth.send(hReqAuth); 
   //  OAuth2 oAuthInfo = (OAuth2)JSON.deserialize(hResAuth.getBody(),OAuth2.class);
  // string responsebody = hresAuth.getbody().tostring();
  
  Map<String,String> res = (Map<String,String>) JSON.deserialize(hResAuth.getBody(),Map<String,String>.class);

accesstoken = res.get('access_token');
  
  
  // json = new JSONObject(responseBody);
    //     accessToken = json.getString('access_token');

    //hresAuth.getbody().access_token;
     return accesstoken;               
    
    
    }


    public static void insertAccounts()
    {
        String jsonRequest = null;
        string oAuthInfo = method1();
        
        if(oAuthInfo != null)
        {
            Http httpdata = new Http();
            HttpRequest hReqData = new HttpRequest();
            HttpResponse hResData = new HttpResponse();
            hReqData.setHeader('Authorization','Bearer '+oAuthInfo);
            hReqData.setHeader('Content-Type','application/json');
            hReqData.setMethod('GET');
            hreqData.setEndpoint('https://na16.salesforce.com/services/apexrest/Accountinfo/001j000000gDWAa');
            hResData = httpData.send(hReqData);
            system.debug('hello123'+hresdata.getbody());
        }
    
    
    }
    
    public static void insertAccounts1()
    {
        string jsonrequest = null;
        string oAuthInfo = method1();
        
        if(oAuthInfo != null)
        {
        
            Account acc =[select id,name,phone from account where id=:'0019000000pVZH1'];
            
            jsonrequest = json.serialize(acc);
            Http Httpdata = new Http();
            HttpRequest hreqData = new HttpRequest();
            HttpResponse hresdata = new HttpResponse();
            hreqData.setHeader('Authorization','Bearer '+oAuthInfo);
            hreqData.setHeader('content-type','applicaton/json');
            hreqdata.setMethod('POST');
            hreqdata.setEndPoint('https://na16.salesforce.com/services/apexrest/Accountinfo/');
            hreqdata.setBody(jsonrequest);
            hresdata = Httpdata.send(hreqdata);
             system.debug('hello123'+hresdata.getbody());
            
        
        
        
        }
    
    }


}