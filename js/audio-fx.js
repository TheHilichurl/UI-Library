/**
 * AUDIO FX SYNTHESIZER
 * Synthesizes dynamic sound effects directly in the browser via Web Audio API.
 * Provides micro-audio feedback for clicks, toggles, sliders, and notification popups.
 */

class AudioFxManager {
    constructor() {
        this.ctx = null;
        this.enabled = true;
    }

    init() {
        if (!this.ctx && (window.AudioContext || window.webkitAudioContext)) {
            const AudioCtx = window.AudioContext || window.webkitAudioContext;
            this.ctx = new AudioCtx();
        }
        if (this.ctx && this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
    }

    play(soundType = 'click') {
        if (!this.enabled) return;
        try {
            this.init();
            if (!this.ctx) return;

            const now = this.ctx.currentTime;
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();
            osc.connect(gain);
            gain.connect(this.ctx.destination);

            switch (soundType) {
                case 'cyber':
                    // High-tech electronic chirp
                    osc.type = 'sawtooth';
                    osc.frequency.setValueAtTime(800, now);
                    osc.frequency.exponentialRampToValueAtTime(1400, now + 0.05);
                    osc.frequency.exponentialRampToValueAtTime(400, now + 0.12);
                    gain.gain.setValueAtTime(0.08, now);
                    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.12);
                    osc.start(now);
                    osc.stop(now + 0.12);
                    break;

                case 'retro':
                    // 8-bit bleep
                    osc.type = 'square';
                    osc.frequency.setValueAtTime(440, now);
                    osc.frequency.setValueAtTime(880, now + 0.04);
                    gain.gain.setValueAtTime(0.06, now);
                    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.1);
                    osc.start(now);
                    osc.stop(now + 0.1);
                    break;

                case 'magic':
                    // Sparkle bell chime
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(1046.5, now); // C6
                    osc.frequency.exponentialRampToValueAtTime(2093, now + 0.18);
                    gain.gain.setValueAtTime(0.1, now);
                    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
                    osc.start(now);
                    osc.stop(now + 0.25);
                    break;

                case 'heavy':
                    // Low mechanical thud
                    osc.type = 'triangle';
                    osc.frequency.setValueAtTime(150, now);
                    osc.frequency.exponentialRampToValueAtTime(40, now + 0.15);
                    gain.gain.setValueAtTime(0.12, now);
                    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
                    osc.start(now);
                    osc.stop(now + 0.15);
                    break;

                case 'notify':
                    // Dual tone notification chime
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(587.33, now); // D5
                    osc.frequency.setValueAtTime(880, now + 0.08); // A5
                    gain.gain.setValueAtTime(0.1, now);
                    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.3);
                    osc.start(now);
                    osc.stop(now + 0.3);
                    break;

                case 'click':
                default:
                    // Subtle crisp click
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(1200, now);
                    osc.frequency.exponentialRampToValueAtTime(200, now + 0.03);
                    gain.gain.setValueAtTime(0.05, now);
                    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.03);
                    osc.start(now);
                    osc.stop(now + 0.03);
                    break;
            }
        } catch (e) {
            // Audio context failed or blocked by autoplay policy
        }
    }
}

const AudioFx = new AudioFxManager();

if (typeof module !== 'undefined' && module.exports) {
    module.exports = { AudioFx, AudioFxManager };
}
