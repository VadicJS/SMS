global with sharing class SMS_Util {

    private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String NS_SF = 'urn:enterprise.soap.sforce.com';

    public static User getUser(String userId) {
        return [SELECT Id, Username, Country__c FROM User WHERE Id = :userId];
    }

    public static User getCurrentUser() {
        return getUser(UserInfo.getUserId());
    }

    public static Boolean isFunctionalityEnabled(String csName, String country) {
        SMS_Setting__c csItem = SMS_Setting__c.getInstance(csName);
        if (csItem == null) {
            return false;
        }
        List<String> csItems = csItem.value__c.split(',');
        Set<String> csSet = new Set<String>();
        csSet.addAll(csItems);
        return csSet.contains(country);
    }

    public static Boolean isFunctionalityEnabled(String csName) {
        return isFunctionalityEnabled(csName, getCurrentUser().Country__c);
    }

    public static void sendMail(String address, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                address
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }

    public static Boolean isTriggerEnabled(String csName) {
        SMS_Trigger_Exceptions__c customSett = SMS_Trigger_Exceptions__c.getInstance(getCurrentUser().Id);
        Object value = customSett.get(csName);
        Boolean isEnabled = (Boolean) value;
        return isEnabled;
    }

    public static String prepareQueryWholesale(SMS_Wholesale__c smsWholesale) {
        String preparedQuery = 'SELECT Id, Name, Email__c, Country__C, City__c FROM SMS_Wholesale__c WHERE Country__c LIKE \'%' + smsWholesale.Country__c + '%\'';
        if (String.isNotBlank(smsWholesale.Name)) {
            preparedQuery += ' AND Name LIKE \'%' + smsWholesale.Name + '%\'';
        }
        if (String.isNotBlank(smsWholesale.City__c)) {
            preparedQuery += ' AND City__c LIKE \'%' + smsWholesale.City__c + '%\' ';
        }
        if (String.isNotBlank(smsWholesale.Email__c)) {
            preparedQuery += ' AND Email__c LIKE \'%' + smsWholesale.Email__c + '%\'';
        }
        return preparedQuery ;
    }

    public with sharing class ShopSelected {

        public Boolean isSelected { get; set; }
        public SMS_Shop__c smsShopWrapped { get; set; }

        public ShopSelected() {
            smsShopWrapped = new SMS_Shop__c();
            isSelected = false;
        }

        public ShopSelected(SMS_Shop__c smsShop, Integer index) {
            this.smsShopWrapped = smsShop;
        }
    }

    public class SupplyWrapper {
        public String importStatus { get; set; }
        public SMS_Supply__c smsSupplyWrapped { get; set; }

        public SupplyWrapper() {
            importStatus = '';
            smsSupplyWrapped = new SMS_Supply__c();
        }

        public SupplyWrapper(SMS_Supply__c smsSupply, String importStatus) {
            this.smsSupplyWrapped = smsSupply;
            this.importStatus = importStatus;
        }
    }

    public class ContractWrapper {
        public SMS_Supply__c smsSupplyWrapped { get; set; }
        public SMS_Shop__c smsShopWrapped { get; set; }
        public Boolean isSelected { get; set; }
        public Boolean isImported { get; set; }
        public String importStatus { get; set; }

        public ContractWrapper() {
            isImported = false;
            isSelected = false;
            importStatus = '';
            smsSupplyWrapped = new SMS_Supply__c();
            smsShopWrapped = new SMS_Shop__c();
        }

        public ContractWrapper(SMS_Supply__c smsSupply, SMS_Shop__c smsShop, String importStatus, Boolean isSelected, Boolean isImported) {
            this.isSelected = isSelected;
            this.isImported = isImported;
            this.smsShopWrapped = smsShop;
            this.smsSupplyWrapped = smsSupply;
            this.importStatus = importStatus;
        }
    }


    public static Boolean insertContractDateValidation(Id shopId, Id wholesaleId, Date csd, Date ced, String status) {
        if (csd >= ced) {
            status = System.Label.Start_before_End_Error;
            return false;
        }
        List<SMS_Supply__c> smsSupplies = [
                SELECT Contract_Start_Date__c, Contract_End_Date__c, Wholesale__r.Name
                FROM SMS_Supply__c
                WHERE
                Shop__c = :shopId AND Wholesale__c = :wholesaleId AND ((Contract_Start_Date__c <= :csd AND Contract_End_Date__c >= :csd) OR (Contract_End_Date__c >= :ced AND Contract_Start_Date__c <= :ced)
                OR (Contract_Start_Date__c >= :csd AND Contract_End_Date__c <= :ced))
        ];
        if (smsSupplies.isEmpty()) {
            status = System.Label.Success_New_Supply;

            return true;
        } else {
            status = System.Label.Date_Overlapping + ' ' +
                    smsSupplies[0].Wholesale__r.Name + ' Start: ' + smsSupplies[0].Contract_Start_Date__c.format() + ', End: ' + smsSupplies[0].Contract_End_Date__c.format();
            return false;
        }
    }

    global class Shop {
        webService String Id { get; set; }
        webService String Name { get; set; }
        webService String Email { get; set; }
        webService String City { get; set; }
        webService String Country { get; set; }

        public Shop() {
        }

        public Shop(SMS_Shop__c shop) {
            this.Id = shop.Id;
            this.Email = shop.Email__c;
            this.Name = shop.Previous_Name__c;
            this.City = shop.City__c;
            this.Country = shop.Country__c;
        }
    }

    global class Wholesale {
        webService String id { get; set; }
        webService String name { get; set; }
        webService String email { get; set; }
        webService String city { get; set; }
        webService String country { get; set; }

        public Wholesale() {
        }

        public Wholesale(SMS_Wholesale__c wholesale) {
            this.id = wholesale.Id;
            this.email = wholesale.Email__c;
            this.name = wholesale.Name;
            this.city = wholesale.City__c;
            this.country = wholesale.Country__c;
        }
    }


    public static List<SMS_Util.Wholesale> makeGetCallout(SMS_Util.Wholesale searchParams) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String name = '';
        String country = '';
        String email = '';
        String city = '';
        if (searchParams.Name != null)
            name = searchParams.Name;
        if (searchParams.Country != null)
            country = searchParams.Country;
        if (searchParams.Email != null)
            email = searchParams.Email;
        if (searchParams.City != null)
            city = searchParams.City;
        request.setEndpoint('https://eu12.salesforce.com/services/apexrest/Wholesalers/?Name=' + name + '&City=' + city + '&Country=' + country + '&Email=' + email);
        request.setHeader('Authorization', 'OAuth ' + login());
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<SMS_Util.Wholesale> wholesales = new List<SMS_Util.Wholesale>();
        if (response.getStatusCode() == 200) {
            wholesales = (List<SMS_Util.Wholesale>) JSON.deserializeStrict(response.getBody(), List<SMS_Util.Wholesale>.class);
        }
        System.debug(response.getStatusCode());
        return wholesales;
    }

    public static HttpResponse makeDeleteCalloutWholesales(List<Id> ids){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://eu12.salesforce.com/services/apexrest/Wholesalers');
        request.setHeader('Authorization', 'OAuth ' + login());
        request.setMethod('DELETE');
        String idsSerialized = JSON.serialize(ids);
        request.setBody(idsSerialized);
        HttpResponse response = http.send(request);
        System.debug('delete res: ' + response);
        return(response);
    }

    public static HttpResponse makeUpdateCalloutWholesalers(List<Wholesale> wholesales){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://eu12.salesforce.com/services/apexrest/Wholesalers');
        request.setHeader('Authorization', 'OAuth ' + login());
        request.setMethod('PATCH');
        String wholesalesSerialized = JSON.serialize(wholesales);
        request.setBody(wholesalesSerialized);
        HttpResponse response = http.send(request);
        System.debug('delete res:' + response);
        return(response);
    }

    global class LoginResponse {
        webService String access_token;
        webService String instance_url;
        webService String token_type;
        webService String issued_at;
        webService String signature;

        public LoginResponse() {

        }

        public LoginResponse(String access_token, String instance_url, String token_type, String issued_at, String signature) {
            this.access_token = access_token;
            this.instance_url = instance_url;
            this.issued_at = issued_at;
            this.token_type = token_type;
            this.signature = signature;
        }
    }

    public static String login() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://login.salesforce.com/services/Soap/c/42.0');
        request.setHeader('SOAPAction', '""');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">' +
                '<soapenv:Header>' + '</soapenv:Header>' + '<soapenv:Body>' + '<urn:login>' +
                '<urn:username>externalapi@britenet.com.pl</urn:username>' +
                '<urn:password>Bilbao97HkNd5VBznzTjv8nhi7cfY4gRp</urn:password>' +
                '</urn:login>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>');
        HttpResponse response = http.send(request);

        Dom.Document responseDocument = response.getBodyDocument();
        Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
        Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body
        Dom.Xmlnode loginResponseElm = bodyElm.getChildElement('loginResponse', NS_SF); // loginResponse
        Dom.Xmlnode resultElm = loginResponseElm.getChildElement('result', NS_SF); // result
        Dom.Xmlnode sessionIdElm = resultElm.getChildElement('sessionId', NS_SF); // sessionId
        System.debug(sessionIdElm.getText());
        return sessionIdElm.getText();
    }
    public class LoginException extends Exception {

    }


    public static void makeUpdateCalloutWholesales() {

    }
}