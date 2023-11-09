Class {
	#name : #GtPomodoro,
	#superclass : #Object,
	#instVars : [
		'start',
		'end',
		'duration',
		'goals',
		'reflection'
	],
	#category : #GtPomodoro
}

{ #category : #accessing }
GtPomodoro >> asDictionary [
	^ (self class slots
		collect: [ :each | 
			each name
				-> ((self perform: each name)
						in: [ :aValue | (aValue isKindOf: Number) ifTrue: [ aValue ] ifFalse: [ aValue asString ] ]) ])
		asDictionary
]

{ #category : #accessing }
GtPomodoro >> displayPomodoro [
	^ (BrVerticalPane new
		exact: 600 @ 300;
		aptitude: BrShadowAptitude;
		margin: (BlInsets all: 6);
		background: Color white;
		addChildren: {BrHorizontalPane new alignCenter
					background: Color white;
					aptitude: BrGlamorousEditorAptitude + BrShadowAptitude;
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical matchParent ];
					margin: (BlInsets all: 20);
					addChildren: {BrLabel new
								margin: (BlInsets all: 10);
								aptitude: BrGlamorousLabelAptitude;
								text: 'Start: '.
							BrButton new
								margin: (BlInsets all: 10);
								aptitude: BrGlamorousButtonWithLabelAptitude;
								label: self start printToSeconds.
							BrLabel new
								margin: (BlInsets all: 10);
								aptitude: BrGlamorousLabelAptitude;
								text: 'Duration: '.
							BrButton new
								margin: (BlInsets all: 10);
								aptitude: BrGlamorousButtonWithLabelAptitude;
								label: self duration asString.
							BrLabel new
								margin: (BlInsets all: 10);
								aptitude: BrGlamorousLabelAptitude;
								text: 'End: '.
							BrButton new
								margin: (BlInsets all: 10);
								aptitude: BrGlamorousButtonWithLabelAptitude;
								label: self end printToSeconds}.
				BrLabel new
					margin: (BlInsets all: 10);
					aptitude: BrGlamorousLabelAptitude;
					text: 'Goals:'.
				BrEditor new
					background: Color white;
					aptitude: BrGlamorousEditorAptitude + BrShadowAptitude;
					margin: (BlInsets all: 20);
					beReadOnlyWithSelection;
					text: self goals.
				BrLabel new
					margin: (BlInsets all: 10);
					aptitude: BrGlamorousLabelAptitude;
					text: 'Reflections:'.
				BrEditableLabel new
					margin: (BlInsets all: 10);
					aptitude: BrGlamorousEditableLabelAptitude;
					text: (self reflection ifNil: [ '' ]);
					when: BrEditorAcceptWish
						do: [ :aWish | self reflection: aWish text asString ]}) asStencil
]

{ #category : #accessing }
GtPomodoro >> duration [
	^ duration
]

{ #category : #accessing }
GtPomodoro >> duration: anObject [
	duration := anObject
]

{ #category : #accessing }
GtPomodoro >> end [
	^ end
]

{ #category : #accessing }
GtPomodoro >> end: anObject [
	end := anObject
]

{ #category : #accessing }
GtPomodoro >> goals [
	^ goals
]

{ #category : #accessing }
GtPomodoro >> goals: anObject [
	goals := anObject
]

{ #category : #accessing }
GtPomodoro >> gtPomodoroFor: aView [
	<gtView>
	^ aView explicit
		title: 'Summary';
		priority: 1;
		stencil: self displayPomodoro
]

{ #category : #accessing }
GtPomodoro >> reflection [
	^ reflection
]

{ #category : #accessing }
GtPomodoro >> reflection: anObject [
	reflection := anObject
]

{ #category : #accessing }
GtPomodoro >> start [
	^ start
]

{ #category : #accessing }
GtPomodoro >> start: anObject [
	start := anObject
]
