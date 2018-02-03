try (closeRolloutFloater RolloutFloater_main) catch()
W = 150 --Width
H = 100 --Height
minThick = 0.7 --Minimum wall thickness
dispStrength = 2 --How much the face is going to be displaced by the bitmap
bendAngle = 0 -- degrees
tessIter = 8 --resolution 10 takes some time
dispBitMap = undefined
dispBitMap = openBitMap "F:\Dropbox\Camera Uploads\2017-03-05 10.39.34.jpg"
-- dispBitMap = selectBitMap caption:"Select a picture"
bitmapChosen = false
aspectRatio = 0.0 -- Compute the W and H later

plane1 = undefined --global
plane2 = undefined --global

fn CreateFrontPlane =
(
	plane1 = Plane length:H  width:W transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0]) isSelected:on lengthsegs:1 widthsegs:1
	p=convertToPoly ( plane1)
	subobjectLevel = 4
	$.EditablePoly.SetSelection #Face #{1}
	for i = 1 to tessIter do
	(
		$.EditablePoly.tessellate #Face
	)

)

fn DisplaceImage = 
(
	displace1 = Displace ()
	modPanel.addModToSelection (displace1) ui:on
		
	displace1.bitmap = dispBitMap
	displace1.strength = -dispStrength -- A negative displacement will make a positive lithophane (Dark areas thick and thick areas thin)
	displace1.lumCenterEnable = on
	displace1.lumCenter = 1

)

fn ExtrudeFrontFace = 
(
	p=convertToPoly ( plane1)
	subobjectLevel = 3
	$.EditablePoly.SetSelection #Edge ((polyOp.getOpenEdges $) as bitarray) --Select the border
	$.edgeExtrudeHeight = 0
	$.edgeExtrudeWidth = 0
	$.EditablePoly.buttonOp #Extrude
	$.EditablePoly.ConvertSelection #Edge #Vertex
	subobjectLevel = 1

	-- Move all vertices on the border to the minThick position along the y-axis
	verts = polyop.getVertSelection p
	for i in verts do 
	(
		pos = polyop.getVert p i
		pos[2]=minThick
		--print pos
		polyop.setVert p i pos
	)
)

fn CreateBackFace = 
(
	plane2 = Plane length:H  width:W transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,minThick,0]) isSelected:on lengthsegs:1 widthsegs:1
	p2=convertToPoly ( plane2)
	subobjectLevel = 1
	verts = #{1..4}
	for i in verts do 
	(
		pos = polyop.getVert p2 i
		pos[2]=minThick
		--print pos
		polyop.setVert p2 i pos
	)
	
	subobjectLevel = 4
	$.EditablePoly.SetSelection #Face #{1}
	$.EditablePoly.flipNormals 1
	--for i = 1 to tessIter do 
	--Back face does not need to be that detailed, just enough so that it can be bent smoothly, 
	--the mesh will thus not be conforming, but the gaps should be minimal and practically not noticable.
	for i = 1 to 5 do
	(
		$.EditablePoly.tessellate #Face
	)
)

fn AttachFaces = 
(
	$.EditablePoly.SetSelection #Face #{}
	--$.EditablePoly.attach $Plane001 $
	$.EditablePoly.attach plane1 $
)

fn WeldVertics = 
(
	subobjectLevel = 1
	nVerts = polyop.getNumVerts plane2
	$.EditablePoly.SetSelection #Vertex #{1..nVerts}
	$.weldThreshold = 0.01
	$.EditablePoly.weldFlaggedVertices ()
	subobjectLevel = 0
)

fn BendImage = 
(
	modPanel.addModToSelection (Bend ()) ui:on
	$.modifiers[#Bend].BendAngle = bendAngle
	$.modifiers[#Bend].BendAxis = 0
)


rollout LithophaneRollout "Lithophane generator v.1.0" width:200 height:422
(
	spinner 'spn_width' "" pos:[13,31] width:72 height:16 range:[0,1000,150] align:#left
	label 'lbl2' "Width" pos:[13,15] width:56 height:16 align:#left
	label 'lbl3' "Height" pos:[13,55] width:56 height:16 align:#left
	spinner 'spn_height' "" pos:[13,71] width:72 height:16 range:[0,1000,100] align:#left
	label 'lbl4' "Minimum thickness" pos:[13,95] width:96 height:16 align:#left
	spinner 'spn_minThick' "" pos:[13,111] width:72 height:16 range:[-100,100,0.7] align:#left
	label 'lbl5' "Displacement Strength" pos:[13,135] width:112 height:16 align:#left
	spinner 'spn_dispStrength' "" pos:[13,151] width:72 height:16 range:[-100,100,1] align:#left
	label 'lbl6' "Tessalations" pos:[13,175] width:112 height:16 align:#left
	spinner 'spn_tessalation' "" pos:[13,191] width:72 height:16 range:[0,10,8] type:#integer scale:1 align:#left
	checkbox 'chk_Bend' "Bend Angle:" pos:[13,215] width:80 height:16 align:#left
	spinner 'spn_bendAngle' "" pos:[13,239] width:72 height:16 range:[0,360,90] align:#left
	button 'btn_chooseImg' "Choose image" pos:[40,263] width:120 height:32 align:#left
	button 'btn_create' "Create!" pos:[40,316] width:120 height:32 align:#left
	progressBar 'pb1' "ProgressBar" pos:[8,364] width:184 height:24 align:#left
	label 'lbl_status' "Label" pos:[9,396] width:120 height:22 align:#left
	
	
	
	fn changeBendState =
	(
		if chk_Bend.checked then
		(spn_bendAngle.enabled = true)
		else
		(spn_bendAngle.enabled = false
		spn_bendAngle.value = 0.0)
	)
	
	fn ChooseBitmap = 
	(
		dispBitMap = selectBitMap caption:"Select a picture"
		if dispBitMap != undefined then (
			btn_chooseImg.tooltip =  dispBitMap.filename
			bitmapChosen = true
			
			dispBitMap.height
			dispBitMap.width
			aspectRatio = (float)dispBitMap.width/dispBitMap.height
			W = H*aspectRatio
			spn_width.value = W
		)
	
		
	)
	
	
	
	on LithophaneRollout open do
	(
		changeBendState()
		btn_chooseImg.tooltip =  "None"
		lbl_status.caption = "ready"
	)
	on spn_width changed val do
	(
		if dispBitMap != undefined then (
			W = spn_width.value
			H = W/aspectRatio
			spn_height.value = H
		)
	)
	on spn_height changed val do
	(
		if dispBitMap != undefined then (
			H = spn_height.value
			W = H*aspectRatio
			spn_width.value = W
		)
	)
	on chk_Bend changed state do
	(
		changeBendState()
	)
	on btn_chooseImg pressed do
	(
		ChooseBitmap()
	)
	on btn_create pressed do
	(
		W = spn_width.value
		H = spn_height.value
		minThick = spn_minThick.value
		dispStrength = spn_dispStrength.value
		tessIter = spn_tessalation.value
		bendAngle = spn_bendAngle.value 
		
		if bitmapChosen then (
			pb1.value = 0
			lbl_status.caption = "Creating front face..."
			CreateFrontPlane()
			pb1.value = 14
			lbl_status.caption = "Displacing image..."
			DisplaceImage()
			pb1.value = 30
			lbl_status.caption = "Extruding front face..."
			ExtrudeFrontFace()
			pb1.value = 45
			lbl_status.caption = "Creating back face..."
			CreateBackFace()
			pb1.value = 60
			lbl_status.caption = "Attaching faces..."
			AttachFaces()
			pb1.value = 75
			lbl_status.caption = "Welding vertices..."
			WeldVertics()
			pb1.value = 90
			lbl_status.caption = "Bending image..."
			BendImage()
			pb1.value = 100
			lbl_status.caption = "Done!"
		) else (
			messagebox "Bitmap not chosen!"
		)
	)
)

RolloutFloater_main = newrolloutfloater "Lithophane generator" 210 460
addrollout LithophaneRollout RolloutFloater_main



