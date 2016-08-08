Content-Type: multipart/mixed; boundary="===============3637413217588227043=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 2/6] tls: Convert encrypt and verify to l_key crypto
Date: Mon, 08 Aug 2016 15:40:57 +0200
Message-ID: <CAOq732Lt9rgt5tX7=McnTpa8cqNoNCD0xZVk-cm3rM_3KKhD=w@mail.gmail.com>
In-Reply-To: <20160805205321.1427-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3637413217588227043==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

Just a minor comment,

On 5 August 2016 at 22:53, Mat Martineau
<mathew.j.martineau@linux.intel.com> wrote:
> diff --git a/ell/tls.c b/ell/tls.c
> index 18e5fae..627b57d 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -36,6 +36,7 @@
>  #include "pem.h"
>  #include "tls-private.h"
>  #include "cipher-private.h"
> +#include "key.h"
>
>  void tls10_prf(const uint8_t *secret, size_t secret_len,
>                 const char *label,
> @@ -142,6 +143,7 @@ static void tls_reset_handshake(struct l_tls *tls)
>
>         if (tls->peer_cert) {
>                 l_free(tls->peer_cert);
> +               l_key_free(tls->peer_pubkey);
>
>                 tls->peer_cert =3D NULL;
>                 tls->peer_pubkey =3D NULL;
> @@ -860,9 +862,9 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls=
 *tls)
>         uint8_t buf[1024 + 32];
>         uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
>         uint8_t pre_master_secret[48];
> -       struct l_asymmetric_cipher *rsa_server_pubkey;
> -       int key_size;
> +       size_t key_size;
>         ssize_t bytes_encrypted;
> +       bool is_public;
>
>         if (!tls->peer_pubkey) {
>                 tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
> @@ -874,37 +876,29 @@ static bool tls_send_rsa_client_key_xchg(struct l_t=
ls *tls)
>         pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
>         l_getrandom(pre_master_secret + 2, 46);
>
> -       /* Fill in the RSA Client Key Exchange body */
> -
> -       rsa_server_pubkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_=
V1_5,
> -                                                       tls->peer_pubkey,
> -                                                       tls->peer_pubkey_=
length,
> -                                                       true);
> -       if (!rsa_server_pubkey) {
> +       if (!l_key_get_info(tls->peer_pubkey, L_CIPHER_RSA_PKCS1_V1_5,
> +                                       L_CHECKSUM_NONE, &key_size,
> +                                       &is_public)) {
>                 tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>
>                 return false;
>         }
> -
> -       key_size =3D l_asymmetric_cipher_get_key_size(rsa_server_pubkey);
> +       key_size /=3D 8;
>
>         if (key_size + 32 > (int) sizeof(buf)) {
> -               l_asymmetric_cipher_free(rsa_server_pubkey);
> -
>                 tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>
>                 return false;
>         }
>
>         l_put_be16(key_size, ptr);
> -       bytes_encrypted =3D l_asymmetric_cipher_encrypt(rsa_server_pubkey,
> -                                                       pre_master_secret,
> -                                                       ptr + 2, 48, key_=
size);
> +       bytes_encrypted =3D l_key_encrypt(tls->peer_pubkey,
> +                                       L_CIPHER_RSA_PKCS1_V1_5,
> +                                       L_CHECKSUM_NONE, pre_master_secre=
t,
> +                                       ptr + 2, 48, key_size);
>         ptr +=3D key_size + 2;
>
> -       l_asymmetric_cipher_free(rsa_server_pubkey);
> -
> -       if (bytes_encrypted !=3D key_size) {
> +       if (bytes_encrypted !=3D (ssize_t) key_size) {
>                 tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>
>                 return false;
> @@ -1006,16 +1000,15 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, ui=
nt8_t *out, size_t len,
>  static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t =
len,
>                                 tls_get_hash_t get_hash)
>  {
> -       struct l_asymmetric_cipher *rsa_client_pubkey;
>         size_t key_size;
> -       ssize_t verify_bytes;
>         uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
>         size_t hash_len;
>         enum l_checksum_type hash_type;
>         uint8_t expected[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
>         size_t expected_len;
> -       uint8_t *digest_info;
>         unsigned int offset;
> +       bool is_public;
> +       bool success;
>
>         /* 2 bytes for SignatureAndHashAlgorithm if version >=3D 1.2 */
>         offset =3D 2;
> @@ -1029,23 +1022,18 @@ static bool tls_rsa_verify(struct l_tls *tls, con=
st uint8_t *in, size_t len,
>                 return false;
>         }
>
> -       rsa_client_pubkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_=
V1_5,
> -                                                       tls->peer_pubkey,
> -                                                       tls->peer_pubkey_=
length,
> -                                                       true);
> -       if (!rsa_client_pubkey) {
> +       if (!l_key_get_info(tls->peer_pubkey, L_CIPHER_RSA_PKCS1_V1_5,
> +                                       L_CHECKSUM_NONE, &key_size,
> +                                       &is_public)) {
>                 tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
> -
> -               return false;
>         }

It looks like this return should stay.

Best regards

--===============3637413217588227043==--

