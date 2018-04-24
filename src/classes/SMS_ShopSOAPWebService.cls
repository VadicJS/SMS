/**
 * Created by BRITENET on 18.04.2018.
 */

global with sharing class SMS_ShopSOAPWebService {

    webservice static List<SMS_Util.Shop> getSmsShops(String name, String city, String country, String email){
        SMS_Shop__c smsShop = new SMS_Shop__c();
        smsShop.Previous_Name__c = name;
        smsShop.City__c = city;
        smsShop.Country__c = country;
        smsShop.Email__c = email;
        String query = SMS_ShopSearchUtils.prepareQuery(smsShop);
        List<SMS_Util.Shop> result = new List<SMS_Util.Shop>();
        for (SMS_Shop__c smsShopElement : Database.query(query)){
            result.add(new SMS_Util.Shop(smsShopElement));
        }
        return result;
    }

    webService static Boolean deleteSmsShop(String Id){
        SMS_Shop__c smsShop = [ SELECT Id FROM SMS_Shop__c WHERE Id=:Id];
        Database.DeleteResult result = Database.delete(smsShop);
        if(result.isSuccess()){
            return true;
        }else{
            return false;
        }
    }

    webService static List<SMS_Shop__c> updateSmsShop(String Id, String name, String city, String email, String country) {
        List<SMS_Shop__c> result = new List<SMS_Shop__c>();
        for (SMS_Shop__c smsShopElement : [SELECT Id, Previous_Name__c, City__c, Country__c, Email__c FROM SMS_Shop__c WHERE Id=:Id]){
            smsShopElement.Email__c = email;
            smsShopElement.Country__c = country;
            smsShopElement.City__c = city;
            smsShopElement.Previous_Name__c = name;
            result.add(smsShopElement);
        }
        Database.upsert(result);
        return result;
    }
}