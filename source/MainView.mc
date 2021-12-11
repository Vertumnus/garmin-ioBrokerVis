using Toybox.WatchUi;
using Toybox.Graphics;

class MainView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        Application.getApp().connect();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var color;
        if(Application.getApp().isConnectionReady()){
            color = Graphics.COLOR_GREEN;
        }
        else if(Application.getApp().hasConnectionError()){
            color = Graphics.COLOR_RED;
        }
        else{
            color = Graphics.COLOR_TRANSPARENT;
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(dc.getWidth() / 2, dc.getHeight() / 2, 70);

        var err = Application.getApp().mIoRequest.mErrorCode;
        if(err != null && err != 200){
            dc.drawText(dc.getWidth() / 2, dc.getHeight() * 80 / 100, Graphics.FONT_XTINY, err, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
