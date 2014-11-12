all: us.json
	
clean:
	rm -rf -- us.json build
	
.PHONY: all clean

#build/cb_2013_us_county_500k.zip:
#	mkdir -p $(dir $@)
#	curl -o $@ http://www2.census.gov/geo/tiger/GENZ2013/$(notdir $@)
build/gz_2010_us_050_00_20m.zip:
	mkdir -p $(dir $@)
	curl -o $@ http://www2.census.gov/geo/tiger/GENZ2010/$(notdir $@)
#	
#build/cb_2013_us_county_500k.shp: build/cb_2013_us_county_500k.zip
build/gz_2010_us_050_00_20m.shp: build/gz_2010_us_050_00_20m.zip
	unzip -od $(dir $@) $<
	touch $@
#	
#build/counties.json: build/cb_2013_us_county_500k.shp
#build/counties.json: build/gz_2010_us_050_00_20m.shp
#	node_modules/.bin/topojson \
#		-o $@ \
#		--projection='width = 1260, height = 600, d3.geo.mercator() \
#			.scale(1280) \
#			.center([103, 38.7]) \
#			.rotate([-180, 0]) \
#			.translate([width / 2, height / 2])' \
#		--simplify=.5 \
#		--filter=none \
#		-- counties=$<
#		
#build/counties.json: build/cb_2013_us_county_500k.shp ACS_13_1YR_B01003_with_ann.csv
#build/counties.json: build/cb_2013_us_county_500k.shp ACS_12_5YR_B01003_with_ann.csv
build/counties.json: build/gz_2010_us_050_00_20m.shp ACS_12_5YR_B01003_with_ann.csv
	node_modules/.bin/topojson \
	-o $@ \
	--id-property='STATE+COUNTY, Id2' \
	--external-properties=ACS_13_1YR_B01003_with_ann.csv \
	--properties='name=Geography' \
	--properties='population=+d.properties["Estimate; Total"]' \
	--projection='width = 1260, height = 600, d3.geo.mercator() \
		.scale(8500) \
		.center([103, 38.7]) \
		.rotate([-180, 0]) \
		.translate([width / 2, height / 2])' \
	--simplify=.5 \
	--filter=none \
	-- counties=$<
#dissolve county boundries within each state
build/states.json: build/counties.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=counties \
		--out-object=states \
		--key='d.id.substring(0, 2)' \
		-- $<
#dissolve state boundries within each country
us.json: build/states.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=states \
		--out-object=nation \
		-- $<
#
#################################
########### Old Data ############
#################################
#
#all: us.json
#	
#clean:
#	rm -rf -- us.json build
#	
#.PHONY: all clean
#$@ - path to target file
#$(dir $@) - dir containing the target file
#$(notdir $@) - target file name
#build/gz_2010_us_050_00_20m.zip:
#	mkdir -p $(dir $@)
#	curl -o $@ http://www2.census.gov/geo/tiger/GENZ2010/$(notdir $@)
	#dl zip containing Census Bureau and save to build dir
#unzip file from above
#$< - first prerequisite of this rule: the shp
#build/gz_2010_us_050_00_20m.shp: build/gz_2010_us_050_00_20m.zip
#	unzip -od $(dir $@) $<
#	touch $@
#convert shapefiles to TopoJSON
#dl zip, zip to shp, shp to json
#modification to reassign col ids in CSV from factfinder2.com 
#build/counties.json: build/gz_2010_us_050_00_20m.shp ACS_12_5YR_B01003_with_ann.csv
#	node_modules/.bin/topojson \
#		-o $@ \
#		--id-property='STATE+COUNTY,Id2' \
#		--external-properties=ACS_12_5YR_B01003_with_ann.csv \
#		--properties='name=Geography' \
#		--properties='population=+d.properties["Estimate; Total"]' \
#		--projection='width = 960, height = 600, d3.geo.albersUsa() \
#			.scale(500) \
#			.translate([width / 2, height / 2])' \
#		--simplify=.5 \
#		--filter=none \
#		-- counties=$<
#dissolve county boundries within each state
#build/states.json: build/counties.json
#	node_modules/.bin/topojson-merge \
#		-o $@ \
#		--in-object=counties \
#		--out-object=states \
#		--key='d.id.substring(0, 2)' \
#		-- $<
#dissolve state boundries within each country
#us.json: build/states.json
#	node_modules/.bin/topojson-merge \
#		-o $@ \
#		--in-object=states \
#		--out-object=nation \
#		-- $<