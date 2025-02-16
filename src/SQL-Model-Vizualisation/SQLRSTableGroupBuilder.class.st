Class {
	#name : #SQLRSTableGroupBuilder,
	#superclass : #HSimpleVisualizationBuilder,
	#instVars : [
		'tableBuilder',
		'canvas',
		'sourceGroup',
		'shoudBeCollapsed'
	],
	#category : #'SQL-Model-Vizualisation'
}

{ #category : #accessing }
SQLRSTableGroupBuilder >> build [

	| tablesNode columnNodes |
	tablesNode := self sourceGroup collect: [ :table |
		              | node |
		              node := self tableBuilder shapeFor: table.
		              self shoudBeCollapsed ifTrue: [ node collapse ].
		              node ].
	columnNodes := tablesNode flatCollect: #children.
	columnNodes do: [ :columnNode |
		self extractAssociationFor: columnNode with: columnNodes ].

	rootNode := HNode new.
	rootNode addAll: tablesNode.
	rootNode layout: (RSForceBasedLayout new
			 charge: -500;
			 length: 80;
			 yourself).

	self rootNode: rootNode.
	super build
]

{ #category : #'accessing - defaults' }
SQLRSTableGroupBuilder >> canvasController: aCanvas [

	^ RSCanvasController new
		  noLegend;
		  in: [ :i | 
			  aCanvas newAnimation
				  duration: 500 milliSeconds;
				  onStepDo: [ aCanvas signalUpdate ];
				  when: RSAnimationEndEvent
				  do: [ i zoomToFitInteraction noZoomToFitOnExtendChanged ]
				  for: self.
			  (i interactions at: RSDraggableCanvasInteraction) left.
			  i configuration
				  maxScale: 3;
				  minScale: 0.5
			  "useBasicZoom;" ];
		  yourself
]

{ #category : #accessing }
SQLRSTableGroupBuilder >> collapseAll [
	shoudBeCollapsed := true
]

{ #category : #accessing }
SQLRSTableGroupBuilder >> extractAssociationFor: nodeColumn with: allNodes [

	| ref |
	ref := (nodeColumn rawModel incomingForeignKeyReferences collect: [
		        :foreignRef |
		        foreignRef foreignKeyConstraint ifNotNil: [ :fkConstraint |
			        fkConstraint columnReferences collect: [ :columnReference |
				        columnReference column ] ] ]) flattened.
	nodeColumn dependenciesToNodes:
		(allNodes select: [ :aColumnNode |
			 ref includes: aColumnNode rawModel ])
]

{ #category : #initialization }
SQLRSTableGroupBuilder >> initialize [

	super initialize.
	tableBuilder := SQLRSTableBuilder new.
	shoudBeCollapsed := false
]

{ #category : #accessing }
SQLRSTableGroupBuilder >> shoudBeCollapsed [

	^ shoudBeCollapsed value
]

{ #category : #accessing }
SQLRSTableGroupBuilder >> shoudBeCollapsed: anObject [

	shoudBeCollapsed := anObject
]

{ #category : #accessing }
SQLRSTableGroupBuilder >> sourceGroup [

	^ sourceGroup
]

{ #category : #accessing }
SQLRSTableGroupBuilder >> sourceGroup: anObject [

	sourceGroup := anObject
]

{ #category : #accessing }
SQLRSTableGroupBuilder >> tableBuilder [

	^ tableBuilder
]

{ #category : #accessing }
SQLRSTableGroupBuilder >> tableBuilder: anObject [

	tableBuilder := anObject
]
