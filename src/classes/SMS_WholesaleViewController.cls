public with sharing class SMS_WholesaleViewController {

    ApexPages.StandardController controller;
    public List<SMS_Util.ContractWrapper> contractsToAdd { get; set; }
    public List<SMS_Util.ContractWrapper> contractsToShow = new List<SMS_Util.ContractWrapper>();
    public Boolean success { get; set; }
    public Boolean datesEnabled { get; set; }
    public Map<Id, Integer> indexBuffer = new Map<Id, Integer>();
    public String status;
    public Boolean displayPopup { get; set; }
    public Boolean notFound { get; set; } {
        notFound = false;
    }
    public Boolean showResult { get; set; }
    public Boolean showNewSupplies { get; set; }
    public Integer size { get; set; }
    public Id wholesaleId;
    public SMS_Shop__c smsShop {
        get {
            if (this.smsShop == null) {
                this.smsShop = new SMS_Shop__c();
            }return smsShop;
        }
        set;
    }

    public SMS_WholesaleViewController(ApexPages.StandardController controller) {
        this.controller = controller;
        wholesaleId = controller.getId();
    }

    public void search() {
        if (!contractsToShow.isEmpty())
            contractsToShow.clear();
        String query = SMS_ShopSearchUtils.prepareQuery(this.smsShop);
        List<SMS_Shop__c> shops = Database.query(query);
        Boolean exists = false;
        for (SMS_Shop__c smsShop : shops) {
            exists = false;
            SMS_Util.ContractWrapper contract = new SMS_Util.ContractWrapper();
            contract.smsShopWrapped = smsShop;
            contract.smsShopWrapped.Id = smsShop.Id;
            if (contractsToAdd != null)
                for (SMS_Util.ContractWrapper con : contractsToAdd) {
                    if (con.smsShopWrapped.Id == contract.smsShopWrapped.Id) {
                        exists = true;
                        break;
                    }
                }
            if (!exists)
                contractsToShow.add(contract);
        }
        showResult = true;
    }

    public List<SMS_Util.ContractWrapper> getContractsFromSearch() {
        showResult = !contractsToShow.isEmpty();
        return contractsToShow;
    }

    public void selectShop() {
        Id selectedShopId = ApexPages.currentPage().getParameters().get('selectedShopId');
        if (contractsToAdd == null) {
            contractsToAdd = new List<SMS_Util.ContractWrapper>();
        }
        for (Integer i = 0; i < contractsToShow.size(); i++) {
            if (contractsToShow[i].smsShopWrapped.Id == selectedShopId && contractsToAdd.size() < 100) {
                contractsToShow[i].isImported = false;
                contractsToShow[i].smsSupplyWrapped.Contract_End_Date__c = null;
                contractsToShow[i].smsSupplyWrapped.Contract_Start_Date__c = null;
                contractsToShow[i].importStatus = '';
                contractsToAdd.add(contractsToShow[i]);
                indexBuffer.put(selectedShopId, i);
                contractsToShow.remove(i);
                showNewSupplies = true;
            }
        }
    }

    public void remove() {
        Id removedShopId = ApexPages.currentPage().getParameters().get('removedShopId');
        for (Integer i = 0; i < contractsToAdd.size(); i++) {
            if (contractsToAdd[i].smsShopWrapped.Id == removedShopId) {
                if (contractsToShow.isEmpty()) {
                    contractsToShow.add(contractsToAdd[i]);
                    showResult = true;
                } else {
                    if ((contractsToAdd[i].smsShopWrapped.Country__c == contractsToShow[0].smsShopWrapped.Country__c)) {
                        if (indexBuffer.get(removedShopId) < contractsToShow.size()) {
                            contractsToShow.add(indexBuffer.get(removedShopId), contractsToAdd[i]);
                        } else {
                            contractsToShow.add(contractsToAdd[i]);
                        }
                    }
                }
                      contractsToAdd.remove(i);
            }
        }
        showResult = true;
        if (contractsToAdd.isEmpty()) {
            showNewSupplies = false;
        }
    }

    public void insertContracts() {
        List<SMS_Supply__c> suppliesToInsert = new List<SMS_Supply__c>();
        for (SMS_Util.ContractWrapper wrappedItem : contractsToAdd) {
            System.debug(wrappedItem.smsShopWrapped.Id);
            SMS_Supply__c supplyToInsert = new SMS_Supply__c();
            supplyToInsert.Shop__c = wrappedItem.smsShopWrapped.Id;
            supplyToInsert.Wholesale__c = wholesaleId;
            supplyToInsert.Contract_Start_Date__c = wrappedItem.smsSupplyWrapped.Contract_Start_Date__c;
            supplyToInsert.Contract_End_Date__c = wrappedItem.smsSupplyWrapped.Contract_End_Date__c;
            suppliesToInsert.add(supplyToInsert);
        }

        if (!suppliesToInsert.isEmpty()) {
            for (SMS_Supply__c supply : suppliesToInsert) {
                Date csd = supply.Contract_Start_Date__c;
                Date ced = supply.Contract_End_Date__c;
                List<SMS_Supply__c> smsSupplies = [
                        SELECT Contract_Start_Date__c, Contract_End_Date__c, Shop__r.Previous_Name__c
                        FROM SMS_Supply__c
                        WHERE
                        Shop__c = :supply.Shop__c AND Wholesale__c = :wholesaleId AND ((Contract_Start_Date__c <= :csd AND Contract_End_Date__c >= :csd) OR (Contract_End_Date__c >= :ced AND Contract_Start_Date__c <= :ced)
                        OR (Contract_Start_Date__c >= :csd AND Contract_End_Date__c <= :ced))
                ];
                if (csd == null || ced == null) {
                    status = System.Label.Fill_dates;
                    setStatus(supply.Shop__c, status, false);
                } else if (csd >= ced) {
                    status = System.Label.Start_before_End_Error;
                    setStatus(supply.Shop__c, status, false);
                } else if (smsSupplies.isEmpty()) {
                    status = System.Label.Success;
                    try {
                        setStatus(supply.Shop__c, status, true);

                        Database.insert(supply);
                    } catch (DmlException exc) {
                        ApexPages.addMessages(exc);
                    }
                } else {
                    status = System.Label.Date_Overlapping + ': ' + smsSupplies[0].Contract_Start_Date__c.format() + ' -- ' + smsSupplies[0].Contract_End_Date__c.format();
                    setStatus(supply.Shop__c, status, false);
                    success = false;
                }
            }
            for (SMS_Util.ContractWrapper con : contractsToAdd) {
                if (con.importStatus != System.Label.Success) {
                    success = false;
                    break;
                } else {
                    success = true;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.Success);
                    ApexPages.addMessage(msg);
                }
            }
            System.debug(success);

        }
    }

    public Boolean setStatus(Id shopId, String status, Boolean isImported) {
        for (SMS_Util.ContractWrapper con : contractsToAdd) {
            System.debug(con.smsShopWrapped.Id + '====' + shopId);
            if (con.smsShopWrapped.Id == shopId) {
                if (!con.isImported) {
                    con.isImported = isImported;
                    con.importStatus = status;
                    success = isImported;
                } else {
                    success = true;
                }
            }
        } return isImported;
    }

    public void clear() {
        this.smsShop = null;
        this.showResult = false;
        this.contractsToAdd = new List<SMS_Util.ContractWrapper>();
        this.showNewSupplies = false;
    }

    public void clearForm() {
        this.smsShop = null;
        this.showResult = false;
        contractsToShow.clear();
    }

    public void showPopup() {
        displayPopup = true;
    }

    public void closePopup() {
        displayPopup = false;
    }

    public void datesChange() {
        Id changedContract = ApexPages.currentPage().getParameters().get('supDateId');
        System.debug('data zmieniona');
        for (SMS_Util.ContractWrapper con : contractsToAdd) {
            if (con.smsShopWrapped.Id == changedContract) {
                con.isImported = false;
            }
        }
    }
}