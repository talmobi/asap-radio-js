package {
	import flash.media.Sound;
	import flash.events.SampleDataEvent;
	import flash.display.Sprite;
    import flash.external.ExternalInterface;
    public class XAudioJS extends Sprite {
        public var sound:Sound = null;
		public var bufferAmount:int = 2500;
		public var bufferTotal:int = 5000;
		public var channel1Buffer:Array = new Array(4096);
		public var channel2Buffer:Array = new Array(4096);
		public var channels:int = 0;
		public var sampleRate:Number = 0;
		public var defaultNeutralLevel:Number = 0;
		public var sampleFramesFound:int = 0;
        public function XAudioJS() {
			ExternalInterface.addCallback('initialize',  initialize);
        }
		//Initialization function for the flash backend of XAudioJS:
        public function initialize(channels:Number, bufferingTotal:Number, defaultNeutralLevel:Number):void {
			//Initialize the new settings:
			this.channels = (int(channels) == 2) ? 2 : 1;
			this.bufferAmount = Math.min(Math.max(int(bufferingTotal - (bufferingTotal % this.channels)), 2048), 4096);
			this.bufferTotal = this.bufferAmount << 1;
			this.defaultNeutralLevel = Math.min(Math.max(defaultNeutralLevel, -1), 1);
			this.checkForSound();
		}
		//Calls the JavaScript function responsible for the polyfill:
		public function requestSamples():Boolean {
			var rawBuffer:String = ExternalInterface.call("audioOutputFlashEvent", " ");
			if (rawBuffer !== null) {
				var buffer:Array = rawBuffer.split(" ");
				this.sampleFramesFound = Math.min(buffer.length, this.bufferTotal) >> (this.channels - 1);
				if ((buffer.length % this.channels) == 0) {	//Outsmart bad programmers from messing us up. :/
					var index:int = 0;
					if (this.channels == 2) {
						for (; index < this.sampleFramesFound; index++) {
							this.channel1Buffer[index] = Math.min(Math.max(Number(buffer[index]) / 0x1869F, -1), 1);
							this.channel2Buffer[index] = Math.min(Math.max(Number(buffer[index + this.sampleFramesFound]) / 0x1869F, -1), 1);
						}
					}
					else {
						for (; index < this.sampleFramesFound; index++) {
							this.channel1Buffer[index] = Math.min(Math.max(Number(buffer[index]) / 0x1869F, -1), 1);
						}
					}
					return true;
				}
			}
			return false;
		}
		//Check to make sure the audio stream is enabled:
		public function checkForSound():void {
			if (this.sound == null) {
				this.sound = new Sound(); 
				this.sound.addEventListener(
					SampleDataEvent.SAMPLE_DATA,
					soundCallback
				);
				this.sound.play();
            }
		}
		//Flash Audio Refill Callback
        public function soundCallback(e:SampleDataEvent):void {
			var index:int = 0;
			if (this.requestSamples()) {
				if (this.channels == 2) {
					//Stereo:
					while (index < this.sampleFramesFound) {
						e.data.writeFloat(this.channel1Buffer[index]);
						e.data.writeFloat(this.channel2Buffer[index++]);
					}
				}
				else {
					//Mono:
					while (index < this.sampleFramesFound) {
						e.data.writeFloat(this.channel1Buffer[index]);
						e.data.writeFloat(this.channel1Buffer[index++]);
					}
				}
			}
			//Write silence if no samples are found:
			while (++index <= 2048) {
				e.data.writeFloat(this.defaultNeutralLevel);
				e.data.writeFloat(this.defaultNeutralLevel);
			}
        }
    }
}