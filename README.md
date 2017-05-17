# Synoptico

Synoptico is a small desktop application that can aggregate multiple websites.
The goal of the project is mainly to get familiar with Elm, Electron and Bacon.js, how they can be
used together and to learn more about functional programming techniques in general. Feedback is very
welcome.

# Usage

1. Create a `json` file describing the URLs to aggregate. The [releases](https://github.com/friegger/synoptico/releases) reference a `sample.json` file with
   the required format.

2. Open the file via the `Open File...` menu entry or just drag it onto the app window. 

# Development

## How to run locally

It has been tested with Node.js 6+.

```
$ npm install
$ npm run elm #-> compiles the Elm code
$ npm start
```

## How to run the tests

```
$ npm install #-> only required once
$ npm test #-> executes the JS and the Elm tests
```


## Building

```
$ cd app
$ npm install
$ cd ..
$ npm run package-linux
$ npm run package-darwin
$ npm run package-windows
```


