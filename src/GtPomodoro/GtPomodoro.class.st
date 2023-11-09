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
