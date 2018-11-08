<?php
/**
 * @author Karsten Deubert <info@deubert.it>
 *
 * Script to generate random sql testdata.
 *
 * row count <-> file size
 *
 * docker image size base mysql:5.6                             = 256MB
 * docker image size example01                                  = 377MB
 *
 * s1.sql       = 1000 rows         = 139872        = 139KB     = 444MB
 * s10.sql      = 10.000 rows       = 1396915       = 1.39MB    = 453MB
 * s100.sql     = 100.000 rows      = 13966641      = 13.9MB    = 460MB
 * s1000.sql    = 1.000.000 rows    = 139666872     = 139MB     = 528MB
 * s10000.sql   = 10.000.000 rows   = 1396665687    = 1.39GB
 */

$opt = getopt('s:o:');

if (!array_key_exists('s', $opt) || empty($opt['s'])) {
    die('missing parameter s for size in 1 = 1000 rows');
}
if (!array_key_exists('o', $opt) || empty($opt['o'])) {
    die('missing parameter o for output file');
}

$pattern = "INSERT INTO `test01`.`test01table` (`id`, `a`, `b`, `c`, `d`) VALUES (NULL, %d, %d, %d, '%s');\n";

$fp = fopen($opt['o'], 'w+');

fwrite($fp, '-- generated on '.date('Y-m-d H:i:s')."\n");
fwrite($fp, '-- size: '.$opt['s']."\n");
fwrite($fp, 'USE test01;'."\n");

for ($i = 0; $i <= ((int)$opt['s']*1000); $i++) {
    fwrite($fp, sprintf($pattern, mt_rand(1,9999999), mt_rand(1,9999999), mt_rand(1,9999999), md5(mt_rand(1,9999999))));
}

fclose($fp);