#!/usr/bin/env node
require('coffee-script/register');

var program = require('commander');

program
   .command('pdf-from-path-to-path <fromPath> <toPath>')
   .action(function (fromPath, toPath) {
      require("./src/commands/pdf-from-path-to-path")(fromPath, toPath)
   })

program.parse(process.argv);
