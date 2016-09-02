require('./globals');
require('./lib/jquery_plugins');
require('./lib/backbone_plugins');
require('bootstrap-sass');

var Central = require('./central');

$(Central.start);
