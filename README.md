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
