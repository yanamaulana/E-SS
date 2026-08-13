<?php
defined('BASEPATH') or exit('No direct script access allowed');

class RevertAccess extends CI_Controller
{
    /**
     * Skrip Scheduler (Cron Job) untuk mengembalikan hak akses sementara.
     * Fungsi ini HANYA boleh dijalankan melalui Command Line (CLI).
     */
    public function revert_permissions()
    {
        // 1. Keamanan: Pastikan skrip ini hanya dijalankan dari CLI (Cron Job)
        if (!is_cli()) {
            echo "This script can only be accessed via the command line.";
            show_error('Forbidden', 403);
            return;
        }

        echo "Starting permission revert process at " . date('Y-m-d H:i:s') . "\n";

        // 2. Cari semua hak akses yang sudah waktunya dikembalikan
        $permissions_to_revert = $this->db->where('Revert_At <=', date('Y-m-d H:i:s'))
            ->where('Is_Reverted', 0)
            ->get('TblTemporaryAccessLog')
            ->result();

        if (empty($permissions_to_revert)) {
            echo "No permissions to revert at this time.\n";
            return;
        }

        echo "Found " . count($permissions_to_revert) . " permission(s) to revert.\n";

        $reverted_count = 0;
        // 3. Loop dan proses setiap hak akses
        foreach ($permissions_to_revert as $log) {
            $this->db->trans_start();

            // a. Kembalikan hak akses di tabel utama
            $this->db->where('UserGroupFuncL_ID', $log->UserGroupFuncL_ID)
                ->update('TUserGroupFuncL', ['sf_ufunc_access' => $log->Previous_Access]);

            // b. Tandai bahwa log ini sudah diproses
            $this->db->where('Log_ID', $log->Log_ID)
                ->update('TblTemporaryAccessLog', [
                    'Is_Reverted' => 1,
                    'Reverted_At' => date('Y-m-d H:i:s')
                ]);

            $this->db->trans_complete();

            if ($this->db->trans_status() === FALSE) {
                $this->db->trans_rollback();
                echo "Failed to revert access for Log_ID: " . $log->Log_ID . ". Rolling back.\n";
            } else {
                $this->db->trans_commit();
                echo "Successfully reverted access for UserGroupFuncL_ID: " . $log->UserGroupFuncL_ID . " (Log_ID: " . $log->Log_ID . ")\n";
                $reverted_count++;
            }
        }

        echo "Process finished. " . $reverted_count . " permission(s) were successfully reverted.\n";
    }
}
