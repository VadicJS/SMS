public with sharing class SMS_ShopsRandomPublicController {

    public SMS_ShopsRandomPublicController() {
    }

    public List<SMS_Shop__c> getShops(){
        List<SMS_Shop__c> smsShops;
        Integer listSize = [SELECT COUNT() FROM SMS_Shop__c];
        Integer offset = Math.floor(Math.random()*(listSize-5)).intValue();
        smsShops = [SELECT Id, Previous_Name__c, City__c, Country__c FROM SMS_Shop__c LIMIT 5 OFFSET :offset];
        return smsShops;
    }
}