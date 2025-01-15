Class {
	#name : #GtPomodoroSettings,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'durations',
		'duration',
		'goals',
		'recalculationsPerSecond',
		'pomodoros',
		'toolbarIcon',
		'serializeWithLepiter'
	],
	#classVars : [
		'ShowRing',
		'Toolbar'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #GtPomodoro
}

{ #category : #accessing }
GtPomodoroSettings class >> asElement [
	^ self default asElement
]

{ #category : #accessing }
GtPomodoroSettings class >> blocElementId [
	^ #'gt-world--pomodoro'
]

{ #category : #accessing }
GtPomodoroSettings class >> defaultDurations [

	^ #('60' '30' '25' '20' '15' '10' '5' '4' '2' '1')
]

{ #category : #accessing }
GtPomodoroSettings class >> disable [
	self toolbar removeItem: self worldPomodoroElement
]

{ #category : #initialization }
GtPomodoroSettings class >> enable [
	self toolbar addItem: self asElement
]

{ #category : #inspecting }
GtPomodoroSettings class >> gtInspectActionFor: anAction [
	<gtAction>
	<gtClassAction>
	^ anAction button
		icon: BrGlamorousVectorIcons inspect;
		tooltip: 'Default Instance Pomodoros';
		priority: 1;
		action: [ :aButton | aButton phlow spawnObject: self default pomodoros ]
]

{ #category : #view }
GtPomodoroSettings class >> gtPomodorosFor: aView [
<gtClassView>
^ aView forward
	title: 'Pomodoros By Day';
	priority: 11;
	object: self default pomodoros;
	view: #gtPomodorosFor:
]

{ #category : #view }
GtPomodoroSettings class >> gtWeeklySummaryFor: aView [
<gtClassView>
^ aView forward
	title: 'Weekly Summary';
	priority: 10;
	object: self default pomodoros;
	view: #gtWeeklySummaryFor:
]

{ #category : #initialization }
GtPomodoroSettings class >> initialize [
	super initialize.
	self enable
]

{ #category : #initialization }
GtPomodoroSettings class >> restart [
	self disable.
	self cleanUp.
	self enable
]

{ #category : #accessing }
GtPomodoroSettings class >> showRing [
	^ ShowRing ifNil: [ ShowRing := true ]
]

{ #category : #accessing }
GtPomodoroSettings class >> toggleRing [
	ShowRing := ShowRing not
]

{ #category : #initialization }
GtPomodoroSettings class >> toolbar [
	^ Toolbar
		ifNil: [ Toolbar := BlSpace
					spaceWithId: GtWorld defaultId
					do: [ :aSpace | (aSpace topMostParent query // GtWorldSpotterSearchElementId) anyOne parent ] ]
]

{ #category : #accessing }
GtPomodoroSettings class >> worldPomodoroElement [
	^ self toolbar children
		detect: [ :each | each id asSymbol = self blocElementId ]
]

{ #category : #accessing }
GtPomodoroSettings >> asElement [
	^ BrButton new
		id: self class blocElementId;
		size: 48 @ 48;
		label: 'Start a Pomodoro Timer';
		aptitude: BrGlamorousButtonWithIconAptitude - BrGlamorousButtonExteriorAptitude
				+ (BrGlamorousWithDropdownAptitude
						handle: [ BrButton new
								id: self class blocElementId;
								size: 48 @ 48;
								aptitude: BrGlamorousButtonWithIconAptitude - BrGlamorousButtonExteriorAptitude;
								icon: self toolbarIcon ]
						content: [ self asGtMagritteViewModel asElement margin: (BlInsets all: 20) ]);
		icon: self toolbarIcon
]

{ #category : #accessing }
GtPomodoroSettings >> countdownAction [
	| iconTask timeTask timeLeft totalTime |
	totalTime := self duration asInteger * 60.0.
	timeLeft := self duration asInteger * 60.0.
	timeTask := BlRepeatedTaskAction new
			delay: 1 second;
			action: [ self class worldPomodoroElement label: timeLeft asInteger seconds asString ].
	iconTask := BlRepeatedTaskAction new
			delay: (1 / self recalculationsPerSecond) second;
			action: [ timeLeft := timeLeft - (1 / self recalculationsPerSecond).
				timeLeft = 60 ifTrue: [ self osNativeNotify: '1 minute left!' ].
				timeLeft < 60
					ifTrue: [ timeTask isRunning ifTrue: [ timeTask stop ].
						self class worldPomodoroElement
							label: 'You better start wrapping it up!';
							icon: (BlTextElement new
									text: (timeLeft asInteger asRopedText
											foreground: BrGlamorousColors linkWithErrorColor;
											fontSize: 24)) ]
					ifFalse: [ self class worldPomodoroElement
							icon: (self
									countdownTimer: (totalTime - timeLeft) / totalTime
									showRing: self class showRing) ].
				timeLeft = 0
					ifTrue: [ self class toolbar
							enqueueTask: [ iconTask stop.
								self osNativeNotify: 'Time is Up'.
								self class worldPomodoroElement
									icon: self toolbarIcon;
									label: 'Start a Pomodoro Timer';
									enable ] asBlTask ] ].
	self class toolbar enqueueTask: iconTask.
	self class toolbar enqueueTask: timeTask
]

{ #category : #accessing }
GtPomodoroSettings >> countdownTimer: percentComplete showRing: showRing [
	| annulusSectors endAngle |
	endAngle := 360 * percentComplete - 90.
	annulusSectors := {(-90 to: endAngle) -> Color black.
			(endAngle to: 270) -> Color transparent}.
	^ (BlElement new
		addChildren: ((showRing ifTrue: [ annulusSectors ] ifFalse: [ annulusSectors allButLast ])
				collect: [ :each | 
					BlElement new
						geometry: (BlAnnulusSectorGeometry new
								startAngle: each key first;
								endAngle: each key last);
						background: each value;
						border: (BlBorder paint: Color black width: 1);
						constraintsDo: [ :c | 
							c horizontal matchParent.
							c vertical matchParent ] ])) asScalableElement
]

{ #category : #accessing }
GtPomodoroSettings >> createPomodoro: aMemento [
	| start aDuration |
	start := DateAndTime now.
	aDuration := aMemento duration asInteger minutes.
	^ GtPomodoro new
		start: start;
		duration: aDuration;
		goals: aMemento goals;
		yourself
]

{ #category : #accessing }
GtPomodoroSettings >> duration [
	^ duration ifNil: [ duration := '25' ]
]

{ #category : #accessing }
GtPomodoroSettings >> duration: anObject [
	duration := anObject
]

{ #category : #accessing }
GtPomodoroSettings >> durations [
	^ durations ifNil: [ durations := self class defaultDurations ]
]

{ #category : #accessing }
GtPomodoroSettings >> durations: aCollection [
	durations := aCollection
]

{ #category : #accessing }
GtPomodoroSettings >> goals [
	^ goals ifNil: [ goals := '' ]
]

{ #category : #accessing }
GtPomodoroSettings >> goals: anObject [
	goals := anObject
]

{ #category : #accessing }
GtPomodoroSettings >> magritteAcceptAction [
	<magritteActionDescription>
	^ super magritteAcceptAction
		onSuccessCallback: (GtMagritteCallback new
				action: [ :aModel :aButton :aMemento :aDescription | 
					aButton fireEvent: BrDropdownHideWish new.
					self class toolbar
						enqueueTask: (BlDelayedTaskAction new
								delay: 0 milliseconds;
								action: [ self class worldPomodoroElement
										disable;
										icon: (self countdownTimer: 0 showRing: self class showRing).
									self countdownAction ]).
					self pomodoros add: (self createPomodoro: aMemento) ]);
		beAlwaysEnabled
]

{ #category : #accessing }
GtPomodoroSettings >> magritteCancelAction [
	<magritteActionDescription>
	^ super magritteCancelAction
		onSuccessCallback: (GtMagritteCallback new
				action: [ :aModel :aButton :aMemento :aDescription | aButton fireEvent: BrDropdownHideWish new ]);
		beAlwaysEnabled
]

{ #category : #accessing }
GtPomodoroSettings >> osNativeNotify: aString [
	OSPlatform current isLinux
		ifTrue: [ GtExternalProcessBuilder new
				command: 'bash';
				args: {'-c'.
						'notify-send -a "Glamorous Toolkit" -i ~/Downloads/gt.svg "' , aString
							, '" && aplay ~/Documents/Audacity/icq.wav &'};
				spawn ]
]

{ #category : #accessing }
GtPomodoroSettings >> pomodoroDurationDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		label: 'Duration';
		priority: 1;
		accessor: #duration;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		display: [ :aString | 
			aString
				ifNil: [ '25' ]
				ifNotNil: [ aString ifEmpty: [ '25' ] ifNotEmpty: [ aString ] ] ];
		options: self durations
]

{ #category : #accessing }
GtPomodoroSettings >> pomodoroGoalsDescription [
	<magritteDescription>
	^ MAMemoDescription new
		label: 'Goals';
		beOptional;
		priority: 3;
		accessor: #goals;
		editorAptitude: [ BrGlamorousEditableLabelAptitude new glamorousFormEditorCodeFontAndSize ];
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		display: [ :aString | aString  ]
]

{ #category : #accessing }
GtPomodoroSettings >> pomodoroOtherDescription [
	"<magritteDescription>"
	^ MAStringDescription new
		label: 'Other Duration';
		beHidden;
		priority: 2;
		accessor: #duration;
		editorAptitude: [ BrGlamorousEditableLabelAptitude new glamorousFormEditorCodeFontAndSize ];
		display: [ :aString | aString  ]
]

{ #category : #accessing }
GtPomodoroSettings >> pomodoros [
	^ pomodoros ifNil: [ pomodoros := GtPomodoros new ]
]

{ #category : #accessing }
GtPomodoroSettings >> recalculationsPerSecond [
	^ recalculationsPerSecond ifNil: [ recalculationsPerSecond := 1 ]
]

{ #category : #accessing }
GtPomodoroSettings >> recalculationsPerSecond: anInteger [
	"Set how many times per second the percentage completion is redrawn"

	recalculationsPerSecond := anInteger
]

{ #category : #accessing }
GtPomodoroSettings >> serializeWithLepiter [
	^ serializeWithLepiter ifNil: [ serializeWithLepiter := true ]
]

{ #category : #accessing }
GtPomodoroSettings >> serializeWithLepiter: aBoolean [
	serializeWithLepiter := aBoolean
]

{ #category : #accessing }
GtPomodoroSettings >> toolbarIcon [
	^ toolbarIcon
		ifNil: [ toolbarIcon := BrGlamorousVectorIcons timer asElement asScalableElement
					asStencil ]
]

{ #category : #accessing }
GtPomodoroSettings >> toolbarIcon: aStencil [
	toolbarIcon := aStencil
]
