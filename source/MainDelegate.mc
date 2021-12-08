using Toybox.WatchUi;

class MainDelegate extends WatchUi.BehaviorDelegate {

    function initialize(){
        BehaviorDelegate.initialize();
    }

    function onTap(oClickEvent){
        if(Application.getApp().isSpaceReady()){
            Application.getApp().requestCurrentIoStates();
            WatchUi.pushView(new SpaceView(), new SpaceDelegate(), WatchUi.SLIDE_LEFT);
        }
    }

}