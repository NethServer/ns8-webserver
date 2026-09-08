<?php
/*
 * Copyright (C) 2026 Nethesis S.r.l.
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Loaded is not usable: php -m lists gd whether or not it was built with
 * WebP, and lists pdo_mysql whether or not the driver registered. Each check
 * returns true or the message to print.
 */

$checks = [
    'bcmath' => fn() => function_exists('bcadd'),
    'bz2' => fn() => function_exists('bzopen'),
    'calendar' => fn() => function_exists('jdtogregorian'),
    'exif' => fn() => function_exists('exif_read_data'),
    'ftp' => fn() => function_exists('ftp_connect'),
    'gmp' => fn() => function_exists('gmp_add'),
    'imap' => fn() => function_exists('imap_open'),
    'intl' => fn() => class_exists('Collator'),
    'ldap' => fn() => function_exists('ldap_connect'),
    'mysqli' => fn() => class_exists('mysqli'),
    'opcache' => fn() => extension_loaded('Zend OPcache'),
    'pcntl' => fn() => function_exists('pcntl_fork'),
    'pgsql' => fn() => function_exists('pg_connect'),
    'soap' => fn() => class_exists('SoapClient'),
    'sockets' => fn() => function_exists('socket_create'),
    'tidy' => fn() => class_exists('tidy'),
    'xml' => fn() => function_exists('xml_parser_create'),
    'xsl' => fn() => class_exists('XSLTProcessor'),
    'zip' => fn() => class_exists('ZipArchive'),

    'gd' => function () {
        $info = gd_info();
        $features = ['FreeType Support', 'JPEG Support', 'PNG Support', 'WebP Support', 'XPM Support'];
        foreach ($features as $feature) {
            if (empty($info[$feature])) {
                return "gd was built without {$feature}";
            }
        }
        return true;
    },

    'imagick' => function () {
        $missing = array_diff(['PNG', 'JPEG', 'GIF', 'WEBP'], Imagick::queryFormats());
        return $missing ? 'imagick handles no ' . implode(', ', $missing) : true;
    },

    'pdo' => function () {
        $missing = array_diff(['mysql', 'pgsql', 'sqlite'], PDO::getAvailableDrivers());
        return $missing ? 'PDO has no driver for ' . implode(', ', $missing) : true;
    },
];

$failed = 0;

foreach ($checks as $name => $check) {
    $result = $check();
    if ($result === true) {
        continue;
    }
    $failed++;
    echo is_string($result) ? $result : "{$name} is loaded but not usable", PHP_EOL;
}

if ($failed > 0) {
    echo "{$failed} runtime check(s) failed", PHP_EOL;
    exit(1);
}

echo 'All runtime checks passed: ' . implode(' ', array_keys($checks)), PHP_EOL;
