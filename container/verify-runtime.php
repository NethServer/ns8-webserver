<?php
/*
 * Copyright (C) 2026 Nethesis S.r.l.
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Loaded is not usable: php -m lists gd whether or not it was built with
 * WebP, and lists pdo_mysql whether or not the driver registered.
 *
 * The extension lists shipped with the image drive the build and this check.
 * Every listed extension needs an entry below, extra entries are allowed for
 * what the lists cannot carry: imap is built differently per PHP version, and
 * OPcache comes from the base image.
 *
 * Each entry returns true, or the message to print.
 */

const LIST_DIR = '/usr/local/share';
const LISTS = ['php-extensions.list', 'pecl-extensions.list'];

$checks = [
    'bcmath' => fn() => function_exists('bcadd'),
    'bz2' => fn() => function_exists('bzopen'),
    'calendar' => fn() => function_exists('jdtogregorian'),
    'exif' => fn() => function_exists('exif_read_data'),
    'ftp' => fn() => function_exists('ftp_connect'),
    'gmp' => fn() => function_exists('gmp_add'),
    'gettext' => fn() => function_exists('gettext'),
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

    'apcu' => function () {
        // The cache is off for the CLI unless apc.enable_cli is set, and storing
        // is what proves the extension works, so the build passes that option
        if (!apcu_enabled()) {
            return function_exists('apcu_store') ? true : 'apcu has no function';
        }
        return apcu_store('verify', 'runtime') && apcu_fetch('verify') === 'runtime'
            ? true
            : 'apcu does not store and fetch a value';
    },

    'igbinary' => fn() => igbinary_unserialize(igbinary_serialize(['x' => 1])) === ['x' => 1]
        ? true
        : 'igbinary does not round-trip a value',

    'redis' => function () {
        if (!class_exists('Redis')) {
            return 'the Redis class is missing';
        }
        // A redis built before igbinary loses the serializer without a word
        return defined('Redis::SERIALIZER_IGBINARY') ? true : 'redis has no igbinary serializer';
    },

    // Not an extension: applications rasterizing PDF shell out to it
    'ghostscript' => function () {
        $probe = sys_get_temp_dir() . '/verify-runtime.ps';
        $page = sys_get_temp_dir() . '/verify-runtime.png';
        $postscript = "%!PS\n/Helvetica findfont 12 scalefont setfont 10 10 moveto (ns8) show showpage\n";

        if (file_put_contents($probe, $postscript) === false) {
            return true;
        }

        exec(
            'gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=png16m -sOutputFile='
                . escapeshellarg($page) . ' ' . escapeshellarg($probe) . ' 2>&1',
            $output,
            $status
        );
        $rendered = $status === 0 && file_exists($page) && filesize($page) > 0;
        @unlink($probe);
        @unlink($page);

        return $rendered ? true : 'ghostscript cannot render a page';
    },

    'pdo_mysql' => fn() => in_array('mysql', PDO::getAvailableDrivers(), true),
    'pdo_pgsql' => fn() => in_array('pgsql', PDO::getAvailableDrivers(), true),
    'pdo_sqlite' => fn() => in_array('sqlite', PDO::getAvailableDrivers(), true),
];

function read_lists(): array
{
    $names = [];

    foreach (LISTS as $file) {
        $path = LIST_DIR . '/' . $file;
        $lines = @file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        if ($lines === false) {
            echo "Cannot read {$path}", PHP_EOL;
            exit(1);
        }
        foreach ($lines as $line) {
            $name = trim(preg_replace('/#.*/', '', $line));
            if ($name !== '') {
                $names[] = $name;
            }
        }
    }

    return $names;
}

$listed = read_lists();

// An extension added to a list without its check would ship untested
$unchecked = array_diff($listed, array_keys($checks));
if ($unchecked) {
    echo 'No runtime check for: ' . implode(', ', $unchecked), PHP_EOL;
    exit(1);
}

$failed = 0;

foreach ($listed as $name) {
    if (!extension_loaded($name)) {
        echo "Extension not loaded: {$name}", PHP_EOL;
        $failed++;
    }
}

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
