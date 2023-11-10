Class {
	#name : #GtPomodoros,
	#superclass : #Object,
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#instVars : [
		'valueHolder',
		'counter'
	],
	#category : #GtPomodoro
}

{ #category : #views }
GtPomodoros class >> gtPomodorosFor: aView [
	<gtView>
	<gtClassView>
	^ aView forward
		title: 'Pomodoros';
		priority: -1;
		object: GtPomodoroSettings default pomodoros;
		view: #gtPomodorosFor:
]

{ #category : #accessing }
GtPomodoros >> add: anItem [
	self valueHolder add: anItem
]

{ #category : #accessing }
GtPomodoros >> addAll: aCollection [
	self valueHolder addAll: aCollection
]

{ #category : #accessing }
GtPomodoros >> counter [
	^ counter
		ifNil: [ self ifEmpty: [ counter := 1 ] ifNotEmpty: [ counter := self size + 1 ] ]
]

{ #category : #accessing }
GtPomodoros >> counter: anInteger [
	counter := anInteger
]

{ #category : #views }
GtPomodoros >> gtPomodorosFor: aView [
	<gtView>
	^ aView explicit
		title: 'Pomodoros';
		priority: 1;
		stencil: [ (BrVerticalPane new
				hMatchParent;
				vFitContent;
				background: Color white;
				addAptitude: BrShadowAptitude new;
				alignCenter;
				addChildren: (self items
						collect: [ :each | (each gtPomodoroFor: GtPhlowView empty) asElement ]))
				asScrollableElement ]
]

{ #category : #initialization }
GtPomodoros >> initialize [
	| folder |
	super initialize.
	folder := '.' asFileReference / #pomodoro.
	(folder exists
		and: [ folder files anySatisfy: [ :aFile | aFile extension = 'json' ] ])
		ifTrue: [ folder files
				select: [ :aFile | aFile extension = 'json' ]
				thenDo: [ :aFile | 
					| json |
					json := NeoJSONObject fromString: aFile contents.
					self items
						add: (GtPomodoro new
								start: json start asDateAndTime;
								duration: json duration asInteger;
								end: json end asDateAndTime;
								goals: json goals;
								reflection: json reflection yourself) ] ]
]

{ #category : #accessing }
GtPomodoros >> items [
	^ items ifNil: [ items := self valueHolder value ]
]

{ #category : #accessing }
GtPomodoros >> valueHolder [
	^ valueHolder
		ifNil: [ valueHolder := (SortedCollection
					sortUsing: [ :aPomodoro | aPomodoro start ] ascending) asValueHolder.
			valueHolder
				whenAddedDo: [ :newValue | 
					| folder |
					folder := ('.' asFileReference / #pomodoro) ensureCreateDirectory.
					folder / self counter asString , 'json'
						writeStreamDo: [ :aStream | STONJSON put: newValue asDictionary onStreamPretty: aStream ].
					self counter: self counter + 1 ].
			valueHolder ]
]

{ #category : #accessing }
GtPomodoros >> valueHolder: anObject [
	valueHolder := anObject
]
