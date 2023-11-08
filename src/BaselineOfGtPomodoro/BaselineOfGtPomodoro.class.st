Class {
	#name : #BaselineOfGtPomodoro,
	#superclass : #BaselineOf,
	#category : #BaselineOfGtPomodoro
}

{ #category : #baseline }
BaselineOfGtPomodoro >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'GtPomodoro'
		]
]
