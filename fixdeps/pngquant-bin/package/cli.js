#!/nix/store/q9w5wr11lv7mzlk1rv7sjbvs8j57csxd-nodejs-10.17.0/bin/node
'use strict';
const execa = require('execa');
const m = require('.');

execa(m, process.argv.slice(2), {stdio: 'inherit'});
