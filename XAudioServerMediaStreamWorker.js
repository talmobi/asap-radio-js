var XAudioJSBuffer = [];
var output = [];
self.onmessage = function (event) {
	var data = event.data;
	var length = data.length;
	for (var i = 0; i < length; ++i) {
		XAudioJSBuffer.push(data[i]);
	}
}
self.onprocessmedia = function (event) {
	var apiBufferLength = event.audioLength * event.audioChannels;
	var len = Math.min(apiBufferLength, XAudioJSBuffer.length);
	if (apiBufferLength > output.length) {
		output = new Float32Array(apiBufferLength);
	}
	for (var i = 0; i < len; ++i) {
		output[i] = XAudioJSBuffer.shift();
	}
	event.writeAudio(output.subarray(0, apiBufferLength));
	self.postMessage(event.audioLength);
};
