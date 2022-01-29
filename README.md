# Garmin ioBroker Visualization

## Content

* [Overview](#overview)
* [Structure](#structure)
* [App flow and navigation](#app-flow-and-navigation)
* [Preconditions](#preconditions)
    - [Details](#details)
        - [Object with configuration](#object-with-configuration)
    - [FAQ](#faq)
* [Settings of the Widget](#settings-of-the-widget)
* [Icon List](#icon-list)
* [Open Tasks](#open-tasks)
* [License](#license)

## Overview

This widget for garmin watches is a UI or visualization for your ioBroker instance. So you can visualize:

* Information as text like e.g. a temperature
* States as colored text or colored icons
* Switches as icons to see if something is on or off and to change the state
* Buttons as icons to trigger something

## Structure

The UI is separated in so called _Spaces_. A _Space_ can be a room or a device or what ever you want to cluster your states. The _Space_ has an icon, so you can identify it, e.g. a couch for the living room. Each _Space_ exists of at least one _Object_ or at most eight _Objects_ (more would overload the little screen of your garmin device). An _Object_ is a visual representation of a state from your ioBroker e.g. the on/off state of a bulb.

## App flow and navigation

First of all the widget try to connect to your ioBroker instance. On an error the widget shows the ioBroker icon framed with a red circle and the error description and/or code. On success the widget shows the first configured _Space_. If you have configured switches or buttons you can interact with the related _Objects_ by tapping on them. By Tapping on the _Space_ icon you can refresh the view to get updated states. Wiping up and down you can navigate through the _Spaces_ (it's the standard navigation on garmin devices to navigate to the next or previous page).

## Preconditions

Of course you need an [ioBroker](https://www.iobroker.net/) instance / server. Additionally you need:

* A simple-api adapter instance
* A secured (https) __signed__ connection to your server i.e. simple-api instance
* An object with the configuration for the visualization

### Details

Your simple-api instance needs in each case the setting for HTTPS. Use appropriate certificates for that. You can find some hints in the [FAQ](#faq).
> __Recommendation:__ Activate also the option _Authentication_ and configure a fitting user with password for your use case.

#### Object with configuration

You need somewhere an object with a special configuration. Currently you have to create it manually.

> __Recommendation:__ Create it under `0_userdata.0`, e.g. `0_userdata.0.garmin` as type `device`. Be sure that your used user for the simple-api has the authorizations to read this object.

After the creation you have to modify the object. At the object data tab you can see the object configuration in json format. You must create or modify the attribute `native`:

```json
{
    "common": {
        "name": "...",

    },
    "native": {
    }
}
```

As already described, the UI is separated into _Spaces_, so you must define first those in an Array:

```json
    "native": {
        "spaces": [
            {
                "icon": "star",
                "color": "#FFAA00",

            }
        ]
    }
```

Each _Space_ has two attributes for visualization. The `icon` and a `color`. See the available icons in the [list](#icon-list) below. You can specify the color in hexadecimal format with a leading #. The `icon` is mandatory. If you do not specify the `color` the widget takes __yellow__ as default.

As you know a _Space_ exists of _Objects_, so you have to specify them too inside:

```json
    "native": {
        "spaces": [
            {
                "icon": "star",
                "objects": [
                    {
                        "type": "<icon>|text|state",

                    }
                ]
            }
        ]
    }
```

An _Object_ has always a `type`. The type could be an icon (see [list](#icon-list) below), a simple text or a state. For any type you can specify a `color` like at the _Space_. The type _text_ has __white__ as default color and the others has __blue__.

The type _text_ needs the additional attribute `get`, where you must specify the state in your ioBroker object list, which has to be read. Additionally you can specify a `unit` as postfix and a `precision` of the decimal places for numbers (rounded).

> Example: Show the temperature -> 21.5°C
> ```json
>   {
>       "type": "text",
>       "get": "adapter.0.channel.device.temperature",
>       "unit": "°C",
>       "precision": "1"
>   }
> ```

The type _icon_ you can use as simple showing indicator, as switch (showing the sate and change it) or as simple command (activate something). The indicator and the switch work only with boolean or similar states. You can control the usage by specifying the attributes `get` and `set` or even not. As switch it needs both attributes, as indicator it needs only `get` and as command it needs only `set`. Depending on the usage you should choose a fitting icon (see [list](#icon-list) below). A switch as well as an indicator should have an icon with the usage _switch_ and a command can have any icon (consider the restrictions described at the [icon list](#icon-list)).  
If you have a similar state to a boolean state, you must configure a mapping. Therefore you have the attributes `true` and `false`. At `true` put in the value for the truly value and at `false` the value for the falsely.  
The command needs additionally the attribute `value`. This attribute contains the value, which has to be sent to the state in ioBroker.

> Example: Switch for a bulb (where the state has the values `on` and `off`) and Command to start a timer
> ```json
>   {
>       "type": "bulb",
>       "color": "#FF9900",
>       "get": "adapter.0.channel.device.state",
>       "set": "adapter.0.channel.device.state",
>       "true": "on",
>       "false": "off"
>   },
>   {
>       "type": "play",
>       "set": "adapter.0.channel.device.timer",
>       "value": "start"
>   }
> ```

The type _state_ is a little bit more complex. You need in any case the attributes `get` and `scopes`. The attribute `get` contains - as you already know - the state in your ioBroker, whose value you want to read. The attribute `scopes` is again an Array with several elements; you can even say the characteristics of the state. So depending on the value of your specified state, one of the _Scopes_ will be shown. Each _Scope_ is more or less like an _Object_. So you must define the attribute `type` here too. This time you have only the choice between a simple text and an icon as indicator (no switch and no command). You can specifiy also a `color` for a _Scope_. Additionally you need at least one of the attributes `value`, `min` or `max`. With `value` you can specify a concrete value of your sate, where the _Scope_ should be active. It overrules the other both attributes, so they are superfluous if you sepcify `value`. With the attributes `min` and `max` you can specify ranges (for numerical values). If one of them is missing, it will be interpreted as endless.

> __Consider:__ The widget checks the _Scopes_ in the specified order; first come, first serve. So if you have an overlap the first fitting _Scope_ wins.

> Example: Show temperature as colored text or icon, if it is too cold or too hot
> ```json
>   {
>       "type": "state",
>       "get": "adapter.0.channel.device.temperature",
>       "scopes": [
>           { /* show snow icon if the temperature is -5 or less */
>               "type": "snow",
>               "color": "#FFFFFF",
>               "max": "-5"
>           },
>           { /* show zero in white (must come first due to overlap with next scope) */
>               "type": "text",
>               "unit": "°C",
>               "precision": "0",
>               "color": "#FFFFFF",
>               "value": "0"
>           },
>           { /* show temperature in blue if it is between -5 and 10 */
>               "type": "text",
>               "unit": "°C",
>               "precision": "1",
>               "color": "#0000FF",
>               "min": "-5",
>               "max": "10"
>           },
>           { /* show temperature in grey if it is between 10 and 20 */
>               "type": "text",
>               "unit": "°C",
>               "precision": "1",
>               "color": "#999999",
>               "min": "10",
>               "max": "20"
>           },
>           { /* show temperature in green if it is between 20 and 30 */
>               "type": "text",
>               "unit": "°C",
>               "precision": "1",
>               "color": "#00FF00",
>               "min": "20",
>               "max": "30"
>           },
>           { /* show temperature in orange if it is between 30 and 40 */
>               "type": "text",
>               "unit": "°C",
>               "precision": "1",
>               "color": "#FF5500",
>               "min": "30",
>               "max": "40"
>           },
>           { /* show alert icon if temperature is higher than 40 */
>               "type": "alert",
>               "color": "#FF0000",
>               "min": "40"
>           }
>       ]
>   }
> ```

### FAQ

> Why do you need a secured signed connection?

Due to some restrictions on the garmin device, you must use https. Otherwise the device refueses the connection.
This is a good thing in general to secure the communication between the garmin device, the garmin Connect Mobile App and your ioBroker server.
Especially when using an authorization concept. But, the connection or in better words the security certificate must be signed from an official organization. You cannot import self signed certificates on the garmin device.

> How can you manage this if your ioBroker is in the local network?

If your IP address from outside is changing periodically (most cases), you need a [dynamic DNS](https://en.wikipedia.org/wiki/Dynamic_DNS) to solve this problem. So you have a static URL redirecting to your network at home. In the standard case your internet router is addressed this way. So you have to manage there a [port forwarding](https://en.wikipedia.org/wiki/Port_forwarding). In the easiest way you simply forward the same port as your simple-api adapter is listening to and of course you must address there your ioBroker server.

> How does it work with the signed certificate?

As already explained you need an official signed certificate. You can use some paid offers to get a certificate or you can use [Let's Encrypt](https://letsencrypt.org). Also ioBroker supports Let's Encrypt. At the generation of the certificates you must consider to use the correct URL, e.g. the URL from your dynamic DNS provider, and that the PC where you use Let's Encrypt from is reachable by this URL (usually on web port: 80). Maybe you need again port forwarding for this. Finally you have the needed certificates you must provide them to your simple-api instance. You need the private key certificate, the public key certificate and maybe also the full chain certificate. Consider also, that the certificates must be updated periodically. Using the guide on the Let's Encrypt web page and using the ioBroker server, where the certificates will be generated, the update process should be no problem.

## Settings of the Widget

There are four settings you can configure in the Garmin Connect Mobile App. The fields with * are mandatory:

1. URL*

    > Put in the URL (incl. port) to your simple-api instance of your ioBroker server, e.g. `https://ioBroker.mydomain.xyz:8088`

    > As default the setting has the URL `http://www.example.com`. This URL triggers a demo setting of _Spaces_ so you can get a look & feel.

2. Definition Object*

    > Specify the object, where you have configured your _Spaces_, e.g. `0_userdata.0.garmin`

3. User

    > Type in a user for authorization (if you have set up your simple-api instance with authorization)

4. Password

    > Provide the password for the user

## Icon List

Take a look in the separate [document](./doc/iconlist.html) with the icon list.

## Open Tasks

- Adapter in ioBroker to create the object with the configuration with a user friendly UI

## License

MIT License

Copyright (c) 2021 [Armin Junge](mailto:armin.junge.81@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.