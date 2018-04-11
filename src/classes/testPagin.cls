/**
 * Created by BRITENET on 11.04.2018.
 */

public with sharing class testPagin {
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController standardSetCtrl {
        get{
            if(standardSetCtrl == null){
                size = 4;
                string queryString = 'Select Name, Type, BillingCity, BillingState, BillingCountry from Account order by Name';
                standardSetCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                standardSetCtrl.setPageSize(size);
                noOfRecords = standardSetCtrl.getResultSize();
            }
            return standardSetCtrl;
        }set;
    }

    Public List<Account> getAccounts(){
        List<Account> accList = new List<Account>();
        for(Account a : (List<Account>)standardSetCtrl.getRecords())
            accList.add(a);
        return accList;
    }

    public pageReference refresh() {
        standardSetCtrl = null;
        getAccounts();
        standardSetCtrl.setPageNumber(1);
        return null;
    }

    public Boolean hasNext {
        get {
            return standardSetCtrl.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return standardSetCtrl.getHasPrevious();
        }
        set;
    }

    public Integer pageNumber {
        get {
            return standardSetCtrl.getPageNumber();
        }
        set;
    }

    public void first() {
        //any custom logic
        standardSetCtrl.first();
    }

    public void last() {
        //any custom logic
        standardSetCtrl.last();
    }

    public void previous() {
        //any custom logic
        standardSetCtrl.previous();
    }

    public void next() {
        //any custom logic
        standardSetCtrl.next();
    }
}