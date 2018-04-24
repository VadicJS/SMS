/**
 * Created by BRITENET on 17.04.2018.
 */

public with sharing class SMS_ShopImportCSVWrapper {
    public SMS_Shop__c smsShop { get; set; }
    public String importStatus { get; set; }
    public Boolean toImport { get; set; }
    public Boolean successfullyImported { get; set; }
    public Integer indexInList { get; set; }
    public Boolean showLinkToView { get; set; }

    public SMS_ShopImportCSVWrapper() {
        smsShop = new SMS_Shop__c();
        importStatus = '';
        toImport = false;
        successfullyImported = false;
        indexInList = -1;
        showLinkToView = false;
    }

    public SMS_ShopImportCSVWrapper(SMS_Shop__c smsShop, Integer index) {
        this.smsShop = smsShop;
        this.indexInList = index;
    }
}