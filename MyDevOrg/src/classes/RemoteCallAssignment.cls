global class RemoteCallAssignment
{
    public static Account account {get;set;}
    public static case casee{get;set;}
    public RemoteCallAssignment(){}
    
    @RemoteAction
    global static Case getCase(string caseNum)
    {
         casee = [SELECT Id, CaseNumber, subject
                   FROM case WHERE caseNumber = :caseNum];
        return casee;
    
   /* account = [SELECT Id, Name, Phone, Type
                   FROM Account WHERE Name = :caseNum];
        return account;*/
    }


}