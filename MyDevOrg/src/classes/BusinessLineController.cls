public class BusinessLineController {

    //public List<SelectOption> buesinesLinesList{set;get;}
    public String recordTypeName{set;get;}
    public String issueTypeName{set;get;}
    public boolean showPrevious{set;get;}
    public Case caseObj{get;set;}
    public String filename {get;set;}
     public transient Blob fileBody {get;set;}
     
    public BusinessLineController() {
        caseObj = new Case();
    }
    
    public List<SelectOption> getBusinesLinesList() {
        List<SelectOption> buesinesLinesList = new List<SelectOption>();
        buesinesLinesList.add(new SelectOption('Tag','Tag Implementation'));
        buesinesLinesList.add(new SelectOption('Shopping','Shopping'));
        buesinesLinesList.add(new SelectOption('RLSA','RLSA Bulk Implementation'));
        buesinesLinesList.add(new SelectOption('Picasso','mSite Audits'));
        buesinesLinesList.add(new SelectOption('build','mSpeed Optimizaitons'));
        buesinesLinesList.add(new SelectOption('multiple','Multiple BUs'));
        
        return buesinesLinesList;
    }
    
    public PageReference save() {
     try {
        if(recordTypeName == 'Tag') {
            caseObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Tag').getRecordTypeId();
        }else if(recordTypeName == 'Shopping') {
            caseObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Shopping').getRecordTypeId();
        }
        caseObj.Issue_Type__c = issueTypeName;
        insert caseObj;
        if(this.fileName != null && this.fileBody != null) {
            Attachment attachment = new Attachment();
            attachment.body = this.fileBody;
            attachment.name = this.fileName;
            attachment.parentid = caseObj.Id;
            Database.SaveResult result = Database.insert(attachment);
        }
     }catch(Exception e) {
            fileBody = Blob.valueof('');
            return null;
     }
     PageReference preference = new PageReference('/apex/case_home');
     preference.setRedirect(true);
     return preference;
    }
    
    public Pagereference cancelPage() {
        PageReference preference = new PageReference('/apex/case_home');
        preference.setRedirect(true);
        return preference;
    }
    
    public pagereference previousPage() {
        PageReference pageRef = Page.Business_Line_Page;
        return pageRef;
    }
    
    
    public pagereference nextPage() {
        if(recordTypeName == null ) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select a business line'));
            return null;
        }
        PageReference pageRef = Page.Issue_Type_Page;
        //pageRef.setRedirect(true);
        showPrevious = true;
        return pageRef;
    }
    
    public pagereference caseDetailPage() {
        if(issueTypeName == null ) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select any issue type'));
            return null;
        }
        PageReference pageRef = Page.Case_Creation_Page;
        return pageRef;
    }
    
    public List<SelectOption> getIssueTypes() {
        List<SelectOption> buesinesLinesList = new List<SelectOption>();
        buesinesLinesList.add(new SelectOption('Bug','Bug'));
        buesinesLinesList.add(new SelectOption('Feature Request','Feature Request'));
        buesinesLinesList.add(new SelectOption('New User Activation/setup','New User Activation/setup'));
        buesinesLinesList.add(new SelectOption('New Project','New Project'));
        buesinesLinesList.add(new SelectOption('Question','Question'));
        buesinesLinesList.add(new SelectOption('Other','Other'));
        
        return buesinesLinesList;
    }
}