#!/usr/bin/env python

# @szj^17Mar10
# check qc_summary_brief according to docs/qc_summary_standards.md

import sys
import os
import pandas as pd
import numpy as np
import click
import re
from itertools import chain

PANEL_PATH = '/lustre/project/og04/pub/database/panel_ca_pm'
STD = {
        # depends on expect_size_Gb
        'size_Gb': [0.3, 2],
        '%(G+C)': [40, 50],
        '%N': [0, 5],
        '%Q20': [80, 100],
        '%Q20': [75, 100],
        'low_qual_filter(%)': [0, 10],
        'adapter_filter(%)': [0, 5],
        'duplicated_filter(%)': [0, 50],
        'mapping_rate': [0.97, 1],
        'coverage_cent': [0.9, 1],
        'specifity_cent': [0.4, 1],
        'uniformity_cent': [0.99, 1],
        # depends on expect_depth
        'capture_depth_1X': [0.5, 2],
        'samtools_dups': [0, 0.8],
        'insert_size': [100, 300],
        # depends on expect_depth
        'seq_depth': [1, 3],
        'trim_adapter': [0, 0.2],
        # depends on capture_depth_1X
        'mut_dep': [0.2, 4],
        }
STD_loose = {
        # depends on expect_size_Gb
        'size_Gb': [0.3, 2],
        '%(G+C)': [40, 55],
        '%N': [0, 5],
        '%Q20': [80, 100],
        '%Q20': [75, 100],
        'low_qual_filter(%)': [0, 10],
        'adapter_filter(%)': [0, 5],
        'duplicated_filter(%)': [0, 50],
        'mapping_rate': [0.97, 1],
        'coverage_cent': [0.9, 1],
        'specifity_cent': [0.4, 1],
        'uniformity_cent': [0.99, 1],
        # depends on expect_depth
        'capture_depth_1X': [0.2, 2],
        'samtools_dups': [0, 0.9],
        'insert_size': [100, 300],
        # depends on expect_depth
        'seq_depth': [0.5, 3],
        'trim_adapter': [0, 0.2],
        # depends on capture_depth_1X
        'mut_dep': [0.05, 4],
        }
qc_table = ''
for key, value in STD.iteritems():
    qc_table += key + '\t' + str(STD[key][0]) + '\t' + str(STD[key][1]) + '\n'
# cache
PANEL_SIZE = {}

def help():
    click.echo("run '{} --help' for help info".format(sys.argv[0]))
    exit()


@click.command()
@click.option('-v', '--verbose', is_flag=True, help="will print verbose messages.\n\n" + "QC_STANDARDS:\n" + qc_table + '\n----\n')
@click.argument('input_qc')
def main(input_qc, verbose=False):
    """
    load <qc_summary_brief.txt> file as pd object,
    and filter according to qc standards
    """
    if verbose:
        click.echo("> verbose mode activated")
    if not os.path.exists(input_qc):
        click.echo('! no such file: {}'.format(input_qc))
        exit()
    if verbose:
        click.echo("> use qc_summary file: {}".format(os.path.abspath(input_qc)))
    qc = pd.read_table(input_qc, na_values = '-')
    if verbose:
        click.echo(">> load successful")
        click.echo(">> column names:")
        click.echo("\t".join(list(qc.columns)))
        # click.echo(">> first line:")
        # click.echo(qc.head(1))
        click.echo('')

    # prepare extra info
    qc['expect_depth'] = [extract_depth(x, verbose) for x in qc['#sample']]
    qc['panel_size'] = [calc_panel_size(extract_panel_type(x, verbose), verbose) for x in qc['#sample']]
    qc['expect_size'] = qc['expect_depth'] * qc['panel_size']
    qc['expect_size_Gb'] = qc['expect_depth'] * qc['panel_size'] / 1000 / 1000 / 1000

    # for x in range(qc.shape[0]):
        # print(qc.loc[x])
    reject_samples = set(list(chain.from_iterable([is_qualified(qc.loc[x], verbose=verbose)[0] for x in range(qc.shape[0])])))
    reject_samples_loose = set(list(chain.from_iterable([is_qualified(qc.loc[x], verbose=verbose,n=1)[1] for x in range(qc.shape[0])])))
    if len(reject_samples) == 0:
        print('> all passed strict')
    else:
        print('> filtered samples strict ({}):\t'.format(len(reject_samples)) + '\t'.join(sorted(reject_samples)))
        if len(reject_samples_loose) == 0:
            print('> all passed loose')
        else:
            print('> filtered samples loose ({}):\t'.format(len(reject_samples_loose)) + '\t'.join(sorted(reject_samples_loose)))
    exit(0)


def extract_depth(sample, verbose=False):
    hit0 = re.findall(r'(\d+\w)x', sample)
    if len(hit0) != 0:
        hit = hit0[0].replace('k', '000')
    else:
        hit = 0
    # if verbose:
        # print('>>>> [extract_depth] input: {}, match: {}, depth: {}'.format(sample, hit0, hit))
    return int(hit)


def extract_panel_type(sample, verbose=False):
    hit0 = re.findall(r'\d+b', sample)
    if len(hit0) != 0:
        hit = hit0[0]
    else:
        hit = None
    return hit


def get_panel_bed(panel_type, verbose=False):
    """
    get panel_bed file from default path
    """
    panel_bed = os.path.join(PANEL_PATH, 'panel' + panel_type + '.bed')
    if not os.path.exists(panel_bed):
        click.echo('! no valid panel_bed: {}'.format(panel_bed))
        exit()
    # click.echo('get panel_bed: {}'.format(panel_bed))
    return panel_bed


def calc_panel_size(panel_type, verbose=False):
    if panel_type is None:
        return 0
    if panel_type in PANEL_SIZE:
        # print('use existing')
        return PANEL_SIZE[panel_type]
    # print('new')
    panel_bed = get_panel_bed(panel_type, verbose=verbose)
    with open(panel_bed) as f:
        size = 0
        for line in f:
            if line.startswith('#'):
                continue
            line = line.strip()
            try:
                chrom, start, end = line.split()
            except ValueError:
                print('! not valid input line:\n{}\nin bed file: {}'.format(line, panel_bed))
                exit(1)
            size += int(end) - int(start) + 1
    PANEL_SIZE[panel_type] = size
    return size


def is_qualified(row, verbose=False, STD=STD,n=0):
    """
    after added expect_depth and expect_size
    input: series object of qc_summary row
    """
    dd = {}
    reject_samples = []
    reject_samples_loose = []

    colnames = list(row.index)
    sample = row['#sample']
    for col in colnames:
        # print("col: {}\tcontent: {}".format(col, row[col]))
        dd[col] = row[col]

    # filter
    std = dict((k,v) for k,v in STD.items())
    std['size_Gb'] = [STD['size_Gb'][0] * dd['expect_size_Gb'],
            STD['size_Gb'][1] * dd['expect_size_Gb']]
    std['capture_depth_1X'] = [STD['capture_depth_1X'][0] * dd['expect_depth'],
            STD['capture_depth_1X'][1] * dd['expect_depth']]
    std['seq_depth'] = [STD['seq_depth'][0] * dd['expect_depth'],
            STD['seq_depth'][1] * dd['expect_depth']]
    std['mut_dep'] = [STD['mut_dep'][0] * dd['capture_depth_1X'],
            STD['mut_dep'][1] * dd['capture_depth_1X']]
    std_loose = dict((k,v) for k,v in STD_loose.items())
    std_loose['size_Gb'] = [STD_loose['size_Gb'][0] * dd['expect_size_Gb'],
            STD_loose['size_Gb'][1] * dd['expect_size_Gb']]
    std_loose['capture_depth_1X'] = [STD_loose['capture_depth_1X'][0] * dd['expect_depth'],
            STD_loose['capture_depth_1X'][1] * dd['expect_depth']]
    std_loose['seq_depth'] = [STD_loose['seq_depth'][0] * dd['expect_depth'],
            STD_loose['seq_depth'][1] * dd['expect_depth']]
    std_loose['mut_dep'] = [STD_loose['mut_dep'][0] * dd['capture_depth_1X'],
            STD_loose['mut_dep'][1] * dd['capture_depth_1X']]
    # for k, v in dd.iteritems():
        # print('dd: {}\t{}'.format(k, v))
    # for k, v in std.iteritems():
        # print('std: {}\t{}'.format(k, v))
    if n==0:
        for key, value in dd.iteritems():
            if key not in std:
                continue
            if std[key][0] <= float(value) <= std[key][1]:
                # print('pass')
                pass
            elif key == 'mut_dep' and str(value) == 'nan':
                pass
            else:
                print('>> reject: {s} on {k} with {v} outside {down} to {up}'.format(s = sample, k = key, v = value, down = std[key][0], up = std[key][1]))
                reject_samples.append(sample)
    else:
        for key, value in dd.iteritems():
            if key not in std_loose:
                continue
            if std_loose[key][0] <= float(value) <= std_loose[key][1]:
                # print('pass')
                pass
            elif key == 'mut_dep' and str(value) == 'nan':
                pass
            else:
                print('>> reject loose: {s} on {k} with {v} outside {down} to {up}'.format(s = sample, k = key, v = value, down = std_loose[key][0], up = std_loose[key][1]))
                reject_samples_loose.append(sample)
    return (reject_samples, reject_samples_loose)

# TODO
# get outlier in each column

# ==== test case
# print(get_panel_bed(panel_type='11b'))
# print(extract_panel_type('HD734S1GD50ng2kx3b1'))
# print(extract_depth('HD734S1GD50ng2kx3b1'))
# print(calc_panel_size('3b'))
# print(calc_panel_size('3b'))
# print(calc_panel_size('11b'))

if __name__ == '__main__':
    if len(sys.argv) == 1:
        help()
    main()
