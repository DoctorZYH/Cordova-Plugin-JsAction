var exec = require('cordova/exec');

exports.open = function (arg0, success, error) {
    exec(success, error, 'JsAction', 'open', [arg0]);
};

exports.close = function (arg0, success, error) {
    exec(success, error, 'JsAction', 'close', [arg0]);
};

exports.action = function (arg0, success, error) {
    exec(success, error, 'JsAction', 'action', [arg0]);
};

exports.onEvent = function (eventId, params) {
    cordova.fireWindowEvent('JsAction.onEvent', {
        eventId: eventId,
        params: params
    });
};

exports.sendMessage = function (arg0, success, error) {
    exec(success, error, 'JsAction', 'sendMessage', [arg0]);
};

exports.onMqttMessage = function (eventId, params) {
    cordova.fireWindowEvent('JsAction.onMqttMessage', {
        eventId: eventId,
        params: params
    });
};
