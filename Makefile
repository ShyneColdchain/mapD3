build/cb_2013_us_county_500k.zip:
	mkdir -p $(dir $@)
	curl -o $@ http://www2.census.gov/geo/tiger/GENZ2013/$(notdir $@)
	
build/cb_2013_us_county_500k.shp: build/cb_2013_us_county_500k.zip
	unzip -od $(dir $@) $<
	touch $@
	
#build/counties.json: build/cb_2013_us_county_500k.shp
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
build/counties.json: build/cb_2013_us_county_500k.shp ACS_13_1YR_B01003_with_ann.csv
	node_modules/.bin/topojson \
	-o $@ \
	--id-property='STATE+COUNTY, Id2' \
	--external-properties=ACS_13_1YR_B01003_with_ann.csv \
	--properties='name=Geography' \
	--properties='population=+d.properties["Estimate; Total"]' \
	--projection='width = 1260, height = 600, d3.geo.mercator() \
		.scale(1280) \
		.center([103, 38.7]) \
		.rotate([-180, 0]) \
		.translate([width / 2, height / 2])' \
	--simplify=.5 \
	--filter=none \
	-- counties=$<