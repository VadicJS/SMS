public with sharing class SMS_ShopSearchController {

    public Boolean searchSuccessful {
        get;
        set;
    }  {searchSuccessful = false;}

    public Boolean showNoResults {get; set;} {showNoResults = false;}

    public String csvString { get; set; }
    public List<SMS_Shop__c> searchResults { get; set; }
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




    public SMS_ShopSearchController(ApexPages.StandardController controller) {
        this.controller = controller;
        if (smsShop == null) {
            smsShop = new SMS_Shop__c();
        }
        searchSuccessful = false;
    }

    public void getSmsShops() {
        String preparedQuery = SMS_ShopSearchUtils.prepareQuery(this.smsShop);
        if(String.isBlank(smsShop.Country__c)) {

        }
        this.searchResults = Database.query(preparedQuery);
        if (searchResults.isEmpty()) {
            searchSuccessful = false;
            showNoResults = true;
        } else {
            searchSuccessful = true;
        }
    }


    public void clear() {
        searchResults = null;
        smsShop = new SMS_Shop__c();
        searchSuccessful = false;
    }

    public PageReference getCsvReference() {
        this.csvString = SMS_ShopCSVWrapper.generateCSV(this.searchResults);
        PageReference pr = new PageReference('/apex/SMS_ShopCSVDownload');
        pr.setRedirect(false);
        return pr;
    }
}