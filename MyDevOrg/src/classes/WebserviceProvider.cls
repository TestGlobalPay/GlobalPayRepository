global class WebserviceProvider {

    webservice static List<Account> getAccountsAndInfo() {
        List<Account> accountList = [Select id,name from account];
        return accountList;
    }
}