global class ExposeAsWebservice {

 webservice static List<Account> fetchAccountInfo() {
     List<Account> accounts = [select id,name from account];
     return accounts;
 }
}