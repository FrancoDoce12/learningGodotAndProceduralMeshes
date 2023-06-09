
# In This file there gona be the functions used for the generetion for 3d meshes and some related thing of that
# INDEX:
# ----- 1: Utils Function : used for utilities and through the code
# ----- 2: Generations Functions: the main functions used for the generation of meshes
# ----- 3: Functions of Creations of meshes and other godot objects  

# -------------------------- 1: Utils Function --------------------------

func manangeTriangle(previusIndexes:Array,indexArray:Array,reverseStep:bool):
	if (previusIndexes.size() >= 3):
		var lastPoint = previusIndexes[previusIndexes.size()-1]
		var secondLastPoint = previusIndexes[previusIndexes.size()-2]
		var thirdLastPoint = previusIndexes[previusIndexes.size()-3]

		if (reverseStep):
			indexArray.append(lastPoint)
			indexArray.append(thirdLastPoint)
			indexArray.append(secondLastPoint)
		else:
			indexArray.append(lastPoint)
			indexArray.append(secondLastPoint)
			indexArray.append(thirdLastPoint)

func multiplyPointsArray(multiplierVector:Vector3, multiplicandArray:Array):
	var newArray = []
	for i in range(multiplicandArray.size()):
		var vector = multiplicandArray[i]
		var newVector = multiplierVector * vector
		newArray.append(newVector)
	return newArray

func transformPointsArray(multiplicandArray:Array):
	var newArray = []
	for i in range(multiplicandArray.size()):
		var vector = multiplicandArray[i]
		var newX = vector.z * -1
		var newZ = vector.x
		var newVector = Vector3(newX, vector.y, newZ)
		newArray.append(newVector)
	return newArray

func changeOrderOfTriangle(indexArray:Array):
	var transformedIndexes = []
	for index in range(0, indexArray.size(),3):
		var firstIndex = indexArray[index]
		var secondIndex = indexArray[index+1]
		var thirdIndex = indexArray[index+2]

		transformedIndexes.append(thirdIndex)
		transformedIndexes.append(secondIndex)
		transformedIndexes.append(firstIndex)
	return transformedIndexes

func sumIndexesSomeValue(indexesArray:Array, value:int):
	var newIndexes = []
	for i in range(indexesArray.size()):
		var index = indexesArray[i]
		newIndexes.append(index + value)
	return newIndexes

func reverse_array(arr):
	var reversed = []
	for i in range(arr.size() - 1, -1, -1):
		reversed.append(arr[i])
	return reversed

func getTrianglesConected(indexArrA:Array, indexArrB:Array):
	if (indexArrA.size() != indexArrB.size()):
		# shuld be imposible
		print_stack()
	var indexArr = []
	var lastIndexes = []
	for i in range(indexArrA.size()):

		var pointA = indexArrA[i]
		var pointB = indexArrB[i]

		lastIndexes.append(pointA)
		manangeTriangle(lastIndexes,indexArr,true)
		
		lastIndexes.append(pointB)
		manangeTriangle(lastIndexes,indexArr,false)
	return indexArr

func conectRingToPole(RingIndexes:Array,PoleIndex:int, reverse:bool):
	var indexArr = []
	var lastIndexes = []
	var pointB = PoleIndex
	for i in range(RingIndexes.size()):
		var pointA = RingIndexes[i]
		var nextPointA
		if (i+1 >= RingIndexes.size()):
			nextPointA = RingIndexes[0]
		else:
			nextPointA = RingIndexes[i+1] 
		lastIndexes.append(pointA)
		lastIndexes.append(pointB)
		lastIndexes.append(nextPointA)
		manangeTriangle(lastIndexes,indexArr,reverse)
	return indexArr


func calculateNormals(vertexArray, indexesArray):
	var normalArray = []

	for _i in range(vertexArray.size()):
		normalArray.append(Vector3.ZERO)

	for i in range(indexesArray.size() / 3):
		var index0 = indexesArray[i * 3 + 0]
		var index1 = indexesArray[i * 3 + 1]
		var index2 = indexesArray[i * 3 + 2]

		var v0 = vertexArray[index0]
		var v1 = vertexArray[index1]
		var v2 = vertexArray[index2]

		var normal = (v1 - v0).cross(v2 - v0)
		normal = -normal


		normalArray[index0] += normal
		normalArray[index1] += normal
		normalArray[index2] += normal

	for i in range(normalArray.size()):
		normalArray[i].normalized()

	return normalArray


# -------------------------- 2: Generations Functions --------------------------
# returns just a dictionary with the keys of "vertexes" and "indexes"
func generateXdistantVectorSphere(radius:int,detail:int) -> Dictionary:
	# returns just a dictionary with the keys of "vertexes" and "indexes"

	# EXPLANAITION:
	# first we gona generate an octavio of vectors of the top left back corner of 
	# the sphere and then copy the points and muliply by -1 diferent axis to get a sphere
	
	# WHY? because it need less sin() and cos() functions calculations with are expensive
	# in the performance, right? 

	# INDEX:
	# 

	#--------------------------------------------------------------------------
	#------------ Starts of Vertexs3d array creation for the mesh -------------
	#--------------------------------------------------------------------------

	# ------ in this part generate an octavio of the sphere in vectors --------


	var totalDegrees = 90 
	var degreeSteps = float(totalDegrees) / detail

	var ringsDetailsArray = []
	var firstRingPoints
	var generalPointsXYZ = []

	for ringY in range(detail):
		var ringsPoints = []

		var totalDegreesForY = degreeSteps * ringY
		var y = sin(deg2rad(totalDegreesForY)) * radius
		var ringDiameter = cos(deg2rad(totalDegreesForY)) * radius
		
		var ringDetail = round(cos(deg2rad(totalDegreesForY)) * detail)
		var degreeStepsNew = float(totalDegrees)/ringDetail
		ringsDetailsArray.append(ringDetail)

		for i in range(ringDetail):
			var totalDegreesIn = degreeStepsNew * i
			var x = ringDiameter * cos(deg2rad((totalDegreesIn)))
			var z = ringDiameter * sin(deg2rad((totalDegreesIn)))
			ringsPoints.append(Vector3(x,y,z))

		if (ringY == 0):
			firstRingPoints = ringsPoints
		else:
			generalPointsXYZ.append_array(ringsPoints)




	#--------------------------------------------------------------------------
	#------------- Starts of Indexes array creation for the mesh --------------
	#--------------------------------------------------------------------------



	var actualPointIndex = 0
	var indexesArray = []
	for ring in range(ringsDetailsArray.size()):

		var actualRingSize = ringsDetailsArray[ring]
		var nextRingSize = 0
		# if exsist the next ring, add it
		if (!(ring+1 >= ringsDetailsArray.size())):
			nextRingSize = ringsDetailsArray[ring+1] 
		
		var ringsDiference = int(actualRingSize - nextRingSize)
		

		var lastIndexes = []
		var ringIndexesArray = []

		# ----------------------- adding the ftriangles -----------------------

		match ringsDiference:
			0:
				for _currentPoint in range(actualRingSize):

					var pointA = actualPointIndex
					var pointB = pointA + actualRingSize

					lastIndexes.append(pointA)
					manangeTriangle(lastIndexes,ringIndexesArray,false)
					
					lastIndexes.append(pointB)
					manangeTriangle(lastIndexes,ringIndexesArray,true)

					actualPointIndex = actualPointIndex + 1

			1: 
				
				for currentPoint in range(actualRingSize):

					var pointA = actualPointIndex
					var pointB = pointA + actualRingSize

					lastIndexes.append(pointA)
					manangeTriangle(lastIndexes,ringIndexesArray,false)
					
					if ((currentPoint + 1 != actualRingSize)  ):
						lastIndexes.append(pointB)
						manangeTriangle(lastIndexes,ringIndexesArray,true)
					
					actualPointIndex = actualPointIndex + 1
			2:
				# tgis sitem uses grupes and the middel grup is larger by 1+
				var grupNormalSize = int(nextRingSize / 2)
				var grupSizeRest = int(nextRingSize) % 2
				var grupesSizes = [grupNormalSize,grupSizeRest+2,grupNormalSize]
				for grup in range(3):
					var grupSize = grupesSizes[grup]
					for _step in range(grupSize):
						# there are 2 points in each step
						# point A being the point of the current ring
						# and point B being the point of the next ring that is in front of point A
						var pointA = actualPointIndex
						var pointB = actualPointIndex + actualRingSize - grup

						lastIndexes.append(pointA)
						manangeTriangle(lastIndexes,ringIndexesArray,false)
						
						lastIndexes.append(pointB)
						manangeTriangle(lastIndexes,ringIndexesArray,true)
						
						actualPointIndex = actualPointIndex + 1

		indexesArray.append_array(ringIndexesArray)



	# creating the points of the sphere

	var generalPointsX_YZ = multiplyPointsArray(Vector3(1,-1,1),generalPointsXYZ)
	
	var quarterSpherePoints = firstRingPoints  +  generalPointsXYZ + generalPointsX_YZ
	var halfSpherePoints = quarterSpherePoints + transformPointsArray(quarterSpherePoints)
	var comleteSpherePoints = halfSpherePoints + multiplyPointsArray(Vector3(-1,1,-1),halfSpherePoints) 
	# adding the poles points
	comleteSpherePoints = comleteSpherePoints + [Vector3(0,-radius,0),Vector3(0,radius,0)]

	# indexesArray = firstRingPoints + generalPointsXYZ indexes....

	# ----------------------- getting the indexes for the quarterSpherePoints -----------------------
	# first we gonna conect the generalPoints-y with the first ring points and the genereal points between them


	
	var generalIndexesX_YZ = []
	for i in range(indexesArray.size()):
		var index =  indexesArray[i]
		# if the index is from the midle ring, whe conect it
		if (index < ringsDetailsArray[0]):
			generalIndexesX_YZ.append(index)
		else:
			generalIndexesX_YZ.append(index + generalPointsXYZ.size())

	# reverse the triangles
	generalIndexesX_YZ = changeOrderOfTriangle(generalIndexesX_YZ)



	var quarterSphereIndexes = indexesArray + generalIndexesX_YZ 
	var halfSphereIndexes = quarterSphereIndexes + sumIndexesSomeValue(quarterSphereIndexes, quarterSpherePoints.size())
	var completeSphereIndexes = halfSphereIndexes + sumIndexesSomeValue(halfSphereIndexes, quarterSpherePoints.size()*2)


	#----------------------------------------------------------------
	#-------------- Initialising the conection points  --------------
	#----------------------------------------------------------------


	# the vertical line are the first points of each ring, meaking a perfect line with all points the same z value, z=0 
	var verticalLineIndexesXYZ = []
	# this is the line (the not stringt end of the quarter) that have to conect with the the vertical line (that it is a straigt line)
	var conectionLineIndexesXYZ = []
	var verticalLineIndexesCount = 0
	for detailInRing in range(ringsDetailsArray.size()):
		verticalLineIndexesXYZ.append(verticalLineIndexesCount)
		verticalLineIndexesCount = verticalLineIndexesCount + ringsDetailsArray[detailInRing]
		conectionLineIndexesXYZ.append(verticalLineIndexesCount-1)




	#----------------------------------------------------------------
	#---------------- Conecting Parts of the Sphere  ----------------
	#----------------------------------------------------------------

	# do the same thing to both conection parts
	var verticalLineIndexesX_YZ = sumIndexesSomeValue(verticalLineIndexesXYZ, generalPointsXYZ.size())
	var conectionLineIndexesX_YZ = sumIndexesSomeValue(conectionLineIndexesXYZ, generalPointsXYZ.size())
	# delete the middle ring index of the array
	verticalLineIndexesX_YZ.pop_front()
	conectionLineIndexesX_YZ.pop_front()
	# invert eh order so it starts fom the buttom of the sphere
	verticalLineIndexesX_YZ.invert()
	conectionLineIndexesX_YZ.invert()


	var concectionLineIndexesQuarterSphere_0 = conectionLineIndexesX_YZ + conectionLineIndexesXYZ
	var concectionLineIndexesQuarterSphere_1 = sumIndexesSomeValue(concectionLineIndexesQuarterSphere_0, quarterSpherePoints.size())
	var concectionLineIndexesQuarterSphere_2 = sumIndexesSomeValue(concectionLineIndexesQuarterSphere_1, quarterSpherePoints.size())
	var concectionLineIndexesQuarterSphere_3 = sumIndexesSomeValue(concectionLineIndexesQuarterSphere_2, quarterSpherePoints.size())

	var verticalLineIndexesQuarterSphere_0 = verticalLineIndexesX_YZ + verticalLineIndexesXYZ
	var verticalLineIndexesQuarterSphere_1 = sumIndexesSomeValue(verticalLineIndexesQuarterSphere_0, quarterSpherePoints.size())
	var verticalLineIndexesQuarterSphere_2 = sumIndexesSomeValue(verticalLineIndexesQuarterSphere_1, quarterSpherePoints.size())
	var verticalLineIndexesQuarterSphere_3 = sumIndexesSomeValue(verticalLineIndexesQuarterSphere_2, quarterSpherePoints.size())


	var conectionOne  = getTrianglesConected(concectionLineIndexesQuarterSphere_0,verticalLineIndexesQuarterSphere_1 )
	var conectionTwo  = getTrianglesConected(concectionLineIndexesQuarterSphere_1,verticalLineIndexesQuarterSphere_2 )
	var conectionThre = getTrianglesConected(concectionLineIndexesQuarterSphere_2,verticalLineIndexesQuarterSphere_3 )
	var conectionFour = getTrianglesConected(concectionLineIndexesQuarterSphere_3,verticalLineIndexesQuarterSphere_0 )


	var conectionPoints = conectionOne + conectionTwo + conectionThre + conectionFour

	#----------------------------------------------------------------
	#----------- Initialising the poles conection rings  ------------
	#----------------------------------------------------------------

	# ---------------- Basic quarter of +y indexes ----------------

	# the top ring is the last int(ringsDetailsArray.back()) of the points Array
	var topRingIndexesOne = []
	for pointIndex in range(ringsDetailsArray.back()):
		topRingIndexesOne.push_front(firstRingPoints.size() + generalPointsXYZ.size() - pointIndex-1)
	
	# ---------------- Basic quarter of -y indexes ----------------
	var buttonRingIndexesOne = sumIndexesSomeValue(topRingIndexesOne,generalPointsXYZ.size())


	# ----------------- creating the rings indexes -----------------

	var topRingIndexesTwo = sumIndexesSomeValue(topRingIndexesOne,quarterSpherePoints.size())
	var topRingIndexesThree = sumIndexesSomeValue(topRingIndexesTwo,quarterSpherePoints.size())
	var topRingIndexesFour = sumIndexesSomeValue(topRingIndexesThree,quarterSpherePoints.size())

	var topRingIndexes = topRingIndexesOne + topRingIndexesTwo + topRingIndexesThree + topRingIndexesFour
	
	var buttonRingIndexesTwo = sumIndexesSomeValue(buttonRingIndexesOne,quarterSpherePoints.size())
	var buttonRingIndexesThree = sumIndexesSomeValue(buttonRingIndexesTwo,quarterSpherePoints.size())
	var buttonRingIndexesFour = sumIndexesSomeValue(buttonRingIndexesThree,quarterSpherePoints.size())

	var buttonRingIndexes = buttonRingIndexesOne + buttonRingIndexesTwo + buttonRingIndexesThree + buttonRingIndexesFour

	#---------------------------------------------------------------
	#------------ Connecting the poles conection rings  ------------
	#---------------------------------------------------------------

	var topPoleIndex = comleteSpherePoints.size()-1
	var buttonPoleIndex = comleteSpherePoints.size()-2


	var topPoleIndexes = conectRingToPole(topRingIndexes,topPoleIndex,false)
	var buttonPoleIndexes = conectRingToPole(buttonRingIndexes,buttonPoleIndex,true)






	var points = comleteSpherePoints
	var indexes = completeSphereIndexes + conectionPoints + topPoleIndexes + buttonPoleIndexes

	# ---------------------------------- debugs prints ----------------------------------
	# print(ringsDetailsArray)
	# print(indexesArray)
	# print("\n")
	# print("POINTS")
	# print(points)
	# print("\n")
	# print(quarterSphereIndexes)

	var noise = OpenSimplexNoise.new()

	# Configure
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.7
	
	
	var pointsAndIndexes = {"vertexes":points,"indexes":indexes}

	return pointsAndIndexes




func generateLinearMesh(totalX,totalZ):
	# totalX,totalZ are in meters

	var arrayVertexs = []
	var totalVerticesX = totalX + 1
	var totalVerticesZ = totalZ + 1

	for indexZ in range(totalVerticesZ):
		for indexX in range(totalVerticesX):
			arrayVertexs.append(Vector3(indexX,0,indexZ))

	var indexArray = []


	for indexZ in range(totalVerticesZ-1):
		var actualIndex = indexZ * totalVerticesX
		for _indexX in range(totalVerticesX-1):

			var indexUp = actualIndex + totalVerticesX
			var indexLeft = actualIndex + 1
			var indexUpLeft = indexUp + 1

			# making the first tringle
			indexArray.append(actualIndex)
			indexArray.append(indexUpLeft)
			indexArray.append(indexUp)

			# making the second tringle
			indexArray.append(actualIndex)
			indexArray.append(indexLeft)
			indexArray.append(indexUpLeft)

			actualIndex = actualIndex + 1

	var total_surface_array = []
	total_surface_array.resize(Mesh.ARRAY_MAX)

	total_surface_array[ArrayMesh.ARRAY_VERTEX] = PoolVector3Array(arrayVertexs)
	total_surface_array[ArrayMesh.ARRAY_INDEX] = PoolIntArray(indexArray)

	var mesh = ArrayMesh.new()

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, total_surface_array)

	var meshInstance = MeshInstance.new()

	meshInstance.mesh = mesh

	var material = SpatialMaterial.new()
	# Asignar un color al material
	material.albedo_color = Color(255, 0, 0)
	# Asignar el material al MeshInstance
	meshInstance.material_override = material

	return meshInstance


	# ------------------ 3: Functions of Creations of meshes and other godot objects  ------------------


func createMeshInstance(vertexArray,indexesArray) -> MeshInstance:

	var normalArray = calculateNormals(vertexArray,indexesArray)
	
	var total_surface_array = []
	total_surface_array.resize(Mesh.ARRAY_MAX)

	total_surface_array[ArrayMesh.ARRAY_VERTEX] = PoolVector3Array(vertexArray)
	total_surface_array[ArrayMesh.ARRAY_INDEX]  = PoolIntArray(indexesArray)
	total_surface_array[ArrayMesh.ARRAY_NORMAL] = PoolVector3Array(normalArray)

	var mesh = ArrayMesh.new()

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, total_surface_array)

	var meshInstance = MeshInstance.new()

	meshInstance.mesh = mesh

	return meshInstance

# returns a mesh, not a mesh intance 
func createMeshNoNormals(vertexArray:Array,indexesArray:Array) -> Mesh:
	# returns a mesh, not a mesh intance 

	var total_surface_array = []
	total_surface_array.resize(Mesh.ARRAY_MAX)

	total_surface_array[ArrayMesh.ARRAY_VERTEX] = PoolVector3Array(vertexArray)
	total_surface_array[ArrayMesh.ARRAY_INDEX] = PoolIntArray(indexesArray)

	var mesh = ArrayMesh.new()

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, total_surface_array)
	
	return mesh


# returns a mesh, not a mesh intance, with normals
func createMesh(vertexArray,indexesArray) -> Mesh:
	# returns a mesh, not a mesh intance, with normals
	var normalArray = calculateNormals(vertexArray,indexesArray)
	
	var total_surface_array = []
	total_surface_array.resize(Mesh.ARRAY_MAX)

	total_surface_array[ArrayMesh.ARRAY_VERTEX] = PoolVector3Array(vertexArray)
	total_surface_array[ArrayMesh.ARRAY_INDEX] = PoolIntArray(indexesArray)
	total_surface_array[ArrayMesh.ARRAY_NORMAL] = PoolVector3Array(normalArray)

	var mesh = ArrayMesh.new()

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, total_surface_array)

	return mesh

# does nothging
func addNormalsToMesh(_mesh:ArrayMesh,_vertexes:Array,_indexes:Array):
	# TODO
	# mesh.get_meta_list()
	# mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,)
	pass