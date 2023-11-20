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
	| pomodoros |
	self ifEmpty: [ ^ aView empty ].
	pomodoros := ((self items groupedBy: [ :each | each start asDate ])
			associations sorted: #key descending)
			collect: [ :each | each key -> (each value sorted: #yourself ascending) ].
	^ aView columnedTree
		title: 'Pomodoros';
		priority: 1;
		items: pomodoros;
		children: [ :each | each isAssociation ifTrue: [ each value ] ifFalse: [ #() ] ];
		column: 'Pomodoros'
			text: [ :each | each isAssociation ifTrue: [ each key asString ] ifFalse: [ each asString ] ];
		column: 'Has Reflection'
			stencil: [ :each | 
				each isAssociation
					ifTrue: [ BlElement new ]
					ifFalse: [ BrCheckbox new
							aptitude: BrGlamorousCheckboxAptitude;
							in: [ :aCheckbox | 
								(each reflection isNil or: [ each reflection = 'nil' ])
									ifTrue: [ aCheckbox uncheck ]
									ifFalse: [ aCheckbox check ].
								aCheckbox ];
							disable ] ];
		expandAll
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
								duration: json duration asDuration;
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
					newValue serializeWithCounter: self counter.
					self counter: self counter + 1 ].
			valueHolder ]
]

{ #category : #accessing }
GtPomodoros >> valueHolder: anObject [
	valueHolder := anObject
]
