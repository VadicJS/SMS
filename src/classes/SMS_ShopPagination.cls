/**
 * Created by BRITENET on 11.04.2018.
 */

public with sharing class SMS_ShopPagination {

    public ApexPages.StandardSetController standardSetCtrl {
        get{
            if(standardSetCtrl == null){
                Integer size = 1;
                string queryString = 'SELECT Previous_Name__c, Email__c, Country__c FROM SMS_Shop__c';
                standardSetCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                standardSetCtrl.setPageSize(size);
                Integer noOfRecords = standardSetCtrl.getResultSize();
            }
            return standardSetCtrl;
        }set;
    }

    public void first() {
        // some custom logic
        standardSetCtrl.first();
    }

    public Boolean hasPrevious {
        get {
            return standardSetCtrl.getHasPrevious();
        }
        set;
    }
}