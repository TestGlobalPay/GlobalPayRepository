public class addFunction {

    
     public Student__c s;
 public Student__c del;
 public List<Student__c> addcourseList {get;set;}
 public List<Student__c> delcourseList {get;set;}
 public List<Student__c> courseList {get;set;}
 public Integer totalCount {get;set;}
 public Integer rowIndex {get;set;}
 
 public List<Student__c> delCourse {get; set;} 
 public addFunction(ApexPages.StandardController controller) {
   
 s = (Student__c)controller.getRecord();
 courseList = [Select Courses__c ,Professor__c,Final_Grade__c from Student__c  ];
 totalCount = courseList.size();
 
 delcourseList = new List<Student__c>();
 delCourse = new List<Student__c>();
 }
 
 public void addRow(){
 addcourseList = new List<Student__c>();
 courseList.add(new Student__c ());
 }
 
 public PageReference Save(){
 
 upsert courseList;
 delete delcourseList;
 return (new ApexPages.StandardController(s)).view();
 } 
 public void deleteRow(){
 
 rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
 System.debug('rowbe deleted ' + rowIndex );
 System.debug('rowm to be deleted '+courseList[rowIndex]);
 del = courseList.remove(rowIndex);
 delcourseList.add(del);
 }
 }