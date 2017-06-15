'use strict';

var Caml_obj = require("../../lib/js/caml_obj.js");

var a = [];

var b = [];

Caml_obj.caml_update_dummy(a, /* record */[/* b */b]);

Caml_obj.caml_update_dummy(b, /* record */[/* a */a]);

exports.a = a;
exports.b = b;
/* No side effect */
