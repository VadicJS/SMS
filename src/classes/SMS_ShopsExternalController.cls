public with sharing class SMS_ShopsExternalController {
    public ApexPages.StandardController controller { get; set; }
    public SMS_Util.Shop searchParamsShop { get {
        if (this.searchParamsShop == null) {
            this.searchParamsShop = new SMS_Util.Shop();
        }return searchParamsShop;
    }
        set;
    }
    public Boolean showResults { get; set; }
    public List<SMS_Util.Shop> celShops = new List<SMS_Util.Shop>();

    public SMS_ShopsExternalController(){

    }
    public SMS_ShopsExternalController(ApexPages.StandardController controller){
        this.controller = controller;
    }

    public void doCallout(){
        System.debug(searchParamsShop);
        celShops = new List<SMS_Util.Shop>();
        for (SMS_Util.Shop sp : SMS_ShopCallout.makeGetCallout(searchParamsShop)) {
            celShops.add(sp);
        }
        if(!celShops.isEmpty())
            showResults = true;

    }
    public List<SMS_Util.Shop> getShops(){
        List<SMS_Util.Shop> extShops = new List<SMS_Util.Shop>();
        extShops = this.celShops;

            System.debug(extShops);
        return extShops;
    }
}