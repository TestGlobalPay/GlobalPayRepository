global class SForceexample
{

    public SForceexample()
    {}


    webservice static string updateStatus(ID accountId)
    {
        Account acc = [Select Id,name,Active__c from Account where Id=:accountId];
        if(acc.Active__c=='Yes')
        {
            return 'Already updated records cannot be updated';
        }
        else 
        {
            acc.Active__c='Yes';
            update acc;
            return 'Record status updated';
        }
    }

}