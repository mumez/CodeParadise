"
I am the base class for Events. I also implement the same protocol as the Announcement class for announcing. 

Implementation:
My class name should match the browser's event type (Event.type, see https://wiki.developer.mozilla.org/en-US/docs/Web/API/Event/type). So event type ""pointermove"" did become CpPointerMoveEvent. The class name prefix #Cp and the class name postfix #Event are discarded for comparison. Please prevent having similar names like #CpPointerMove or #CpPointermoveEvent, because only one will be used (more specific, last being installed in the ClientEnvironment).

Beware: CpPointerEnterEvent and CpPointerLeaveEvent work slightly differently than expected. These can only be used on the <body> tag.

"
Class {
	#name : #CpEvent,
	#superclass : #Object,
	#instVars : [
		'type',
		'timeStamp',
		'target',
		'elements',
		'currentElementIndex'
	],
	#category : #'CodeParadise-WebApplication-Events'
}

{ #category : #'processing - private' }
CpEvent class >> addListenerTo: anElement [

	<primitive: 'primitiveEventAddListenerTo:' module: 'CpDOMPlugin'>
	self primitiveFailed
]

{ #category : #'accessing - modifiers' }
CpEvent class >> altModifier [

	^ 1
]

{ #category : #'processing - private' }
CpEvent class >> createEventProcess [

	"Create an event process, register it and start it"

	| eventProcess |

	"Create process with highest priority to handle events as fast as possible"
	eventProcess := Process
		forContext: [ [

			"Wait for events to become available"
			Processor activeProcess suspend.

			"Dispatch the events"
			self dispatchEvents ] repeat ] asContext
		priority: Processor highestPriority.

	"Register the event process so the VM (plugin) can activate it"
	self registerEventProcess: eventProcess.

	"Start the process (which will actually put it to sleep waiting for the first event)"
	eventProcess resume
]

{ #category : #'accessing - modifiers' }
CpEvent class >> ctrlAltModifier [

	^ self ctrlModifier + self altModifier
]

{ #category : #'accessing - modifiers' }
CpEvent class >> ctrlModifier [

	^ 2
]

{ #category : #'accessing - modifiers' }
CpEvent class >> ctrlShiftModifier [

	^ self ctrlModifier + self shiftModifier
]

{ #category : #'processing - private' }
CpEvent class >> dispatchEvent: anEvent [

	[ anEvent dispatch ] on: Error do: [ :error |
		self crError: 'Error when handling event ', anEvent printString.
		self crError: error description.
		self crError: error signalerContext printString ]
]

{ #category : #'processing - private' }
CpEvent class >> dispatchEvents [

	"Handle events.
	
	Implementation:
	Try to prevent long running synchronous calls for performance (jitter/yank in UI)."

	self latestEvents do: [ :each | self dispatchEvent: each ]
]

{ #category : #announcing }
CpEvent class >> handlesAnnouncement: anAnnouncement [

	"The receiver acts as a filter to determine whether subscribers who used the receiver as signaling tag (event identifier class or symbol)
	should receive incoming announcement. In particular, registering to a superclass will receive the announcements from all subclasses.
	See Announcement >> #handlesAnnouncement:"

	^ anAnnouncement class includesBehavior: self
]

{ #category : #'processing - private' }
CpEvent class >> isListenedToOn: anElement [

	<primitive: 'primitiveEventIsListenedToOn:' module: 'CpDOMPlugin'>
	self primitiveFailed
]

{ #category : #'processing - private' }
CpEvent class >> latestEvents [

	<primitive: 'primitiveEventLatestEvents' module: 'CpDOMPlugin'>
	^ #()

]

{ #category : #'accessing - modifiers' }
CpEvent class >> metaCtrlAltModifier [

	^ self metaModifier + self ctrlModifier + self altModifier
]

{ #category : #'accessing - modifiers' }
CpEvent class >> metaModifier [

	^ 4
]

{ #category : #accessing }
CpEvent class >> point: aPoint isSimilarTo: otherPoint [

	| distance |

	distance := aPoint dist: otherPoint.

	^ distance < self similarDistance
]

{ #category : #'class initialization' }
CpEvent class >> postInstall [

	super postInstall.

	self registerEventClass: self forType: self type
]

{ #category : #'class initialization' }
CpEvent class >> postInstallOnce [

	"Create the event handler process once"

	self createEventProcess

]

{ #category : #'processing - private' }
CpEvent class >> registerEventClass: anEventClass forType: aString [

	<primitive: 'primitiveEventRegisterClass:forType:' module: 'CpDOMPlugin'>
	self primitiveFailed

]

{ #category : #'processing - private' }
CpEvent class >> registerEventProcess: eventHandlerProcess [

	<primitive: 'primitiveEventRegisterProcess:' module: 'CpDOMPlugin'>
	self primitiveFailed

]

{ #category : #'accessing - modifiers' }
CpEvent class >> shiftModifier [

	^ 8
]

{ #category : #accessing }
CpEvent class >> similarDistance [

	^ 8
]

{ #category : #accessing }
CpEvent class >> type [

	"Answer the Javascript type (a String) representing the receiver"

	^ (self nameWithoutPrefix withoutSuffix: #Event) asLowercase
]

{ #category : #announcing }
CpEvent >> asAnnouncement [

	^ self
]

{ #category : #testing }
CpEvent >> autoPropagate [

	^ false
]

{ #category : #accessing }
CpEvent >> currentElement [

	"Answer the current (targetted) DOM element (similar to the DOM's currentTarget).
	Answer nil if the receiver has been dispatched to all interested elements."

	^ self elements at: currentElementIndex ifAbsent: [ nil ]
]

{ #category : #dispatching }
CpEvent >> dispatch [

	"Dispatch the receiver by announcing it through its element"

	(self currentElement ifNil: [ ^ self ])
		announce: self.

	"Propagate (bubble up to top level) to next interested element"
	self autoPropagate
		ifTrue: [ self propagate ]
]

{ #category : #accessing }
CpEvent >> elements [

	"Answer the DOM elements (from descendant to ancestor) which are interested in the event.
	This might be different than the target which received the event."

	^ elements
]

{ #category : #accessing }
CpEvent >> elements: anArray [

	elements := anArray
]

{ #category : #testing }
CpEvent >> hasAllModifiers: anInteger [

	"Answer whether the receiver has at least the specified modifiers.

	Can be used to validate specific combinations.
	Example: To check if at least shift and ctrl are pressed:
		keyEvent hasAllModifiers: CpKeyEvent shiftModifier + CpKeyEvent ctrlModifier"

	^ (self modifiers bitAnd: anInteger) = anInteger
]

{ #category : #testing }
CpEvent >> hasAltModifier [

	^ (self modifiers bitAnd: self class altModifier) ~= 0
]

{ #category : #testing }
CpEvent >> hasBubbled [

	^ currentElementIndex > 1
]

{ #category : #testing }
CpEvent >> hasCtrlModifier [

	^ (self modifiers bitAnd: self class ctrlModifier) ~= 0
]

{ #category : #testing }
CpEvent >> hasExactModifiers: anInteger [

	"Answer whether the receiver has the exact specified modifiers.

	Can be used to validate specific combinations.
	Example: To check if only shift and ctrl are pressed:
		keyEvent hasExactModifiers: CpKeyEvent shiftModifier + CpKeyEvent ctrlModifier"

	^ self modifiers = anInteger
]

{ #category : #testing }
CpEvent >> hasMetaModifier [

	^ (self modifiers bitAnd: self class metaModifier) ~= 0
]

{ #category : #testing }
CpEvent >> hasModifiers [

	^ self modifiers ~= 0
]

{ #category : #testing }
CpEvent >> hasNoModifiers [

	^ self modifiers = 0
]

{ #category : #testing }
CpEvent >> hasSameOrigin: anEvent [

	"Answer whether the receiver and the specified Event share the same origin.

	Implementation:
	The same origin is shared if the event is targetted to the same DOM element and
	has the same timestamp of occurrence."

	^ self target = anEvent target and: [ self timeStamp = anEvent timeStamp ]
]

{ #category : #testing }
CpEvent >> hasShiftModifier [

	^ (self modifiers bitAnd: self class shiftModifier) ~= 0
]

{ #category : #testing }
CpEvent >> hasSomeModifiers: anInteger [

	"Answer whether the receiver has at least one the specified modifiers.

	Can be used to validate specific combinations.
	Example: To check if at least one of shift or ctrl is pressed (i.e. or both are pressed):
		keyEvent hasSomeModifiers: CpKeyEvent shiftModifier + CpKeyEvent ctrlModifier"

	^ (self modifiers bitAnd: anInteger) ~= 0
]

{ #category : #initialization }
CpEvent >> initialize [

	super initialize.

	"By default start at the first element of the elements
	(in #currentElement it is validated a first element exists)"
	elements := #().
	currentElementIndex := 1
]

{ #category : #testing }
CpEvent >> modifiers [

	"Answer the key modifiers of the receiver.

	Implementation: Only Key, Pointer and Drag events support this at the moment."

	^ 0
]

{ #category : #copying }
CpEvent >> postCopy [

	"Create a full copy of the receiver without shared state, to allow the copy to be dispatched
	or propagated without influencing the (original) receiver"

	super postCopy.

	"Implementation: Only elements need to be 'deep' copied, other fields can be shared."
	elements := elements copy
]

{ #category : #announcing }
CpEvent >> prepareForDelivery [

	"This method will be executed once before subscriptions delivery.
	If nobody subscribed on me this method will not be called.
	It allows to put some heavy initialization logic here. It will be executed only 
	if there is interest on me
	See Announcement >> #prepareForDelivery"
]

{ #category : #'dispatching - private' }
CpEvent >> preventDefault [

	<primitive: 'primitiveEventPreventDefault' module: 'CpDOMPlugin'>
	self primitiveFailed

]

{ #category : #printing }
CpEvent >> printOn: aStream [

	aStream
		nextPutAll: self class name ;
		nextPutAll: ', type: ' ;
		print: self type ;
		nextPutAll: ', timeStamp: ' ;
		print: self timeStamp ;
		nextPutAll: ', target: ' ;
		print: self target ;
		nextPutAll: ', currentElement: ' ;
		print: self currentElement
]

{ #category : #dispatching }
CpEvent >> propagate [

	"Propagate the receiver to the next interested element"

	currentElementIndex > self elements size
		ifTrue: [ ^ self ].

	currentElementIndex := currentElementIndex + 1.
	self dispatch
]

{ #category : #dispatching }
CpEvent >> redispatch [

	"Dispatch the receiver again (any current propagation is ignored)"

	self
		reset ;
		dispatch
]

{ #category : #dispatching }
CpEvent >> reset [

	"Reset the receiver to allow dispatching again (from the deepest DOM element)"

	currentElementIndex := 1
]

{ #category : #dispatching }
CpEvent >> stopPropagation [

	"Stop propagation (bubbling) of the receiver"

	currentElementIndex := self elements size
]

{ #category : #accessing }
CpEvent >> target [

	"Answer the DOM element which received the event.
	In contrast with regular browser events, this target
	might be part of a shadow DOM."

	^ target
]

{ #category : #accessing }
CpEvent >> target: aDomElement [

	target := aDomElement
]

{ #category : #accessing }
CpEvent >> timeStamp [

	"Answer the relative timestamp (an Integer in millisecond resolution) for when the receiver was triggered"

	^ timeStamp
]

{ #category : #accessing }
CpEvent >> timeStamp: aNumber [

	"Set the relative timestamp for when the receiver was triggered"

	timeStamp := aNumber
]

{ #category : #accessing }
CpEvent >> type [

	^ type
]

{ #category : #accessing }
CpEvent >> type: aString [

	type := aString
]
