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
