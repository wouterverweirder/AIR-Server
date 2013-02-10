const STATE_CONNECT = "connect";
const STATE_CONNECTING = "connecting";
const STATE_PLAY = "play";
const STATE_CALIBRATE = "calibrate";
const STATE_PLAYING = "playing";
const STATE_FINISHED = "finished";

var currentState = STATE_CONNECT;

var mainView;
var connectionView;
var connectedView;
var socket;

var targetRotation = 0;
var rotation = 0;

var lastTimeSent = 0;

var isWinner = false;
var playerName = "";
var myColor = "";

Ext.setup(
        {
            onReady: init
        }
)

function init()
{
    connectionView = new Ext.Panel(
        {
            layout: {
                type: "vbox",
                pack: "center"
            },
            items: [
                {
                    xtype: "form",
                    cls: "connectionForm",
                    items: [
                        {
                            xtype: "fieldset",
                            title: "Connection Settings",
                            items: [
                                {
                                    xtype: "textfield",
                                    id: "ip",
                                    name: "ip",
                                    label: "IP",
                                    value: "127.0.0.1",
                                    required: true,
                                    useClearIcon: true
                                },
                                {
                                    xtype: "textfield",
                                    id: "port",
                                    name: "port",
                                    label: "Port",
                                    value: "1235",
                                    required: true,
                                    useClearIcon: true
                                }
                            ]
                        },
                        {
                            xtype: "button",
                            text: "Connect",
                            handler: connectClickHandler
                        }
                    ]
                }
            ]
        }
    );

    connectedView = new Ext.Panel(
        {
            html:   "<div id='wrapper'>" +
                        "<div id='outer'>" +
                            "<div id='contentwrap'>" +
                                "<div id='content'>" +
                                    "<div id='connected'>" +
                                        "<div id='calibrate'>" +
                                            "<div class='container'>" +
                                                "<div class='background'></div>" +
                                                "<div class='schijf_container'>" +
                                                    "<div id='horizon_ok'></div>" +
                                                    "<div id='horizon_nok'></div>" +
                                                    "<div id='schijf'>" +
                                                        "<div id='lines_ok'></div>" +
                                                        "<div id='lines_nok'></div>" +
                                                    "</div>" +
                                                "</div>" +
                                            "</div>" +
                                        "</div>" +
                                        "<div id='playButton' class='button'>" +
                                            "<div class='background'></div>" +
                                            "<div class='label'>PLAY</div>" +
                                        "</div>" +
                                        "<div id='playingBackground'>" +
                                            "<div id='mySpaceShip'></div>" +
                                            "<div id='playingNameField'></div>" +
                                        "</div>" +
                                        "<div id='winner'></div>" +
                                        "<div id='loser'></div>" +
                                        "<div id='replay' class='button'>" +
                                            "<div class='background'></div>" +
                                            "<div class='label'>PLAY AGAIN</div>" +
                                        "</div>" +
                                    "</div>" +
                                "</div>" +
                            "</div>" +
                        "</div>" +
                    "</div>"
        }
    );

    mainView = new Ext.Panel(
        {
            fullscreen: true,
            layout: "card",
            items: [connectionView, connectedView],
            cls: "mainView"
        }
    );

    Ext.get(Ext.query("body")).on("click", clickHandler, this);
    Ext.get("playButton").on("click", playButtonClickHandler, this);
    Ext.get("replay").on("click", playButtonClickHandler, this);

    //test
    //setCurrentState(STATE_PLAYING);

    //create render loop
    setInterval("renderHandler()", 40);
}

function clickHandler()
{
    switch(currentState)
    {
        case STATE_CALIBRATE:
        case STATE_PLAYING:
            sendMessage("SHOOT");
            break;
    }
}

function setCurrentState(newState)
{
    currentState = newState;

    //visibility booleans
    var connectionPanelVisible = false;
    var playButtonVisible = false;
    var calibrateVisible;
    var playingBackgroundVisible = false;
    var playingNameFieldVisible = false;
    var mySpaceShipVisible = false;
    var winnerVisible = false;
    var loserVisible = false;
    var replayVisible = false;
    switch(currentState)
    {
        case STATE_CONNECT:
            clearSocket();
            connectionPanelVisible = true;
            break;
        case STATE_CONNECTING:
            break;
        case STATE_PLAY:
            playButtonVisible = true;
            break;
        case STATE_CALIBRATE:
            calibrateVisible = true;
            break;
        case STATE_PLAYING:
            playingBackgroundVisible = true;
            playingNameFieldVisible = true;
            mySpaceShipVisible = true;
            break;
        case STATE_FINISHED:
            if(isWinner) winnerVisible = true;
            else loserVisible = true;
            replayVisible = true;
            break;
    }

    if(connectionPanelVisible)
    {
        mainView.setActiveItem(connectionView);
    }
    else
    {
        mainView.setActiveItem(connectedView);
    }

    Ext.get("calibrate").setStyle("display", (calibrateVisible) ? "block" : "none");
    Ext.get("playButton").setStyle("display", (playButtonVisible) ? "block" : "none");
    Ext.get("playingBackground").setStyle("display", (playingBackgroundVisible) ? "block" : "none");
    Ext.get("playingNameField").setStyle("display", (playingNameFieldVisible) ? "block" : "none");
    Ext.get("mySpaceShip").setStyle("display", (mySpaceShipVisible) ? "block" : "none");
    Ext.get("winner").setStyle("display", (winnerVisible) ? "block" : "none");
    Ext.get("loser").setStyle("display", (loserVisible) ? "block" : "none");
    Ext.get("replay").setStyle("display", (replayVisible) ? "block" : "none");

}

function connectClickHandler()
{
    setCurrentState(STATE_CONNECTING);
    clearSocket();
    try
    {
        socket = new WebSocket("ws://" + Ext.getCmp("ip").getValue() + ":" + Ext.getCmp("port").getValue());
        socket.onopen = socketOpenHandler;
        socket.onmessage = socketMessageHandler;
        socket.onclose = socketCloseHandler;
    }
    catch(exception)
    {
        alert("Error: " + exception);
    }
}

function playButtonClickHandler()
{
    joinGame();
}

function clearSocket()
{
    if(socket != null)
    {
        socket.onopen = null;
        socket.onmessage = null;
        socket.onclose = null;
        socket.close();
        socket = null;
    }
}

function socketOpenHandler()
{
    setCurrentState(STATE_PLAY);

    window.ondevicemotion = motionHandler;
}

function socketMessageHandler(message)
{
    var o = JSON.parse(message.data.replace(/[\u0000\u00ff]/g, ''));

    if(o.data != null)
    {
        if(o.data.player != null)
        {
            playerName = o.data.player;
            Ext.get("playingNameField").update(playerName);
        }
        if(o.data.color != null)
        {
            myColor = o.data.color;
            switch(myColor)
            {
                case "red":
                    Ext.get("mySpaceShip").setStyle("background-image", "url(images/red.png)");
                    break;
                case "green":
                    Ext.get("mySpaceShip").setStyle("background-image", "url(images/green.png)");
                    break;
            }
        }
    }
    if(o.command != null)
    {
        switch(o.command)
        {
            case "PLAY":
                setCurrentState(STATE_PLAY)
                break;
            case "WAITING_FOR_CONNECTIONS":
            case "CALIBRATE":
                setCurrentState(STATE_CALIBRATE)
                break;
            case "COUNTING_DOWN":
            case "PLAYING":
                setCurrentState(STATE_PLAYING);
                break;
            case "WIN":
                isWinner = true;
                setCurrentState(STATE_FINISHED);
                break;
            case "LOSE":
                isWinner = false;
                setCurrentState(STATE_FINISHED);
                break;
        }
    }
}

function socketCloseHandler()
{
    setCurrentState(STATE_CONNECT);
}

function joinGame()
{
    //send the join command
    sendMessage("JOIN_SPACESHOOTER");
}

function sendMessage(command, data)
{
    if(socket != null)
    {
        var message = {
            command: command,
            data: data
        }
        socket.send(JSON.stringify(message));
    }
}

function motionHandler(event)
{
    var now = new Date();

    var xFactor = "" + (event.accelerationIncludingGravity.x / 10);
    var yFactor = "" + (event.accelerationIncludingGravity.y / 10);
    var zFactor = "" + (event.accelerationIncludingGravity.z / 10);

    targetRotation = yFactor * 180;
    //only send it every so often...
    if((now.getTime() - lastTimeSent) > 200)
    {
        sendMessage("ACCELEROMETER", {x: yFactor, y:xFactor, z:zFactor});

        lastTimeSent = now.getTime();
    }
}

function renderHandler()
{
    switch(currentState)
    {
        case STATE_CALIBRATE:
        case STATE_PLAYING:
            if(!isNaN(rotation))
            {
                rotation += (targetRotation - rotation) * .3;

                //snap to 0
                if(targetRotation < 10 && targetRotation > -10 && rotation < 10 && rotation > -10)
                {
                    sendMessage("CALIBRATED");
                    Ext.get("schijf").setStyle("-webkit-transform", "rotate(0deg)");
                    Ext.get("horizon_ok").setStyle("display", "block");
                    Ext.get("lines_ok").setStyle("display", "block");
                    Ext.get("horizon_nok").setStyle("display", "none");
                    Ext.get("lines_nok").setStyle("display", "none");
                }
                else
                {
                    Ext.get("schijf").setStyle("-webkit-transform", "rotate(" + Math.round(rotation) + "deg)");
                    Ext.get("horizon_ok").setStyle("display", "none");
                    Ext.get("lines_ok").setStyle("display", "none");
                    Ext.get("horizon_nok").setStyle("display", "block");
                    Ext.get("lines_nok").setStyle("display", "block");
                }
            }
            break;
    }
}