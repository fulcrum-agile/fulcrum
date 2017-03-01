require('libs');
require('./extra/jasmine-sinon');
require('./extra/jasmine-jquery');

var context = require.context('.', true, /.+_spec\.js$/);

context.keys().forEach(context);

module.exports = context;