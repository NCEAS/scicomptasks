import sys

ECSO_file = open("d1-ECSO.owl", "r")

from lxml import etree as ET

data = ET.parse(ECSO_file)

output_file = open("ECSO_output.txt", "w")


root = data.getroot()

###Tag names
class_tag = '{http://www.w3.org/2002/07/owl#}Class'
label_tag = '{http://www.w3.org/2000/01/rdf-schema#}label'
preferred_label_tag = '{http://www.w3.org/2004/02/skos/core#}prefLabel'
rdf_description_tag = '{http://www.w3.org/1999/02/22-rdf-syntax-ns#}Description'
definition_tag = '{http://www.w3.org/2004/02/skos/core#}definition'

###Attributes for owl:Class and rdf:Description tags
class_attribute = '{http://www.w3.org/1999/02/22-rdf-syntax-ns#}about'
description_attribute = '{http://www.w3.org/1999/02/22-rdf-syntax-ns#}about'

### Writes column header
output_file.write('URI' + '\t'+ 'Label' + '\t' + 'Preferred Label' + '\t' + 'Definition' + '\n' )


### Gets URIs for owl:Class tags and outputs labels and definitions
for owl_class in root.iter(class_tag):	
	if class_attribute in owl_class.attrib:
		
		#If both labels and preferred labels present
		if owl_class.find(label_tag) is not None and owl_class.find(preferred_label_tag) is not None:
			#If definitions also present, output them
			if owl_class.find(definition_tag) is not None:
				
				#Removes new lines from class definitions
				if '\n' in owl_class.find(definition_tag).text:
					cleaned_class_definition = owl_class.find(definition_tag).text.replace('\n', ' ')
					output_file.write(owl_class.attrib[class_attribute].rstrip() + '\t' + owl_class.find(label_tag).text.rstrip() + '\t' + owl_class.find(preferred_label_tag).text + '\t' + cleaned_class_definition)
				else: 
					output_file.write(owl_class.attrib[class_attribute].rstrip() + '\t' + owl_class.find(label_tag).text.rstrip() + '\t' + owl_class.find(preferred_label_tag).text + '\t' + owl_class.find(definition_tag).text.strip('\r\n') + '\n')
			else: 
				output_file.write(owl_class.attrib[class_attribute].rstrip() + '\t' + owl_class.find(label_tag).text.rstrip() + '\t' + owl_class.find(preferred_label_tag).text.rstrip() + '\n')

		#If only labels present	
		elif owl_class.find(label_tag) is not None:
			output_file.write(owl_class.attrib[class_attribute].rstrip() + '\t' + owl_class.find(label_tag).text.rstrip() + '\t' + "" + '\t' + '\n')

		#If only preferred labels present
		elif owl_class.find(preferred_label_tag) is not None:
			output_file.write(owl_class.attrib[class_attribute].rstrip() + '\t' + "" + '\t' + owl_class.find(preferred_label_tag).text.rstrip() + '\t' + '\n')
		
		#If no labels present
		else:
			output_file.write(owl_class.attrib[class_attribute].rstrip() + '\t' + "" + '\t' + "" + '\t' + '\n')


### Gets URIs for rdf:Description tags and outputs labels and definitions
for rdf_description in root.iter(rdf_description_tag):
	if description_attribute in rdf_description.attrib:    

		#If both labels and preferred labels present
		if rdf_description.find(label_tag) is not None and rdf_description.find(preferred_label_tag) is not None:
			#If definitions also present, output them
			if rdf_description.find(definition_tag) is not None:
			
				#Removes new lines from rdf descriptions
				if '\n' in rdf_description.find(definition_tag).text:					
					cleaned_rdf_definition = rdf_description.find(definition_tag).text.replace('\n', ' ')
					output_file.write(rdf_description.attrib[description_attribute].rstrip() + '\t' + rdf_description.find(label_tag).text.rstrip() + '\t' + rdf_description.find(preferred_label_tag).text.rstrip() + '\t' + cleaned_rdf_definition)
				else:
					output_file.write(rdf_description.attrib[description_attribute].rstrip() + '\t' + rdf_description.find(label_tag).text.rstrip() + '\t' + rdf_description.find(preferred_label_tag).text.rstrip() + '\t' + rdf_description.find(definition_tag).text.strip('\r\n') + '\n')
			else:
				output_file.write(rdf_description.attrib[description_attribute].rstrip() + '\t' + rdf_description.find(label_tag).text.rstrip() + '\t' + rdf_description.find(preferred_label_tag).text.rstrip() + '\n')
		
		#If only labels present	
		elif rdf_description.find(label_tag) is not None:
			output_file.write(rdf_description.attrib[description_attribute].rstrip() + '\t' + rdf_description.find(label_tag).text.rstrip() + '\t' + "" + '\t' + '\n')

		#If only preferred labels present
		elif rdf_description.find(preferred_label_tag) is not None:
			output_file.write(rdf_description.attrib[description_attribute].rstrip() + '\t' + "" + '\t' + rdf_description.find(preferred_label_tag).text.rstrip() + '\t' + '\n')

		#If no labels present
		else:
			output_file.write(rdf_description.attrib[description_attribute].rstrip() + '\t' + "" + '\t' + '\n')

output_file.close()







