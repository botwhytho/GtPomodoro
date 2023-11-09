Class {
	#name : #GtPomodoroSettings,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'durations',
		'duration',
		'goals',
		'element'
	],
	#classVars : [
		'Toolbar'
	],
	#category : #GtPomodoro
}

{ #category : #accessing }
GtPomodoroSettings class >> asElement [
	^ self default asElement
]

{ #category : #accessing }
GtPomodoroSettings class >> defaultDurations [

	^ #('60' '30' '25' '20' '15' '10' '5' '1' "'Other'")
]

{ #category : #initialization }
GtPomodoroSettings class >> initialize [
	super initialize.
	self toolbar addItem: self asElement
]

{ #category : #initialization }
GtPomodoroSettings class >> toolbar [
	^ Toolbar
		ifNil: [ Toolbar := BlSpace
					spaceWithId: GtWorld defaultId
					do: [ :aSpace | (aSpace topMostParent query // GtWorldSpotterSearchElementId) anyOne parent ] ]
]

{ #category : #accessing }
GtPomodoroSettings >> asElement [
	element := BrButton new.
	element
		id: #gtPomodoro;
		size: 48 @ 48;
		label: 'Start a Pomodoro Timer';
		aptitude: BrGlamorousButtonWithIconAptitude - BrGlamorousButtonExteriorAptitude
				+ (BrGlamorousWithDropdownAptitude
						handle: [ BrButton new
								size: 48 @ 48;
								aptitude: BrGlamorousButtonWithIconAptitude - BrGlamorousButtonExteriorAptitude;
								icon: BrGlamorousVectorIcons timer ]
						content: [ self asGtMagritteViewModel asElement margin: (BlInsets all: 20) ]);
		icon: BrGlamorousVectorIcons timer.
	^ element
]

{ #category : #accessing }
GtPomodoroSettings >> countdownAction [
	| iconTask timeTask timeLeft totalTime |
	totalTime := self duration * 60.
	timeLeft := self duration * 60.
	timeTask := BlRepeatedTaskAction new
			delay: 1 second;
			action: [ self element label: timeLeft asInteger seconds asString ].
	iconTask := BlRepeatedTaskAction new
			delay: 0.25 second;
			action: [ timeLeft := timeLeft - 0.25.
				self element
					icon: (self countdownTimer: (totalTime - timeLeft) / totalTime showRing: false).
				timeLeft = 0
					ifTrue: [ self inform: 'Stopped'.
						timeTask stop.
						iconTask stop.
						self element
							icon: BrGlamorousVectorIcons timer;
							label: 'Start a Pomodoro Timer' ] ].
	self element enqueueTask: iconTask.
	self element enqueueTask: timeTask
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
						when: BlClickEvent doOnce: [ :e | e target phlow spawnObject: each key ];
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
					self element
						disable;
						icon: (self countdownTimer: 0 showRing: false).
					self countdownAction ]);
		beAlwaysEnabled
]

{ #category : #accessing }
GtPomodoroSettings >> magritteCancelAction [
	<magritteActionDescription>
	^ super magritteCancelAction
		onSuccessCallback: (GtMagritteCallback new
				action: [ :aModel :aButton :aMemento :aDescription | 
					self inform: 'Cancelled'.
					aButton fireEvent: BrDropdownHideWish new ]);
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
