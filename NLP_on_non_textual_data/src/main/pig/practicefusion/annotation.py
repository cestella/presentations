#!/usr/bin/python

@outputSchema("annotation:chararray")
def annotate(value, quantiles):
    ret = 'unknown'
    val = float(value)
    q = [ 'min', '25th_percentile', '50th_percentile', '75th_percentile', 'max']
    for i in xrange(len(quantiles)):
        if val < quantiles[i]:
            ret = q[i]
            break
    return (ret)

@outputSchema("str:chararray")
def row_to_string(data_type, name, value):
    out = []
    if data_type is not None and data_type != 'NULL' and len(data_type) > 0:
        out.append(data_type)
    if name is not None and name != 'NULL' and len(name) > 0:
        out.append(name)
    if value is not None and value != 'NULL' and len(value) > 0:
        out.append(value)
    return "::".join(out).replace(' ', '_').lower()

@outputSchema("str:chararray")
def group_to_string(grp):
    return " ".join([x[0] for x in grp])
