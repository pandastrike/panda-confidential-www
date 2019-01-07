import "coffeescript/register"
import fs from "fs"
import pug from "jstransformer-pug"
import stylus from "jstransformer-stylus"
import webpack from "webpack"
import Path from "path"
import {define, run, glob, read, write,
  extension, copy, transform, watch, serve} from "panda-9000"
import {read as _read, rmr, mkdirp} from "panda-quill"
import {go, map, wait, tee, reject} from "panda-river"
import {match, merge} from "panda-parchment"

import Biscotti from "./biscotti"
import markdown from "./markdown"
import {source, intermediate, target, imagePattern} from "./constants"

define "clean", ->
  rmr target
  rmr intermediate

define "biscotti", Biscotti source, intermediate, target

define "images", ->
  go [
    glob "**/*.{#{imagePattern}}", source
    map copy target
  ]

define "html", ->
  go [
    glob [ "**/*.pug", "!**/components" ], intermediate
    wait map read
    map transform pug, filters: {markdown}
    map extension ".html"
    map write target
  ]

define "css", ->
  go [
    glob [ "**/*.styl", "!**/components" ], intermediate
    wait map read
    map transform stylus, compress: true
    map extension ".css"
    map write target
  ]

define "js", ->
  new Promise (yay, nay) ->
    webpack
      entry: Path.resolve intermediate, "index.coffee"
      mode: "development"
      devtool: "inline-source-map"
      output:
        path: target
        filename: "index.js"
        devtoolModuleFilenameTemplate: (info, args...) ->
          {namespace, resourcePath} = info
          "webpack://#{namespace}/#{resourcePath}"
      module:
        rules: [
          test: /\.coffee$/
          use: [ 'coffee-loader' ]
        ,
          test: /\.js$/
          use: [ "source-map-loader" ]
          enforce: "pre"
        ,
          test: /\.styl$/
          exclude: /styles/
          use: [ "raw-loader", "stylus-loader" ]
        ,
          test: /\.pug$/
          use: [
            loader: "pug-loader"
            options:
              filters: {markdown}
              globals: {markdown}
          ]
        ]
      resolve:
        modules: [
          Path.resolve "node_modules"
        ]
        extensions: [ ".js", ".json", ".coffee" ]
      plugins: [

      ]
      (error, result) ->
        console.error result.toString colors: true
        if error? || result.hasErrors()
          nay error
        else
          fs.writeFileSync "webpack-stats.json",
            JSON.stringify result.toJson()
          yay()

define "build", [ "clean", "biscotti", "html&", "css&", "js&", "images&" ]

define "watch", watch source, -> run "build"

define "server",
  serve target,
    files: extensions: [ "html" ]
    logger: "tiny"
    rewrite: true
    port: 8000

define "default", [ "build", "watch&", "server&" ]
