library(lidR)
library(RCSF)
library(itcSegment)
library(VoxR)
library(rgl)
library(sf)

#Write in
las <- readLAS("d:\\karasawa\\merge\\rg scale fusion.las")

#Define CRS
st_crs(las) <- 32654
epsg(las)

print(las)

#voxel
vlas <- voxelize_points(las, 0.05)
plot(vlas)
vlas@header@VLR <- list()
print(vlas)
writeLAS(vlas, "d:\\karasawa\\merge\\rg scale fusion v005.las")

las <- readLAS("d:\\karasawa\\merge\\voxel01.las")

#Ground classification
las <- classify_ground(las, algorithm = csf(sloop_smooth = TRUE,
                                            class_threshold = 0.5,
                                            cloth_resolution = 0.3,
                                            rigidness = 3L,
                                            iterations = 500L,
                                            time_step = 0.65))

plot(las, size = 3, bg = "white", color = "Classification")

#DTM
gnd <- filter_ground(las)
plot(gnd, size = 3, bg = "white", color = "Classification")

dtm <- rasterize_terrain(las, 0.1, knnidw())
plot(dtm, col = gray(1:50/50))


#Normalized
nlas <- las - dtm
plot(nlas, size = 4, bg = "white")
chm <- rasterize_canopy(nlas, res = 0.2, algorithm = p2r())
col <- height.colors(25)
plot(chm, col = col)

#ITD
ttops <- locate_trees(nlas, lmf(ws = 3))
plot(ttops)

#Show tree
a <- plot(nlas, bg = "white", size = 4)
add_treetops3d(a, ttops)


#ITS
algo <- dalponte2016(chm, ttops)
slas <- segment_trees(las, algo) # segment point cloud
plot(slas, bg = "white", size = 4, color = "treeID", axis = TRUE) # visualize trees

#canopy in 2D
crowns <- crown_metrics(slas, func = .stdtreemetrics, geom = "convex")
plot(crowns["convhull_area"], main = "Crown area (convex hull)")

crowns <- algo()
plot(crowns, col = pastel.colors(200))

writeLAS(slas, "d:\\karasawa\\merge\\its053.las")

writeLAS(nlas, "d:\\karasawa\\merge\\nlas.las")

#pick tree
tree100 <- filter_poi(slas, treeID == 20)
plot(tree100, size = 5, bg = "white")



#voxel
las <- readLAS("d:\\karasawa\\Stemflow\\Tree 1 branches all.las")
vlas <- voxelize_points(las, 0.05)
plot(vlas)
vlas@header@VLR <- list()
writeLAS(vlas, "d:\\karasawa\\Stemflow\\Tree 1 branches 005.las")

las <- readLAS("d:\\karasawa\\merge\\voxel01.las")

