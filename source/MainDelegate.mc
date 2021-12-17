using Toybox.WatchUi;

class MainDelegate extends WatchUi.BehaviorDelegate {

    function initialize(){
        BehaviorDelegate.initialize();
    }

    function onTap(oClickEvent){
        Application.getApp().connect();
    }

}