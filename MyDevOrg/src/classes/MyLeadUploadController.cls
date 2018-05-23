public class MyLeadUploadController {
    public Lead lead{get;set;}
    public String leadname{get;set;}
    public Blob fileContent {get;set;}
    public String fileName{get;set;}
    
    public void leadInformation() {
        lead = [select id, name,phone,LastName from Lead where lastName =:leadname Limit 1 ];
    }
    
    public void savePage() {
        System.debug('fileContent===>'+fileContent);
        System.debug('fileName===>'+fileName);
    }
}