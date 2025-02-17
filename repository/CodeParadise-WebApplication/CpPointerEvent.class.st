Class {
	#name : #CpPointerEvent,
	#superclass : #CpMouseEvent,
	#instVars : [
		'pointerId',
		'pointerType'
	],
	#category : #'CodeParadise-WebApplication-Events'
}

{ #category : #accessing }
CpPointerEvent >> pointerId [

	^ pointerId
]

{ #category : #accessing }
CpPointerEvent >> pointerId: aNumber [

	pointerId := aNumber
]

{ #category : #accessing }
CpPointerEvent >> pointerType [

	^ pointerType
]

{ #category : #accessing }
CpPointerEvent >> pointerType: aString [

	pointerType := aString
]

{ #category : #printing }
CpPointerEvent >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: ', pointerId: ' ;
		print: self pointerId ;
		nextPutAll: ', pointerType: ' ;
		print: self pointerType
]
