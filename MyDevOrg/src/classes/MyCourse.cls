public class MyCourse {
    public void printCourseTypes() {
        sObject[] courseType = [select Name from Course__c];
        for(sObject s : courseType) {
            System.debug(s);
        }
    }
    
}