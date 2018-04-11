public with sharing class SMS_ShopMessaging {

    ApexPages.StandardController controller;
    public SMS_Shop__c smsShop {
        get {
            if (smsShop == null) {
                smsShop = new SMS_Shop__c();
            }
            return this.smsShop;
        }
        set;
    }

    public String subject {get; set;}
    public String body {get; set;}

    public SMS_ShopMessaging(ApexPages.StandardController controller) {
        this.controller = controller;
        this.smsShop =( SMS_Shop__c)controller.getRecord();
    }

    public void sendMessage(){
        if (String.isBlank(subject) || String.isBlank(body)){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Subject and Body are required');
            ApexPages.addMessage(msg);
        }else {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Email sent seccessfully');
            ApexPages.addMessage(msg);
            sendMail(smsShop.Email__c, subject, body);
        }
    }

    public static void sendMail(String address, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {address};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public void clear() {
        this.body = null;
        this.subject = null;
    }
}