/**
 * Created by BRITENET on 08.04.2018.
 */

public with sharing class SMS_PopUpWindow {

    public Boolean displayPopup {get;set;}

    public SMS_PopUpWindow(ApexPages.StandardController controller) {

    }

    public void showPopup() {
        displayPopup = true;
    }

    public void closePopup() {
        displayPopup = false;
    }

}