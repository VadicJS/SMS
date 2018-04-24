/**
 * Created by BRITENET on 18.04.2018.
 */

global with sharing class SMS_WholesaleSOAPWebService {



    webservice static List<SMS_Util.Wholesale> getSmsWholesales(String name, String city, String country, String email){
        SMS_Wholesale__c smsWholesale = new SMS_Wholesale__c();
        smsWholesale.Name = name;
        smsWholesale.City__c = city;
        smsWholesale.Country__c = country;
        smsWholesale.Email__c = email;
        String query = SMS_Util.prepareQueryWholesale(smsWholesale);
        List<SMS_Util.Wholesale> result = new List<SMS_Util.Wholesale>();
        for (SMS_Wholesale__c smsWholesaleElement : Database.query(query)){
            result.add(new SMS_Util.Wholesale(smsWholesaleElement));
        }
        return result;
    }

    webService static Boolean deleteSmsWholesale(String Id){
        SMS_Wholesale__c smsWholesale = [SELECT Id FROM SMS_Wholesale__c WHERE Id=:Id];
        //try catch
        Database.DeleteResult result = Database.delete(smsWholesale);
        if(result.isSuccess()){
            return true;
        }else{
            return false;
        }
    }

    webService static void updateSmsWholesale(String Id, String name, String city, String email, String country) {
        SMS_Wholesale__c smsWholesaleElement = [SELECT Id, Name, City__c, Country__c, Email__c FROM SMS_Wholesale__c WHERE Id=:Id];
            smsWholesaleElement.Email__c = email;
            smsWholesaleElement.Country__c = country;
            smsWholesaleElement.City__c = city;
            smsWholesaleElement.Name = name;
        try {
            Database.SaveResult result = Database.update(smsWholesaleElement);
        }catch(DmlException exc){
            exc.getMessage();
        }

    }



}