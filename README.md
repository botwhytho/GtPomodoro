# GtPomodoro
A Pomodoro timer inside Glamorous Toolkit
## Installation

```Smalltalk
[ EpMonitor current
	disableDuring: [ Metacello new
			repository: 'github://botwhytho/GtPomodoro:main/src';
			baseline: 'GtPomodoro';
			load ] ] forkAt: 29 named: #MyGtBlogExport
```

To depend on this package add this to your baseline:

```Smalltalk
spec baseline: 'GtPomodoro' with: [spec repository: 'github://botwhytho/GtPomodoro:main/src']
```

Icon path [data](https://github.com/botwhytho/GtPomodoro/blob/e89cfe214ceba7ce7ab142a4295dd3edf21d4639/src/GtPomodoro/BrGlamorousVectorIcons.extension.st#L10) is made from [this](https://www.onlinewebfonts.com/icon/464077) svg icon which is licensed under CC BY 4.0
