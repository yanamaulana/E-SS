<?php
defined('BASEPATH') or exit('No direct script access allowed');

/**
 * DataTable Helper
 * Reusable functions for DataTables server-side processing
 * Used by multiple controllers for consistent DataTable handling
 */

if (!function_exists('dt_get_order')) {
    /**
     * Get validated column order and direction from DataTables request
     * 
     * @param array $requestData $_REQUEST from DataTables
     * @param array $columns Array of valid column names
     * @return array [column_name, direction]
     */
    function dt_get_order(array $requestData, array $columns): array
    {
        $columnIndex = isset($requestData['order'][0]['column']) ? intval($requestData['order'][0]['column']) : 0;
        $direction = strtoupper($requestData['order'][0]['dir'] ?? 'ASC');

        if (!isset($columns[$columnIndex])) {
            $columnIndex = 0;
        }

        if ($direction !== 'ASC' && $direction !== 'DESC') {
            $direction = 'ASC';
        }

        return [$columns[$columnIndex], $direction];
    }
}

if (!function_exists('dt_build_like_condition')) {
    /**
     * Build parameterized LIKE search condition for SQL
     * Uses CodeIgniter's escape_like_str() to prevent SQL injection
     * 
     * @param string $searchValue Search keyword
     * @param array $searchColumns Columns to search
     * @param object $ci CodeIgniter instance (uses $this->db)
     * @return string SQL search condition or empty string
     */
    function dt_build_like_condition(string $searchValue, array $searchColumns, $ci): string
    {
        if ($searchValue === '') {
            return '';
        }

        $escapedSearch = $ci->db->escape_like_str($searchValue);
        $conditions = array_map(function ($column) use ($escapedSearch) {
            return "$column LIKE '%{$escapedSearch}%'";
        }, $searchColumns);

        return ' AND (' . implode(' OR ', $conditions) . ') ';
    }
}

if (!function_exists('dt_build_fts_condition')) {
    /**
     * Build SQL Server Full-Text Search CONTAINS condition
     * For advanced text search using FTS indexes
     * 
     * @param string $searchValue Search keyword
     * @param array $searchColumns Columns to search (FTS indexed)
     * @param object $ci CodeIgniter instance (uses $this->db)
     * @return string SQL FTS condition or empty string
     */
    function dt_build_fts_condition(string $searchValue, array $searchColumns, $ci): string
    {
        if ($searchValue === '') {
            return '';
        }

        $ftsKeyword = "'\"*" . $ci->db->escape_str($searchValue) . "*\"'";
        $columnStr = implode(', ', $searchColumns);

        return " AND (CONTAINS(($columnStr), $ftsKeyword)) ";
    }
}

if (!function_exists('dt_format_datetime')) {
    /**
     * Format datetime string to specified format
     * Returns '-' for empty/null values
     * 
     * @param string|null $datetime Datetime string
     * @param string $format PHP date format (default: Y-m-d H:i)
     * @return string Formatted datetime or '-'
     */
    function dt_format_datetime(?string $datetime, string $format = 'Y-m-d H:i'): string
    {
        return !empty($datetime) ? date($format, strtotime($datetime)) : '-';
    }
}

if (!function_exists('dt_map_row')) {
    /**
     * Map database row to output array with optional transforms
     * Supports callable transforms for custom field processing
     * 
     * @param array $row Database row data
     * @param array $fieldMap Mapping of output_key => database_column
     * @param array $transforms Optional [output_key => callable] for custom transforms
     * @return array Mapped and transformed row
     */
    function dt_map_row(array $row, array $fieldMap, array $transforms = []): array
    {
        $result = [];
        foreach ($fieldMap as $outputKey => $rowKey) {
            $value = $row[$rowKey] ?? null;

            if (isset($transforms[$outputKey])) {
                $value = call_user_func($transforms[$outputKey], $value);
            }

            $result[$outputKey] = $value;
        }
        return $result;
    }
}

if (!function_exists('dt_build_response')) {
    /**
     * Build complete DataTables response with pagination and filtering
     * Handles both LIKE and FTS search modes
     * 
     * @param string $baseSql Base SQL query (before WHERE search conditions)
     * @param array $orderColumns Valid columns for ordering
     * @param array $searchColumns Columns to search
     * @param array $fieldMap Row mapping configuration
     * @param array $requestData $_REQUEST from DataTables
     * @param object $ci CodeIgniter instance
     * @param bool $useFts Use Full-Text Search instead of LIKE (default: false)
     * @param array $transforms Optional row transforms
     * @return array DataTables response [draw, recordsTotal, recordsFiltered, data]
     */
    function dt_build_response(
        string $baseSql,
        array $orderColumns,
        array $searchColumns,
        array $fieldMap,
        array $requestData,
        $ci,
        bool $useFts = false,
        array $transforms = []
    ): array {
        list($order, $dir) = dt_get_order($requestData, $orderColumns);
        $start = isset($requestData['start']) ? intval($requestData['start']) : 0;
        $length = isset($requestData['length']) ? intval($requestData['length']) : 10;
        $searchValue = trim($requestData['search']['value'] ?? '');

        // Build search condition
        if ($useFts) {
            $searchCondition = dt_build_fts_condition($searchValue, $searchColumns, $ci);
        } else {
            $searchCondition = dt_build_like_condition($searchValue, $searchColumns, $ci);
        }

        $filteredSql = $baseSql . $searchCondition;

        // Count total and filtered records
        $totalData = $ci->db->query($baseSql)->num_rows();
        $totalFiltered = $ci->db->query($filteredSql)->num_rows();

        // Paginate and fetch data
        $pageSql = $filteredSql . " ORDER BY $order $dir OFFSET $start ROWS FETCH NEXT $length ROWS ONLY ";
        $query = $ci->db->query($pageSql);

        $data = [];
        foreach ($query->result_array() as $row) {
            $data[] = dt_map_row($row, $fieldMap, $transforms);
        }

        return [
            'draw' => intval($requestData['draw'] ?? 0),
            'recordsTotal' => intval($totalData),
            'recordsFiltered' => intval($totalFiltered),
            'data' => $data,
        ];
    }
}
