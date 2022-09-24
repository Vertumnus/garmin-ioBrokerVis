module ioBrokerUtil {
    function getColor(sColor, defaultColor){
        if(sColor == null){
            return defaultColor;
        }
        if(sColor.find("#") == 0){
            return sColor.substring(1, sColor.length()).toNumberWithBase(16);
        }
        return sColor.toNumberWithBase(0);
    }

    function getIconId(sType, bOn){
        switch(sType){
            case "alert":
                return 0xF312.toChar().toString();
            case "back":
                return 0xF331.toChar().toString();
            case "barbell":
                return 0xF3A0.toChar().toString();
            case "bathroom":
                return 0xF3B7.toChar().toString();
            case "battery-charge":
                return 0xF341.toChar().toString();
            case "battery-full":
                return 0xF342.toChar().toString();
            case "battery-low":
                return 0xF340.toChar().toString();
            case "bedroom":
                return 0xF3A1.toChar().toString();
            case "bluetooth":
                if(bOn == false){
                    return "t";
                }
                else{
                    return "T";
                }
            case "books":
                return 0xF3A4.toChar().toString();
            case "build":
                return 0xF3B4.toChar().toString();
            case "bulb":
                if(bOn == false){
                    return "b";
                }
                else{
                    return "B";
                }
            case "camera":
                if(bOn == false){
                    return "k";
                }
                else{
                    return "K";
                }
            case "car":
                return 0xF3AF.toChar().toString();
            case "caret-back":
                return 0xF300.toChar().toString();
            case "caret-down":
                return 0xF303.toChar().toString();
            case "caret-forward":
                return 0xF302.toChar().toString();
            case "caret-up":
                return 0xF301.toChar().toString();
            case "check":
                if(bOn == false){
                    return "c";
                }
                else{
                    return "C";
                }
            case "childroom":
                return 0xF3B9.toChar().toString();
            case "close":
                return 0xF313.toChar().toString();
            case "cloudy":
                return 0xF322.toChar().toString();
            case "cloudy-night":
                return 0xF321.toChar().toString();
            case "paired":
                if(bOn == false){
                    return "a";
                }
                else{
                    return "A";
                }
            case "deck":
                return 0xF3B8.toChar().toString();
            case "dining":
                return 0xF3B1.toChar().toString();
            case "eye":
                if(bOn == false){
                    return "e";
                }
                else{
                    return "E";
                }
            case "favorite":
                return 0xF3B5.toChar().toString();
            case "feed":
                return 0xF3A8.toChar().toString();
            case "flash":
                if(bOn == false){
                    return "f";
                }
                else{
                    return "F";
                }
            case "forward":
                return 0xF335.toChar().toString();
            case "game":
                return 0xF3A3.toChar().toString();
            case "headset":
                if(bOn == false){
                    return "h";
                }
                else{
                    return "H";
                }
            case "home":
                return 0xF3BC.toChar().toString();
            case "info":
                return 0xF311.toChar().toString();
            case "kitchen":
                return 0xF3BA.toChar().toString();
            case "lamp":
                return 0xF3AE.toChar().toString();
            case "link":
                if(bOn == false){
                    return "o";
                }
                else{
                    return "O";
                }
            case "living":
                return 0xF3A9.toChar().toString();
            case "lock":
                if(bOn == false){
                    return "l";
                }
                else{
                    return "L";
                }
            case "mic":
                if(bOn == false){
                    return "m";
                }
                else{
                    return "M";
                }
            case "moon":
                return 0xF320.toChar().toString();
            case "music":
                return 0xF3A5.toChar().toString();
            case "notify":
                if(bOn == false){
                    return "n";
                }
                else{
                    return "N";
                }
            case "ok":
                return 0xF310.toChar().toString();
            case "partly-sunny":
                return 0xF323.toChar().toString();
            case "pause":
                return 0xF333.toChar().toString();
            case "play":
                return 0xF332.toChar().toString();
            case "power":
                if(bOn == false){
                    return "p";
                }
                else{
                    return "P";
                }
            case "rainy":
                return 0xF325.toChar().toString();
            case "seal":
                if(bOn == false){
                    return "i";
                }
                else{
                    return "I";
                }
            case "skip-back":
                return 0xF330.toChar().toString();
            case "skip-forward":
                return 0xF336.toChar().toString();
            case "snow":
                return 0xF3A6.toChar().toString();
            case "sparkles":
                return 0xF3A7.toChar().toString();
            case "speaker":
                return 0xF3AB.toChar().toString();
            case "stairs":
                return 0xF3BB.toChar().toString();
            case "star":
                return 0xF3B3.toChar().toString();
            case "stop":
                return 0xF334.toChar().toString();
            case "sunny":
                return 0xF324.toChar().toString();
            case "target":
                if(bOn == false){
                    return "g";
                }
                else{
                    return "G";
                }
            case "thermo":
                return 0xF3AA.toChar().toString();
            case "thunder":
                return 0xF326.toChar().toString();
            case "toggle":
                if(bOn == false){
                    return "r";
                }
                else{
                    return "R";
                }
            case "torch":
                return 0xF3AD.toChar().toString();
            case "tv":
                return 0xF3AC.toChar().toString();
            case "vol-down":
                return "<";
            case "vol-up":
                return ">";
            case "volume":
                if(bOn == false){
                    return "v";
                }
                else{
                    return "V";
                }
            case "wand":
                return 0xF3A2.toChar().toString();
            case "wc":
                return 0xF3B2.toChar().toString();
            case "work":
                return 0xF3B6.toChar().toString();
            case "yard":
                return 0xF3B0.toChar().toString();
            default:
                return "";
        }
    }
}