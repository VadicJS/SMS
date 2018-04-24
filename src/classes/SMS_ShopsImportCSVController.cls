public with sharing class SMS_ShopsImportCSVController {
    public transient Blob csvBlob { get; set; }
    public transient String csvString { get; set; }
    public String[] csvFileLines { get; set; }
    public List<SMS_ShopImportCSVWrapper> shopList { get; set; }
    public Boolean readyToImport { get; set; }
    public Boolean enableImportButton { get; set; }

    public SMS_ShopsImportCSVController() {
        csvFileLines = new String[]{};
        shopList = new List<SMS_ShopImportCSVWrapper>();
        readyToImport = false;
        this.enableImportButton = false;
    }

    public void process() {
        this.shopList = new List<SMS_ShopImportCSVWrapper>();
        try {
            csvString = csvBlob.toString();
            csvFileLines = csvString.split('\n');
            System.debug(csvFileLines);
            for (Integer i = 1; i < csvFileLines.size(); i++) {
                SMS_ShopImportCSVWrapper smsShopWrapped = new SMS_ShopImportCSVWrapper() ;
                String[] csvRecordData = csvFileLines[i].split(',');
                smsShopWrapped.smsShop.Previous_Name__c = csvRecordData[0];
                smsShopWrapped.smsShop.Previous_Name__c = smsShopWrapped.smsShop.Previous_Name__c.replace('\"', '');
                smsShopWrapped.smsShop.Email__c = csvRecordData[1];
                smsShopWrapped.smsShop.Email__c = smsShopWrapped.smsShop.Email__c.replace('\"', '');
                smsShopWrapped.smsShop.City__c = csvRecordData[2];
                smsShopWrapped.smsShop.City__c = smsShopWrapped.smsShop.City__c.replace('\"', '');
                smsShopWrapped.smsShop.Country__c = csvRecordData[3];
                smsShopWrapped.smsShop.Country__c = smsShopWrapped.smsShop.Country__c.replace('\"', '');
                shopList.add(smsShopWrapped);
                if (shopList.size() > 0) {
                    readyToImport = true;
                }
            }
        } catch (Exception exc) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, exc.getMessage());
            ApexPages.addMessage(errorMessage);
        }
    }

    public void importShops() {
        List<SMS_Shop__c> shopsToImport = new List<SMS_Shop__c>();
        List<SMS_ShopImportCSVWrapper> shopsWrapperToImport = new List<SMS_ShopImportCSVWrapper>();
        for (Integer i = 0; i < shopList.size(); i++) {
            if (shopList[i].toImport == true && shopList[i].successfullyImported != true) {
                if (String.isEmpty(shopList[i].smsShop.Email__c)) {
                    shopList[i].importStatus = System.Label.Email_Required;
                } else {
                    shopsToImport.add(shopList[i].smsShop);
                    shopList[i].indexInList = i;
                    shopsWrapperToImport.add(new SMS_ShopImportCSVWrapper(shopList[i].smsShop, i));
                }
            }
        }


        for (Integer i = 0; i < shopsToImport.size(); i++) {
            try {
                Database.SaveResult result = Database.insert(shopsToImport[i]);
                SMS_Shop__c row = shopsWrapperToImport[i].smsShop;
                shopsWrapperToImport[i].importStatus = System.Label.Imported;
                shopList[i].smsShop.Id = row.Id;
                shopsWrapperToImport[i].successfullyImported = true;
            } catch (DmlException exc) {
                if (exc.getMessage().contains('DUPLICATES_DETECTED')) {
                    String errLabel = System.Label.Duplicated_Record;
                    shopsWrapperToImport[i].importStatus = errLabel;
                    shopsWrapperToImport[i].showLinkToView = true;
                } else {
                    shopsWrapperToImport[i].importStatus = exc.getMessage();
                }

            }
        }
        for (Integer i = 0; i < shopList.size(); i++) {
            for (SMS_ShopImportCSVWrapper wrapper : shopsWrapperToImport) {
                if (shopList[i].indexInList == wrapper.indexInList) {
                    shopList[i].importStatus = wrapper.importStatus;
                    shopList[i].successfullyImported = wrapper.successfullyImported;
                    shopList[i].showLinkToView = wrapper.showLinkToView;
                }
            }
        }
    }

    public void enableImport() {
        this.enableImportButton = true;
    }

    public void selectAll() {
        for (SMS_ShopImportCSVWrapper shopWrapper : shopList) {
            enableImportButton = true;
            shopWrapper.toImport = true;
        }
    }

    public void selectNone() {
        for (SMS_ShopImportCSVWrapper shopWrapper : shopList) {
            shopWrapper.toImport = false;
            enableImportButton = false;
        }
    }

    public void reverseSelect() {
        for (SMS_ShopImportCSVWrapper shopWrapper : shopList) {
            shopWrapper.toImport = (shopWrapper.toImport == true) ? false : true;
        }
    }
}