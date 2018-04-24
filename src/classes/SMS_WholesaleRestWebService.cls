@RestResource(urlMapping='/Wholesales/*')
global with sharing class SMS_WholesaleRestWebService {
    @HttpGet
    global static List<SMS_Util.Wholesale> getWholesales() {
        SMS_Wholesale__c smsWholesale = new SMS_Wholesale__c();
        RestRequest req = RestContext.request;
        smsWholesale.Name = req.params.get('name');
        smsWholesale.Email__c = req.params.get('email');
        smsWholesale.Country__c = req.params.get('country');
        smsWholesale.City__c = req.params.get('city');
        String query = SMS_Util.prepareQueryWholesale(smsWholesale);
        List<SMS_Util.Wholesale> results = new List<SMS_Util.Wholesale>();
        for (SMS_Wholesale__c wholesaleEl : Database.query(query)) {
            results.add(new SMS_Util.Wholesale(wholesaleEl));
        }
        return results;
    }

    @HttpDelete
    global static Boolean deleteWholesales() {
        RestRequest req = RestContext.request;
        String param = req.params.get('id');
        List<String> ids = (List<String>) JSON.deserialize(req.requestBody.toString(), List<String>.class);

        List<Id> toDelete = new List<Id>();
        for (String id : ids) {
            try {
                Database.delete(id, true);
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
        }
        return true;
    }


    @HttpPut
    global static List<SMS_Util.Wholesale> updateWholesales() {
        List<SMS_Wholesale__c> smsWholesales = new List<SMS_Wholesale__c>();
        RestRequest req = RestContext.request;
        List<SMS_Util.Wholesale> wholesales = (List<SMS_Util.Wholesale>) JSON.deserialize(req.requestBody.toString(), List<SMS_Util.Wholesale>.class);
        for (SMS_Util.Wholesale wholesaleElement : wholesales) {
            SMS_Wholesale__c upSmsWholesale = new SMS_Wholesale__c();
            upSmsWholesale.Id = wholesaleElement.Id;
            upSmsWholesale.Name = wholesaleElement.Name;
            upSmsWholesale.Email__c = wholesaleElement.Email;
            upSmsWholesale.City__c = wholesaleElement.City;
            upSmsWholesale.Country__c = wholesaleElement.Country;
            smsWholesales.add(upSmsWholesale);
        }
        Database.update(smsWholesales);
        return wholesales;
    }
}