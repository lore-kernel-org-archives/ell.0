Content-Type: multipart/mixed; boundary="===============8280587831114874623=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: [PATCH] cipher: add AES-CMAC hashing support
Date: Wed, 29 May 2019 15:29:42 +0000
Message-ID: <1559143780.3694.10.camel@intel.com>
In-Reply-To: <20190529105234.d5hn6i2gbx4boswj@scytale>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8280587831114874623==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

On Wed, 2019-05-29 at 12:52 +0200, Micha=C5=82 Lowas-Rzechonek wrote:
> Hi Brian,
> =

> On 05/29, Gix, Brian wrote:
> > > > > The algorythm is supported in the kernel, and it is used heavily =
by
> > > > > Bluetooth Mesh, and is the one Mesh required algorythm missing fr=
om ELL.
> =

> Is this about mesh_crypto_aes_ccm_encrypt and
> mesh_crypto_aes_ccm_decrypt functions in mesh/crypto.c?

The code you copy pasted below *is* the usage of AES_CCM that we use in mes=
h, but it is *not* the topic of the
patch I posted here to ELL yesterday. AES-CMAC is the algorythm we use in M=
esh to generate all of the various
Keys and IDs from master Net and App keys....  It is a simple one-direction=
al hashing function, and as I also
learned yesterday, is already supported in ELLs checksum.c code.


> =

> If so, they can be implemented with l_aead_cipher_* API, without any
> changes to ELL, see below.
> =

> There is a slight problem, though - this works only on newer kernels
> (IIRC, 4.9+), and some vendors (particularly Freescale i.MX6) do not
> provide them :(


This is definitely a question worth answering. We are aware that pre-4.9 ke=
rnels did not correctly support
AES_CCM, so switching the mesh daemon's crypto to pure ELL supported kernel=
 based encryption and decryption
will mean that the daemon is not supported on very old kernels.


As far as Freescale platforms go, I do not know how to answer that question=
.  At some point we do need to move
on from older platforms so that the rest are not "held back". But I do not =
know if that time is yet now.

I would really like to get Marcel's opinion on this.


> =

> What's worse, my experiments show what the kernel does *not* report an
> error while bind()ing the algo socket, but the results are wrong :(
> =

> =

> =

> bool mesh_crypto_aes_ccm_encrypt(const uint8_t nonce[NONCE_LEN],
> 		const uint8_t key[KEY_LEN],
> 		const uint8_t *aad, uint16_t aad_len,
> 		const uint8_t *msg, uint16_t msg_len,
> 		uint8_t *out_msg,
> 		void *out_mic, size_t mic_size)
> {
> 	bool result;
> 	struct l_aead_cipher *cipher =3D l_aead_cipher_new(L_AEAD_CIPHER_AES_CCM,
> 			&key[0], KEY_LEN, mic_size);
> =

> 	if (!cipher)
> 		return false;
> =

> 	if (!out_msg)
> 		return false;
> =

> 	result =3D l_aead_cipher_encrypt(cipher, (void *)msg, msg_len,
> 			aad, aad_len, &nonce[0], NONCE_LEN,
> 			(void *)out_msg, msg_len + mic_size);
> =

> 	if (out_mic) {
> 		switch (mic_size) {
> 		case 4:
> 			*(uint32_t *)out_mic =3D l_get_be32(out_msg + msg_len);
> 			break;
> 		case 8:
> 			*(uint64_t *)out_mic =3D l_get_be64(out_msg + msg_len);
> 			break;
> 		default:
> 			/* Unsupported MIC size */
> 			return false;
> 		}
> 	}
> =

> 	l_aead_cipher_free(cipher);
> 	return result;
> }
> =

> bool mesh_crypto_aes_ccm_decrypt(const uint8_t nonce[13], const uint8_t k=
ey[16],
> 				const uint8_t *aad, uint16_t aad_len,
> 				const uint8_t *enc_msg, uint16_t enc_msg_len,
> 				uint8_t *out_msg,
> 				void *out_mic, size_t mic_size)
> {
> 	bool result;
> 	struct l_aead_cipher *cipher =3D l_aead_cipher_new(L_AEAD_CIPHER_AES_CCM,
> 			&key[0], KEY_LEN, mic_size);
> =

> 	if (!cipher)
> 		return false;
> =

> 	result =3D l_aead_cipher_decrypt(cipher, (void *)enc_msg, enc_msg_len,
> 			aad, aad_len, &nonce[0], NONCE_LEN,
> 			(void *)out_msg, enc_msg_len - mic_size);
> =

> 	if (out_mic) {
> 		switch (mic_size) {
> 		case 4:
> 			*(uint32_t *)out_mic =3D l_get_be32(out_msg +
> 					enc_msg_len - mic_size);
> 			break;
> 		case 8:
> 			*(uint64_t *)out_mic =3D l_get_be64(out_msg +
> 					enc_msg_len - mic_size);
> 			break;
> 		default:
> 			/* Unsupported MIC size */
> 			return false;
> 		}
> 	}
> =

> 	l_aead_cipher_free(cipher);
> 	return result;
> }
>=20
--===============8280587831114874623==--

