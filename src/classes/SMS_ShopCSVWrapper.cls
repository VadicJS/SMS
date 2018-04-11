/**
 * Created by BRITENET on 11.04.2018.
 */

public with sharing class SMS_ShopCSVWrapper {

    private static String line(String[] cells) {
        return String.join(cells, ',') + '\n';
    }
    private static String format(Date d) {
        return d != null ? '"' + d.format().escapeCsv() + '"' : '""';
    }
    private static String format(String s) {
        return s != null ? '"' + s.escapeCsv() + '"' : '""';
    }
    private static String format(Decimal d, Integer scale) {
        return d != null ? String.valueOf(d.setScale(scale)) : '';
    }
    private static String format(Decimal d) {
        return format(d, 2);
    }

    public static String generateCSV(List<SMS_Shop__c> smsShops) {

        String csvLine = line(new String[]{
                format('Previous Name'),
                format('Email'),
                format('Country')
        });
        for (SMS_Shop__c shop : smsShops) {
            csvLine += line(new String[]{
                    format(shop.Previous_Name__c),
                    format(shop.Email__c),
                    format(shop.Country__c)
            });
        }

        return csvLine;
    }


}