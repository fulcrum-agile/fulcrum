require('cloudinary_js/js/jquery.ui.widget');
require('cloudinary_js/js/jquery.iframe-transport');
require('cloudinary_js/js/jquery.fileupload');
require('cloudinary_js');

window.executeAttachinary = function executeAttachinary() {
  $('.attachinary-input').attachinary({ template: $('#attachinary_template').html() });
};

$(executeAttachinary);
