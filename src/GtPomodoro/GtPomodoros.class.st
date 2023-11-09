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
	^ counter ifNil: [ counter := 1 ]
]

{ #category : #accessing }
GtPomodoros >> counter: anInteger [
	counter := anInteger
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
