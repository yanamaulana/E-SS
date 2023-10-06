<?php
defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Delete all files and directories inside a directory recursively.
 *
 * @param string $directory The path to the directory
 * @param bool $deleteSelf Whether to delete the directory itself
 * @return bool True on success, false on failure
 */
function delete_files($directory, $deleteSelf = false)
{
    $ci = &get_instance();
    $ci->load->helper('file');

    // Check if the directory exists
    if (!is_dir($directory)) {
        return false;
    }

    $items = array_diff(scandir($directory), array('.', '..'));

    foreach ($items as $item) {
        $path = $directory . '/' . $item;

        $segments = explode('/', $path);
        $filename = end($segments);

        if ($filename != 'index.html') {
            // Delete files
            if (is_file($path)) {
                unlink($path);
            }

            // Delete directories
            if (is_dir($path)) {
                delete_files($path, true);
            }
        }
    }

    // Delete the directory itself if specified
    // if ($deleteSelf) {
    //     rmdir($directory);
    // }

    return true;
}
