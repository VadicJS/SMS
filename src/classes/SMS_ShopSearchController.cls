public with sharing class SMS_ShopSearchController {

    public Boolean notFound { get; set; } {
        notFound = false;
    }
    public Boolean showResult { get; set; }
    public Integer noOfRecords { get; set; }
    public Integer size { get; set; }
    private String sortDirection = '';
    private String sortExp = ' ';
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                    sortDirection = 'ASC';
            sortExp = value;
        }
    }

    public String csvString { get; set; }
    public List<SMS_Shop__c> xlsList { get; set; }
    public ApexPages.StandardSetController setCon { get; set; }
    public List<SelectOption> paginationSizeOptions { get; set; }
    public SMS_Shop__c smsShop {
        get {
            if (this.smsShop == null) {
                this.smsShop = new SMS_Shop__c();
            }return smsShop;
        }
        set;
    }

    String errorStr = '';
    public SMS_ShopSearchController(ApexPages.StandardController controller) {

        size = 2;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('2', '2'));
        paginationSizeOptions.add(new SelectOption('10', '10'));
        paginationSizeOptions.add(new SelectOption('20', '20'));
        paginationSizeOptions.add(new SelectOption('30', '30'));

        this.csvString = csvString;
        this.xlsList = xlsList;
    }

    public String getSortDirection()
    {
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
                return sortDirection;
    }

    public void setSortDirection(String value)
    {
        sortDirection = value;
    }

    public void showAll() {
        try {
            if (smsShop != null) {
                String orderBy = '';
                if(String.isNotBlank(sortDirection) && String.isNotBlank(sortExpression))
                        orderBy = ' ORDER BY ' + sortExpression + ' ' + sortDirection;
                System.debug(orderBy);
                String query = SMS_ShopSearchUtils.prepareQuery(this.smsShop) +orderBy;
                System.debug(query);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                if (setCon.getResultSize() > 0) {
                    notFound = false;
                    showResult = true;
                } else {
                    notFound = true;
                    showResult = false;
                }
            }
        } catch (Exception ex) {

            errorStr = 'Error Occured while Searching.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'errorStr:' + ex.getMessage()));
        }
    }

    public List<SMS_Shop__c> getShops() {
        if (setCon.getResultSize() > 0) {
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
            return (List<SMS_Shop__c>) setCon.getRecords();
        } else {
            return null;
        }
    }

    public void refreshPageSize() {
        setCon.setPageSize(size);
    }

    public void clear() {
        this.smsShop = null;
        this.showResult = false;
    }

    public List<SMS_Shop__c> getTotalShops() {
        List<SMS_Shop__c> totalShops = new List<SMS_Shop__c>();
        totalShops = Database.query(SMS_ShopSearchUtils.prepareQuery(this.smsShop));
        return totalShops;
    }

    public PageReference getCsvReference() {
        this.csvString = SMS_ShopCSVWrapper.generateCSV(this.getTotalShops());
        PageReference pr = new PageReference('/apex/SMS_ShopCSVDownload');
        pr.setRedirect(false);
        return pr;
    }

    public PageReference getXlsReference() {
        this.xlsList = getTotalShops();
        PageReference pr = new PageReference('/apex/SMS_ShopSearchXLS');
        pr.setRedirect(false);
        return pr;
    }
}