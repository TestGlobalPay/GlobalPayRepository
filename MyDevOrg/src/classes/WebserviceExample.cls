global class WebserviceExample{

    webservice static List<Case> method1() {
        List<Case> casesList = [select id from case];
        return casesList;
    }
}