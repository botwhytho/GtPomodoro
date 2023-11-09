Class {
	#name : #GtPomodoroSettings,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'durations',
		'duration',
		'goals',
		'element',
		'recalculationsPerSecond'
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

{ #category : #initialization }
GtPomodoroSettings class >> initialize [
	super initialize.
	self enable
]

{ #category : #accessing }
GtPomodoroSettings class >> showRing [
	^ ShowRing ifNil: [ ShowRing := false ]
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
	"element :=" ^ BrButton new
			id: self class blocElementId;
			size: 48 @ 48;
			label: 'Start a Pomodoro Timer';
			aptitude: BrGlamorousButtonWithIconAptitude - BrGlamorousButtonExteriorAptitude
					+ (BrGlamorousWithDropdownAptitude
							handle: [ BrButton new
									id: self class blocElementId;
									size: 48 @ 48;
									aptitude: BrGlamorousButtonWithIconAptitude - BrGlamorousButtonExteriorAptitude;
									icon: BrGlamorousVectorIcons timer ]
							content: [ self asGtMagritteViewModel asElement
									margin: (BlInsets all: 20) ]);
			icon: BrGlamorousVectorIcons timer.
	"^ element"
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
				self class worldPomodoroElement
					icon: (self
							countdownTimer: (totalTime - timeLeft) / totalTime
							showRing: self class showRing).
				timeLeft = 0
					ifTrue: [ self class toolbar
							enqueueTask: [ timeTask stop.
								iconTask stop.
								self class worldPomodoroElement
									icon: BrGlamorousVectorIcons timer;
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
						geometry: (BlAnnulusSector new
								startAngle: each key first;
								endAngle: each key last);
						background: each value;
						border: (BlBorder paint: Color black width: 1);
						constraintsDo: [ :c | 
							c horizontal matchParent.
							c vertical matchParent ] ])) asScalableElement
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
GtPomodoroSettings >> element [
	^ element
		ifNil: [ element := (self class toolbar query // self class blocElementId) anyOne ]
]

{ #category : #accessing }
GtPomodoroSettings >> element: anObject [
	^ element := anObject
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
				action: [ :aModel "self inform: 'accepted'." :aButton :aMemento :aDescription | 
					aButton fireEvent: BrDropdownHideWish new.
					self class toolbar
						enqueueTask: (BlDelayedTaskAction new
								delay: 0 milliseconds;
								action: [ self class worldPomodoroElement
										disable;
										icon: (self countdownTimer: 0 showRing: self class showRing).
									self countdownAction ]) ]);
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
GtPomodoroSettings >> recalculationsPerSecond [
	^ recalculationsPerSecond ifNil: [ recalculationsPerSecond := 1 ]
]

{ #category : #accessing }
GtPomodoroSettings >> recalculationsPerSecond: anInteger [
	"Set how many times per second the percentage completion is redrawn"

	recalculationsPerSecond := anInteger
]
