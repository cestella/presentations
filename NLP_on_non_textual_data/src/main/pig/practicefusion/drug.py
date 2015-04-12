#!/usr/bin/python

@outputSchema("name:chararray")
def drug_name(drug):
    if drug is None or len(drug) == 0:
       return ''
    elif '(' in drug and ')' in drug:
       return drug[drug.find('(')+1:drug.find(')')].lower() 
    else:
       tokens = drug.strip().split(' ')
       if len(tokens) > 0:
          return tokens[0].lower()
       else:
          return drug.lower()
