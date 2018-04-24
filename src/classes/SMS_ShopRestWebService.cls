@RestResource(urlMapping='/Shops/*')
global with sharing class SMS_ShopRestWebService {


    @HttpGet
    global static List<SMS_Util.Shop> getShops() {
        SMS_Shop__c smsShop = new SMS_Shop__c();
        RestRequest req = RestContext.request;
        smsShop.Previous_Name__c = req.params.get('name');
        smsShop.Email__c = req.params.get('email');
        smsShop.Country__c = req.params.get('country');
        smsShop.City__c = req.params.get('city');
        String query = SMS_ShopSearchUtils.prepareQuery(smsShop);
        List<SMS_Util.Shop> results = new List<SMS_Util.Shop>();
        for (SMS_Shop__c shopElement : Database.query(query)) {
            results.add(new SMS_Util.Shop(shopElement));
        }
        return results;
    }

    @HttpDelete
    global static Boolean deleteShops() {
        RestRequest req = RestContext.request;
        String param = req.params.get('id');
        List<String> ids = (List<String>) JSON.deserialize(req.requestBody.toString(), List<String>.class);
        try {
            List<Id> toDelete = new List<Id>();
            for (String id : ids) {
                toDelete.add(id);
            }
            List<SMS_Shop__c> shops = [SELECT Id FROM SMS_Shop__c WHERE Id IN :toDelete];
            Database.delete(shops, false);

        } catch (QueryException exc) {
            System.debug(exc.getMessage());
            return false;
        } catch (DmlException exc) {
            System.debug(exc.getMessage());
            return false;
        } catch (Exception exc) {
            System.debug(exc.getMessage());
            return false;
        }

        return true;
    }


    @HttpPut
    global static List<SMS_Util.Shop> updateShops() {
        List<SMS_Shop__c> smsShops = new List<SMS_Shop__c>();
        RestRequest req = RestContext.request;
        List<SMS_Util.Shop> shops = (List<SMS_Util.Shop>) JSON.deserialize(req.requestBody.toString(), List<SMS_Util.Shop>.class);
        for (SMS_Util.Shop shop : shops) {
            SMS_Shop__c upSmsShop = new SMS_Shop__c();
            upSmsShop.Id = shop.Id;
            upSmsShop.Previous_Name__c = shop.Name;
            upSmsShop.Email__c = shop.Email;
            upSmsShop.City__c = shop.City;
            upSmsShop.Country__c = shop.Country;
            smsShops.add(upSmsShop);
        }
        Database.update(smsShops);
        return shops;
    }
}