try (closeRolloutFloater RolloutFloater_main) catch()
W = 150
H = 100
minThick = 1
dispStrength = 2
bendAngle = 0 -- degrees
tessIter = 8 --resolution 9 is high quality, 10 crashes the PC 
dispBitMap = undefined
dispBitMap = openBitMap "F:\Dropbox\Camera Uploads\2017-03-05 10.39.34.jpg"
-- dispBitMap = selectBitMap caption:"Select a picture"
bitmapChosen = false
aspectRatio = 0.0

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
	displace1.strength = -dispStrength
)

fn ExtrudeFrontFace = 
(
	p=convertToPoly ( plane1)
	subobjectLevel = 3
	$.EditablePoly.SetSelection #Edge ((polyOp.getOpenEdges $) as bitarray)
	$.edgeExtrudeHeight = 0
	$.edgeExtrudeWidth = 0
	$.EditablePoly.buttonOp #Extrude
	$.EditablePoly.ConvertSelection #Edge #Vertex
	subobjectLevel = 1

	verts = polyop.getVertSelection p
	for i in verts do 
	(
		pos = polyop.getVert p i
		pos[2]=dispStrength+minThick
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
		pos[2]=minThick+dispStrength
		--print pos
		polyop.setVert p2 i pos
	)
	
	subobjectLevel = 4
	$.EditablePoly.SetSelection #Face #{1}
	$.EditablePoly.flipNormals 1
	for i = 1 to tessIter do
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


rollout LithopaneRollout "Lithopane generator v.1.0" width:201 height:570
(
	label 'lbl1' "Lithopane Generator" pos:[49,8] width:103 height:24 align:#left
	spinner 'spn_width' "" pos:[8,56] width:72 height:16 range:[0,1000,150] align:#left
	label 'lbl2' "Width" pos:[8,40] width:56 height:16 align:#left
	label 'lbl3' "Height" pos:[8,80] width:56 height:16 align:#left
	spinner 'spn_height' "" pos:[8,96] width:72 height:16 range:[0,1000,100] align:#left
	label 'lbl4' "Minimum thickness" pos:[8,120] width:96 height:16 align:#left
	spinner 'spn_minThick' "" pos:[8,136] width:72 height:16 range:[0,1000,0.5] align:#left
	label 'lbl5' "Displacement Strength" pos:[8,160] width:112 height:16 align:#left
	spinner 'spn_dispStrength' "" pos:[8,176] width:72 height:16 range:[0,1000,1] align:#left
	label 'lbl6' "Tessalations" pos:[8,200] width:112 height:16 align:#left
	spinner 'spn_tessalation' "" pos:[8,216] width:72 height:16 range:[0,10,8] type:#integer scale:1 align:#left
	checkbox 'chk_Bend' "Bend Angle:" pos:[8,240] width:80 height:16 align:#left
	spinner 'spn_bendAngle' "" pos:[8,264] width:72 height:16 range:[0,360,90] align:#left
	button 'btn_chooseImg' "Choose image" pos:[40,288] width:120 height:32 align:#left
	label 'lbl_img' "None" pos:[8,328] width:112 height:16 align:#left
	button 'btn_create' "Create!" pos:[40,464] width:120 height:32 align:#left
	progressBar 'pb1' "ProgressBar" pos:[8,512] width:184 height:24 align:#left
	bitmap 'bmp1' "Bitmap" pos:[8,352] width:184 height:98 align:#left
	label 'lbl_status' "Label" pos:[9,544] width:120 height:22 align:#left
	
	
	
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
			lbl_img.caption = dispBitMap.filename
			bitmapChosen = true
			bmp1.bitmap = dispBitMap
			dispBitMap.height
			dispBitMap.width
			aspectRatio = (float)dispBitMap.width/dispBitMap.height
			W = H*aspectRatio
			spn_width.value = W
		)
	
		
	)
	
	
	
	on LithopaneRollout open do
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
			dispBitMap = openBitMap "F:\Dropbox\Camera Uploads\2017-03-05 10.39.34.jpg"
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

--createdialog LithopaneRollout

RolloutFloater_main = newrolloutfloater "Lithopane generator" 210 610
addrollout LithopaneRollout RolloutFloater_main




--CreateFrontPlane()
--DisplaceImage()
--ExtrudeFrontFace()
--CreateBackFace()
--AttachFaces()
--WeldVertics()
--BendImage()


