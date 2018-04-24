public with sharing class SMS_ShopSearchUtils {
    public static String prepareQuery(SMS_Shop__c smsShop) {
        String preparedQuery = 'SELECT Id, Previous_Name__C, Email__c, Country__C, City__c FROM SMS_Shop__c WHERE Country__c LIKE \'%' + smsShop.Country__c + '%\'';
        if (String.isNotBlank(smsShop.Previous_Name__c)) {
            preparedQuery += ' AND Previous_Name__c LIKE \'%' + smsShop.Previous_Name__c + '%\'';
        }
        if (String.isNotBlank(smsShop.City__c)) {
            preparedQuery += ' AND City__c LIKE \'%' + smsShop.City__c + '%\' ';
        }
        if (String.isNotBlank(smsShop.Email__c)) {
            preparedQuery += ' AND Email__c LIKE \'%' + smsShop.Email__c + '%\'';
        }
        return preparedQuery ;
    }

}