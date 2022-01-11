'use strict';

import spUtils from './Utils';
import spDetector from './detector';

/*
 global ProgressBar
*/

spUtils.$document.ready(() => {

  // progressbar.js@1.0.0 version is used
  // Docs: http://progressbarjs.readthedocs.org/en/1.0.0/

  /*-----------------------------------------------
  |   Progress Circle
  -----------------------------------------------*/
  const progresCircle = $('.progress-circle');
  if (progresCircle.length) {
    progresCircle.each((index, value) => {
      const $this = $(value);
      const options = $this.data('options');

      const bar = new ProgressBar.Circle(value, $.extend({
        color: '#aaa',
        // This has to be the same size as the maximum width to
        // prevent clipping
        strokeWidth: 1.5,
        trailWidth: 1.4,
        easing: 'easeInOut',
        duration: 3000,
        svgStyle: {
          'stroke-linecap': 'round',
          display: 'block',
          width: '100%',
        },
        text: {
          autoStyleContainer: false,
        },
        from: {
          color: '#aaa',
          width: 1,
        },
        to: {
          color: '#333',
          width: 1,
        },
        // Set default step function for all animate calls
        step: (state, circle) => {
          circle.path.setAttribute('stroke', state.color);
          // circle.path.setAttribute('stroke-width', state.width);

          const percentage = Math.round(circle.value() * 100);
          circle.setText(`<span class='value'>${percentage}<b>%</b></span> <span class="pt-2">${options.text}</span>`);
        },
      }, options.css));

      let playProgressTriggered = false;
      const progressCircleAnimation = () => {
        if (!playProgressTriggered) {
          if (spUtils.isScrolledIntoView(value) || spDetector.isPuppeteer) {
            bar.animate(options.progress / 100);
            playProgressTriggered = true;
          }
        }
        return playProgressTriggered;
      };
      progressCircleAnimation();
      spUtils.$window.scroll(() => {
        progressCircleAnimation();
      });
    });
  }

  /*-----------------------------------------------
  |   Progress Line
  -----------------------------------------------*/
  const progressLine = $('.progress-line');
  if (progressLine.length) {
    progressLine.each((index, value) => {
      const $this = $(value);
      const options = $this.data('options');

      const bar = new ProgressBar.Line(value, $.extend({
        strokeWidth: 1,
        easing: 'easeInOut',
        duration: 3000,
        color: '#333',
        trailColor: '#eee',
        trailWidth: 1,
        svgStyle: {
          width: '100%',
          height: '0.25rem',
          'stroke-linecap': 'round',
          'border-radius': '0.125rem',
        },
        text: {
          style: { transform: null },
          autoStyleContainer: false,
        },
        from: { color: '#aaa' },
        to: { color: '#111' },
        step(state, line) {
          line.setText(`<span class='value'>${Math.round(line.value() * 100)}<b>%</b></span> <span>${options.text}</span>`);
        },
      }, options.css));
      let playProgressTriggered = false;
      const progressLineAnimation = () => {
        if (!playProgressTriggered) {
          if (spUtils.isScrolledIntoView(value) || spDetector.isPuppeteer) {
            bar.animate(options.progress / 100);
            playProgressTriggered = true;
          }
        }
        return playProgressTriggered;
      };
      progressLineAnimation();
      spUtils.$window.scroll(() => {
        progressLineAnimation();
      });
    });
  }
});
