public with sharing class SMS_ShopEditController {

    public final SMS_Shop__c smsShop;
    public ApexPages.StandardController controller { get; set; }
    public Attachment att { get; set; }
    private Id parentId { get; set; }
    public String attachmentId { get; set; }
    public Boolean showDefaultFoto { get; set; }
    public transient String imageBody { get; set; }
    public Boolean showPopup { get; set; }

    public SMS_ShopEditController(ApexPages.StandardController controller) {
        this.controller = controller;
        parentId = controller.getId();
        attId();
        this.smsShop = (SMS_Shop__c) controller.getRecord();
    }

    public void uploadImage() {
        att = new Attachment();
        att.parentId = parentId;
        att.Name = 'image';
        att.ContentType = 'image/jpeg;base64';
        System.debug(imageBody);
        imageBody = imageBody.removeStart('data:image/jpeg;base64,');
        Blob body = EncodingUtil.base64Decode(imageBody);
        System.debug(body);
        att.body = body;
        insert att;

    }

    public void deleteImage() {
        List<Attachment> attachedFiles = [SELECT Id from Attachment where ParentId = :this.parentId ORDER BY LastModifiedDate];
        delete attachedFiles;
        showDefaultFoto = true;
        closePopup();
    }

    public void attId() {
        List<Attachment> attachedFiles = [SELECT Id from Attachment where ParentId = :this.parentId ORDER BY LastModifiedDate DESC Limit 1];
        if (attachedFiles.isEmpty()) {
            showDefaultFoto = true;
        } else {
            showDefaultFoto = false;
            attachmentId = attachedFiles[0].Id;
        }
    }

    public PageReference save() {
        try {
            upsert smsShop;
            if (!String.isEmpty(imageBody)) {
                att = new Attachment();
                att.parentId = controller.getId();
                att.Name = 'image';
                att.ContentType = 'image/jpeg;base64';
                imageBody = imageBody.removeStart('data:image/jpeg;base64,');
                Blob body = EncodingUtil.base64Decode(imageBody);
                att.body = body;
                insert att;
            }
        } catch (DMLException exc) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage());
            ApexPages.addMessage(msg);
        }
        return new ApexPages.StandardController(smsShop).view();
    }

    public void displayPopup() {
        showPopup = true;
    }

    public void closePopup() {
        showPopup = false;
    }
}