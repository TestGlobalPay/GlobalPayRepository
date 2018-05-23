public class RestCallouts {
    public static Http objhttp;
    public static HttpRequest req ;
    public static HttpResponse res ;
    
    public static void MakeRestCallout()
    {
           objhttp = new Http();
           req = new HttpRequest();
           res = new HttpResponse();
           //req.setMethod('POST'); 
           req.setMethod('GET');
           req.setEndpoint('/services/data/v34.0/sobjects');
           Blob headerValue = Blob.valueOf('rnallam@heidrick.com.kmcwf'+ ':' + 'heidrick123');
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
          // Set the necessary Headers
           req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Accept','application/vnd.cpc.authreturn+xml');
            req.setHeader('Content-type','application/vnd.cpc.authreturn+xml; charset=UTF-8');
            req.setHeader('Accept-Language', 'en-CA');
            req.setTimeout(120000);
  
   //Set request format
   String reqBody = '<XML> </XML>';
            req.setBody(reqBody);
  
   
            try {
                res = objhttp.send(req);
            }
            catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
               
            }
   if(res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200)
            {
               // Logic to parse the response
              }
  
}
}