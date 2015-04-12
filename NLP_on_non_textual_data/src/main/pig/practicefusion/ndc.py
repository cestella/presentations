#!/usr/bin/python

@outputSchema("ndc:chararray")
def convert_ndc(v_ndc):
    ret_ndc = ''
    v_format = ''
    lengths = []
    cnt = 0
    for c in v_ndc:
        if c == '-':
            lengths.append(str(cnt))
            cnt = 0
        else:
            cnt = cnt + 1
    lengths.append(str(cnt))
    v_format = "-".join(lengths)

    if len(lengths) == 3:
        if v_format == '6-4-2':
            ret_ndc = v_ndc[1:6] + v_ndc[7:7+4] + v_ndc[12:12 + 2]
        elif v_format == '6-4-1':
            ret_ndc = v_ndc[1:6] + v_ndc[7:7+4] + '0' + v_ndc[12:12 + 1]
        elif v_format == '6-3-2':
            ret_ndc = v_ndc[1:6] + '0' + v_ndc[7:7+3] + v_ndc[11:11 + 2]
        elif v_format == '6-3-1':
            ret_ndc = v_ndc[1:6] + '0' + v_ndc[7:7+3] + '0' + v_ndc[11:11 + 1]
        elif v_format == '5-4-2':
            ret_ndc = v_ndc[0:5] + v_ndc[6:6+4] + v_ndc[11:11 + 2]
        elif v_format == '5-4-1':
            ret_ndc = v_ndc[0:5] + v_ndc[6:6+4] + '0' + v_ndc[11:11 + 1]
        elif v_format == '5-3-2':
            ret_ndc = v_ndc[0:5] + '0' + v_ndc[6:6+3] + v_ndc[10:10 + 2]
        elif v_format == '4-4-2':
            ret_ndc = '0' + v_ndc[0:4] + v_ndc[5:5+4] + v_ndc[10:10 + 2]
    elif len(v_ndc) == 11 and '-' not in v_ndc:
        ret_ndc = v_ndc
    else:
        ret_ndc = ''
    ret_ndc = ret_ndc.replace('*','0')
    return ret_ndc
