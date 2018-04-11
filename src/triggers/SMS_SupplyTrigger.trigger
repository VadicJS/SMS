/**
 * Created by BRITENET on 09.04.2018.
 */

trigger SMS_SupplyTrigger on SMS_Supply__c (before insert) {


    if (Trigger.isInsert && Trigger.isBefore) {
        List<SMS_Supply__c> existingSupplies = [SELECT Wholesale__c, Shop__c FROM SMS_Supply__c];

        for (SMS_Supply__c supplies : Trigger.new) {
            for (SMS_Supply__c sups : existingSupplies) {
                if (sups.Wholesale__c == supplies.Wholesale__c && sups.Shop__c == supplies.Shop__c) {
                    supplies.addError('This relation between shop and wholesale already exists.');
                }
            }
        }
    }
}

