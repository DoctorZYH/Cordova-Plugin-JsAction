var exec = require('cordova/exec');

exports.connectMQ = function (arg0, success, error) {
    exec(success, error, 'JsAction', 'connectMQ', [arg0]);
};

exports.open = function (arg0, success, error) {
    exec(success, error, 'JsAction', 'open', [arg0]);
};

exports.close = function (arg0, success, error) {
    exec(success, error, 'JsAction', 'close', [arg0]);
};

exports.action = function (arg0, success, error) {
    exec(success, error, 'JsAction', 'action', [arg0]);
};

// 全局
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

// 当前页面
exports.onEventDocument = function (eventId, params) {
    cordova.fireDocumentEvent('JsAction.onEventDocument', {
        eventId: eventId,
        params: params
    });
};
