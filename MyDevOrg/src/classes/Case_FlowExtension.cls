public class Case_FlowExtension {

    //public Flow.Interview.Case_CaseCreatorFlow caseFlow {get; set;}
    public transient Attachment attachment;
    public boolean hasAttachment {get; set;}
    
    // This is for unit testing purposes
    public Case_FlowExtension() {}
    
    // This is because we need a standard controller to override the standard "New" case button
    public Case_FlowExtension(ApexPages.StandardController controller) {}

    public PageReference getCaseUrl() {
        PageReference page;
        //if (caseFlow != null) {
            //page = new PageReference('/' + caseFlow.Variable_Case_ID);
            //page.setRedirect(true);
        //}
        return page;
    } 
    
    public PageReference getFinishUrl() {
        PageReference page;
        //if (caseFlow != null) {
            // Go to the retURL if it exists
            //if (caseFlow.Variable_Return_URL != null) {
                //page = new PageReference('/' + caseFlow.Variable_Return_URL);
            // Otherwise, go to the Cases home page
            //} else {
                page = new PageReference('/apex/Case_Home');
            //}
            page.setRedirect(true);
        //}
        return page;
    }
    
    public Attachment getAttachment() {
        if (attachment == null) {
            attachment = new Attachment();
        } 
        return attachment;
    }
    
    public void setAttachment(Attachment a) {
        this.attachment = a;
    }

    public boolean getAllowAttachments() {
        boolean allowAttachments = false;
        //if (caseFlow != null) {
          //  allowAttachments = caseFlow.Variable_Allow_Attachments;
        //}
        return allowAttachments;
    } 
    
    /*
    public PageReference upload() {
        try {
            String caseId = String.ValueOf(caseFlow.getVariableValue('Variable_Case_ID'));
            attachment.ParentId = caseId;
            insert attachment;
            
            // Increment attachments count 
            Case c = [SELECT Id, Num_Flow_Attachments__c FROM Case WHERE Id = :caseId];
            if (c.Num_Flow_Attachments__c == null) {
                c.Num_Flow_Attachments__c = 1;
            } else {
                c.Num_Flow_Attachments__c = c.Num_Flow_Attachments__c + 1;
            }
            update c;
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Attachment uploaded successfully'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return null;
    }    
    */
    
    public PageReference upload() {
        try {
            Account a = [SELECT Id FROM Account ORDER BY CreatedDate ASC LIMIT 1];
            attachment.ParentId = a.Id;
            insert attachment;
            hasAttachment = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Attachment uploaded successfully'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return null;
    }    
    
    public void reattach() {
        try {
            Account acc = [SELECT Id FROM Account ORDER BY CreatedDate ASC LIMIT 1];
            List<Attachment> atts = [SELECT Id, Body, Name, ParentId FROM Attachment 
                                      WHERE ParentId     = :acc.Id 
                                        AND CreatedById  = :UserInfo.getUserId() 
                                        AND CreatedDate >= :DateTime.now().addMinutes(-5)];
            
            List<Attachment> newAtts = new List<Attachment>();
            for (Attachment att : atts) {
                Attachment clone = new Attachment();
                clone.Name       = att.Name;
                clone.Body       = att.Body;
                //clone.ParentId   = String.ValueOf(caseFlow.getVariableValue('Variable_Case_ID'));
                newAtts.add(clone);
            }
            insert newAtts;
            delete atts;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    
    // Easter egg
    public Integer getCaseNumber() {
        Integer caseNumber;
        try {
            //String caseId = caseFlow.Variable_Case_ID;
            //if (caseId != null) {
               // Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];
               //caseNumber = Integer.valueOf(c.CaseNumber);   
            //}
        } catch (Exception e) { }
        return caseNumber;
    }    

}