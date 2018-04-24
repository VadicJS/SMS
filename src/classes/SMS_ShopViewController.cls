/**
 * Created by BRITENET on 13.04.2018.
 */

public with sharing class SMS_ShopViewController {

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

    public SMS_Supply__c smsSupply {
        get {
            if (smsSupply == null) {
                smsSupply = new SMS_Supply__c();
            }
            return this.smsSupply;
        }
        set;
    }

    public SMS_Wholesale__c smsWholesale {
        get {
            if (smsWholesale == null) {
                smsWholesale = new SMS_Wholesale__c();
            }
            return this.smsWholesale;
        }
        set;
    }

    public Boolean notFound { get; set; } {
        notFound = false;
    }
    public Boolean showPageMessages { get; set; }
    public String wholesaleId { get; set; }
    public Boolean showResult { get; set; }
    public Boolean showAddContract { get; set; }
    public Integer noOfRecords { get; set; }
    public ApexPages.StandardSetController setCon { get; set; }
    public Boolean showTable { get; set; }
    public Boolean displayPopup { get; set; }
    public boolean success { get; set; }
    public String subject { get; set; }
    public String body { get; set; }
    public List<SelectOption> paginationSizeOptions { get; set; }
    public List<SelectOption> paginationOrderOptions { get; set; }
    public String orderBy { get; set; }
    public Integer size { get; set; }
    public Attachment att{ get; set; }
    private Id parentId { get; set; }
    public String attachmentId{ get; set; }
    public Boolean showDefaultFoto{ get; set; }
    public transient String imageBody{ get; set; }


    public SMS_ShopViewController(ApexPages.StandardController controller) {
        this.controller = controller;
        this.smsShop = (SMS_Shop__c) controller.getRecord();
        this.success = false;
        this.showTable = false;
        size = 2;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('2', '2'));
        paginationSizeOptions.add(new SelectOption('10', '10'));
        paginationSizeOptions.add(new SelectOption('20', '20'));
        paginationSizeOptions.add(new SelectOption('30', '30'));
        orderBy = '';
        paginationOrderOptions = new List<SelectOption>();
        paginationOrderOptions.add(new SelectOption(' ORDER BY Name ASC', 'Name ASC'));
        paginationOrderOptions.add(new SelectOption(' ORDER BY Name DESC', 'Name DESC'));
        att = new Attachment();
        parentId = controller.getId();
        attId();
    }

    public void attId(){
        List<Attachment> attachedFiles = [ SELECT Id from Attachment where ParentId=:this.parentId ORDER BY LastModifiedDate DESC Limit 1];
        if (attachedFiles.isEmpty()) {
            showDefaultFoto = true;
        }else {
            showDefaultFoto = false;
            attachmentId = attachedFiles[0].Id;
        }
    }



    public void showAll() {
        try {
            if (smsWholesale != null) {
                String query = SMS_ShopViewUtils.prepareQueryWholesale(this.smsWholesale) + orderBy;
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                System.debug(query);
                if (setCon.getResultSize() > 0) {
                    notFound = false;
                    showResult = true;
                    System.debug(setCon.getRecords());
                } else {
                    notFound = true;
                    showResult = false;
                }
            }
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'errorStr:' + ex.getMessage()));
        }
    }

    public List<SMS_Wholesale__c> getWholesales() {
        if (setCon.getResultSize() > 0) {
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
            List<SMS_Wholesale__c> wholesales = new List<SMS_Wholesale__c>();
            wholesales = setCon.getRecords();
            return wholesales;
        } else {
            return null;
        }
    }

    public void sendMessage() {
        if (String.isBlank(subject) || String.isBlank(body)) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Subject and Body are required');
            ApexPages.addMessage(msg);
            this.showPageMessages = false;
            success = false;
        } else {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email sent successfully');
            ApexPages.addMessage(msg);
            sendMail(smsShop.Email__c, subject, body);
            this.showPageMessages = true;
            this.subject = null;
            this.body = null;
            this.success = true;
        }
    }

    public static void sendMail(String address, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                address
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }


    public void clear() {
        this.body = null;
        this.subject = null;
    }

    public void clearWholesaleForm() {
        this.smsWholesale = new SMS_Wholesale__c();
        this.showResult = false;
        this.smsSupply.Contract_Start_Date__c = null;
        this.smsSupply.Contract_End_Date__c = null;
        this.showAddContract = false;
        wholesaleId = null;
        this.notFound = false;
    }

    public void showPopup() {
        displayPopup = true;
    }

    public void closePopup() {
        displayPopup = false;
    }

    public void getId() {
        wholesaleId = apexpages.currentpage().getparameters().get('selectedWholesaleId');
        System.debug('Id => ' + wholesaleId);
        this.smsWholesale = [SELECT Name, Country__c, City__c FROM SMS_Wholesale__c WHERE Id = :wholesaleId];
        System.debug(smsWholesale);
        showAddContract = true;
    }

    public void insertSupplyIntoDB() {
        if(smsSupply.Contract_Start_Date__c == null || smsSupply.Contract_End_Date__c == null){
            this.showPageMessages = false;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have to fill both date fields');
            ApexPages.addMessage(msg);

        }else {
            if (SMS_ShopViewUtils.validateDates(smsShop.Id, wholesaleId, this.smsSupply.Contract_Start_Date__c, this.smsSupply.Contract_End_Date__c)) {
                this.showPageMessages = true;
                SMS_Supply__c supplyToInsert = new SMS_Supply__c();
                supplyToInsert.Wholesale__c = wholesaleId;
                supplyToInsert.Shop__c = smsShop.Id;
                supplyToInsert.Contract_Start_Date__c = this.smsSupply.Contract_Start_Date__c;
                supplyToInsert.Contract_End_Date__c = this.smsSupply.Contract_End_Date__c;
                success = true;
                insert supplyToInsert;
                this.clearWholesaleForm();
            } else {
                this.showPageMessages = false;
                success = false;
            }
        }
    }

    public static Boolean getIsLicenseNoEnabled() {
        return SMS_Util.isFunctionalityEnabled(
                'ShopLicenseEnabled'
        );
    }

}