public class MyRelationalClass {
    public void relationalObjectsMerchandise() {
        List<sObject> chaildObjects  = [select name,id from Marchandise__c];
    }
}