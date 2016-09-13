var webpack = require('karma-webpack');
var webpackConfig = require('./webpack.config');
var path = require('path');
var webpackEntryFile = '../spec/javascripts/index.js';
var karmaPreprocessors = {};

karmaPreprocessors[webpackEntryFile] = ['webpack', 'sourcemap'];

webpackConfig.entry = {
  test: path.resolve(__dirname, webpackEntryFile)
};

webpackConfig.devtool = 'inline-source-map';

module.exports = function(config) {
  config.set({
    browsers: ['PhantomJS'],
    port: 9876,
    basePath: '.',
    files: [
      // avoids running tests twice when on watch mode
      { pattern: webpackEntryFile, watched: false, included: true, served: true }
    ],
    preprocessors: karmaPreprocessors,
    frameworks: ['jasmine', 'sinon'],
    plugins: [
      webpack,
      'karma-jasmine',
      'karma-sinon',
      'karma-phantomjs-launcher',
      'karma-chrome-launcher',
      'karma-spec-reporter',
      'karma-sourcemap-loader'
    ],
    reporters: ['spec'],
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: false,
    singleRun: true,
    webpack: webpackConfig,
    webpackMiddleware: {
      noInfo: true
    },
    phantomjsLauncher: {
      exitOnResourceError: false
    }
  });
}