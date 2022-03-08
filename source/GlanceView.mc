using Toybox.WatchUi;

(:glance)
class GlanceView extends WatchUi.GlanceView {

    private var greeting;

    function initialize() {
        GlanceView.initialize();
    }

    function onShow() {
        greeting = new WatchUi.Text({
            :text=>Application.Properties.getValue("greet"),
            :color=>Graphics.COLOR_DK_BLUE,
            :font=>Graphics.FONT_LARGE,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER,
            :locX=>WatchUi.LAYOUT_HALIGN_START
        });
        Application.getApp().atGlance();
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
        greeting.draw(dc);
    }
}