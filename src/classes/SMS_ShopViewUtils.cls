public with sharing class SMS_ShopViewUtils {

    public static String prepareQueryWholesale(SMS_Wholesale__c smsWholesale) {
        String preparedQuery = 'SELECT Id, Name, City__c, Country__c FROM SMS_Wholesale__c WHERE Country__c LIKE \'%' + smsWholesale.Country__c + '%\'';
        if (String.isNotBlank(smsWholesale.Name)) {
            preparedQuery += ' AND Name LIKE \'%' + smsWholesale.Name + '%\'';
        }
        if (String.isNotBlank(smsWholesale.City__c)) {
            preparedQuery += ' AND City__c LIKE \'%' + smsWholesale.City__c + '%\' ';
        }
        return preparedQuery;
    }

    public static Boolean validateDates(Id shopId, Id wholesaleId, Date csd, Date ced) {
        if(csd>=ced){
            ApexPages.Message err = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Start_before_End_Error);
            ApexPages.addMessage(err);
            return false;
        }
        List<SMS_Supply__c> smsSupplies = [SELECT Contract_Start_Date__c, Contract_End_Date__c, Wholesale__r.Name FROM SMS_Supply__c WHERE
        Shop__c = :shopId AND Wholesale__c = :wholesaleId AND ((Contract_Start_Date__c<=:csd AND Contract_End_Date__c>=:csd) OR (Contract_End_Date__c>=:ced AND Contract_Start_Date__c<=:ced)
                                                            OR (Contract_Start_Date__c>=:csd AND Contract_End_Date__c<=:ced))];
        if(smsSupplies.isEmpty())
        {
            ApexPages.Message confirm = new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.Success_New_Supply);
            ApexPages.addMessage(confirm);
            return true;
        }else{
            ApexPages.Message err = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Date_Overlapping + ' ' +
                    smsSupplies[0].Wholesale__r.Name + ' Start: ' + smsSupplies[0].Contract_Start_Date__c.format() + ', End: ' + smsSupplies[0].Contract_End_Date__c.format());
            ApexPages.addMessage(err);
            return false;
        }
    }
}