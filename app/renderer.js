const {remote, ipcRenderer} = require('electron')
const {dialog} = remote
const fs = require('fs')
const elm = require('./elm')
const B = require('baconjs')
const {head} = require('ramda')

window.Elm = elm

const app = Elm.App.fullscreen()

const openDialog = () => {
	const paths = dialog.showOpenDialog({
		title: 'Open File'
	})
	const path = paths ? head(paths) : null

	return path ? path : B.never()
}

const loadFile = (path) => {
	return B.combineTemplate({
		content: B.fromNodeCallback(fs.readFile, path),
		path
	})
}

const parse = B.try(({content, path}) => ({content: JSON.parse(content), path}))

const render = B.try(({content, path}) => {
	app.ports.openSynopticoSet.send(content)
	document.title = path
})

const getFilePath = B.try(ev => ev.dataTransfer.files[0].path)

const $onDrop = B.fromEvent(document.body, 'drop')
	.doAction('preventDefault')
	.flatMap(getFilePath)

B.fromBinder(sink => app.ports.error.subscribe(sink))
	.onValue(msg => window.alert(msg))

B.fromEvent(ipcRenderer, 'open-file')
	.flatMap(openDialog)
	.merge($onDrop)
	.flatMap(loadFile)
	.flatMap(parse)
	.flatMap(render)
	.onError(err => window.alert(err.toString()))

B.mergeAll(
	B.fromEvent(document, 'dragover'),
	B.fromEvent(document, 'drop')
).onValue(ev => ev.preventDefault())
