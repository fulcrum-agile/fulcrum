window.$ = window.jQuery = require('jquery');
window.I18n = require('i18n-js');
window._ = require('underscore');

var Markdown = require('vendor/Markdown.Converter');
window.md = new Markdown.Converter();

window.Chart = require('chart.js');
window.Chartkick = require('chartkick');
