using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Communications;

class MainView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function showError(dc){
        var err = Application.getApp().mIoRequest.mErrorCode;
        if(err == null){
            return;
        }
        var text = "";
        switch(err){
            case Communications.SECURE_CONNECTION_REQUIRED:
                text = "HTTPS required";
                break;
            case Communications.NETWORK_RESPONSE_OUT_OF_MEMORY:
            case Communications.NETWORK_RESPONSE_TOO_LARGE:
            case Communications.INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE:
            case Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE:
                text = "Response issue (" + err + ")";
                break;
            case Communications.NETWORK_REQUEST_TIMED_OUT:
                text = "Unavailable";
                break;
            case Communications.INVALID_HTTP_METHOD_IN_REQUEST:
            case Communications.INVALID_HTTP_BODY_IN_REQUEST:
            case Communications.INVALID_HTTP_HEADER_FIELDS_IN_REQUEST:
                text = "Request issue (" + err + ")";
                break;
            case Communications.BLE_CONNECTION_UNAVAILABLE:
                text = "No Connection";
                break;
            case 400:
                text = "Bad Request";
                break;
            case 401:
                text = "Unauthorized";
                break;
            case 403:
                text = "Forbidden";
                break;
            case 404:
                text = "Not Found";
                break;
            default:
                if(err < 200 || err >= 300){
                    text = "Error (" + err + ")";
                }
                break;
        }
        if(text != ""){
            dc.drawText(dc.getWidth() / 2, dc.getHeight() * 75 / 100, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_CENTER);
        }
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
        Application.getApp().atMain();
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

        showError(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
