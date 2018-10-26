Content-Type: multipart/mixed; boundary="===============1679088749255095862=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] build: Add all remaining exported symbols to the library
 script
Date: Fri, 26 Oct 2018 09:37:03 -0700
Message-ID: <20181026163703.4847-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1679088749255095862==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Only a subset of the LIB_EXPORT symbols reported by
tools/extract-symbols.sh were included in the initial version of
ell/ell.sym
---

The current ell.sym breaks the link step for our non-iwd project.

Let me know (or just edit before committing) if the ELL_0.10 version
needs to be updated too.

 ell/ell.sym | 336 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 336 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 71ec669..9696129 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -94,6 +94,342 @@ global:
 	l_main_quit;
 	l_main_run_with_signal;
 	l_main_get_epoll_fd;
+	/* base64 */
+	l_base64_decode;
+	l_base64_encode;
+	/* checksum */
+	l_checksum_new;
+	l_checksum_new_cmac_aes;
+	l_checksum_new_hmac;
+	l_checksum_clone;
+	l_checksum_free;
+	l_checksum_reset;
+	l_checksum_update;
+	l_checksum_updatev;
+	l_checksum_get_digest;
+	l_checksum_get_string;
+	l_checksum_is_supported;
+	l_checksum_cmac_aes_supported;
+	/* cipher */
+	l_cipher_new;
+	l_aead_cipher_new;
+	l_cipher_free;
+	l_aead_cipher_free;
+	l_cipher_encrypt;
+	l_cipher_encryptv;
+	l_cipher_decrypt;
+	l_cipher_decryptv;
+	l_cipher_set_iv;
+	l_aead_cipher_encrypt;
+	l_aead_cipher_decrypt;
+	l_cipher_is_supported;
+	l_aead_cipher_is_supported;
+	/* dbus */
+	l_dbus_proxy_get_path;
+	l_dbus_proxy_get_interface;
+	l_dbus_proxy_get_property;
+	l_dbus_proxy_set_property;
+	l_dbus_proxy_method_call;
+	l_dbus_client_new;
+	l_dbus_client_destroy;
+	l_dbus_client_set_connect_handler;
+	l_dbus_client_set_disconnect_handler;
+	l_dbus_client_set_ready_handler;
+	l_dbus_client_set_proxy_handlers;
+	l_dbus_message_set_no_reply;
+	l_dbus_message_get_no_reply;
+	l_dbus_message_set_no_autostart;
+	l_dbus_message_get_no_autostart;
+	l_dbus_message_new_method_call;
+	l_dbus_message_new_signal;
+	l_dbus_message_new_method_return;
+	l_dbus_message_new_error_valist;
+	l_dbus_message_new_error;
+	l_dbus_message_ref;
+	l_dbus_message_unref;
+	l_dbus_message_get_error;
+	l_dbus_message_is_error;
+	l_dbus_message_get_arguments_valist;
+	l_dbus_message_get_arguments;
+	l_dbus_message_set_arguments;
+	l_dbus_message_set_arguments_valist;
+	l_dbus_message_get_path;
+	l_dbus_message_get_interface;
+	l_dbus_message_get_member;
+	l_dbus_message_get_destination;
+	l_dbus_message_get_sender;
+	l_dbus_message_get_signature;
+	l_dbus_message_iter_next_entry;
+	l_dbus_message_iter_get_variant;
+	l_dbus_message_iter_get_fixed_array;
+	l_dbus_message_builder_new;
+	l_dbus_message_builder_destroy;
+	l_dbus_message_builder_append_basic;
+	l_dbus_message_builder_enter_container;
+	l_dbus_message_builder_leave_container;
+	l_dbus_message_builder_enter_struct;
+	l_dbus_message_builder_leave_struct;
+	l_dbus_message_builder_enter_array;
+	l_dbus_message_builder_leave_array;
+	l_dbus_message_builder_enter_dict;
+	l_dbus_message_builder_leave_dict;
+	l_dbus_message_builder_enter_variant;
+	l_dbus_message_builder_leave_variant;
+	l_dbus_message_builder_append_from_iter;
+	l_dbus_message_builder_append_from_valist;
+	l_dbus_message_builder_finalize;
+	l_dbus_interface_method;
+	l_dbus_interface_signal;
+	l_dbus_interface_property;
+	l_dbus_property_changed;
+	l_dbus_new;
+	l_dbus_new_default;
+	l_dbus_destroy;
+	l_dbus_set_ready_handler;
+	l_dbus_set_disconnect_handler;
+	l_dbus_set_debug;
+	l_dbus_send_with_reply;
+	l_dbus_send;
+	l_dbus_cancel;
+	l_dbus_register;
+	l_dbus_unregister;
+	l_dbus_method_call;
+	l_dbus_register_interface;
+	l_dbus_unregister_interface;
+	l_dbus_register_object;
+	l_dbus_unregister_object;
+	l_dbus_object_add_interface;
+	l_dbus_object_remove_interface;
+	l_dbus_object_manager_enable;
+	l_dbus_add_disconnect_watch;
+	l_dbus_add_service_watch;
+	l_dbus_remove_watch;
+	l_dbus_add_signal_watch;
+	l_dbus_remove_signal_watch;
+	l_dbus_name_acquire;
+	/* dhcp */
+	l_dhcp_lease_get_address;
+	l_dhcp_lease_get_gateway;
+	l_dhcp_lease_get_netmask;
+	l_dhcp_lease_get_broadcast;
+	l_dhcp_lease_get_server_id;
+	l_dhcp_lease_get_t1;
+	l_dhcp_lease_get_t2;
+	l_dhcp_lease_get_lifetime;
+	l_dhcp_client_new;
+	l_dhcp_client_destroy;
+	l_dhcp_client_add_request_option;
+	l_dhcp_client_set_address;
+	l_dhcp_client_set_interface_name;
+	l_dhcp_client_set_hostname;
+	l_dhcp_client_get_lease;
+	l_dhcp_client_start;
+	l_dhcp_client_stop;
+	l_dhcp_client_set_event_handler;
+	/* dir */
+	l_dir_watch_new;
+	l_dir_watch_destroy;
+	/* file */
+	l_file_get_contents;
+	/* genl */
+	l_genl_new;
+	l_genl_new_default;
+	l_genl_ref;
+	l_genl_unref;
+	l_genl_set_debug;
+	l_genl_set_close_on_unref;
+	l_genl_set_unicast_handler;
+	l_genl_msg_new;
+	l_genl_msg_new_sized;
+	l_genl_msg_ref;
+	l_genl_msg_unref;
+	l_genl_msg_get_command;
+	l_genl_msg_get_version;
+	l_genl_msg_get_error;
+	l_genl_msg_append_attr;
+	l_genl_msg_append_attrv;
+	l_genl_msg_enter_nested;
+	l_genl_msg_leave_nested;
+	l_genl_attr_init;
+	l_genl_attr_next;
+	l_genl_attr_recurse;
+	l_genl_family_new;
+	l_genl_family_ref;
+	l_genl_family_unref;
+	l_genl_family_set_watches;
+	l_genl_family_get_version;
+	l_genl_family_get_genl;
+	l_genl_family_can_send;
+	l_genl_family_can_dump;
+	l_genl_family_send;
+	l_genl_family_dump;
+	l_genl_family_cancel;
+	l_genl_family_has_group;
+	l_genl_family_register;
+	l_genl_family_unregister;
+	/* hwdb */
+	l_hwdb_new;
+	l_hwdb_new_default;
+	l_hwdb_ref;
+	l_hwdb_unref;
+	l_hwdb_lookup;
+	l_hwdb_lookup_valist;
+	l_hwdb_lookup_free;
+	l_hwdb_foreach;
+	/* idle */
+	l_idle_create;
+	l_idle_oneshot;
+	l_idle_remove;
+	/* io */
+	l_io_new;
+	l_io_destroy;
+	l_io_get_fd;
+	l_io_set_close_on_destroy;
+	l_io_set_read_handler;
+	l_io_set_write_handler;
+	l_io_set_disconnect_handler;
+	l_io_set_debug;
+	/* key */
+	l_key_new;
+	l_key_free;
+	l_key_free_norevoke;
+	l_key_update;
+	l_key_extract;
+	l_key_get_payload_size;
+	l_key_get_info;
+	l_key_compute_dh_public;
+	l_key_compute_dh_secret;
+	l_key_encrypt;
+	l_key_decrypt;
+	l_key_sign;
+	l_key_verify;
+	l_keyring_new;
+	l_keyring_restrict;
+	l_keyring_free;
+	l_keyring_free_norevoke;
+	l_keyring_link;
+	l_keyring_unlink;
+	l_key_is_supported;
+	/* log */
+	l_log_set_ident;
+	l_log_set_handler;
+	l_log_set_null;
+	l_log_set_stderr;
+	l_log_set_syslog;
+	l_log_set_journal;
+	l_log_with_location;
+	l_debug_add_section;
+	l_debug_enable_full;
+	l_debug_disable;
+	/* net */
+	l_net_get_mac_address;
+	l_net_get_name;
+	/* netlink */
+	l_netlink_new;
+	l_netlink_destroy;
+	l_netlink_send;
+	l_netlink_cancel;
+	l_netlink_register;
+	l_netlink_unregister;
+	l_netlink_set_debug;
+	/* pem */
+	l_pem_load_buffer;
+	l_pem_load_file;
+	l_pem_load_certificate;
+	l_pem_load_private_key;
+	/* pkcs5 */
+	l_pkcs5_pbkdf1;
+	l_pkcs5_pbkdf2;
+	/* plugin */
+	l_plugin_add;
+	l_plugin_load;
+	l_plugin_unload;
+	/* getrandom */
+	l_getrandom;
+	l_getrandom_is_supported;
+	/* ringbuf */
+	l_ringbuf_new;
+	l_ringbuf_free;
+	l_ringbuf_set_input_tracing;
+	l_ringbuf_capacity;
+	l_ringbuf_len;
+	l_ringbuf_drain;
+	l_ringbuf_peek;
+	l_ringbuf_write;
+	l_ringbuf_avail;
+	l_ringbuf_printf;
+	l_ringbuf_vprintf;
+	l_ringbuf_read;
+	/* settings */
+	l_settings_new;
+	l_settings_free;
+	l_settings_load_from_data;
+	l_settings_to_data;
+	l_settings_load_from_file;
+	l_settings_set_debug;
+	l_settings_get_groups;
+	l_settings_has_group;
+	l_settings_get_keys;
+	l_settings_has_key;
+	l_settings_get_value;
+	l_settings_set_value;
+	l_settings_get_bool;
+	l_settings_set_bool;
+	l_settings_get_int;
+	l_settings_set_int;
+	l_settings_get_uint;
+	l_settings_set_uint;
+	l_settings_get_int64;
+	l_settings_set_int64;
+	l_settings_get_uint64;
+	l_settings_set_uint64;
+	l_settings_get_string;
+	l_settings_set_string;
+	l_settings_get_string_list;
+	l_settings_set_string_list;
+	l_settings_get_double;
+	l_settings_set_double;
+	l_settings_get_float;
+	l_settings_set_float;
+	l_settings_remove_group;
+	l_settings_remove_key;
+	/* signal */
+	l_signal_create;
+	l_signal_remove;
+	/* timeout */
+	l_timeout_create;
+	l_timeout_create_ms;
+	l_timeout_modify;
+	l_timeout_modify_ms;
+	l_timeout_remove;
+	/* tls */
+	l_tls_handle_rx;
+	l_tls_prf_get_bytes;
+	l_tls_new;
+	l_tls_free;
+	l_tls_write;
+	l_tls_close;
+	l_tls_set_cacert;
+	l_tls_set_auth_data;
+	l_tls_alert_to_str;
+	/* uintset */
+	l_uintset_new_from_range;
+	l_uintset_new;
+	l_uintset_free;
+	l_uintset_take;
+	l_uintset_put;
+	l_uintset_contains;
+	l_uintset_get_min;
+	l_uintset_get_max;
+	l_uintset_find_unused_min;
+	l_uintset_find_max;
+	l_uintset_find_min;
+	/* uuid */
+	l_uuid_v3;
+	l_uuid_v5;
+	l_uuid_is_valid;
+	l_uuid_get_version;
+	l_uuid_to_string;
 local:
 	*;
 };
-- =

2.19.1


--===============1679088749255095862==--

