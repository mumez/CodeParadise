"
I am a Key(board) Event. I offer an interface to low level key press and release events.
For text entry please also have a look at InputEvent.

I have a slightly different behavior than the browser variant. For the space(bar) key I answer #Space as key value instead of ' '. This is to be more consistent across whitespace characters like #Tab and #Backspace.

"
Class {
	#name : #CpKeyEvent,
	#superclass : #CpUserInterfaceEvent,
	#instVars : [
		'modifiers',
		'key',
		'repeat',
		'isComposing'
	],
	#category : #'CodeParadise-WebApplication-Events'
}

{ #category : #accessing }
CpKeyEvent >> isComposing [

	^ isComposing
]

{ #category : #accessing }
CpKeyEvent >> isComposing: aBoolean [

	isComposing := aBoolean
]

{ #category : #accessing }
CpKeyEvent >> key [

	^ key = ' '
		ifTrue: [ #Space ]
		ifFalse: [ key ]

]

{ #category : #accessing }
CpKeyEvent >> key: aString [

	key := aString
]

{ #category : #accessing }
CpKeyEvent >> keyWithModifiers [

	"Answer a String representing the receiver's key with modifiers prepended"

	self key ifNil: [ ^ nil ].
	(self key size = 1 or: [ self hasModifiers not ])
		ifTrue: [ ^ self key ].

	^ String streamContents: [ :stream |
		self hasAltModifier
			ifTrue: [ stream nextPutAll: 'A-' ].
		self hasCtrlModifier
			ifTrue: [ stream nextPutAll: 'C-' ].
		self hasMetaModifier
			ifTrue: [ stream nextPutAll: 'M-' ].
		self hasShiftModifier
			ifTrue: [ stream nextPutAll: 'S-' ].
		stream nextPutAll: self key ]
]

{ #category : #accessing }
CpKeyEvent >> modifiers [

	"Answer an Integer specifying the different modifiers pressed.
	Combine the following individual numbers:
		1 - alt
		2 - ctrl
		4 - meta
		8 - shift"

	^ modifiers
]

{ #category : #accessing }
CpKeyEvent >> modifiers: anInteger [

	modifiers := anInteger
]

{ #category : #printing }
CpKeyEvent >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: ', modifiers: ' ;
		print: self modifiers ;
		nextPutAll: ', key: ' ;
		print: self key ;
		nextPutAll: ', repeat: ' ;
		print: self repeat ;
		nextPutAll: ', isComposing: ' ;
		print: self isComposing
]

{ #category : #accessing }
CpKeyEvent >> repeat [

	^ repeat
]

{ #category : #accessing }
CpKeyEvent >> repeat: aBoolean [

	repeat := aBoolean
]
