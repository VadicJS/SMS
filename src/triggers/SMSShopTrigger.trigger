trigger SMSShopTrigger on SMS_Shop__c (after insert) {
    if (!SMS_Util.isTriggerEnabled('SMSShopTrigger')) {
        if (Trigger.isAfter && Trigger.isInsert) {
            for (SMS_Shop__c smsShop : Trigger.new) {
                SMS_Util.sendMail(smsShop.Email__c, 'Invitation Mail', 'Welcome in Our Network ' + smsShop.Previous_Name__c);
            }
        }
    }
}