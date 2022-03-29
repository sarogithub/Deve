public with sharing class data_table {
    @AuraEnabled(cacheable=true)
    Public static list<Account> loadCases(){
        list<Account> c = new list<Account>();
        c = [Select Id, Name from Account LIMIT 10];
        return c;
    }
}