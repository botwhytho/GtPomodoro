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
	^ 'gt-world--pomodoro'
]

{ #category : #accessing }
GtPomodoroSettings class >> defaultDurations [

	^ #('60' '30' '25' '20' '15' '10' '5' '1' "'Other'")
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

{ #category : #initialization }
GtPomodoroSettings class >> toolbar [
	^ BlSpace
		spaceWithId: GtWorld defaultId
		do: [ :aSpace | (aSpace topMostParent query // GtWorldSpotterSearchElementId) anyOne parent ]
]

{ #category : #accessing }
GtPomodoroSettings class >> worldPomodoroElement [
	^ (self toolbar query // self blocElementId) anyOne
]

{ #category : #accessing }
GtPomodoroSettings >> asElement [
	element := BrButton new
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
	^ element
]

{ #category : #accessing }
GtPomodoroSettings >> countdownAction [
	| iconTask timeTask timeLeft totalTime |
	totalTime := self duration asInteger * 60.
	timeLeft := self duration asInteger * 60.
	timeTask := BlRepeatedTaskAction new
			delay: 1 second;
			action: [ self class worldPomodoroElement label: timeLeft asInteger seconds asString ].
	iconTask := BlRepeatedTaskAction new
			delay: 0.25 second;
			action: [ timeLeft := timeLeft - 0.25.
				self class worldPomodoroElement
					icon: (self countdownTimer: (totalTime - timeLeft) / totalTime showRing: false).
				timeLeft = 0
					ifTrue: [ self inform: 'Stopped'.
						timeTask stop.
						iconTask stop.
						self class worldPomodoroElement
							icon: BrGlamorousVectorIcons timer;
							label: 'Start a Pomodoro Timer' ] ].
	self class worldPomodoroElement enqueueTask: iconTask.
	self class worldPomodoroElement enqueueTask: timeTask
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
					aButton
						enqueueTask: [ self class worldPomodoroElement
								disable;
								icon: (self countdownTimer: 0 showRing: false).
							self countdownAction ] asBlTask ]);
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
