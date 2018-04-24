public with sharing class SMS_WholesalesExternalController {
    public ApexPages.StandardController controller { get; set; }
    public List<Id> idsToDelete = new List<Id>();
    public List<SMS_Util.Wholesale> wholesales = new List<SMS_Util.Wholesale>();
    public String fetchedId {
        get;
        set {
            fetchedId = value;
            System.debug('value: '+value);
        }
    }
    public SMS_Util.Wholesale searchParamsWholesale{ get {
        if (this.searchParamsWholesale == null) {
            this.searchParamsWholesale = new SMS_Util.Wholesale();
        }return searchParamsWholesale;
    }
        set;
    }
    public Boolean showResults { get; set; }
    public List<SMS_Util.Wholesale> celWholesales = new List<SMS_Util.Wholesale>();

    public SMS_WholesalesExternalController(){
    }

    public SMS_WholesalesExternalController(ApexPages.StandardController controller){
        this.controller = controller;
    }

    public void fetchId(){
        System.debug('fetchedId' + fetchedId);
    }

    public void makeGetCallout(){
        System.debug(searchParamsWholesale);
        celWholesales = new List<SMS_Util.Wholesale>();
        if(searchParamsWholesale.country == null)
            searchParamsWholesale.country = '';
        for (SMS_Util.Wholesale sp : SMS_Util.makeGetCallout(searchParamsWholesale)) {
            celWholesales.add(sp);
        }
        if(!celWholesales.isEmpty())
            showResults = true;

    }
    public List<SMS_Util.Wholesale> getWholesales(){
        List<SMS_Util.Wholesale> extWholesales = new List<SMS_Util.Wholesale>();
        extWholesales = this.celWholesales;
        System.debug(extWholesales);
        return extWholesales;
    }

    public void deleteWholesale(){
        System.debug('wholesaleId: ' + fetchedId);
        idsToDelete.add(fetchedId);
        SMS_Util.makeDeleteCalloutWholesales(idsToDelete);
        idsToDelete.clear();
        makeGetCallout();
    }

    public void updateWholesale(){

    }

}