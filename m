Content-Type: multipart/mixed; boundary="===============8899757264028945906=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH] cipher: add AES-CMAC hashing support
Date: Wed, 29 May 2019 12:52:34 +0200
Message-ID: <20190529105234.d5hn6i2gbx4boswj@scytale>
In-Reply-To: <1559100302.25030.14.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8899757264028945906==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 05/29, Gix, Brian wrote:
> > > > The algorythm is supported in the kernel, and it is used heavily by
> > > > Bluetooth Mesh, and is the one Mesh required algorythm missing from=
 ELL.

Is this about mesh_crypto_aes_ccm_encrypt and
mesh_crypto_aes_ccm_decrypt functions in mesh/crypto.c?

If so, they can be implemented with l_aead_cipher_* API, without any
changes to ELL, see below.

There is a slight problem, though - this works only on newer kernels
(IIRC, 4.9+), and some vendors (particularly Freescale i.MX6) do not
provide them :(

What's worse, my experiments show what the kernel does *not* report an
error while bind()ing the algo socket, but the results are wrong :(



bool mesh_crypto_aes_ccm_encrypt(const uint8_t nonce[NONCE_LEN],
		const uint8_t key[KEY_LEN],
		const uint8_t *aad, uint16_t aad_len,
		const uint8_t *msg, uint16_t msg_len,
		uint8_t *out_msg,
		void *out_mic, size_t mic_size)
{
	bool result;
	struct l_aead_cipher *cipher =3D l_aead_cipher_new(L_AEAD_CIPHER_AES_CCM,
			&key[0], KEY_LEN, mic_size);

	if (!cipher)
		return false;

	if (!out_msg)
		return false;

	result =3D l_aead_cipher_encrypt(cipher, (void *)msg, msg_len,
			aad, aad_len, &nonce[0], NONCE_LEN,
			(void *)out_msg, msg_len + mic_size);

	if (out_mic) {
		switch (mic_size) {
		case 4:
			*(uint32_t *)out_mic =3D l_get_be32(out_msg + msg_len);
			break;
		case 8:
			*(uint64_t *)out_mic =3D l_get_be64(out_msg + msg_len);
			break;
		default:
			/* Unsupported MIC size */
			return false;
		}
	}

	l_aead_cipher_free(cipher);
	return result;
}

bool mesh_crypto_aes_ccm_decrypt(const uint8_t nonce[13], const uint8_t key=
[16],
				const uint8_t *aad, uint16_t aad_len,
				const uint8_t *enc_msg, uint16_t enc_msg_len,
				uint8_t *out_msg,
				void *out_mic, size_t mic_size)
{
	bool result;
	struct l_aead_cipher *cipher =3D l_aead_cipher_new(L_AEAD_CIPHER_AES_CCM,
			&key[0], KEY_LEN, mic_size);

	if (!cipher)
		return false;

	result =3D l_aead_cipher_decrypt(cipher, (void *)enc_msg, enc_msg_len,
			aad, aad_len, &nonce[0], NONCE_LEN,
			(void *)out_msg, enc_msg_len - mic_size);

	if (out_mic) {
		switch (mic_size) {
		case 4:
			*(uint32_t *)out_mic =3D l_get_be32(out_msg +
					enc_msg_len - mic_size);
			break;
		case 8:
			*(uint64_t *)out_mic =3D l_get_be64(out_msg +
					enc_msg_len - mic_size);
			break;
		default:
			/* Unsupported MIC size */
			return false;
		}
	}

	l_aead_cipher_free(cipher);
	return result;
}

-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND

--===============8899757264028945906==--

