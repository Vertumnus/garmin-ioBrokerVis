using Toybox.WatchUi;

(:glance)
class GlanceView extends WatchUi.GlanceView {
    function initialize() {
        GlanceView.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.GlanceLayout(dc));
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
    }
}