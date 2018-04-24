/**
 * Created by BRITENET on 23.04.2018.
 */

public with sharing class SMS_ShopCallout {

    public static List<SMS_Util.Shop> makeGetCallout(SMS_Util.Shop searchParams) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String name = '';
        String country = '';
        String email = '';
        String city = '';
        if(searchParams.Name != null)
            name = searchParams.Name;
        if(searchParams.Country != null)
            country = searchParams.Country;
        if(searchParams.Email != null)
            email = searchParams.Email;
        if(searchParams.City != null)
            city = searchParams.City;
        request.setEndpoint('https://eu12.salesforce.com/services/apexrest/Shops/?Name=' + name + '&City=' + city + '&Country=' + country + '&email=' + email);
        request.setHeader('Authorization', 'OAuth 00D1r000000eUPq!ARMAQEX0sAt2vtNpNWBTE1jQ00sISCvUuhgP2nkFSpXfa7.eKETky.MSLwdpnG8Pg0jsuUWt9XNBQ3Wiz3tjqQMRoWp9v6v1');
        request.setMethod('GET');
        System.debug(request.getEndpoint());
        HttpResponse response = http.send(request);
        List<SMS_Util.Shop> shops = new List<SMS_Util.Shop>();
        if (response.getStatusCode() == 200) {
            shops = (List<SMS_Util.Shop>) JSON.deserializeStrict(response.getBody(), List<SMS_Util.Shop>.class);
            //System.debug('Received the following shops:');
//            for (Object shopElement: shops) {
//                System.debug(shopElement);
//            }
        }
        return shops;
    }
}