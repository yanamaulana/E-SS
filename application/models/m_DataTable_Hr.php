<?php

/**
 * Models     : Datatables serverside based php
 * Modified   : Fauzan Falah
 * Website    : https://www.codekop.com/
 * 
 * 
 * 
 * 
 */
class m_DataTable_Hr extends CI_Model
{
    private $HR;
    function __construct()
    {
        parent::__construct();
        $this->HR = $this->load->database('HR', TRUE);
    }

    function get_tables($tables, $cari, $iswhere)
    {
        // Ambil data yang di ketik user pada textbox pencarian
        $search = htmlspecialchars($_POST['search']['value']);
        // Ambil data limit per page
        $limit = preg_replace("/[^a-zA-Z0-9.]/", '', "{$_POST['length']}");
        // Ambil data start
        $start = preg_replace("/[^a-zA-Z0-9.]/", '', "{$_POST['start']}");

        $query = $tables;

        if (!empty($iswhere)) {
            $sql = $this->HR->query("SELECT * FROM " . $query . " WHERE " . $iswhere);
        } else {
            $sql = $this->HR->query("SELECT * FROM " . $query);
        }

        $sql_count = $sql->num_rows();

        $cari = implode(" LIKE '%" . $search . "%' OR ", $cari) . " LIKE '%" . $search . "%'";


        // Untuk mengambil nama field yg menjadi acuan untuk sorting
        $order_field = $_POST['order'][0]['column'];

        // Untuk menentukan order by "ASC" atau "DESC"
        $order_ascdesc = $_POST['order'][0]['dir'];
        $order = " ORDER BY " . $_POST['columns'][$order_field]['data'] . " " . $order_ascdesc;

        if (!empty($iswhere)) {
            $sql_data = $this->HR->query("SELECT * FROM " . $query . " WHERE $iswhere AND (" . $cari . ")" . $order . " OFFSET " . $start . " ROWS FETCH NEXT " . $limit . " ROWS ONLY");
        } else {
            $sql_data = $this->HR->query("SELECT * FROM " . $query . " WHERE (" . $cari . ")" . $order . " OFFSET " . $start . " ROWS FETCH NEXT " . $limit . " ROWS ONLY");
        }


        if (isset($search)) {
            if (!empty($iswhere)) {
                $sql_cari =  $this->HR->query("SELECT * FROM " . $query . " WHERE $iswhere (" . $cari . ")");
            } else {
                $sql_cari =  $this->HR->query("SELECT * FROM " . $query . " WHERE (" . $cari . ")");
            }
            $sql_filter_count = $sql_cari->num_rows();
        } else {
            if (!empty($iswhere)) {
                $sql_filter = $this->HR->query("SELECT * FROM " . $query . "WHERE " . $iswhere);
            } else {
                $sql_filter = $this->HR->query("SELECT * FROM " . $query);
            }
            $sql_filter_count = $sql_filter->num_rows();
        }
        $data = $sql_data->result_array();

        $callback = array(
            'draw' => $_POST['draw'], // Ini dari datatablenya
            'recordsTotal' => $sql_count,
            'recordsFiltered' => $sql_filter_count,
            'data' => $data
        );
        return json_encode($callback); // Convert array $callback ke json
    }

    function get_tables_where($tables, $cari, $where, $iswhere)
    {
        // Ambil data yang di ketik user pada textbox pencarian
        $search = htmlspecialchars($_POST['search']['value']);
        // Ambil data limit per page
        $limit = preg_replace("/[^a-zA-Z0-9.]/", '', "{$_POST['length']}");
        // Ambil data start
        $start = preg_replace("/[^a-zA-Z0-9.]/", '', "{$_POST['start']}");

        $setWhere = array();
        foreach ($where as $key => $value) {
            $setWhere[] = $key . " like '%" . $value . "%'";
        }

        $fwhere = implode(' AND ', $setWhere);

        if (!empty($iswhere)) {
            $sql = $this->HR->query("SELECT * FROM " . $tables . " WHERE $iswhere AND " . $fwhere);
        } else {
            $sql = $this->HR->query("SELECT * FROM " . $tables . " WHERE " . $fwhere);
        }
        $sql_count = $sql->num_rows();

        $query = $tables;
        $cari = implode(" LIKE '%" . $search . "%' OR ", $cari) . " LIKE '%" . $search . "%'";

        // Untuk mengambil nama field yg menjadi acuan untuk sorting
        $order_field = $_POST['order'][0]['column'];

        // Untuk menentukan order by "ASC" atau "DESC"
        $order_ascdesc = $_POST['order'][0]['dir'];
        $order = " ORDER BY " . $_POST['columns'][$order_field]['data'] . " " . $order_ascdesc;

        if (!empty($iswhere)) {
            $sql_data = $this->HR->query("SELECT * FROM (SELECT *, ROW_NUMBER() OVER (" . $order . ") AS row_num FROM " . $query . " WHERE $iswhere AND " . $fwhere . " AND (" . $cari . ")) AS temp_table WHERE row_num BETWEEN " . ($start + 1) . " AND " . ($start + $limit));
        } else {
            $sql_data = $this->HR->query("SELECT * FROM (SELECT *, ROW_NUMBER() OVER (" . $order . ") AS row_num FROM " . $query . " WHERE " . $fwhere . " AND (" . $cari . ")) AS temp_table WHERE row_num BETWEEN " . ($start + 1) . " AND " . ($start + $limit));
        }


        if (isset($search)) {
            if (!empty($iswhere)) {
                $sql_cari =  $this->HR->query("SELECT * FROM " . $query . " WHERE $iswhere AND " . $fwhere . " AND (" . $cari . ")");
            } else {
                $sql_cari =  $this->HR->query("SELECT * FROM " . $query . " WHERE " . $fwhere . " AND (" . $cari . ")");
            }
            $sql_filter_count = $sql_cari->num_rows();
        } else {
            if (!empty($iswhere)) {
                $sql_filter = $this->HR->query("SELECT * FROM " . $tables . " WHERE $iswhere AND " . $fwhere);
            } else {
                $sql_filter = $this->HR->query("SELECT * FROM " . $tables . " WHERE " . $fwhere);
            }
            $sql_filter_count = $sql_filter->num_rows();
        }

        $data = $sql_data->result_array();

        $callback = array(
            'draw' => $_POST['draw'], // Ini dari datatablenya    
            'recordsTotal' => $sql_count,
            'recordsFiltered' => $sql_filter_count,
            'data' => $data
        );
        return json_encode($callback); // Convert array $callback ke json
    }

    function get_tables_query($query, $cari, $where, $iswhere)
    {
        // Ambil data yang di ketik user pada textbox pencarian
        $search = htmlspecialchars($_POST['search']['value']);
        // Ambil data limit per page
        $limit = preg_replace("/[^a-zA-Z0-9.]/", '', "{$_POST['length']}");
        // Ambil data start
        $start = preg_replace("/[^a-zA-Z0-9.]/", '', "{$_POST['start']}");

        if ($where != null) {
            $setWhere = array();
            foreach ($where as $key => $value) {
                $setWhere[] = $key . "='" . $value . "'";
            }
            $fwhere = implode(' AND ', $setWhere);

            if (!empty($iswhere)) {
                $sql = $this->HR->query($query . " WHERE  $iswhere AND " . $fwhere);
            } else {
                $sql = $this->HR->query($query . " WHERE " . $fwhere);
            }
            $sql_count = $sql->num_rows();

            $cari = implode(" LIKE '%" . $search . "%' OR ", $cari) . " LIKE '%" . $search . "%'";

            // Untuk mengambil nama field yg menjadi acuan untuk sorting
            $order_field = $_POST['order'][0]['column'];

            // Untuk menentukan order by "ASC" atau "DESC"
            $order_ascdesc = $_POST['order'][0]['dir'];
            $order = " ORDER BY " . $_POST['columns'][$order_field]['data'] . " " . $order_ascdesc;

            if (!empty($iswhere)) {
                $sql_data = $this->HR->query($query . " WHERE $iswhere AND " . $fwhere . " AND (" . $cari . ")" . $order . " LIMIT " . $limit . " OFFSET " . $start);
            } else {
                $sql_data = $this->HR->query($query . " WHERE " . $fwhere . " AND (" . $cari . ")" . $order . " LIMIT " . $limit . " OFFSET " . $start);
            }

            if (isset($search)) {
                if (!empty($iswhere)) {
                    $sql_cari =  $this->HR->query($query . " WHERE $iswhere AND " . $fwhere . " AND (" . $cari . ")");
                } else {
                    $sql_cari =  $this->HR->query($query . " WHERE " . $fwhere . " AND (" . $cari . ")");
                }
                $sql_filter_count = $sql_cari->num_rows();
            } else {
                if (!empty($iswhere)) {
                    $sql_filter = $this->HR->query($query . " WHERE $iswhere AND " . $fwhere);
                } else {
                    $sql_filter = $this->HR->query($query . " WHERE " . $fwhere);
                }
                $sql_filter_count = $sql_filter->num_rows();
            }
            $data = $sql_data->result_array();
        } else {

            $sql = $this->HR->query($query);


            $sql_count =  $sql->num_rows();

            // $cari = implode(" LIKE '%" . $search . "%' OR ", $cari) . " LIKE '%" . $search . "%'";

            // // Untuk mengambil nama field yg menjadi acuan untuk sorting
            // $order_field = $_POST['order'][0]['column'];

            // // Untuk menentukan order by "ASC" atau "DESC"
            // $order_ascdesc = $_POST['order'][0]['dir'];
            // $order = " ORDER BY " . $_POST['columns'][$order_field]['data'] . " " . $order_ascdesc;

            // if (!empty($iswhere)) {
            //     $sql_data = $this->HR->query($query . " WHERE $iswhere AND (" . $cari . ")" . $order . " LIMIT " . $limit . " OFFSET " . $start);
            // } else {
            //     $sql_data = $this->HR->query($query . " WHERE (" . $cari . ")" . $order . " LIMIT " . $limit . " OFFSET " . $start);
            // }

            // if (isset($search)) {
            //     if (!empty($iswhere)) {
            //         $sql_cari =  $this->HR->query($query . " WHERE $iswhere AND (" . $cari . ")");
            //     } else {
            //         $sql_cari =  $this->HR->query($query . " WHERE (" . $cari . ")");
            //     }
            //     $sql_filter_count = $sql_cari->num_rows();
            // } else {
            //     if (!empty($iswhere)) {
            //         $sql_filter = $this->HR->query($query . " WHERE $iswhere");
            //     } else {
            //         $sql_filter = $this->HR->query($query);
            //     }
            // }
            $sql_filter_count = $sql->num_rows();
            $data =  $sql->result_array();
        }

        $callback = array(
            'draw' => $_POST['draw'], // Ini dari datatablenya    
            'recordsTotal' => $sql_count,
            'recordsFiltered' => $sql_filter_count,
            'data' => $data
        );
        return json_encode($callback); // Convert array $callback ke json
    }

    function get_tables_query_csrf($query, $cari, $where, $csrf_name, $csrf_hash)
    {
        // Ambil data yang di ketik user pada textbox pencarian
        $search = htmlspecialchars($_POST['search']['value']);
        // Ambil data limit per page
        $limit = preg_replace("/[^a-zA-Z0-9.]/", '', "{$_POST['length']}");
        // Ambil data start
        $start = preg_replace("/[^a-zA-Z0-9.]/", '', "{$_POST['start']}");

        if ($where != null) {
            $setWhere = array();
            foreach ($where as $key => $value) {
                $setWhere[] = $key . "='" . $value . "'";
            }

            $fwhere = implode(' AND ', $setWhere);

            $sql = $this->HR->query($query . " WHERE " . $fwhere);
            $sql_count = $sql->num_rows();

            $cari = implode(" LIKE '%" . $search . "%' OR ", $cari) . " LIKE '%" . $search . "%'";

            // Untuk mengambil nama field yg menjadi acuan untuk sorting
            $order_field = $_POST['order'][0]['column'];

            // Untuk menentukan order by "ASC" atau "DESC"
            $order_ascdesc = $_POST['order'][0]['dir'];
            $order = " ORDER BY " . $_POST['columns'][$order_field]['data'] . " " . $order_ascdesc;

            $sql_data = $this->HR->query($query . " WHERE " . $fwhere . " AND (" . $cari . ")" . $order . " LIMIT " . $limit . " OFFSET " . $start);
            $sql_filter = $this->HR->query($query . " WHERE " . $fwhere);

            if (isset($search)) {
                $sql_cari =  $this->HR->query($query . " WHERE " . $fwhere . " AND (" . $cari . ")");
                $sql_filter_count = $sql_cari->num_rows();
            } else {
                $sql_filter_count = $sql_filter->num_rows();
            }

            $data = $sql_data->result_array();
        } else {

            $sql = $this->HR->query($query);
            $sql_count = $sql->num_rows();

            $cari = implode(" LIKE '%" . $search . "%' OR ", $cari) . " LIKE '%" . $search . "%'";

            // Untuk mengambil nama field yg menjadi acuan untuk sorting
            $order_field = $_POST['order'][0]['column'];

            // Untuk menentukan order by "ASC" atau "DESC"
            $order_ascdesc = $_POST['order'][0]['dir'];
            $order = " ORDER BY " . $_POST['columns'][$order_field]['data'] . " " . $order_ascdesc;

            $sql_data = $this->HR->query($query . " WHERE (" . $cari . ")" . $order . " LIMIT " . $limit . " OFFSET " . $start);
            $sql_filter = $this->HR->query($query);

            if (isset($search)) {
                $sql_cari =  $this->HR->query($query . " WHERE (" . $cari . ")");
                $sql_filter_count = $sql_cari->num_rows();
            } else {
                $sql_filter_count = $sql_filter->num_rows();
            }

            $data = $sql_data->result_array();
        }

        $callback = array(
            'draw' => $_POST['draw'], // Ini dari datatablenya    
            'recordsTotal' => $sql_count,
            'recordsFiltered' => $sql_filter_count,
            'data' => $data
        );
        $callback[$csrf_name] = $csrf_hash;

        return json_encode($callback); // Convert array $callback ke json
    }
}
