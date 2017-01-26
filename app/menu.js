const {app, Menu} = require('electron')
const B = require('baconjs')

exports.Menu = function() {

	return B.fromBinder(sink => {
		const template = [
			{
				label: 'File',
				submenu: [
					{
						label: 'New Window',
						accelerator: 'CmdOrCtrl+N',
						click: () => sink()
					},
					{
						label: 'Open File...',
						accelerator: 'CmdOrCtrl+O',
						click (_, focusedWindow) {
							if (focusedWindow){
								focusedWindow.webContents.send('open-file')
							} else {
								sink('open-file')
							}
						}
					}
				]
			},
			{
				label: 'View',
				submenu: [
					{
						label: 'Reload',
						accelerator: 'CmdOrCtrl+R',
						click (item, focusedWindow) {
							if (focusedWindow) focusedWindow.reload()
						}
					},
					{
						label: 'Toggle Developer Tools',
						accelerator: process.platform === 'darwin' ? 'Alt+Command+I' : 'Ctrl+Shift+I',
						click (item, focusedWindow) {
							if (focusedWindow) focusedWindow.webContents.toggleDevTools()
						}
					},
					{
						type: 'separator'
					},
					{
						role: 'resetzoom'
					},
					{
						role: 'zoomin'
					},
					{
						role: 'zoomout'
					},
					{
						type: 'separator'
					},
					{
						role: 'togglefullscreen'
					}
				]
			},
			{
				role: 'window',
				submenu: [
					{
						role: 'minimize'
					},
					{
						role: 'close'
					}
				]
			},
			{
				role: 'help',
				submenu: [
					{
						label: 'Learn More',
						click () { require('electron').shell.openExternal('http://electron.atom.io') }
					}
				]
			}
		];

		if (process.platform === 'darwin') {
			template.unshift({
				label: app.getName(),
				submenu: [
					{
						role: 'about'
					},
					{
						type: 'separator'
					},
					{
						role: 'services',
						submenu: []
					},
					{
						type: 'separator'
					},
					{
						role: 'hide'
					},
					{
						role: 'hideothers'
					},
					{
						role: 'unhide'
					},
					{
						type: 'separator'
					},
					{
						role: 'quit'
					}
				]
			});
			// Edit menu.
			template[1].submenu.push(
				{
					type: 'separator'
				},
				{
					label: 'Speech',
					submenu: [
						{
							role: 'startspeaking'
						},
						{
							role: 'stopspeaking'
						}
					]
				}
			);
			// Window menu.
			template[3].submenu = [
				{
					label: 'Close',
					accelerator: 'CmdOrCtrl+W',
					role: 'close'
				},
				{
					label: 'Minimize',
					accelerator: 'CmdOrCtrl+M',
					role: 'minimize'
				},
				{
					label: 'Zoom',
					role: 'zoom'
				},
				{
					type: 'separator'
				},
				{
					label: 'Bring All to Front',
					role: 'front'
				}
			]
		}

		const menu = Menu.buildFromTemplate(template);
		Menu.setApplicationMenu(menu);
	})
};

exports.DockMenu = () => {
	if (app.dock.setMenu) {
		return B.fromBinder(sink => {
			const dockMenu = Menu.buildFromTemplate([
				{label: 'New Window', click: () => sink()},
			])
			app.dock.setMenu(dockMenu)
		})
	} else {
		return B.never()
	}
}
