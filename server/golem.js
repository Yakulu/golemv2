var express = require('express');
var app = express();
app.use(express.static('public'));

var server = app.listen(8043, function () {});
